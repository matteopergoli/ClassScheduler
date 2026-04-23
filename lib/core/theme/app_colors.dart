// lib/core/theme/app_colors.dart
// All colour tokens for ClassScheduler.
// Dark theme mirrors the JSX mockup palette exactly.

import 'package:flutter/material.dart';

/// ─── DARK THEME TOKENS ────────────────────────────────────────────────────
abstract class AppColorsDark {
  // Backgrounds
  static const Color scaffoldBg     = Color(0xFF0B0D14);
  static const Color surfaceBg      = Color(0xFF0F1118);
  static const Color cardBg         = Color(0xFF131620);
  static const Color cardBgHovered  = Color(0xFF181C28);
  static const Color navBarBg       = Color(0xF20F1118); // 95% opacity

  // Borders
  static const Color borderDefault  = Color(0x14FFFFFF); // 8% white
  static const Color borderHovered  = Color(0x2EFFFFFF); // 18% white
  static const Color borderSubtle   = Color(0x0AFFFFFF); // 4% white

  // Brand / accent
  static const Color primary        = Color(0xFF6C63FF);
  static const Color primaryLight   = Color(0xFFA78BFA);
  static const Color primaryGlow    = Color(0x806C63FF); // 50%

  // Gradient pairs (used for card accent bars + buttons)
  static const List<List<Color>> palettes = [
    [Color(0xFF6C63FF), Color(0xFFA78BFA)], // violet
    [Color(0xFFF472B6), Color(0xFFFB7185)], // pink-red
    [Color(0xFF34D399), Color(0xFF2DD4BF)], // green-teal
    [Color(0xFFFBBF24), Color(0xFFF97316)], // amber-orange
    [Color(0xFF60A5FA), Color(0xFF818CF8)], // blue-indigo
  ];

  // Status colours
  static const Color success        = Color(0xFF10B981);
  static const Color successBg      = Color(0x1A10B981); // 10%
  static const Color successBorder  = Color(0x5910B981); // 35%
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningBg      = Color(0x1AF59E0B);
  static const Color error          = Color(0xFFEF4444);
  static const Color errorBg        = Color(0x1AEF4444);

  // Text
  static const Color textPrimary    = Color(0xFFF1F5F9);
  static const Color textSecondary  = Color(0xFFE2E8F0);
  static const Color textMuted      = Color(0xFF94A3B8);
  static const Color textDisabled   = Color(0xFF475569);
  static const Color textPlaceholder= Color(0xFF64748B);

  // Trial / subscription banner
  static const Color trialBg        = Color(0x336C63FF); // 20%
  static const Color trialBorder    = Color(0x4D6C63FF); // 30%

  // Subject / teacher colours (timetable cells) — 12 perceptually distinct.
  // Must stay in sync with _palette in step4_subjects_screen.dart.
  static const List<Color> subjectPalette = [
    Color(0xFF6C63FF), // violet
    Color(0xFFEF4444), // red
    Color(0xFF10B981), // emerald
    Color(0xFFF59E0B), // amber
    Color(0xFF3B82F6), // blue
    Color(0xFFEC4899), // hot pink
    Color(0xFF14B8A6), // teal
    Color(0xFF8B5CF6), // purple
    Color(0xFFF97316), // orange
    Color(0xFF06B6D4), // cyan
    Color(0xFF84CC16), // lime
    Color(0xFFE879F9), // fuchsia
  ];
}

/// ─── LIGHT THEME TOKENS ───────────────────────────────────────────────────
abstract class AppColorsLight {
  static const Color scaffoldBg     = Color(0xFFF8F9FF);
  static const Color surfaceBg      = Color(0xFFFFFFFF);
  static const Color cardBg         = Color(0xFFFFFFFF);
  static const Color cardBgHovered  = Color(0xFFF1F5FF);
  static const Color navBarBg       = Color(0xFAFFFFFF);

  static const Color borderDefault  = Color(0x1A000000); // 10% black
  static const Color borderHovered  = Color(0x33000000); // 20% black
  static const Color borderSubtle   = Color(0x0D000000); // 5% black

  static const Color primary        = Color(0xFF6C63FF);
  static const Color primaryLight   = Color(0xFF8B83FF);
  static const Color primaryGlow    = Color(0x406C63FF);

  static const List<List<Color>> palettes = AppColorsDark.palettes;

  static const Color success        = Color(0xFF059669);
  static const Color successBg      = Color(0x1A059669);
  static const Color successBorder  = Color(0x59059669);
  static const Color warning        = Color(0xFFD97706);
  static const Color warningBg      = Color(0x1AD97706);
  static const Color error          = Color(0xFFDC2626);
  static const Color errorBg        = Color(0x1ADC2626);

  static const Color textPrimary    = Color(0xFF0F172A);
  static const Color textSecondary  = Color(0xFF1E293B);
  static const Color textMuted      = Color(0xFF64748B);
  static const Color textDisabled   = Color(0xFF94A3B8);
  static const Color textPlaceholder= Color(0xFFCBD5E1);

  static const Color trialBg        = Color(0x1A6C63FF);
  static const Color trialBorder    = Color(0x336C63FF);

  static const List<Color> subjectPalette = AppColorsDark.subjectPalette;
}

/// ─── RUNTIME HELPER ───────────────────────────────────────────────────────
/// Usage: AppColors.of(context).primary
class AppColors {
  final Color scaffoldBg;
  final Color surfaceBg;
  final Color cardBg;
  final Color cardBgHovered;
  final Color navBarBg;
  final Color borderDefault;
  final Color borderHovered;
  final Color borderSubtle;
  final Color primary;
  final Color primaryLight;
  final Color primaryGlow;
  final List<List<Color>> palettes;
  final Color success;
  final Color successBg;
  final Color successBorder;
  final Color warning;
  final Color warningBg;
  final Color error;
  final Color errorBg;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textDisabled;
  final Color textPlaceholder;
  final Color trialBg;
  final Color trialBorder;
  final List<Color> subjectPalette;

  const AppColors._({
    required this.scaffoldBg,
    required this.surfaceBg,
    required this.cardBg,
    required this.cardBgHovered,
    required this.navBarBg,
    required this.borderDefault,
    required this.borderHovered,
    required this.borderSubtle,
    required this.primary,
    required this.primaryLight,
    required this.primaryGlow,
    required this.palettes,
    required this.success,
    required this.successBg,
    required this.successBorder,
    required this.warning,
    required this.warningBg,
    required this.error,
    required this.errorBg,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textDisabled,
    required this.textPlaceholder,
    required this.trialBg,
    required this.trialBorder,
    required this.subjectPalette,
  });

  static const AppColors dark = AppColors._(
    scaffoldBg: AppColorsDark.scaffoldBg,
    surfaceBg: AppColorsDark.surfaceBg,
    cardBg: AppColorsDark.cardBg,
    cardBgHovered: AppColorsDark.cardBgHovered,
    navBarBg: AppColorsDark.navBarBg,
    borderDefault: AppColorsDark.borderDefault,
    borderHovered: AppColorsDark.borderHovered,
    borderSubtle: AppColorsDark.borderSubtle,
    primary: AppColorsDark.primary,
    primaryLight: AppColorsDark.primaryLight,
    primaryGlow: AppColorsDark.primaryGlow,
    palettes: AppColorsDark.palettes,
    success: AppColorsDark.success,
    successBg: AppColorsDark.successBg,
    successBorder: AppColorsDark.successBorder,
    warning: AppColorsDark.warning,
    warningBg: AppColorsDark.warningBg,
    error: AppColorsDark.error,
    errorBg: AppColorsDark.errorBg,
    textPrimary: AppColorsDark.textPrimary,
    textSecondary: AppColorsDark.textSecondary,
    textMuted: AppColorsDark.textMuted,
    textDisabled: AppColorsDark.textDisabled,
    textPlaceholder: AppColorsDark.textPlaceholder,
    trialBg: AppColorsDark.trialBg,
    trialBorder: AppColorsDark.trialBorder,
    subjectPalette: AppColorsDark.subjectPalette,
  );

  static const AppColors light = AppColors._(
    scaffoldBg: AppColorsLight.scaffoldBg,
    surfaceBg: AppColorsLight.surfaceBg,
    cardBg: AppColorsLight.cardBg,
    cardBgHovered: AppColorsLight.cardBgHovered,
    navBarBg: AppColorsLight.navBarBg,
    borderDefault: AppColorsLight.borderDefault,
    borderHovered: AppColorsLight.borderHovered,
    borderSubtle: AppColorsLight.borderSubtle,
    primary: AppColorsLight.primary,
    primaryLight: AppColorsLight.primaryLight,
    primaryGlow: AppColorsLight.primaryGlow,
    palettes: AppColorsLight.palettes,
    success: AppColorsLight.success,
    successBg: AppColorsLight.successBg,
    successBorder: AppColorsLight.successBorder,
    warning: AppColorsLight.warning,
    warningBg: AppColorsLight.warningBg,
    error: AppColorsLight.error,
    errorBg: AppColorsLight.errorBg,
    textPrimary: AppColorsLight.textPrimary,
    textSecondary: AppColorsLight.textSecondary,
    textMuted: AppColorsLight.textMuted,
    textDisabled: AppColorsLight.textDisabled,
    textPlaceholder: AppColorsLight.textPlaceholder,
    trialBg: AppColorsLight.trialBg,
    trialBorder: AppColorsLight.trialBorder,
    subjectPalette: AppColorsLight.subjectPalette,
  );

  /// Retrieve the correct AppColors for the current theme.
  static AppColors of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? dark : light;
  }
  /// Alias for cardBg — used by grid and form widgets.
  Color get surfaceVariant => cardBg;

}