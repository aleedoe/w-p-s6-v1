// ============================================
// FILE 10: lib/widgets/product/product_stock_badge.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/views/widgets/stock/stock_status_helper.dart';

/// Widget badge untuk menampilkan status stok produk
class ProductStockBadge extends StatelessWidget {
  final int quantity;

  const ProductStockBadge({
    Key? key,
    required this.quantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = StockStatusHelper.getStatusColor(quantity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Stok: $quantity',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }
}