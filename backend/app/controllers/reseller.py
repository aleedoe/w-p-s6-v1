from flask import request, jsonify
from flask_jwt_extended import create_access_token
from ..models import Reseller, db


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
