// ============================================
// FILE 14: lib/widgets/stock/stock_empty_state.dart
// ============================================
import 'package:flutter/material.dart';

/// Widget untuk menampilkan state kosong
class StockEmptyState extends StatelessWidget {
  final bool hasSearch;

  const StockEmptyState({Key? key, this.hasSearch = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: const Color(0xFF999999),
          ),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Produk tidak ditemukan' : 'Belum ada produk',
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
