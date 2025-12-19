import 'package:flutter/material.dart';
import 'package:mobile/models/product.dart';
import 'package:mobile/utils/price_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool inCart;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.inCart,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.quantity <= 0;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Icon
            _buildProductIcon(),
            SizedBox(width: 16),

            // Product Info
            Expanded(child: _buildProductInfo(isOutOfStock)),

            // Add to Cart Button
            _buildAddButton(isOutOfStock),
          ],
        ),
      ),
    );
  }

  Widget _buildProductIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.inventory_2, color: Color(0xFF4CAF50), size: 32),
    );
  }

  Widget _buildProductInfo(bool isOutOfStock) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        if (product.itemCode != null && product.itemCode!.isNotEmpty)
          Text(
            'Kode: ${product.itemCode}',
            style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
          ),
        SizedBox(height: 8),
        Row(
          children: [
            Text(
              'Rp ${PriceFormatter.format(product.price)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
            SizedBox(width: 12),
            _buildStockBadge(isOutOfStock),
          ],
        ),
      ],
    );
  }

  Widget _buildStockBadge(bool isOutOfStock) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? Color(0xFFF44336).withOpacity(0.1)
            : Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOutOfStock ? 'Habis' : 'Stok: ${product.quantity}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isOutOfStock ? Color(0xFFF44336) : Color(0xFF2196F3),
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isOutOfStock) {
    return GestureDetector(
      onTap: isOutOfStock ? null : onAddToCart,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOutOfStock
              ? Color(0xFF999999)
              : inCart
              ? Color(0xFF2196F3)
              : Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isOutOfStock
              ? []
              : [
                  BoxShadow(
                    color: (inCart ? Color(0xFF2196F3) : Color(0xFF4CAF50))
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
        ),
        child: Icon(
          inCart ? Icons.check : Icons.add,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
