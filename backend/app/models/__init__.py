from flask_sqlalchemy import SQLAlchemy

# Inisialisasi database
db = SQLAlchemy()

from .admin import Admin
from .category import Category
from .product import Product
from .image import Image
from .transaction import Transaction
from .detail_transaction import DetailTransaction
from .return_transaction import ReturnTransaction
from .return_detail_transaction import ReturnDetailTransaction
from .reseller import Reseller
from .stock_out import ResellerStockOut, ResellerStockOutDetail
from .stock import Stock
