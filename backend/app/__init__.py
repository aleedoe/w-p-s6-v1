from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_jwt_extended import JWTManager
from config import config
from app.models import *
from flask_cors import CORS
from datetime import timedelta
import os


migrate = Migrate()
jwt = JWTManager()

def create_app(config_name='development'):
    app = Flask(
        __name__,
        static_folder=os.path.join(os.path.dirname(__file__), "..", "static"),
        static_url_path="/static"
    )
    app.config['JWT_ACCESS_TOKEN_EXPIRES'] = timedelta(hours=1)
    app.config.from_object(config[config_name])

    # Pastikan folder upload ada
    os.makedirs(app.config["UPLOAD_FOLDER"], exist_ok=True)

    # Enable CORS
    CORS(app, resources={
        r"/api/*": {
            "origins": [
                "http://localhost:3000",
                "http://127.0.0.1:3000",
                "http://localhost:49797",
                "http://127.0.0.1:49797"
            ],
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # Initialize extensions
    migrate.init_app(app, db)
    jwt.init_app(app)
    
    # Register blueprints
    from .routes import admin_bp, reseller_bp
    app.register_blueprint(admin_bp, url_prefix='/api/admin')
    app.register_blueprint(reseller_bp, url_prefix='/api/reseller')
    
    # Import models
    from .models import admin, category, product, image, transaction, detail_transaction, return_transaction, return_detail_transaction, reseller, stock_out, stock
    
    db.init_app(app)
    
    return app
