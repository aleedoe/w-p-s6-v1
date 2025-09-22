from flask import request, jsonify, current_app
from flask_jwt_extended import create_access_token, get_jwt_identity
from ..models import Admin, db, Product, Category, Image
from werkzeug.utils import secure_filename
import os
import uuid


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

    # Ambil data form (bukan JSON lagi, karena ada file upload)
    name = request.form.get("name", product.name)
    price = request.form.get("price", product.price)
    quantity = request.form.get("quantity", product.quantity)
    description = request.form.get("description", product.description)
    id_category = request.form.get("id_category", product.id_category)

    product.name = name
    product.price = price
    product.quantity = quantity
    product.description = description
    product.id_category = id_category

    # Tambah gambar baru (jika ada)
    files = request.files.getlist("images")
    for file in files:
        if file:
            ext = os.path.splitext(file.filename)[1]
            filename = f"{uuid.uuid4().hex}{ext}"
            filename = secure_filename(filename)

            save_path = os.path.join(current_app.config["UPLOAD_FOLDER"], filename)
            file.save(save_path)

            relative_path = f"{filename}"

            new_image = Image(
                id_product=product.id,
                name=relative_path
            )
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

    db.session.delete(product)
    db.session.commit()

    return jsonify({"msg": "Product deleted successfully"}), 200