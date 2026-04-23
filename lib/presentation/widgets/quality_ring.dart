// lib/presentation/widgets/quality_ring.dart
//
// Circular SVG-style quality score gauge matching the JSX QualityRing.
// Used on school cards and the result panel.

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class QualityRing extends StatelessWidget {
  final int? score;       // 0-100, null = not yet generated
  final double size;
  final List<Color>? palette; // optional override for card palette colour

  const QualityRing({
    super.key,
    required this.score,
    this.size = 52,
    this.palette,
  });

  Color _ringColor(AppColors colors) {
    if (score == null) return colors.textDisabled;
    if (score! >= 90) return colors.success;
    if (score! >= 75) return colors.warning;
    if (score! >= 50) return colors.primary;
    return colors.error;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color  = _ringColor(colors);

    return CustomPaint(
      size: Size(size, size),
      painter: _RingPainter(
        score: score,
        ringColor: color,
        trackColor: colors.borderDefault,
        strokeWidth: 5.5,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: score != null
              ? Text(
                  '$score',
                  style: AppTextStyles.numericSmall.copyWith(color: color),
                )
              : Text('—',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: colors.textDisabled)),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final int? score;
  final Color ringColor;
  final Color trackColor;
  final double strokeWidth;

  const _RingPainter({
    required this.score,
    required this.ringColor,
    required this.trackColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx     = size.width / 2;
    final cy     = size.height / 2;
    final radius = (size.width - strokeWidth) / 2;
    final rect   = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    // Track
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );

    // Arc
    if (score != null && score! > 0) {
      final sweep = 2 * pi * (score! / 100);
      canvas.drawArc(
        rect,
        -pi / 2,
        sweep,
        false,
        Paint()
          ..color = ringColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.score != score || old.ringColor != ringColor;
}
