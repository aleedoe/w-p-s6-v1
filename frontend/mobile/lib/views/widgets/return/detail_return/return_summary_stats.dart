// lib/views/return/widgets/return_summary_stats.dart
import 'package:flutter/material.dart';

class ReturnSummaryStats extends StatelessWidget {
  final int totalProducts;
  final int totalQuantity;

  const ReturnSummaryStats({
    Key? key,
    required this.totalProducts,
    required this.totalQuantity,
  }) : super(key: key);

  // Widget pembantu untuk kartu statistik tunggal
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Produk',
            '$totalProducts',
            Icons.inventory_2_outlined,
            Color(0xFFFF6B6B),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Kuantitas',
            '$totalQuantity',
            Icons.shopping_basket_outlined,
            Color(0xFFF44336),
          ),
        ),
      ],
    );
  }
}
