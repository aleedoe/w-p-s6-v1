// lib/pages/transaction_detail/utils/format_utils.dart
import 'package:intl/intl.dart';

/// Utility class untuk memformat data (tanggal, harga, dll)
class FormatUtils {
  FormatUtils._(); // Private constructor untuk mencegah instantiasi

  /// Memformat tanggal lengkap dengan format: dd MMMM yyyy, HH:mm
  /// Contoh: 15 Oktober 2024, 14:30
  static String formatDateFull(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString; // Return original string jika parsing gagal
    }
  }

  /// Memformat harga dengan pemisah ribuan menggunakan titik (.)
  /// Contoh: 1500000 -> 1.500.000
  static String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Memformat harga dengan simbol mata uang
  /// Contoh: 1500000 -> Rp 1.500.000
  static String formatPriceWithCurrency(double price) {
    return 'Rp ${formatPrice(price)}';
  }

  /// Memformat tanggal dengan format pendek: dd/MM/yyyy
  /// Contoh: 15/10/2024
  static String formatDateShort(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Memformat angka dengan pemisah ribuan
  /// Contoh: 15000 -> 15.000
  static String formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
