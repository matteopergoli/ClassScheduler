// lib/presentation/schedule/result_panel.dart
//
// FR-GEN-03 / §8.4.2 — Result panel shown after generation completes.
//
// Displays:
//   (a) Status banner: Perfect (green) / Soft violations (amber) /
//       Hard violations (red)
//   (b) Quality Score gauge (0–100)
//   (c) F1 teacher free hours, F2 subject changes
//   (d) Hard and soft violation lists with plain-language descriptions
//       and corrective suggestions
//   (e) Computation time + iterations completed

import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/scheduler/scheduler_input.dart';
import '../../l10n/generated/app_localizations.dart';

class ResultPanel extends StatelessWidget {
  final ScheduleResult    result;
  final AppColors         colors;
  final AppLocalizations  l10n;
  final VoidCallback      onDismiss;

  const ResultPanel({
    super.key,
    required this.result,
    required this.colors,
    required this.l10n,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isHard    = result.status == ResultStatus.hardViolations;
    final isSoft    = result.status == ResultStatus.softViolationsOnly;
    final isPerfect = result.status == ResultStatus.perfect;

    final bannerColor = isPerfect
        ? colors.success
        : isSoft
            ? colors.warning
            : colors.error;
    final bannerBg = bannerColor.withOpacity(0.10);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: bannerBg,
          border: Border.all(color: bannerColor.withOpacity(0.30)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(children: [
                Icon(
                  isPerfect
                      ? Icons.check_circle_outline_rounded
                      : isSoft
                          ? Icons.warning_amber_rounded
                          : Icons.error_outline_rounded,
                  color: bannerColor, size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isPerfect
                        ? l10n.resultPerfect
                        : isSoft
                            ? l10n.resultSoftViolations(
                                result.softViolations.length)
                            : l10n.resultHardViolations(
                                result.hardViolations.length),
                    style: AppTextStyles.labelMedium
                        .copyWith(color: bannerColor),
                  ),
                ),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(Icons.close_rounded,
                      size: 18, color: colors.textMuted),
                ),
              ]),
            ),

            // ── Stats row: quality score + F1/F2 ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(children: [
                // Quality gauge
                _QualityGauge(
                  score:  result.qualityScore,
                  color:  bannerColor,
                  colors: colors,
                ),
                const SizedBox(width: 16),
                // F1 / F2 / time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatRow(
                        icon:   Icons.person_outline_rounded,
                        label:  l10n.teacherFreeHours,
                        value:  '${result.teacherFreeHours}',
                        colors: colors,
                      ),
                      const SizedBox(height: 4),
                      _StatRow(
                        icon:   Icons.swap_horiz_rounded,
                        label:  l10n.subjectChanges,
                        value:  '${result.subjectChanges}',
                        colors: colors,
                      ),
                      const SizedBox(height: 4),
                      _StatRow(
                        icon:   Icons.timer_outlined,
                        label:  l10n.computationTime,
                        value:  _formatDuration(result.computationTime),
                        colors: colors,
                      ),
                      if (result.restartsUsed > 0) ...[
                        const SizedBox(height: 4),
                        _StatRow(
                          icon:   Icons.refresh_rounded,
                          label:  l10n.restartsUsed,
                          value:  '${result.restartsUsed}',
                          colors: colors,
                        ),
                      ],
                      if (result.isCancelled) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          Icon(Icons.cancel_outlined,
                              size: 14, color: colors.warning),
                          const SizedBox(width: 4),
                          Text(l10n.generationCancelled,
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: colors.warning)),
                        ]),
                      ],
                    ],
                  ),
                ),
              ]),
            ),

            // ── Hard violations list ──────────────────────────────────
            if (result.hardViolations.isNotEmpty)
              _ViolationList(
                violations: result.hardViolations,
                isHard:     true,
                colors:     colors,
                l10n:       l10n,
              ),

            // ── Soft violations list ──────────────────────────────────
            if (result.softViolations.isNotEmpty)
              _ViolationList(
                violations: result.softViolations,
                isHard:     false,
                colors:     colors,
                l10n:       l10n,
              ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.inSeconds < 1) return '${d.inMilliseconds}ms';
    return '${d.inSeconds}.${(d.inMilliseconds % 1000) ~/ 100}s';
  }
}

// ── Quality gauge ─────────────────────────────────────────────────────────

class _QualityGauge extends StatelessWidget {
  final int       score;
  final Color     color;
  final AppColors colors;

  const _QualityGauge({
    required this.score,
    required this.color,
    required this.colors,
  });

  String get _label {
    if (score >= 90) return 'Excellent';
    if (score >= 75) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) => Tooltip(
    message: 'Higher scores mean fewer teacher gaps '
             'and fewer subject changes per day.',
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 64, height: 64,
          child: Stack(alignment: Alignment.center, children: [
            // Background ring
            CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 6,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                  color.withOpacity(0.12)),
            ),
            // Score ring
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100.0),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => CircularProgressIndicator(
                value: v,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            // Score text
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('$score',
                  style: AppTextStyles.titleMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                      height: 1.0)),
              Text('/100',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: colors.textMuted,
                      fontSize: 9)),
            ]),
          ]),
        ),
        const SizedBox(height: 4),
        Text(_label,
            style: AppTextStyles.labelSmall
                .copyWith(color: color)),
      ],
    ),
  );
}

// ── Stat row ──────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String   label;
  final String   value;
  final AppColors colors;

  const _StatRow({
    required this.icon,   required this.label,
    required this.value,  required this.colors,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 13, color: colors.textMuted),
    const SizedBox(width: 5),
    Text(label,
        style: AppTextStyles.labelSmall
            .copyWith(color: colors.textMuted)),
    const SizedBox(width: 4),
    Text(value,
        style: AppTextStyles.labelSmall.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700)),
  ]);
}

// ── Violation list ────────────────────────────────────────────────────────

class _ViolationList extends StatefulWidget {
  final List<ConstraintViolation> violations;
  final bool                      isHard;
  final AppColors                 colors;
  final AppLocalizations          l10n;

  const _ViolationList({
    required this.violations, required this.isHard,
    required this.colors,     required this.l10n,
  });

  @override
  State<_ViolationList> createState() => _ViolationListState();
}

class _ViolationListState extends State<_ViolationList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.isHard
        ? widget.colors.error
        : widget.colors.warning;
    final count  = widget.violations.length;
    final shown  = _expanded ? widget.violations : widget.violations.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Divider
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
          child: Divider(
              color: accent.withOpacity(0.20), height: 1),
        ),
        // Section heading
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
          child: Text(
            widget.isHard
                ? widget.l10n.hardViolationsHeading(count)
                : widget.l10n.softViolationsHeading(count),
            style: AppTextStyles.labelSmall
                .copyWith(color: accent, fontWeight: FontWeight.w700),
          ),
        ),
        // Violation rows
        ...shown.map((v) => Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                widget.isHard
                    ? Icons.error_outline_rounded
                    : Icons.info_outline_rounded,
                size: 14, color: accent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('[${v.constraintId}] ${v.description}',
                        style: AppTextStyles.bodySmall.copyWith(
                            color: widget.colors.textPrimary)),
                    if (v.suggestion != null) ...[
                      const SizedBox(height: 2),
                      Text('→ ${v.suggestion}',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: widget.colors.textMuted)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )),
        // Show more / less
        if (count > 2)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
              child: Text(
                _expanded
                    ? widget.l10n.showLess
                    : widget.l10n.showMore(count - 2),
                style: AppTextStyles.labelSmall.copyWith(
                    color: accent,
                    decoration: TextDecoration.underline),
              ),
            ),
          ),
      ],
    );
  }
}
