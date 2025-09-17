from . import db
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash

class ReturnDetailTransaction(db.Model):
    __tablename__ = 'return_detail_transactions'
    
    id = db.Column(db.Integer, primary_key=True)
    id_product = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    reason = db.Column(db.String(255))
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    product = db.relationship('Product', backref='return_details')