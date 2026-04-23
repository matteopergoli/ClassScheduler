// lib/core/constants/app_dimensions.dart

/// Layout constants used throughout the app.
abstract class AppDimensions {
  // Spacing
  static const double xs    = 4.0;
  static const double sm    = 8.0;
  static const double md    = 16.0;
  static const double lg    = 24.0;
  static const double xl    = 32.0;
  static const double xxl   = 48.0;

  // Radius
  static const double radiusSm   = 8.0;
  static const double radiusMd   = 12.0;
  static const double radiusLg   = 16.0;
  static const double radiusXl   = 20.0;
  static const double radiusXxl  = 28.0;
  static const double radiusFull = 999.0;

  // Touch targets — 48dp minimum per §5.3 + Material guidelines
  static const double minTouchTarget = 48.0;

  // Card / container
  static const double cardPaddingH = 24.0;
  static const double cardPaddingV = 20.0;
  static const double cardGap      = 14.0;

  // Navigation bar
  static const double navBarHeight = 80.0;

  // Screen horizontal padding
  static const double screenPadH = 20.0;

  // Timetable grid
  static const double gridTimeColWidth  = 52.0;
  static const double gridCellHeight    = 52.0;
  static const double gridCellMinWidth  = 80.0;
  static const double gridHeaderHeight  = 36.0;
  static const double gridBreakRowHeight= 28.0;
  static const double gridRowHeight = 52.0;
  static const double gridColWidth  = 96.0;
}
