// lib/views/stock_out/widgets/stock_out_summary_stats.dart

import 'package:flutter/material.dart';
import 'package:mobile/models/stock_out_detail.dart';

/// Widget untuk menampilkan statistik ringkasan stock out
/// berupa total produk dan total kuantitas
class StockOutSummaryStats extends StatelessWidget {
  final StockOutDetailResponse detailData;

  const StockOutSummaryStats({Key? key, required this.detailData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StockOutStatCard(
            title: 'Total Produk',
            value: '${detailData.totalProducts}',
            icon: Icons.inventory_2_outlined,
            color: Color(0xFF4CAF50),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _StockOutStatCard(
            title: 'Total Kuantitas',
            value: '${detailData.totalQuantity}',
            icon: Icons.shopping_basket_outlined,
            color: Color(0xFF8BC34A),
          ),
        ),
      ],
    );
  }
}

/// Card statistik individual untuk menampilkan satu metrik
class _StockOutStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StockOutStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}
