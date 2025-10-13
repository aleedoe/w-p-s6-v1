// ============================================================================
// lib/pages/order_page/utils/status_utils.dart
// ============================================================================

import 'package:flutter/material.dart';

/// Utility class untuk mengelola status transaksi
class StatusUtils {
  /// Mengkonversi label status Indonesia ke enum status
  static String getStatusFromLabel(String label) {
    switch (label) {
      case 'Selesai':
        return 'completed';
      case 'Menunggu':
        return 'pending';
      case 'Diproses':
        return 'processing';
      case 'Dibatalkan':
        return 'cancelled';
      default:
        return '';
    }
  }

  /// Mendapatkan warna berdasarkan status transaksi
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Color(0xFF4CAF50); // Hijau
      case 'pending':
        return Color(0xFFFF9800); // Orange
      case 'processing':
        return Color(0xFF2196F3); // Biru
      case 'cancelled':
        return Color(0xFFF44336); // Merah
      default:
        return Color(0xFF999999); // Abu-abu
    }
  }
}
