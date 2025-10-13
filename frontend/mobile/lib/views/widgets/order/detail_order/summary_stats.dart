// lib/pages/transaction_detail/widgets/summary_stats.dart
import 'package:flutter/material.dart';
import '../../../models/transaction_detail.dart';
import '../utils/style_utils.dart';

/// Widget untuk menampilkan statistik ringkasan transaksi
class TransactionSummaryStats extends StatelessWidget {
  final TransactionDetailResponse detailData;

  const TransactionSummaryStats({Key? key, required this.detailData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Total Produk',
            value: '${detailData.totalProducts}',
            icon: Icons.inventory_2_outlined,
            color: Color(0xFF2196F3),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Total Kuantitas',
            value: '${detailData.totalQuantity}',
            icon: Icons.shopping_basket_outlined,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  /// Membangun kartu statistik individual
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: StyleUtils.defaultBoxShadow,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
