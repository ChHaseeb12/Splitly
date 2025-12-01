import 'package:flutter/material.dart';

/// Design System Constants for Splitly
/// Maintains consistent styling throughout the app
class AppColors {
  // Primary Colors (Grey tones theme)
  static const Color primary = Color(0xFF2C2C2C);
  static const Color primaryLight = Color(0xFF4A4A4A);
  static const Color primaryDark = Color(0xFF1A1A1A);

  // Accent Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFFAFAFA);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);

  // Category Colors
  static const Map<String, Color> categoryColors = {
    'FOOD': Color(0xFFFF6B6B),
    'ENTERTAINMENT': Color(0xFF4ECDC4),
    'UTILITIES': Color(0xFFFFE66D),
    'TRANSPORTATION': Color(0xFF95E1D3),
    'SHOPPING': Color(0xFFF38181),
    'TRAVEL': Color(0xFFAA96DA),
    'PERSONAL': Color(0xFFFCBF49),
    'HEALTH': Color(0xFF06FFA5),
    'SUBSCRIPTION': Color(0xFF5F9DF7),
    'OTHER': Color(0xFFB8B8B8),
  };
}

class AppSpacing {
  // Spacing Scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Padding
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);

  // Horizontal Padding
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(
    horizontal: sm,
  );
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(
    horizontal: md,
  );
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(
    horizontal: lg,
  );

  // Vertical Padding
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(
    vertical: sm,
  );
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(
    vertical: md,
  );
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(
    vertical: lg,
  );
}

class AppBorderRadius {
  // Border Radius Scale
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 999.0;

  // BorderRadius Objects
  static BorderRadius radiusSM = BorderRadius.circular(sm);
  static BorderRadius radiusMD = BorderRadius.circular(md);
  static BorderRadius radiusLG = BorderRadius.circular(lg);
  static BorderRadius radiusXL = BorderRadius.circular(xl);
  static BorderRadius radiusRound = BorderRadius.circular(round);
}

class AppElevation {
  // Elevation Scale
  static const double none = 0.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;

  // Shadow Definitions
  static List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppTypography {
  // Font Sizes
  static const double fontSizeXS = 12.0;
  static const double fontSizeSM = 14.0;
  static const double fontSizeMD = 16.0;
  static const double fontSizeLG = 18.0;
  static const double fontSizeXL = 20.0;
  static const double fontSize2XL = 24.0;
  static const double fontSize3XL = 32.0;

  // Font Weights
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Text Styles
  static const TextStyle h1 = TextStyle(
    fontSize: fontSize3XL,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: fontSize2XL,
    fontWeight: fontWeightBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: fontSizeXL,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: fontSizeLG,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: fontWeightRegular,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: fontSizeSM,
    fontWeight: fontWeightRegular,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: fontWeightRegular,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: fontSizeXS,
    fontWeight: fontWeightRegular,
    color: AppColors.textTertiary,
  );

  static const TextStyle button = TextStyle(
    fontSize: fontSizeMD,
    fontWeight: fontWeightSemiBold,
    color: AppColors.textOnPrimary,
  );
}

class AppConstants {
  // Touch Target Sizes (Accessibility)
  static const double minTouchTarget = 48.0;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Icon Sizes
  static const double iconSizeSM = 16.0;
  static const double iconSizeMD = 24.0;
  static const double iconSizeLG = 32.0;
  static const double iconSizeXL = 48.0;
}
