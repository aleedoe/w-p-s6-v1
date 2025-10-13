// ============================================
// FILE 12: lib/widgets/stock/stock_loading_state.dart
// ============================================
import 'package:flutter/material.dart';

/// Widget untuk menampilkan state loading
class StockLoadingState extends StatelessWidget {
  const StockLoadingState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Memuat data...',
            style: TextStyle(color: Color(0xFF666666), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
