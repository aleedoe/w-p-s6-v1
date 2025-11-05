"""delete category table

Revision ID: 608733402a07
Revises: 248f1800be97
Create Date: 2025-11-05 11:00:52.358422
"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

# revision identifiers, used by Alembic.
revision = '608733402a07'
down_revision = '248f1800be97'
branch_labels = None
depends_on = None


def upgrade():
    # Hapus foreign key dan kolom dari tabel products dulu
    with op.batch_alter_table('products', schema=None) as batch_op:
        batch_op.drop_constraint('products_ibfk_1', type_='foreignkey')
        batch_op.drop_column('id_category')

    # Setelah constraint dan kolom hilang, baru aman hapus tabel categories
    op.drop_table('categories')


def downgrade():
    # Kembalikan tabel categories
    op.create_table(
        'categories',
        sa.Column('id', mysql.INTEGER(), autoincrement=True, nullable=False),
        sa.Column('name', mysql.VARCHAR(length=100), nullable=False),
        sa.Column('created_at', mysql.DATETIME(), server_default=sa.text('(now())'), nullable=True),
        sa.Column('updated_at', mysql.DATETIME(), server_default=sa.text('(now())'), nullable=True),
        sa.PrimaryKeyConstraint('id'),
        mysql_collate='utf8mb4_0900_ai_ci',
        mysql_default_charset='utf8mb4',
        mysql_engine='InnoDB'
    )

    # Tambahkan kembali kolom dan foreign key di products
    with op.batch_alter_table('products', schema=None) as batch_op:
        batch_op.add_column(sa.Column('id_category', mysql.INTEGER(), nullable=False))
        batch_op.create_foreign_key('products_ibfk_1', 'categories', ['id_category'], ['id'])
