import 'package:flutter/material.dart';

// ─── Colors ───────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  // Premium Indigo Palette
  static const Color primary        = Color(0xFF6C63FF); 
  static const Color primaryLight   = Color(0xFFEAEAFF);
  static const Color primaryDark    = Color(0xFF5A52D5);
  static const Color primaryGlow    = Color(0x336C63FF);

  // Accent & Functional
  static const Color secondary      = Color(0xFFFF6584);
  static const Color secondaryLight = Color(0xFFFFF0F3);
  static const Color success        = Color(0xFF00D2A0);
  static const Color successLight   = Color(0xFFE6FBF7);
  static const Color warning        = Color(0xFFFFB24D);
  static const Color warningLight   = Color(0xFFFFF7EA);
  static const Color error          = Color(0xFFFF5252);
  static const Color errorLight     = Color(0xFFFFEEEE);

  // Surfaces & Backgrounds
  static const Color background     = Color(0xFFF8FAFF); // Very light blue-ish tint
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color cardBorder     = Color(0xFFF0F2F8);
  
  // Translucent / Glassmorphism tokens
  static const Color glassSurface   = Color(0xCCFFFFFF);
  static const Color glassBorder    = Color(0x33FFFFFF);

  // Text
  static const Color textPrimary    = Color(0xFF1A1A2E);
  static const Color textSecondary  = Color(0xFF5F617A);
  static const Color textMuted      = Color(0xFFA0A5C0);
  
  // Elements
  static const Color divider        = Color(0xFFF1F3F9);
  static const Color blocked        = Color(0xFFF4F6FB);
  static const Color blockedText    = Color(0xFFB0B5D0);

  // Shimmer
  static const Color shimmer1       = Color(0xFFF1F3F9);
  static const Color shimmer2       = Color(0xFFF9FAFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    colors: [surface, background],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Legacy compatibility
  static const Color neutral            = textMuted;
  static const Color todoChipBg         = Color(0xFFF1F3F9);
  static const Color inProgressChipBg   = warningLight;
  static const Color doneChipBg         = successLight;
}

// ─── Text Styles ──────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    fontFamily: 'Inter', // Fallback to system if not loaded
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.55,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.8,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}

// ─── Dimensions ───────────────────────────────────────────────────────────────
class AppDimens {
  AppDimens._();

  static const double pagePadding  = 24.0;
  static const double cardRadius   = 20.0;
  static const double buttonRadius = 16.0;
  static const double inputRadius  = 16.0;
  static const double chipRadius   = 12.0;
  static const double cardPadding  = 20.0;
  static const double cardGap      = 12.0;
  static const double sectionGap   = 32.0;
}

