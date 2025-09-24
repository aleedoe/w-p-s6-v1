from flask import request, jsonify, current_app
from flask_jwt_extended import create_access_token, get_jwt_identity
from ..models import Admin, db, Product, Category, Image, Transaction, Reseller, DetailTransaction, ReturnTransaction, ReturnDetailTransaction
from sqlalchemy import func
from werkzeug.utils import secure_filename
import os
import uuid


def admin_login():
    data = request.get_json()
    print(data)
    
    # Mencari admin berdasarkan email
    admin = Admin.query.filter_by(email=data.get('email')).first()
    
    # Cek apakah admin ditemukan dan password valid
    if admin and admin.check_password(data.get('password')):
        # Membuat token akses
        access_token = admin.generate_auth_token()
        
        # Menyusun response dengan data yang diinginkan (name, email, access_token)
        return jsonify({
            "id": admin.id,
            "name": admin.name,
            "email": admin.email,
            "access_token": access_token
        }), 200
    
    return jsonify({"msg": "Bad email or password"}), 401


def get_all_products():
    products = Product.query.join(Category).all()
    
    result = []
    for product in products:
        result.append({
            "id": product.id,
            "name": product.name,
            "category": product.category.name if product.category else None,
            "quantity": product.quantity,
            "price": product.price
        })
    
    return jsonify(result), 200


def get_product_detail(product_id):
    product = Product.query.filter_by(id=product_id).first()
    
    if not product:
        return jsonify({"msg": "Product not found"}), 404
    
    # Ambil semua gambar terkait produk
    images = [img.name for img in product.images]
    
    result = {
        "id": product.id,
        "name": product.name,
        "images": images,
        "price": product.price,
        "quantity": product.quantity,
        "description": product.description,
        "id_category": product.id_category
    }
    
    return jsonify(result), 200


def create_product():
    name = request.form.get("name")
    price = request.form.get("price")
    id_category = request.form.get("id_category")
    quantity = request.form.get("quantity", 0)
    description = request.form.get("description", "")

    # Validasi sederhana
    if not name or not price or not id_category:
        return jsonify({"msg": "Missing required fields"}), 400

    category = Category.query.filter_by(id=id_category).first()
    if not category:
        return jsonify({"msg": "Category not found"}), 404

    new_product = Product(
        name=name,
        quantity=quantity,
        price=price,
        description=description,
        id_category=id_category
    )

    db.session.add(new_product)
    db.session.flush()  # supaya id_product langsung tersedia

    # Upload multiple images
    files = request.files.getlist("images")
    for file in files:
        if file:
            # Ambil ekstensi asli
            ext = os.path.splitext(file.filename)[1]
            # Generate nama random
            filename = f"{uuid.uuid4().hex}{ext}"
            filename = secure_filename(filename)

            save_path = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
            file.save(save_path)

            new_image = Image(
                id_product=new_product.id,
                name=filename
            )
            db.session.add(new_image)

    db.session.commit()

    return jsonify({
        "msg": "Product created successfully",
        "product": {
            "id": new_product.id,
            "name": new_product.name,
            "quantity": new_product.quantity,
            "price": new_product.price,
            "description": new_product.description,
            "id_category": new_product.id_category,
            "images": [img.name for img in new_product.images]  # daftar path gambar
        }
    }), 201


def update_product(product_id):
    product = Product.query.filter_by(id=product_id).first()
    if not product:
        return jsonify({"msg": "Product not found"}), 404

    # Ambil data dari form-data
    name = request.form.get("name")
    price = request.form.get("price")
    quantity = request.form.get("quantity")
    description = request.form.get("description")
    id_category = request.form.get("id_category")

    if name:
        product.name = name
    if price:
        product.price = price
    if quantity:
        product.quantity = quantity
    if description is not None:
        product.description = description
    if id_category:
        product.id_category = id_category

    # ===== Hapus gambar lama =====
    removed_images = request.form.getlist("removedImages[]")  # frontend kirim array
    for filename in removed_images:
        img = Image.query.filter_by(id_product=product.id, name=filename).first()
        if img:
            # hapus record di DB
            db.session.delete(img)

            # hapus file fisik
            file_path = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
            if os.path.exists(file_path):
                os.remove(file_path)

    # ===== Tambahkan gambar baru =====
    files = request.files.getlist("images")
    for file in files:
        if file:
            ext = os.path.splitext(file.filename)[1]
            filename = f"{uuid.uuid4().hex}{ext}"
            filename = secure_filename(filename)

            save_path = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
            file.save(save_path)

            relative_path = f"{filename}"
            new_image = Image(id_product=product.id, name=relative_path)
            db.session.add(new_image)

    db.session.commit()

    return jsonify({
        "msg": "Product updated successfully",
        "product": {
            "id": product.id,
            "name": product.name,
            "quantity": product.quantity,
            "price": product.price,
            "description": product.description,
            "id_category": product.id_category,
            "images": [img.name for img in product.images]
        }
    }), 200


def delete_product(product_id):
    product = Product.query.filter_by(id=product_id).first()
    if not product:
        return jsonify({"msg": "Product not found"}), 404

    # Hapus gambar dari DB & storage
    for img in product.images:  # relasi ke tabel Image
        file_path = os.path.join(current_app.config["UPLOAD_FOLDER"], img.name)
        if os.path.exists(file_path):
            os.remove(file_path)
        db.session.delete(img)

    # Hapus produk
    db.session.delete(product)
    db.session.commit()

    return jsonify({"msg": "Product deleted successfully"}), 200


def get_all_transactions():
    # Query dengan join
    transactions = (
        db.session.query(
            Transaction.id.label("id_transaction"),
            Transaction.status.label("status"),  # TAMBAHKAN INI - field status dari Transaction
            Reseller.id.label("reseller_id"),
            Reseller.name.label("reseller_name"),
            Transaction.created_at.label("transaction_date"),
            func.sum(DetailTransaction.quantity).label("total_items"),
            func.sum(DetailTransaction.quantity * Product.price).label("total_price")
        )
        .join(Reseller, Transaction.id_reseller == Reseller.id)
        .join(DetailTransaction, Transaction.id == DetailTransaction.id_transaction)
        .join(Product, DetailTransaction.id_product == Product.id)
        .group_by(Transaction.id, Transaction.status, Reseller.name, Transaction.created_at)  # TAMBAHKAN Transaction.status
        .all()
    )

    # Format hasil ke JSON
    result = []
    for t in transactions:
        result.append({
            "id_transaction": t.id_transaction,
            "status": t.status,  # TAMBAHKAN INI - field status dalam response
            "id_reseller": t.reseller_id,
            "reseller_name": t.reseller_name,
            "transaction_date": t.transaction_date.strftime("%Y-%m-%d %H:%M:%S"),
            "total_items": int(t.total_items) if t.total_items else 0,
            "total_price": float(t.total_price) if t.total_price else 0
        })

    return jsonify(result)


def get_transaction_detail(transaction_id):
    # Ambil transaksi utama
    transaction = (
        db.session.query(Transaction)
        .join(Reseller, Transaction.id_reseller == Reseller.id)
        .filter(Transaction.id == transaction_id)
        .first()
    )

    if not transaction:
        return jsonify({"error": "Transaction not found"}), 404

    # Ambil detail per produk
    details = (
        db.session.query(
            Product.id.label("id_product"),
            Product.name.label("product_name"),
            Product.price.label("product_price"),
            DetailTransaction.quantity.label("quantity")
        )
        .join(Product, DetailTransaction.id_product == Product.id)
        .filter(DetailTransaction.id_transaction == transaction_id)
        .all()
    )

    # Hitung total item & total harga
    total_items = sum(d.quantity for d in details)
    total_price = sum(d.quantity * d.product_price for d in details)

    # Format hasil ke JSON
    result = {
        "id_transaction": transaction.id,
        "status": transaction.status,  # TAMBAHKAN INI - field status dalam response detail
        "id_reseller": transaction.id_reseller,
        "reseller_name": transaction.reseller.name,
        "transaction_date": transaction.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        "products": [
            {
                "id_product": d.id_product,
                "product_name": d.product_name,
                "quantity": d.quantity,
                "price": float(d.product_price),
                "subtotal": float(d.quantity * d.product_price)
            }
            for d in details
        ],
        "total_items": total_items,
        "total_price": float(total_price)
    }

    return jsonify(result)


def accept_transaction(transaction_id):
    # Cari transaksi berdasarkan ID
    transaction = db.session.query(Transaction).filter(Transaction.id == transaction_id).first()

    if not transaction:
        return jsonify({"error": "Transaction not found"}), 404

    # Update status transaksi menjadi 'accepted'
    transaction.status = 'accepted'
    db.session.commit()

    return jsonify({"message": f"Transaction {transaction_id} has been accepted."}), 200


def reject_transaction(transaction_id):
    # Cari transaksi berdasarkan ID
    transaction = db.session.query(Transaction).filter(Transaction.id == transaction_id).first()

    if not transaction:
        return jsonify({"error": "Transaction not found"}), 404

    # Update status transaksi menjadi 'rejected'
    transaction.status = 'rejected'
    db.session.commit()

    return jsonify({"message": f"Transaction {transaction_id} has been rejected."}), 200


def get_all_return_transactions():
    # Query dengan join
    return_transactions = (
        db.session.query(
            ReturnTransaction.id.label("id_return_transaction"),
            ReturnTransaction.status.label("status"),
            Reseller.id.label("reseller_id"),
            Reseller.name.label("reseller_name"),
            ReturnTransaction.created_at.label("return_date"),
            func.sum(ReturnDetailTransaction.quantity).label("total_items"),
            func.sum(ReturnDetailTransaction.quantity * Product.price).label("total_price")
        )
        .join(Reseller, ReturnTransaction.id_reseller == Reseller.id)
        .join(ReturnDetailTransaction, ReturnTransaction.id == ReturnDetailTransaction.id_return_transaction)
        .join(Product, ReturnDetailTransaction.id_product == Product.id)
        .group_by(ReturnTransaction.id, Reseller.id, Reseller.name, ReturnTransaction.created_at, ReturnTransaction.status)
        .all()
    )

    # Format hasil ke JSON
    result = []
    for rt in return_transactions:
        result.append({
            "id_return_transaction": rt.id_return_transaction,
            "status": rt.status,
            "id_reseller": rt.reseller_id,
            "reseller_name": rt.reseller_name,
            "return_date": rt.return_date.strftime("%Y-%m-%d %H:%M:%S"),
            "total_items": int(rt.total_items) if rt.total_items else 0,
            "total_price": float(rt.total_price) if rt.total_price else 0
        })

    return jsonify(result)


def get_return_transaction_detail(return_transaction_id):
    # Ambil return transaksi utama
    return_transaction = (
        db.session.query(ReturnTransaction)
        .join(Reseller, ReturnTransaction.id_reseller == Reseller.id)
        .filter(ReturnTransaction.id == return_transaction_id)
        .first()
    )

    if not return_transaction:
        return jsonify({"error": "Return Transaction not found"}), 404

    # Ambil detail produk yang direturn
    details = (
        db.session.query(
            Product.id.label("id_product"),
            Product.name.label("product_name"),
            Product.price.label("product_price"),
            ReturnDetailTransaction.quantity.label("quantity"),
            ReturnDetailTransaction.reason.label("reason")
        )
        .join(Product, ReturnDetailTransaction.id_product == Product.id)
        .filter(ReturnDetailTransaction.id_return_transaction == return_transaction_id)
        .all()
    )

    # Hitung total item & total harga
    total_items = sum(d.quantity for d in details)
    total_price = sum(d.quantity * d.product_price for d in details)

    # Format hasil ke JSON
    result = {
        "id_return_transaction": return_transaction.id,
        "id_transaction": return_transaction.id_transaction,
        "id_reseller": return_transaction.id_reseller,
        "reseller_name": return_transaction.reseller.name,
        "status": return_transaction.status,
        "return_date": return_transaction.created_at.strftime("%Y-%m-%d %H:%M:%S"),
        "products": [
            {
                "id_product": d.id_product,
                "product_name": d.product_name,
                "quantity": d.quantity,
                "price": float(d.product_price),
                "subtotal": float(d.quantity * d.product_price),
                "reason": d.reason
            }
            for d in details
        ],
        "total_items": total_items,
        "total_price": float(total_price)
    }

    return jsonify(result)


def accept_return_transaction(return_transaction_id):
    # Cari return transaction berdasarkan ID
    return_transaction = (
        db.session.query(ReturnTransaction)
        .filter(ReturnTransaction.id == return_transaction_id)
        .first()
    )

    if not return_transaction:
        return jsonify({"error": "Return Transaction not found"}), 404

    # Update status return menjadi 'accepted'
    return_transaction.status = 'accepted'
    db.session.commit()

    return jsonify({"message": f"Return Transaction {return_transaction_id} has been accepted."}), 200


def reject_return_transaction(return_transaction_id):
    # Cari return transaction berdasarkan ID
    return_transaction = (
        db.session.query(ReturnTransaction)
        .filter(ReturnTransaction.id == return_transaction_id)
        .first()
    )

    if not return_transaction:
        return jsonify({"error": "Return Transaction not found"}), 404

    # Update status return menjadi 'rejected'
    return_transaction.status = 'rejected'
    db.session.commit()

    return jsonify({"message": f"Return Transaction {return_transaction_id} has been rejected."}), 200