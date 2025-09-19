from flask import Blueprint
from .controllers.admin import admin_login

admin_bp = Blueprint('admin', __name__)
reseller_bp = Blueprint('reseller', __name__)


# Admin routes
admin_bp.route('/login', methods=['POST'])(admin_login)