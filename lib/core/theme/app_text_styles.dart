// lib/core/theme/app_text_styles.dart
//
// Typography using GoogleFonts (downloaded automatically — no local TTF files needed).
// DM Sans for UI/body text, Playfair Display for headings.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTextStyles {
  // ── Playfair Display ──────────────────────────────────────────────────────

  static TextStyle get displayLarge => GoogleFonts.playfairDisplay(
    fontSize: 32, fontWeight: FontWeight.w900,
    height: 1.1, letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => GoogleFonts.playfairDisplay(
    fontSize: 26, fontWeight: FontWeight.w800, height: 1.15,
  );

  static TextStyle get headingLarge => GoogleFonts.playfairDisplay(
    fontSize: 22, fontWeight: FontWeight.w700, height: 1.2,
  );

  // ── DM Sans ───────────────────────────────────────────────────────────────

  static TextStyle get titleMedium => GoogleFonts.dmSans(
    fontSize: 18, fontWeight: FontWeight.w700, height: 1.3,
  );

  static TextStyle get titleSmall => GoogleFonts.dmSans(
    fontSize: 15, fontWeight: FontWeight.w600, height: 1.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
    fontSize: 14, fontWeight: FontWeight.w500, height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w400, height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w400, height: 1.5,
  );

  static TextStyle get labelLarge => GoogleFonts.dmSans(
    fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.04,
  );

  static TextStyle get labelMedium => GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.04,
  );

  static TextStyle get labelSmall => GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.08,
  );

  static TextStyle get overline => GoogleFonts.dmSans(
    fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.10,
  );

  static TextStyle get numericDisplay => GoogleFonts.dmSans(
    fontSize: 26, fontWeight: FontWeight.w900,
    letterSpacing: -0.5, height: 1.0,
  );

  static TextStyle get numericSmall => GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w700, height: 1.0,
  );

  static TextStyle get button => GoogleFonts.dmSans(
    fontSize: 13, fontWeight: FontWeight.w700,
    letterSpacing: 0.02, height: 1.2,
  );

  static TextStyle get buttonSmall => GoogleFonts.dmSans(
    fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.02,
  );
}
