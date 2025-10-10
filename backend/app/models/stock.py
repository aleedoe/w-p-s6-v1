from . import db

class Stock(db.Model):
    __tablename__ = 'stocks'

    id = db.Column(db.Integer, primary_key=True)
    id_reseller = db.Column(db.Integer, db.ForeignKey('resellers.id'), nullable=False)
    id_product = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, default=0)
    updated_at = db.Column(db.DateTime, server_default=db.func.now(), onupdate=db.func.now())

    reseller = db.relationship('Reseller', backref='stocks')
    product = db.relationship('Product', backref='reseller_stocks')
