from flask import request, jsonify
from flask_jwt_extended import create_access_token
from sqlalchemy import func
from ..models import Reseller, db, Product, Category, DetailTransaction, Image, Transaction


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
