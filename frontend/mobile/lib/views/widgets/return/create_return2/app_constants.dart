// lib/constants/app_constants.dart
import 'package:flutter/material.dart';

/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ========== Colors ==========

  /// Primary color palette
  static const Color primaryColor = Color(0xFFFF6B6B);
  static const Color primaryLightColor = Color(0xFFFF8E8E);
  static const Color primaryDarkColor = Color(0xFFF44336);

  /// Success color
  static const Color successColor = Color(0xFF4CAF50);

  /// Text colors
  static const Color textPrimaryColor = Color(0xFF333333);
  static const Color textSecondaryColor = Color(0xFF666666);
  static const Color textHintColor = Color(0xFF999999);

  /// Background colors
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardBackgroundColor = Colors.white;

  /// Border colors
  static const Color borderColor = Color(0xFFEEEEEE);
  static const Color dividerColor = Color(0xFFEEEEEE);

  // ========== Spacing ==========

  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 24.0;

  // ========== Border Radius ==========

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;

  // ========== Text Styles ==========

  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle subheadingStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textPrimaryColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    color: textPrimaryColor,
  );

  static const TextStyle captionStyle = TextStyle(
    fontSize: 12,
    color: textSecondaryColor,
  );

  // ========== Shadows ==========

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}
