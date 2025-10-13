// ============================================
// FILE 16: lib/utils/price_formatter.dart
// ============================================
/// Utility class untuk formatting harga
class PriceFormatter {
  /// Format harga ke format Rupiah dengan pemisah ribuan
  static String format(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }
}