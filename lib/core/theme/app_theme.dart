// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ── DARK ──────────────────────────────────────────────────────────────────
  static ThemeData get dark {
    return _build(
      brightness: Brightness.dark,
      scaffoldBg: AppColorsDark.scaffoldBg,
      surfaceBg: AppColorsDark.surfaceBg,
      cardBg: AppColorsDark.cardBg,
      primary: AppColorsDark.primary,
      primaryLight: AppColorsDark.primaryLight,
      textPrimary: AppColorsDark.textPrimary,
      textSecondary: AppColorsDark.textSecondary,
      textMuted: AppColorsDark.textMuted,
      borderDefault: AppColorsDark.borderDefault,
      success: AppColorsDark.success,
      error: AppColorsDark.error,
      warning: AppColorsDark.warning,
      statusBarBrightness: Brightness.dark,
      navIconColor: AppColorsDark.textMuted,
      navSelectedColor: AppColorsDark.primaryLight,
    );
  }

  // ── LIGHT ─────────────────────────────────────────────────────────────────
  static ThemeData get light {
    return _build(
      brightness: Brightness.light,
      scaffoldBg: AppColorsLight.scaffoldBg,
      surfaceBg: AppColorsLight.surfaceBg,
      cardBg: AppColorsLight.cardBg,
      primary: AppColorsLight.primary,
      primaryLight: AppColorsLight.primaryLight,
      textPrimary: AppColorsLight.textPrimary,
      textSecondary: AppColorsLight.textSecondary,
      textMuted: AppColorsLight.textMuted,
      borderDefault: AppColorsLight.borderDefault,
      success: AppColorsLight.success,
      error: AppColorsLight.error,
      warning: AppColorsLight.warning,
      statusBarBrightness: Brightness.light,
      navIconColor: AppColorsLight.textMuted,
      navSelectedColor: AppColorsLight.primary,
    );
  }

  // ── SHARED BUILDER ────────────────────────────────────────────────────────
  static ThemeData _build({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surfaceBg,
    required Color cardBg,
    required Color primary,
    required Color primaryLight,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color borderDefault,
    required Color success,
    required Color error,
    required Color warning,
    required Brightness statusBarBrightness,
    required Color navIconColor,
    required Color navSelectedColor,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // ── Colour scheme ──────────────────────────────────────────────────
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight.withOpacity(0.2),
        onPrimaryContainer: primaryLight,
        secondary: primaryLight,
        onSecondary: Colors.white,
        secondaryContainer: primaryLight.withOpacity(0.15),
        onSecondaryContainer: primaryLight,
        tertiary: AppColorsDark.palettes[2][0], // teal accent
        onTertiary: Colors.white,
        error: error,
        onError: Colors.white,
        surface: surfaceBg,
        onSurface: textPrimary,
        onSurfaceVariant: textMuted,
        outline: borderDefault,
        outlineVariant: borderDefault.withOpacity(0.5),
        shadow: Colors.black,
        scrim: Colors.black54,
      ),

      scaffoldBackgroundColor: scaffoldBg,

      // ── Typography ────────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: textPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: textPrimary),
        headlineLarge: AppTextStyles.headingLarge.copyWith(color: textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: textPrimary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: textSecondary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textSecondary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: textMuted),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: textSecondary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: textMuted),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: textMuted),
      ),

      // ── AppBar ────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: statusBarBrightness,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),

      // ── Bottom Navigation ─────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColorsDark.navBarBg : AppColorsLight.navBarBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: primary.withOpacity(0.15),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: navSelectedColor, size: 22);
          }
          return IconThemeData(color: navIconColor, size: 22);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.labelSmall.copyWith(
              color: navSelectedColor,
              fontWeight: FontWeight.w700,
            );
          }
          return AppTextStyles.labelSmall.copyWith(color: navIconColor);
        }),
      ),

      // ── Cards ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderDefault, width: 1),
        ),
        margin: const EdgeInsets.all(0),
      ),

      // ── Input fields ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: textMuted),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: textMuted),
        errorStyle: AppTextStyles.labelSmall.copyWith(color: error),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 48), // 48dp min touch target (§5.3)
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textSecondary,
          side: BorderSide(color: borderDefault),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: AppTextStyles.button,
          minimumSize: const Size(0, 48),
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.05),
        selectedColor: primary.withOpacity(0.2),
        labelStyle: AppTextStyles.labelMedium.copyWith(color: textSecondary),
        side: BorderSide(color: borderDefault),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: borderDefault,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? const Color(0xFF1E2130) : const Color(0xFF1E293B),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        actionTextColor: primaryLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(color: textPrimary),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
      ),

      // ── BottomSheet ───────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: cardBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: isDark
            ? Colors.white.withOpacity(0.15)
            : Colors.black.withOpacity(0.15),
      ),

      // ── FloatingActionButton ──────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Tooltip ───────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2D3E) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Switch ────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? Colors.white : textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) =>
            s.contains(WidgetState.selected) ? primary : borderDefault),
      ),

      // ── Tab bar ───────────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textMuted,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicatorColor: primary,
        dividerColor: Colors.transparent,
      ),
    );
  }
}

/// Extension to access AppColors from ThemeData without BuildContext.
extension ThemeDataX on ThemeData {
  AppColors get appColors =>
      brightness == Brightness.dark ? AppColors.dark : AppColors.light;
}
