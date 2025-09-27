from . import db

class ResellerStockOut(db.Model):
    __tablename__ = 'reseller_stock_outs'
    
    id = db.Column(db.Integer, primary_key=True)
    id_reseller = db.Column(db.Integer, db.ForeignKey('resellers.id'), nullable=False)
    note = db.Column(db.String(255))  # contoh: "penjualan ke customer A"
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    reseller = db.relationship('Reseller', backref='stock_outs')


class ResellerStockOutDetail(db.Model):
    __tablename__ = 'reseller_stock_out_details'
    
    id = db.Column(db.Integer, primary_key=True)
    id_stock_out = db.Column(db.Integer, db.ForeignKey('reseller_stock_outs.id'), nullable=False)
    id_product = db.Column(db.Integer, db.ForeignKey('products.id'), nullable=False)
    quantity = db.Column(db.Integer, nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    stock_out = db.relationship('ResellerStockOut', backref='details')
    product = db.relationship('Product', backref='reseller_stock_out_details')
