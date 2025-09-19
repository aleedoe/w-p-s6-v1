from flask import request, jsonify
from flask_jwt_extended import create_access_token, get_jwt_identity
from ..models import Admin, db, Product, Category, Image

def admin_login():
    data = request.get_json()
    print(data)
    admin = Admin.query.filter_by(email=data.get('email')).first()
    
    if admin and admin.check_password(data.get('password')):
        access_token = admin.generate_auth_token()
        return jsonify(access_token=access_token), 200
    
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
    data = request.get_json()

    # Validasi input sederhana
    required_fields = ["name", "price", "id_category"]
    for field in required_fields:
        if field not in data:
            return jsonify({"msg": f"{field} is required"}), 400

    # Cek apakah kategori ada
    category = Category.query.filter_by(id=data["id_category"]).first()
    if not category:
        return jsonify({"msg": "Category not found"}), 404

    new_product = Product(
        name=data["name"],
        quantity=data.get("quantity", 0),
        price=data["price"],
        description=data.get("description", ""),
        id_category=data["id_category"]
    )

    db.session.add(new_product)
    db.session.commit()

    return jsonify({
        "msg": "Product created successfully",
        "product": {
            "id": new_product.id,
            "name": new_product.name,
            "quantity": new_product.quantity,
            "price": new_product.price,
            "description": new_product.description,
            "id_category": new_product.id_category
        }
    }), 201


def update_product(product_id):
    product = Product.query.filter_by(id=product_id).first()
    
    if not product:
        return jsonify({"msg": "Product not found"}), 404

    data = request.get_json()

    # Update field jika ada di request
    product.name = data.get("name", product.name)
    product.quantity = data.get("quantity", product.quantity)
    product.price = data.get("price", product.price)
    product.description = data.get("description", product.description)
    product.id_category = data.get("id_category", product.id_category)

    db.session.commit()

    return jsonify({
        "msg": "Product updated successfully",
        "product": {
            "id": product.id,
            "name": product.name,
            "quantity": product.quantity,
            "price": product.price,
            "description": product.description,
            "id_category": product.id_category
        }
    }), 200


def delete_product(product_id):
    product = Product.query.filter_by(id=product_id).first()
    
    if not product:
        return jsonify({"msg": "Product not found"}), 404

    db.session.delete(product)
    db.session.commit()

    return jsonify({"msg": "Product deleted successfully"}), 200