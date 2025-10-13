// ============================================================================
// lib/pages/order_page/utils/date_formatter.dart
// ============================================================================

import 'package:intl/intl.dart';

/// Utility class untuk memformat tanggal
class DateFormatter {
  /// Memformat string tanggal menjadi format yang lebih mudah dibaca
  /// Format: dd/MM/yy HH:mm
  static String format(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yy HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      // Jika parsing gagal, kembalikan string asli
      return dateString;
    }
  }
}