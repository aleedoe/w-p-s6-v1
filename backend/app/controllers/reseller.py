from flask import request, jsonify
from flask_jwt_extended import create_access_token
from ..models import Reseller, db, Product, Category


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