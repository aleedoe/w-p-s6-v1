from flask import Blueprint
from .controllers.admin import admin_login, get_all_products, get_product_detail, update_product, create_product, delete_product, get_all_transactions, get_transaction_detail, accept_transaction, reject_transaction, get_all_return_transactions, get_return_transaction_detail, reject_return_transaction, accept_return_transaction

admin_bp = Blueprint('admin', __name__)
reseller_bp = Blueprint('reseller', __name__)


# Admin routes
admin_bp.route('/login', methods=['POST'])(admin_login)
admin_bp.route('/products', methods=['GET'])(get_all_products)
admin_bp.route('/products/<int:product_id>', methods=['GET'])(get_product_detail)
admin_bp.route('/products', methods=['POST'])(create_product)
admin_bp.route('/products/<int:product_id>', methods=['PUT'])(update_product)
admin_bp.route('/products/<int:product_id>', methods=['DELETE'])(delete_product)

admin_bp.route('/transactions', methods=['GET'])(get_all_transactions)
admin_bp.route('/transactions/<int:transaction_id>', methods=['GET'])(get_transaction_detail)
admin_bp.route('/transactions/<int:transaction_id>/accept', methods=['PUT'])(accept_transaction)
admin_bp.route('/transactions/<int:transaction_id>/reject', methods=['PUT'])(reject_transaction)

admin_bp.route('/return-transactions', methods=['GET'])(get_all_return_transactions)
admin_bp.route('/return-transactions/<int:return_transaction_id>', methods=['GET'])(get_return_transaction_detail)
admin_bp.route('/return-transactions/<int:return_transaction_id>/accept', methods=['PUT'])(accept_return_transaction)
admin_bp.route('/return-transactions/<int:return_transaction_id>/reject', methods=['PUT'])(reject_return_transaction)


# Reseller routes
from .controllers.reseller import reseller_login, res_get_all_products, res_get_product_detail, res_get_stocks

reseller_bp.route('/login', methods=['POST'])(reseller_login)
reseller_bp.route('/products', methods=['GET'])(res_get_all_products)
reseller_bp.route('/products/<int:product_id>', methods=['GET'])(res_get_product_detail)
reseller_bp.route('/stocks', methods=['GET'])(res_get_stocks)