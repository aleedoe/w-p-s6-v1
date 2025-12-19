from . import db

class Product(db.Model):
    __tablename__ = 'products'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    item_code = db.Column(db.String(50), nullable=True)
    item_series = db.Column(db.String(100), nullable=True)
    quantity = db.Column(db.Integer, default=0)
    description = db.Column(db.Text)
    price = db.Column(db.Float, nullable=False)
    expired_date = db.Column(db.DateTime, nullable=True)
    created_at = db.Column(db.DateTime, server_default=db.func.now())
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())
