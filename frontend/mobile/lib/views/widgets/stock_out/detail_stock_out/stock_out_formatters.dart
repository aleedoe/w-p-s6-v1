// lib/views/stock_out/utils/stock_out_formatters.dart

import 'package:intl/intl.dart';

/// Utility class untuk formatting data stock out
/// Menyediakan fungsi-fungsi helper untuk format tanggal dan harga
class StockOutFormatters {
  StockOutFormatters._(); // Private constructor untuk mencegah instansiasi

  /// Format tanggal lengkap dengan jam
  /// Format: dd MMMM yyyy, HH:mm
  /// Contoh: 16 Oktober 2025, 14:30
  static String formatDateFull(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      // Kembalikan string asli jika parsing gagal
      return dateString;
    }
  }

  /// Format harga dengan pemisah ribuan menggunakan titik
  /// Contoh: 1500000 -> 1.500.000
  static String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Format harga dengan prefix "Rp" dan pemisah ribuan
  /// Contoh: 1500000 -> Rp 1.500.000
  static String formatPriceWithCurrency(double price) {
    return 'Rp ${formatPrice(price)}';
  }
}