// lib/pages/transaction_detail/utils/style_utils.dart
import 'package:flutter/material.dart';

/// Utility class untuk styling dan konstanta visual
class StyleUtils {
  StyleUtils._(); // Private constructor untuk mencegah instantiasi

  // ========== Warna-warna yang digunakan ==========
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color primaryLightColor = Color(0xFF64B5F6);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFF44336);
  static const Color neutralDarkColor = Color(0xFF333333);
  static const Color neutralGrayColor = Color(0xFF666666);
  static const Color neutralLightGrayColor = Color(0xFF999999);
  static const Color neutralVeryLightGrayColor = Color(0xFFEEEEEE);
  static const Color backgroundColor = Color(0xFFF5F5F5);

  // ========== Box Shadow yang umum digunakan ==========
  static final List<BoxShadow> defaultBoxShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  // ========== Gradient yang umum digunakan ==========
  static final LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, primaryLightColor],
  );

  // ========== Border Radius ==========
  static const double borderRadiusLarge = 16;
  static const double borderRadiusMedium = 12;
  static const double borderRadiusSmall = 8;

  // ========== Padding ==========
  static const double paddingLarge = 24;
  static const double paddingMedium = 16;
  static const double paddingSmall = 12;

  // ========== Font Sizes ==========
  static const double fontSizeXLarge = 28;
  static const double fontSizeLarge = 24;
  static const double fontSizeMedium = 18;
  static const double fontSizeRegular = 14;
  static const double fontSizeSmall = 12;

  /// Mendapatkan warna berdasarkan status transaksi
  /// Status: completed, pending, processing, cancelled, default
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return successColor;
      case 'pending':
        return warningColor;
      case 'processing':
        return primaryColor;
      case 'cancelled':
        return errorColor;
      default:
        return neutralLightGrayColor;
    }
  }

  /// Mendapatkan ikon berdasarkan status transaksi
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_outline;
      case 'pending':
        return Icons.schedule_outlined;
      case 'processing':
        return Icons.hourglass_bottom_outlined;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  /// TextStyle untuk heading besar
  static const TextStyle headingLargeStyle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.bold,
    color: neutralDarkColor,
  );

  /// TextStyle untuk heading medium
  static const TextStyle headingMediumStyle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.bold,
    color: neutralDarkColor,
  );

  /// TextStyle untuk body text regular
  static const TextStyle bodyRegularStyle = TextStyle(
    fontSize: fontSizeRegular,
    color: neutralGrayColor,
  );

  /// TextStyle untuk body text dengan weight medium
  static const TextStyle bodyMediumStyle = TextStyle(
    fontSize: fontSizeRegular,
    fontWeight: FontWeight.w600,
    color: neutralDarkColor,
  );

  /// TextStyle untuk caption/small text
  static const TextStyle captionStyle = TextStyle(
    fontSize: fontSizeSmall,
    color: neutralGrayColor,
  );
}