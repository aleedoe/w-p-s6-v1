// lib/views/return/utils/return_helpers.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReturnHelpers {
  /// Mengembalikan nilai status API (string) dari label yang ditampilkan (bahasa Indonesia).
  static String getStatusFromLabel(String label) {
    switch (label) {
      case 'Disetujui':
        return 'approved';
      case 'Menunggu':
        return 'pending';
      case 'Diproses':
        return 'processing';
      case 'Ditolak':
        return 'rejected';
      default:
        return ''; // Untuk 'Semua'
    }
  }

  /// Mengembalikan warna yang sesuai berdasarkan status return.
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF4CAF50); // Hijau
      case 'pending':
        return const Color(0xFFFF9800); // Oranye
      case 'processing':
        return const Color(0xFF2196F3); // Biru
      case 'rejected':
        return const Color(0xFFF44336); // Merah
      default:
        return const Color(0xFF999999); // Abu-abu
    }
  }

  /// Memformat string tanggal menjadi format 'dd/MM/yy HH:mm'.
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      // Menggunakan locale 'id_ID' jika tersedia, jika tidak, default.
      final formatter = DateFormat('dd/MM/yy HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      // Mengembalikan string asli jika parsing gagal
      return dateString;
    }
  }
}
