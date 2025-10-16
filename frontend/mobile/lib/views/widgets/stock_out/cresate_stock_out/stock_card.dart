// lib/widgets/stockout/stock_card.dart
import 'package:flutter/material.dart';
import 'package:mobile/models/create_stockout.dart';
import 'package:mobile/utils/price_formatter.dart';

/// Widget untuk menampilkan kartu stok produk
class StockCard extends StatelessWidget {
  final StockItem stock;
  final bool inCart;
  final VoidCallback onAddToCart;

  const StockCard({
    Key? key,
    required this.stock,
    required this.inCart,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = stock.currentStock <= 0;

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
            _buildProductIcon(),
            SizedBox(width: 16),
            _buildProductInfo(isOutOfStock),
            _buildAddButton(isOutOfStock),
          ],
        ),
      ),
    );
  }

  /// Builds product icon
  Widget _buildProductIcon() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Color(0xFFFF9800).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.inventory_2, color: Color(0xFFFF9800), size: 32),
    );
  }

  /// Builds product information section
  Widget _buildProductInfo(bool isOutOfStock) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stock.productName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          SizedBox(height: 4),
          Text(
            stock.categoryName,
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Rp ${PriceFormatter.format(stock.price)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF666666),
                ),
              ),
              SizedBox(width: 12),
              _buildStockBadge(isOutOfStock),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds stock availability badge
  Widget _buildStockBadge(bool isOutOfStock) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOutOfStock
            ? Color(0xFFF44336).withOpacity(0.1)
            : Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isOutOfStock ? 'Habis' : 'Stok: ${stock.currentStock}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isOutOfStock ? Color(0xFFF44336) : Color(0xFF4CAF50),
        ),
      ),
    );
  }

  /// Builds add to cart button
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
              : Color(0xFFFF9800),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isOutOfStock
              ? []
              : [
                  BoxShadow(
                    color: (inCart ? Color(0xFF2196F3) : Color(0xFFFF9800))
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
