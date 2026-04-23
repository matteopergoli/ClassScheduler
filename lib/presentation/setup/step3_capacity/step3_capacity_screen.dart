// lib/presentation/setup/step3_capacity/step3_capacity_screen.dart
//
// FR-TS-04: Per-classroom, per-day lesson slot configuration.
//
// Each lesson cell is independently toggleable — active or blocked —
// supporting gaps anywhere in the day (beginning, middle, end).
// The state is stored as DayCapacityModel.activeSlots: List<int>,
// a sorted list of 0-based lesson-slot indices that are available.
//
// "Apply to all days" copies the exact activeSlots of the tapped day
// to every other active day for the same classroom.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_models.dart';
import '../../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../setup_screen.dart';
import '../step1_periods/step1_periods_screen.dart';
import '../step2_classrooms/step2_classrooms_screen.dart';

// ── Providers ────────────────────────────────────────────────────────────────

final _periodsStreamProvider =
    StreamProvider.family<List<PeriodModel>, String>((ref, schoolId) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return PeriodRepository(uid: uid, schoolId: schoolId).watchAll();
});

final _dayCapacitiesStreamProvider =
    StreamProvider.family<List<DayCapacityModel>, String>((ref, schoolId) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return DayCapacityRepository(uid: uid, schoolId: schoolId).watchAll();
});

// ── Screen ───────────────────────────────────────────────────────────────────

class Step3CapacityScreen extends ConsumerWidget {
  const Step3CapacityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n       = AppLocalizations.of(context);
    final colors     = AppColors.of(context);
    final school     = ref.watch(activeSchoolProvider);
    final activeDays = ref.watch(activeDaysProvider);
    if (school == null) return const SizedBox.shrink();

    final classroomsAsync = ref.watch(classroomsStreamProvider(school.id));
    final capacitiesAsync = ref.watch(_dayCapacitiesStreamProvider(school.id));
    final periodsAsync    = ref.watch(_periodsStreamProvider(school.id));

    return periodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (periods) {
        final lessonPeriods = periods
            .where((p) => p.type == PeriodType.lesson)
            .toList();

        return ListView(
          padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenPadH, vertical: 16),
          children: [
            _InfoBanner(colors: colors, l10n: l10n),
            const SizedBox(height: 16),

            classroomsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(e.toString()),
              data: (classrooms) => capacitiesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(e.toString()),
                data: (capacities) {
                  // Build lookup: classroomId -> dayCode -> DayCapacityModel
                  final lookup = <String, Map<String, DayCapacityModel>>{};
                  for (final c in capacities) {
                    lookup.putIfAbsent(c.classroomId, () => {})[c.dayOfWeek] = c;
                  }

                  return Column(
                    children: [
                      ...classrooms.map((classroom) => _ClassroomGrid(
                            classroom:     classroom,
                            activeDays:    activeDays,
                            allPeriods:    periods,
                            lessonPeriods: lessonPeriods,
                            capacities:    lookup[classroom.id] ?? {},
                            colors:        colors,
                            l10n:          l10n,
                            onToggle: (day, newSlots) async {
                              final uid = ref.read(currentUserProvider)!.uid;
                              await DayCapacityRepository(
                                      uid: uid, schoolId: school.id)
                                  .set(
                                classroomId: classroom.id,
                                dayOfWeek:   day,
                                activeSlots: newSlots,
                              );
                            },
                            onApplyToAllDays: (slots) async {
                              final uid = ref.read(currentUserProvider)!.uid;
                              await DayCapacityRepository(
                                      uid: uid, schoolId: school.id)
                                  .setAll(
                                classroomId: classroom.id,
                                dayToSlots: {
                                  for (final d in activeDays) d: slots,
                                },
                              );
                            },
                          )),
                      const SizedBox(height: 8),
                      _Legend(colors: colors),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Info banner ───────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.colors, required this.l10n});
  final AppColors        colors;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color:        colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border:       Border.all(color: colors.primary.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 15, color: colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.step3Description,
              style: AppTextStyles.bodySmall.copyWith(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Classroom grid card ───────────────────────────────────────────────────────

class _ClassroomGrid extends StatelessWidget {
  const _ClassroomGrid({
    required this.classroom,
    required this.activeDays,
    required this.allPeriods,
    required this.lessonPeriods,
    required this.capacities,
    required this.colors,
    required this.l10n,
    required this.onToggle,
    required this.onApplyToAllDays,
  });

  final ClassroomModel                      classroom;
  final List<String>                        activeDays;
  final List<PeriodModel>                   allPeriods;
  final List<PeriodModel>                   lessonPeriods;
  final Map<String, DayCapacityModel>       capacities;
  final AppColors                           colors;
  final AppLocalizations                    l10n;
  final Future<void> Function(String day, List<int> newSlots) onToggle;
  final Future<void> Function(List<int> slots)                 onApplyToAllDays;

  Map<String, String> get _dayLabels => {
    DayCode.mon: l10n.monShort,
    DayCode.tue: l10n.tueShort,
    DayCode.wed: l10n.wedShort,
    DayCode.thu: l10n.thuShort,
    DayCode.fri: l10n.friShort,
    DayCode.sat: l10n.satShort,
    DayCode.sun: l10n.sunShort,
  };

  @override
  Widget build(BuildContext context) {
    final totalLesson = lessonPeriods.length;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.cardGap),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        colors.cardBg,
        border:       Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(classroom.name,
              style: AppTextStyles.titleSmall
                  .copyWith(color: colors.textPrimary)),
          const SizedBox(height: 14),

          ...activeDays.asMap().entries.map((entry) {
            final isLast = entry.key == activeDays.length - 1;
            final day    = entry.value;

            // Active slots for this day — default: all lesson slots active.
            final model     = capacities[day];
            final rawSlots  = model?.activeSlots ??
                List<int>.generate(totalLesson, (i) => i);
            // Clamp to valid range and sort.
            final safeSlots = rawSlots
                .where((i) => i >= 0 && i < totalLesson)
                .toList()
              ..sort();

            return Column(
              children: [
                _DayRow(
                  label:            _dayLabels[day] ?? day,
                  allPeriods:       allPeriods,
                  lessonPeriods:    lessonPeriods,
                  activeSlots:      safeSlots,
                  totalLessonSlots: totalLesson,
                  colors:           colors,
                  onToggle: (newSlots) => onToggle(day, newSlots),
                  onApplyToAllDays: () => onApplyToAllDays(safeSlots),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      thickness: 0.5,
                      color: colors.borderSubtle),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ── Day row ───────────────────────────────────────────────────────────────────
//
// StatefulWidget so that _activeSet — the local copy of which slots are on —
// is shared by both the slot track and the hour counter in the same row.
// This ensures the counter updates instantly on tap, not only after the
// Firestore stream confirms the write.

class _DayRow extends StatefulWidget {
  const _DayRow({
    required this.label,
    required this.allPeriods,
    required this.lessonPeriods,
    required this.activeSlots,
    required this.totalLessonSlots,
    required this.colors,
    required this.onToggle,
    required this.onApplyToAllDays,
  });

  final String                            label;
  final List<PeriodModel>                 allPeriods;
  final List<PeriodModel>                 lessonPeriods;
  final List<int>                         activeSlots;
  final int                               totalLessonSlots;
  final AppColors                         colors;
  final void Function(List<int> newSlots) onToggle;
  final VoidCallback                      onApplyToAllDays;

  @override
  State<_DayRow> createState() => _DayRowState();
}

class _DayRowState extends State<_DayRow> {
  late Set<int> _activeSet;

  @override
  void initState() {
    super.initState();
    _activeSet = widget.activeSlots.toSet();
  }

  @override
  void didUpdateWidget(_DayRow old) {
    super.didUpdateWidget(old);
    // Sync from Firestore stream only when the value genuinely changed.
    // Avoids overwriting an optimistic tap that hasn't been confirmed yet.
    if (!_setsEqual(old.activeSlots.toSet(), widget.activeSlots.toSet())) {
      setState(() => _activeSet = widget.activeSlots.toSet());
    }
  }

  bool _setsEqual(Set<int> a, Set<int> b) =>
      a.length == b.length && a.containsAll(b);

  void _toggle(int index) {
    final updated = Set<int>.from(_activeSet);
    if (_activeSet.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    final sorted = updated.toList()..sort();
    setState(() => _activeSet = updated);
    widget.onToggle(sorted);
  }

  @override
  Widget build(BuildContext context) {
    final count  = _activeSet.length;
    final isFull = count == widget.totalLessonSlots;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(widget.label,
                style: AppTextStyles.labelSmall
                    .copyWith(color: widget.colors.textMuted)),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _SlotTrack(
              allPeriods:  widget.allPeriods,
              activeSet:   _activeSet,
              colors:      widget.colors,
              onToggle:    _toggle,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 28,
            child: Text(
              '${count}h',
              textAlign: TextAlign.right,
              style: AppTextStyles.labelSmall.copyWith(
                color:      isFull ? widget.colors.primary : widget.colors.textMuted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 2),
          _RowMenu(
            colors:          widget.colors,
            onApplyToAllDays: widget.onApplyToAllDays,
          ),
        ],
      ),
    );
  }
}

// ── Slot track ────────────────────────────────────────────────────────────────
//
// Pure StatelessWidget — receives the live activeSet from _DayRowState
// and a per-index toggle callback. No local state needed here.

class _SlotTrack extends StatelessWidget {
  const _SlotTrack({
    required this.allPeriods,
    required this.activeSet,
    required this.colors,
    required this.onToggle,
  });

  final List<PeriodModel>      allPeriods;
  final Set<int>               activeSet;   // owned by _DayRowState
  final AppColors              colors;
  final void Function(int idx) onToggle;    // toggles a single index

  @override
  Widget build(BuildContext context) {
    int lessonIndex = 0;

    return Row(
      children: allPeriods.asMap().entries.map((entry) {
        final i      = entry.key;
        final period = entry.value;
        final isLast = i == allPeriods.length - 1;

        if (period.type == PeriodType.breakSlot) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: isLast ? 0 : 3),
              child: _SlotCell(
                isBreak:  true,
                isActive: false,
                colors:   colors,
                onTap:    null,
              ),
            ),
          );
        }

        final myIndex  = lessonIndex++;
        final isActive = activeSet.contains(myIndex);

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 3),
            child: Tooltip(
              message:      '${period.startTime}\u2013${period.endTime}',
              waitDuration: const Duration(milliseconds: 500),
              child: _SlotCell(
                isBreak:  false,
                isActive: isActive,
                colors:   colors,
                onTap:    () => onToggle(myIndex),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Slot cell ─────────────────────────────────────────────────────────────────

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.isBreak,
    required this.isActive,
    required this.colors,
    required this.onTap,
  });

  final bool          isBreak;
  final bool          isActive;
  final AppColors     colors;
  final VoidCallback? onTap;

  Color get _bg {
    if (isBreak)  return colors.warning.withOpacity(0.22);
    if (isActive) return colors.primary.withOpacity(0.28);
    return colors.borderSubtle;
  }

  Color get _border {
    if (isBreak)  return colors.warning.withOpacity(0.35);
    if (isActive) return colors.primary.withOpacity(0.45);
    return colors.borderDefault;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        curve:    Curves.easeOut,
        height:   20,
        decoration: BoxDecoration(
          color:        _bg,
          borderRadius: BorderRadius.circular(3),
          border:       Border.all(color: _border, width: 0.5),
        ),
      ),
    );
  }
}

// ── Row menu ──────────────────────────────────────────────────────────────────

class _RowMenu extends StatelessWidget {
  const _RowMenu({required this.colors, required this.onApplyToAllDays});
  final AppColors    colors;
  final VoidCallback onApplyToAllDays;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28, height: 28,
      child: PopupMenuButton<String>(
        padding:  EdgeInsets.zero,
        iconSize: 16,
        icon: Icon(Icons.more_vert, size: 16, color: colors.textDisabled),
        onSelected: (v) {
          if (v == 'apply_all') onApplyToAllDays();
        },
        itemBuilder: (ctx) {
          final l10n = AppLocalizations.of(ctx);
          return [
            PopupMenuItem(
              value: 'apply_all',
              child: Text(l10n.step3ApplyToAllDays,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textPrimary)),
            ),
          ];
        },
      ),
    );
  }
}

// ── Legend ────────────────────────────────────────────────────────────────────

class _Legend extends StatelessWidget {
  const _Legend({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _LegendDot(
          bg:     colors.primary.withOpacity(0.28),
          border: colors.primary.withOpacity(0.45),
          label:  l10n.lessonSlot,
          colors: colors,
        ),
        const SizedBox(width: 14),
        _LegendDot(
          bg:     colors.warning.withOpacity(0.22),
          border: colors.warning.withOpacity(0.35),
          label:  l10n.breakSlot,
          colors: colors,
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.bg,
    required this.border,
    required this.label,
    required this.colors,
  });
  final Color     bg;
  final Color     border;
  final String    label;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(
            color:        bg,
            borderRadius: BorderRadius.circular(2),
            border:       Border.all(color: border, width: 0.5),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: AppTextStyles.labelSmall
                .copyWith(color: colors.textMuted)),
      ],
    );
  }
}
