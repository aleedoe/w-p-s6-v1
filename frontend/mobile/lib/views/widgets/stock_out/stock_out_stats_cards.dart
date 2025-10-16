// ===================================================================
// lib/views/stock_out/widgets/stock_out_stats_cards.dart
// ===================================================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_out.dart';
/// Cards untuk menampilkan statistik stock out
/// Menampilkan total stock out, total produk, dan total quantity
class StockOutStatsCards extends StatelessWidget {
  final StockOutResponse stockOutData;

  const StockOutStatsCards({Key? key, required this.stockOutData})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: _StockOutStatCard(
              title: 'Total Stock Out',
              value: '${stockOutData.totalStockOuts}',
              icon: Icons.inventory_2_outlined,
              color: Color(0xFF4CAF50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StockOutStatCard(
              title: 'Total Produk',
              value: '${_calculateTotalProducts()}',
              icon: Icons.shopping_bag_outlined,
              color: Color(0xFF8BC34A),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StockOutStatCard(
              title: 'Total Qty',
              value: '${_calculateTotalQuantity()}',
              icon: Icons.stacked_line_chart,
              color: Color(0xFFAED581),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalProducts() {
    return stockOutData.stockOuts.fold<int>(
      0,
      (sum, s) => sum + s.totalProducts,
    );
  }

  int _calculateTotalQuantity() {
    return stockOutData.stockOuts.fold<int>(
      0,
      (sum, s) => sum + s.totalQuantity,
    );
  }
}

/// Widget individual untuk stat card
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
      padding: EdgeInsets.all(12),
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
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
