from . import db
from flask_jwt_extended import create_access_token
from werkzeug.security import generate_password_hash, check_password_hash

class ReturnTransaction(db.Model):
    __tablename__ = 'return_transactions'
    
    id = db.Column(db.Integer, primary_key=True)
    id_transaction = db.Column(db.Integer, db.ForeignKey('transactions.id'), nullable=False)
    id_reseller = db.Column(db.Integer, db.ForeignKey('resellers.id'), nullable=False)
    status = db.Column(db.String(50), default='pending')
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    transaction = db.relationship('Transaction', backref='return_transactions')
    reseller = db.relationship('Reseller', backref='return_transactions')