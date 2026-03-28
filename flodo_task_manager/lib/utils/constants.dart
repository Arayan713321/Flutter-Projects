import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary       = Color(0xFF6C63FF); // indigo violet
  static const Color primaryLight  = Color(0xFFEEEDFF);
  static const Color primaryDark   = Color(0xFF4B44CC);
  static const Color secondary     = Color(0xFFFF6584);
  static const Color success       = Color(0xFF43D9AD);
  static const Color successLight  = Color(0xFFE6FBF5);
  static const Color warning       = Color(0xFFFFBE5C);
  static const Color warningLight  = Color(0xFFFFF4E0);
  static const Color error         = Color(0xFFFF5C5C);
  static const Color errorLight    = Color(0xFFFFEEEE);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color background    = Color(0xFFF4F5FA);
  static const Color cardBg        = Color(0xFFFFFFFF);
  static const Color textPrimary   = Color(0xFF1C1C2E);
  static const Color textSecondary = Color(0xFF6B6B80);
  static const Color textMuted     = Color(0xFFA0A0B0);
  static const Color divider       = Color(0xFFEEEEF5);
  static const Color blocked       = Color(0xFFF0F0F5);
  static const Color blockedText   = Color(0xFFB0B0C0);
  static const Color shimmer1      = Color(0xFFE8E8F0);
  static const Color shimmer2      = Color(0xFFF5F5FA);

  // Compatibility aliases for legacy model code (task.dart)
  static const Color neutral            = textMuted;
  static const Color todoChipBg         = Color(0xFFF0F0F5); // matches 'blocked' color
  static const Color inProgressChipBg   = warningLight;
  static const Color doneChipBg         = successLight;
}

// ─── Text Styles ──────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.primary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

// ─── Dimensions ───────────────────────────────────────────────────────────────
class AppDimens {
  AppDimens._();

  static const double pagePadding  = 20.0;
  static const double cardRadius   = 18.0;
  static const double buttonRadius = 14.0;
  static const double inputRadius  = 14.0;
  static const double chipRadius   = 10.0;
  static const double cardPadding  = 18.0;
  static const double cardGap      = 14.0;
  static const double sectionGap   = 24.0;
}
