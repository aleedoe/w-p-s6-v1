// ============================================
// FILE 11: lib/widgets/product/product_price_section.dart
// ============================================
import 'package:flutter/material.dart';
import 'price_formatter.dart';

/// Widget untuk menampilkan harga dan statistik pergerakan stok
class ProductPriceSection extends StatelessWidget {
  final double price;
  final int totalIn;
  final int totalOut;

  const ProductPriceSection({
    Key? key,
    required this.price,
    required this.totalIn,
    required this.totalOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Harga
        Text(
          'Rp ${PriceFormatter.format(price)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),

        // Statistik stok masuk dan keluar
        Row(
          children: [
            _buildStatisticItem(
              icon: Icons.arrow_downward,
              value: totalIn.toString(),
              color: const Color(0xFF2196F3),
            ),
            const SizedBox(width: 8),
            _buildStatisticItem(
              icon: Icons.arrow_upward,
              value: totalOut.toString(),
              color: const Color(0xFFF44336),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticItem({
    required IconData icon,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        Text(' $value', style: TextStyle(fontSize: 12, color: color)),
      ],
    );
  }
}
