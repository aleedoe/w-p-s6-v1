// ===================================================================
// lib/views/stock_out/widgets/stock_out_empty_state.dart
// ===================================================================
import 'package:flutter/material.dart';

/// Widget untuk menampilkan empty state
class StockOutEmptyState extends StatelessWidget {
  final bool hasSearchQuery;

  const StockOutEmptyState({Key? key, required this.hasSearchQuery})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Color(0xFF999999)),
          SizedBox(height: 16),
          Text(
            hasSearchQuery
                ? 'Stock out tidak ditemukan'
                : 'Belum ada stock out',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
