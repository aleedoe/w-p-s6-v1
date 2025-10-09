from flask import request, jsonify
from flask_jwt_extended import create_access_token
from sqlalchemy import func
from ..models import Reseller, db, Product, Category, DetailTransaction, Image, Transaction, ReturnTransaction, ReturnDetailTransaction
from sqlalchemy.exc import SQLAlchemyError

def reseller_login():
    data = request.get_json()

    # Mencari reseller berdasarkan email
    reseller = Reseller.query.filter_by(email=data.get('email')).first()

    # Cek apakah reseller ditemukan dan password valid
    if reseller and reseller.check_password(data.get('password')):
        # Membuat token akses
        access_token = reseller.generate_auth_token()
        
        # Menyusun response dengan data yang diinginkan
        return jsonify({
            "id": reseller.id,
            "name": reseller.name,
            "email": reseller.email,
            "phone": reseller.phone,
            "address": reseller.address,
            "access_token": access_token
        }), 200

    return jsonify({"msg": "Bad email or password"}), 401


def res_get_all_products():
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


def res_get_product_detail(product_id):
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


def res_get_stocks(id_reseller: int):
    # Query dengan join
    detail_transactions = (
        db.session.query(
            DetailTransaction.id.label("id_detail_transaction"),
            Transaction.id_reseller.label("id_reseller"),
            Product.id.label("id_product"),
            DetailTransaction.quantity.label("quantity"),
            Product.name.label("product_name"),
            Product.price.label("price"),
            Product.description.label("description"),
            Category.name.label("category_name")
        )
        .join(Transaction, DetailTransaction.id_transaction == Transaction.id)
        .join(Product, DetailTransaction.id_product == Product.id)
        .join(Category, Product.id_category == Category.id)
        .filter(Transaction.id_reseller == id_reseller)
        .all()
    )

    result = []
    total_products = 0
    total_quantity = 0

    for dt in detail_transactions:
        # Ambil semua gambar produk
        images = (
            db.session.query(Image.name)
            .filter(Image.id_product == dt.id_product)
            .all()
        )
        image_list = [img.name for img in images]

        total_products += 1
        total_quantity += dt.quantity

        result.append({
            "id_detail_transaction": dt.id_detail_transaction,
            "id_reseller": dt.id_reseller,
            "id_product": dt.id_product,
            "quantity": dt.quantity,
            "product_name": dt.product_name,
            "price": float(dt.price),
            "description": dt.description,
            "category_name": dt.category_name,
            "images": image_list
        })

    return jsonify({
        "id_reseller": id_reseller,
        "total_products": total_products,   # jumlah produk unik di detail transaksi
        "total_quantity": total_quantity,   # total kuantitas semua produk di detail transaksi
        "details": result
    })


def res_get_transactions(id_reseller: int):
    transactions = (
        db.session.query(
            Transaction.id.label("id_transaction"),
            Transaction.status.label("status"),
            Transaction.created_at.label("created_at"),
            # jumlah produk unik berdasarkan id_product
            func.count(func.distinct(DetailTransaction.id_product)).label("total_products"),
            # total harga = sum(quantity * price)
            func.sum(DetailTransaction.quantity * Product.price).label("total_price")
        )
        .join(DetailTransaction, DetailTransaction.id_transaction == Transaction.id)
        .join(Product, DetailTransaction.id_product == Product.id)
        .filter(Transaction.id_reseller == id_reseller)
        .group_by(Transaction.id, Transaction.status, Transaction.created_at)
        .order_by(Transaction.created_at.desc())
        .all()
    )

    result = []
    for t in transactions:
        result.append({
            "id_transaction": t.id_transaction,
            "status": t.status,
            "created_at": t.created_at.strftime("%Y-%m-%d %H:%M:%S"),
            "total_products": int(t.total_products),  # jumlah produk unik
            "total_price": float(t.total_price) if t.total_price else 0.0
        })

    return jsonify({
        "id_reseller": id_reseller,
        "transactions": result
    })


def res_get_transaction_detail(id_reseller: int, id_transaction: int):
    details = (
        db.session.query(
            DetailTransaction.id.label("id_detail_transaction"),
            Product.id.label("id_product"),
            Product.name.label("product_name"),
            Product.price.label("price"),
            DetailTransaction.quantity.label("quantity"),
            (DetailTransaction.quantity * Product.price).label("total_price")
        )
        .join(Transaction, DetailTransaction.id_transaction == Transaction.id)
        .join(Product, DetailTransaction.id_product == Product.id)
        .filter(Transaction.id_reseller == id_reseller)
        .filter(Transaction.id == id_transaction)
        .all()
    )

    result = []
    total_products = 0
    total_quantity = 0
    total_price = 0

    for d in details:
        result.append({
            "id_detail_transaction": d.id_detail_transaction,
            "id_product": d.id_product,
            "product_name": d.product_name,
            "price": float(d.price),
            "quantity": d.quantity,
            "total_price": float(d.total_price)
        })

        total_products += 1
        total_quantity += d.quantity
        total_price += d.total_price

    return jsonify({
        "id_reseller": id_reseller,
        "id_transaction": id_transaction,
        "total_products": total_products,   # jumlah produk unik dalam transaksi ini
        "total_quantity": total_quantity,   # total kuantitas semua produk
        "total_price": float(total_price),  # total harga semua produk
        "details": result
    })


def res_create_transaction(id_reseller: int):

    data = request.get_json()

    # Validasi input
    if not data or "details" not in data or not isinstance(data["details"], list):
        return jsonify({"message": "Invalid request body"}), 400

    details_data = data["details"]

    if len(details_data) == 0:
        return jsonify({"message": "Detail transaksi tidak boleh kosong"}), 400

    try:
        # 1️⃣ Buat transaksi utama
        transaction = Transaction(
            id_reseller=id_reseller,
            status="pending"
        )
        db.session.add(transaction)
        db.session.flush()  # supaya ID transaksi langsung tersedia

        total_price = 0
        detail_records = []

        # 2️⃣ Proses setiap produk dalam detail transaksi
        for item in details_data:
            id_product = item.get("id_product")
            quantity = item.get("quantity")

            if not id_product or not quantity or quantity <= 0:
                db.session.rollback()
                return jsonify({"message": "id_product dan quantity wajib diisi dengan benar"}), 400

            # Ambil data produk
            product = Product.query.get(id_product)
            if not product:
                db.session.rollback()
                return jsonify({"message": f"Produk dengan ID {id_product} tidak ditemukan"}), 404

            # Cek stok
            if product.quantity < quantity:
                db.session.rollback()
                return jsonify({"message": f"Stok produk '{product.name}' tidak mencukupi"}), 400

            # Kurangi stok produk
            product.quantity -= quantity

            # Hitung total harga per produk
            total_price_item = product.price * quantity
            total_price += total_price_item

            # Buat detail transaksi
            detail = DetailTransaction(
                id_transaction=transaction.id,
                id_product=id_product,
                quantity=quantity
            )
            detail_records.append({
                "id_product": id_product,
                "product_name": product.name,
                "price": float(product.price),
                "quantity": quantity,
                "total_price": float(total_price_item)
            })
            db.session.add(detail)

        # 3️⃣ Commit semua perubahan
        db.session.commit()

        # 4️⃣ Kembalikan hasil
        return jsonify({
            "message": "Transaksi berhasil dibuat",
            "transaction": {
                "id_transaction": transaction.id,
                "id_reseller": id_reseller,
                "status": transaction.status,
                "total_price": float(total_price),
                "total_products": len(detail_records),
                "details": detail_records
            }
        }), 201

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"message": "Gagal membuat transaksi", "error": str(e)}), 500


def res_get_return_transactions(id_reseller: int):
    # Query untuk mendapatkan data return transaction
    returns = (
        db.session.query(
            ReturnTransaction.id.label("id_return_transaction"),
            ReturnTransaction.id_transaction.label("id_transaction"),
            ReturnTransaction.status.label("status"),
            ReturnTransaction.created_at.label("return_date"),
            Transaction.created_at.label("transaction_date"),
            func.sum(ReturnDetailTransaction.quantity).label("total_quantity")
        )
        .join(Transaction, ReturnTransaction.id_transaction == Transaction.id)
        .join(ReturnDetailTransaction, ReturnDetailTransaction.id_return_transaction == ReturnTransaction.id)
        .filter(ReturnTransaction.id_reseller == id_reseller)
        .group_by(
            ReturnTransaction.id,
            ReturnTransaction.id_transaction,
            ReturnTransaction.status,
            ReturnTransaction.created_at,
            Transaction.created_at
        )
        .order_by(ReturnTransaction.created_at.desc())
        .all()
    )

    result = []
    for r in returns:
        result.append({
            "id_return_transaction": r.id_return_transaction,
            "id_transaction": r.id_transaction,
            "return_date": r.return_date.strftime("%Y-%m-%d %H:%M:%S") if r.return_date else None,
            "transaction_date": r.transaction_date.strftime("%Y-%m-%d %H:%M:%S") if r.transaction_date else None,
            "total_quantity": int(r.total_quantity) if r.total_quantity else 0,
            "status": r.status
        })

    return jsonify({
        "id_reseller": id_reseller,
        "return_transaction": result
    })



def res_get_return_transaction_detail(id_reseller: int, id_return_transaction: int):
    # Ambil semua detail produk yang diretur untuk reseller dan transaksi retur tertentu
    details = (
        db.session.query(
            ReturnDetailTransaction.id.label("id_return_detail_transaction"),
            Product.id.label("id_product"),
            Product.name.label("product_name"),
            Product.price.label("price"),
            ReturnDetailTransaction.quantity.label("quantity"),
            ReturnDetailTransaction.reason.label("reason"),
            (ReturnDetailTransaction.quantity * Product.price).label("total_price")
        )
        .join(ReturnTransaction, ReturnDetailTransaction.id_return_transaction == ReturnTransaction.id)
        .join(Product, ReturnDetailTransaction.id_product == Product.id)
        .filter(ReturnTransaction.id_reseller == id_reseller)
        .filter(ReturnTransaction.id == id_return_transaction)
        .all()
    )

    result = []
    total_products = 0
    total_quantity = 0
    total_price = 0

    for d in details:
        result.append({
            "id_return_detail_transaction": d.id_return_detail_transaction,
            "id_product": d.id_product,
            "product_name": d.product_name,
            "price": float(d.price),
            "quantity": d.quantity,
            "reason": d.reason,
            "total_price": float(d.total_price)
        })
        total_products += 1
        total_quantity += d.quantity
        total_price += d.total_price

    return jsonify({
        "id_reseller": id_reseller,
        "id_return_transaction": id_return_transaction,
        "total_products": total_products,   # jumlah produk unik yang diretur
        "total_quantity": total_quantity,   # total seluruh jumlah barang retur
        "total_price": float(total_price),  # total nilai barang retur
        "details": result
    })


def res_create_return_transaction(id_reseller: int, id_transaction: int):
    data = request.get_json()

    # Validasi input body
    if not data or "details" not in data or not isinstance(data["details"], list):
        return jsonify({"message": "Invalid request body"}), 400

    details_data = data["details"]

    if len(details_data) == 0:
        return jsonify({"message": "Detail return tidak boleh kosong"}), 400

    try:
        # 1️⃣ Pastikan transaksi asli ada dan milik reseller ini
        transaction = Transaction.query.filter_by(
            id=id_transaction, id_reseller=id_reseller
        ).first()
        if not transaction:
            return jsonify({"message": "Transaksi tidak ditemukan untuk reseller ini"}), 404

        # 2️⃣ Buat transaksi return utama
        return_transaction = ReturnTransaction(
            id_transaction=id_transaction,
            id_reseller=id_reseller,
            status="pending"
        )
        db.session.add(return_transaction)
        db.session.flush()  # supaya id_return_transaction langsung tersedia

        return_details = []

        # 3️⃣ Proses setiap produk yang di-return
        for item in details_data:
            id_product = item.get("id_product")
            quantity = item.get("quantity")
            reason = item.get("reason", "")

            if not id_product or not quantity or quantity <= 0:
                db.session.rollback()
                return jsonify({"message": "id_product dan quantity wajib diisi dengan benar"}), 400

            # Cek apakah produk ada di transaksi asli
            detail_transaction = DetailTransaction.query.filter_by(
                id_transaction=id_transaction,
                id_product=id_product
            ).first()

            if not detail_transaction:
                db.session.rollback()
                return jsonify({"message": f"Produk dengan ID {id_product} tidak ditemukan pada transaksi ini"}), 404

            # Cek apakah jumlah return tidak melebihi jumlah pembelian
            if quantity > detail_transaction.quantity:
                db.session.rollback()
                return jsonify({"message": f"Jumlah return untuk produk ID {id_product} melebihi jumlah transaksi"}), 400

            # Ambil data produk
            product = Product.query.get(id_product)
            if not product:
                db.session.rollback()
                return jsonify({"message": f"Produk dengan ID {id_product} tidak ditemukan"}), 404

            # Tambahkan kembali stok produk
            product.quantity += quantity

            # Buat detail return
            return_detail = ReturnDetailTransaction(
                id_return_transaction=return_transaction.id,
                id_product=id_product,
                quantity=quantity,
                reason=reason
            )
            db.session.add(return_detail)

            return_details.append({
                "id_product": id_product,
                "product_name": product.name,
                "quantity_returned": quantity,
                "reason": reason
            })

        # 4️⃣ Commit semua perubahan
        db.session.commit()

        # 5️⃣ Kembalikan hasil
        return jsonify({
            "message": "Return transaction berhasil dibuat",
            "return_transaction": {
                "id_return_transaction": return_transaction.id,
                "id_transaction": id_transaction,
                "id_reseller": id_reseller,
                "status": return_transaction.status,
                "total_products_returned": len(return_details),
                "details": return_details
            }
        }), 201

    except SQLAlchemyError as e:
        db.session.rollback()
        return jsonify({"message": "Gagal membuat return transaction", "error": str(e)}), 500