// lib/utils/format_utils.dart
import 'package:intl/intl.dart';

/// Utility class for formatting data
class FormatUtils {
  /// Format price with Indonesian Rupiah format
  /// Example: 1000000 -> "1.000.000"
  static String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Format date to Indonesian date format
  /// Example: "2024-01-15 10:30:00" -> "15/01/24 10:30"
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yy HH:mm', 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format date with custom pattern
  static String formatDateWithPattern(String dateString, String pattern) {
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat(pattern, 'id_ID');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Format currency with Rp prefix
  /// Example: 1000000 -> "Rp 1.000.000"
  static String formatCurrency(double price) {
    return 'Rp ${formatPrice(price)}';
  }
}
