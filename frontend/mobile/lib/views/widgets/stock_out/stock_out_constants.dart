// lib/views/stock_out/constants/stock_out_constants.dart

import 'package:flutter/material.dart';

/// Konstanta untuk halaman Stock Out
/// Berisi definisi warna, spacing, dan teks yang digunakan
class StockOutConstants {
  // Private constructor untuk mencegah instantiation
  StockOutConstants._();

  // ===================================================================
  // COLORS
  // ===================================================================

  /// Warna primary untuk tema hijau
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color lightGreen = Color(0xFF66BB6A);
  static const Color mediumGreen = Color(0xFF8BC34A);
  static const Color softGreen = Color(0xFFAED581);

  /// Warna background
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color whiteBackground = Colors.white;

  /// Warna teks
  static const Color darkTextColor = Color(0xFF333333);
  static const Color mediumTextColor = Color(0xFF666666);
  static const Color lightTextColor = Color(0xFF999999);

  /// Warna untuk status
  static const Color errorColor = Color(0xFFF44336);
  static const Color successColor = Color(0xFF4CAF50);

  /// Warna untuk floating action button
  static const Color fabColor = Color(0xFF2196F3);

  // ===================================================================
  // SPACING
  // ===================================================================

  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
  static const double spacingXLarge = 24.0;

  // ===================================================================
  // BORDER RADIUS
  // ===================================================================

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 24.0;

  // ===================================================================
  // FONT SIZES
  // ===================================================================

  static const double fontSizeSmall = 11.0;
  static const double fontSizeRegular = 14.0;
  static const double fontSizeMedium = 18.0;
  static const double fontSizeLarge = 20.0;
  static const double fontSizeXLarge = 24.0;

  // ===================================================================
  // ICON SIZES
  // ===================================================================

  static const double iconSizeSmall = 18.0;
  static const double iconSizeRegular = 24.0;
  static const double iconSizeLarge = 64.0;

  // ===================================================================
  // TABLE DIMENSIONS
  // ===================================================================

  static const double tableColumnSpacing = 24.0;
  static const double tableHorizontalMargin = 24.0;
  static const double tableHeadingRowHeight = 56.0;
  static const double tableDataRowHeight = 64.0;

  // ===================================================================
  // SHADOW
  // ===================================================================

  static BoxShadow get defaultShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 10,
    offset: Offset(0, 2),
  );

  // ===================================================================
  // TEXT STYLES
  // ===================================================================

  static const TextStyle appBarTitleStyle = TextStyle(
    color: Colors.white,
    fontSize: fontSizeXLarge,
    fontWeight: FontWeight.bold,
  );

  static TextStyle appBarSubtitleStyle = TextStyle(
    color: Colors.white.withOpacity(0.9),
    fontSize: fontSizeRegular,
  );

  static const TextStyle tableHeaderStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: primaryGreen,
    fontSize: fontSizeRegular,
  );

  static const TextStyle tableIdStyle = TextStyle(
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  );

  static const TextStyle tableDateStyle = TextStyle(color: mediumTextColor);

  static const TextStyle statValueStyle = TextStyle(
    fontSize: fontSizeLarge,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle statTitleStyle = TextStyle(
    fontSize: fontSizeSmall,
    color: mediumTextColor,
  );

  static const TextStyle sectionHeaderStyle = TextStyle(
    fontSize: fontSizeMedium,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  );

  static const TextStyle emptyStateStyle = TextStyle(
    color: mediumTextColor,
    fontSize: fontSizeRegular,
  );

  // ===================================================================
  // DECORATIONS
  // ===================================================================

  static BoxDecoration get cardDecoration => BoxDecoration(
    color: whiteBackground,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: [defaultShadow],
  );

  static BoxDecoration get appBarDecoration => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [primaryGreen, lightGreen],
    ),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(radiusLarge),
      bottomRight: Radius.circular(radiusLarge),
    ),
  );

  static BoxDecoration get searchBarDecoration => BoxDecoration(
    color: whiteBackground,
    borderRadius: BorderRadius.circular(radiusMedium),
    boxShadow: [defaultShadow],
  );

  static BoxDecoration buttonDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.2),
    borderRadius: BorderRadius.circular(radiusSmall),
  );

  static BoxDecoration badgeDecoration(Color color) => BoxDecoration(
    color: color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusSmall),
  );

  // ===================================================================
  // MESSAGES
  // ===================================================================

  static const String loadingMessage = 'Memuat data...';
  static const String refreshSuccessMessage = 'Data berhasil diperbarui';
  static const String unexpectedErrorMessage =
      'Terjadi kesalahan yang tidak terduga';
  static const String emptyStateMessage = 'Belum ada stock out';
  static const String notFoundMessage = 'Stock out tidak ditemukan';
  static const String retryButtonLabel = 'Coba Lagi';

  // ===================================================================
  // HINTS & LABELS
  // ===================================================================

  static const String searchHint = 'Cari berdasarkan ID Stock Out...';
  static const String appBarTitle = 'Manajemen Stock Out';
  static const String appBarSubtitle = 'Kelola pengeluaran stok';
  static const String tableHeaderIdStockOut = 'ID Stock Out';
  static const String tableHeaderDate = 'Tanggal';
  static const String tableHeaderTotalProducts = 'Total Produk';
  static const String tableHeaderTotalQty = 'Total Qty';
  static const String tableHeaderAction = 'Aksi';

  // Stats labels
  static const String statTotalStockOut = 'Total Stock Out';
  static const String statTotalProducts = 'Total Produk';
  static const String statTotalQty = 'Total Qty';
}
