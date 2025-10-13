// ============================================
// FILE 17: lib/utils/stock_status_helper.dart
// ============================================
import 'package:flutter/material.dart';

/// Utility class untuk menentukan status dan warna stok
class StockStatusHelper {
  /// Mendapatkan warna berdasarkan jumlah stok
  /// Red: <= 3 (Stok rendah)
  /// Orange: 4-7 (Stok sedang)
  /// Green: > 7 (Stok tinggi)
  static Color getStatusColor(int quantity) {
    if (quantity <= 3) {
      return const Color(0xFFF44336); // Red for low stock
    } else if (quantity <= 7) {
      return const Color(0xFFFF9800); // Orange for medium stock
    } else {
      return const Color(0xFF4CAF50); // Green for high stock
    }
  }
}
