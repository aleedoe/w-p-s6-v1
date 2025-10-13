// ============================================
// FILE 5: lib/widgets/stock/stock_stats_section.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:mobile/models/stock_detail.dart';
import 'package:mobile/views/widgets/stock/stat_card.dart';

/// Widget untuk menampilkan statistik stok (total produk dan total quantity)
class StockStatsSection extends StatelessWidget {
  final StockResponse stockData;

  const StockStatsSection({
    Key? key,
    required this.stockData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Total Produk',
              value: '${stockData.totalProducts}',
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF2196F3),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StatCard(
              title: 'Total Stok',
              value: stockData.totalQuantity,
              icon: Icons.storage_outlined,
              color: const Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}