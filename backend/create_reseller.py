import os
from app import create_app, db
from app.models import Reseller

def create_reseller(password, email, name="Reseller Baru", phone=None, address=None):
    # Membuat aplikasi Flask
    app = create_app()

    # Push context aplikasi
    with app.app_context():
        # Cek apakah reseller sudah ada dengan email
        if Reseller.query.filter_by(email=email).first():
            print(f"Reseller dengan email {email} sudah ada!")
            return

        # Buat reseller baru
        reseller = Reseller(
            name=name,
            email=email,
            phone=phone,
            address=address
        )
        reseller.set_password(password)  # Set password menggunakan metode set_password
        
        db.session.add(reseller)
        db.session.commit()
        
        print(f"Reseller {name} berhasil dibuat!")
        print(f"Email   : {email}")
        print(f"Password: {password}")
        print(f"Phone   : {phone}")
        print(f"Address : {address}")

if __name__ == "__main__":
    # Ganti dengan credential yang diinginkan
    create_reseller(
        password="reseller123",
        email="reseller@example.com",
        name="Reseller Utama",
        phone="08123456789",
        address="Jl. Contoh No. 123, Jakarta"
    )
