// lib/presentation/constraints/slot_range_picker.dart
//
// Visual, tappable slot-range picker for the constraint form — replaces
// the old Start-slot/End-slot dropdowns with a single row of cells in the
// same visual style as Setup → Step 3's per-day slot track
// (step3_capacity_screen.dart's _SlotTrack/_SlotCell), so picking a slot
// range for a rule constraint looks and feels like picking active slots
// there. Deliberately re-styled here rather than shared/imported — that
// file's widgets are private to Setup and the two features can evolve
// independently.
//
// Interaction: tap an enabled cell with nothing selected → selects it
// alone (start == end). Tap a different enabled cell while one is active
// → completes the range from the original tap to this one (order-
// independent), unless a disabled cell falls strictly inside — then the
// tap is ignored so the user can try again. Tapping the sole selected
// cell again clears the selection.

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';

class SlotRangePicker extends StatelessWidget {
  /// All periods (LESSON + BREAK) for the school, sorted by sortOrder.
  final List<PeriodModel> allPeriods;

  /// Currently selected range, in lesson-index space (0-based position
  /// among LESSON-type periods only — the same index space as
  /// DayCapacityModel.activeSlots). Null/null = nothing selected.
  final int? startSlotIdx;
  final int? endSlotIdx;

  /// Lesson indices that can't be tapped (structurally blocked, or — for
  /// MUST_ASSIGN — already claimed by the subject's teacher elsewhere). A
  /// disabled index that is currently part of the selected range is still
  /// shown as selected and stays tappable, so editing an existing
  /// constraint whose slot has since become blocked never locks the form.
  final Set<int> disabledLessonIndices;

  /// Optional per-index reason shown in that cell's tooltip.
  final Map<int, String> disabledReasons;

  final AppColors colors;
  final void Function(int? start, int? end) onRangeChanged;

  const SlotRangePicker({
    super.key,
    required this.allPeriods,
    required this.startSlotIdx,
    required this.endSlotIdx,
    required this.disabledLessonIndices,
    this.disabledReasons = const {},
    required this.colors,
    required this.onRangeChanged,
  });

  void _handleTap(int lessonIdx) {
    final start = startSlotIdx;
    final end   = endSlotIdx;
    if (start == null) {
      onRangeChanged(lessonIdx, lessonIdx);
      return;
    }
    if (start == lessonIdx && end == lessonIdx) {
      onRangeChanged(null, null); // tapping the sole selected cell clears it
      return;
    }
    // Redefine the range from the original anchor (the current start) to
    // this new tap, order-independent.
    final lo = start < lessonIdx ? start : lessonIdx;
    final hi = start < lessonIdx ? lessonIdx : start;
    for (var i = lo; i <= hi; i++) {
      final isCurrentEndpoint = i == start || i == end;
      if (disabledLessonIndices.contains(i) && !isCurrentEndpoint) {
        return; // a disabled cell blocks this range — ignore the tap
      }
    }
    onRangeChanged(lo, hi);
  }

  /// The selected range's actual time, e.g. "09:00–11:00" — kept on screen
  /// for as long as a selection exists (not just briefly after tapping),
  /// since the cells alone don't show which hours they represent.
  String? get _selectionTimeLabel {
    final s = startSlotIdx;
    final e = endSlotIdx;
    if (s == null || e == null) return null;
    final lessons =
        allPeriods.where((p) => p.type != PeriodType.breakSlot).toList();
    if (s >= lessons.length || e >= lessons.length) return null;
    final start = lessons[s];
    final end   = lessons[e];
    return start.id == end.id
        ? '${start.startTime}–${start.endTime}'
        : '${start.startTime}–${end.endTime}';
  }

  @override
  Widget build(BuildContext context) {
    var lessonIndex = 0;
    final hasSelection = startSlotIdx != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: allPeriods.asMap().entries.map((entry) {
            final i      = entry.key;
            final period = entry.value;
            final isLast = i == allPeriods.length - 1;

            if (period.type == PeriodType.breakSlot) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 3),
                  child: _SlotCell(
                    isBreak: true,
                    state:   _CellState.normal,
                    colors:  colors,
                    onTap:   null,
                  ),
                ),
              );
            }

            final myIndex = lessonIndex++;
            final inRange = startSlotIdx != null && endSlotIdx != null &&
                myIndex >= startSlotIdx! && myIndex <= endSlotIdx!;
            final disabled =
                disabledLessonIndices.contains(myIndex) && !inRange;
            final state = inRange
                ? _CellState.selected
                : disabled
                    ? _CellState.disabled
                    : _CellState.normal;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: isLast ? 0 : 3),
                child: Tooltip(
                  message: disabled
                      ? (disabledReasons[myIndex] ?? 'Not available')
                      : '${period.startTime}–${period.endTime}',
                  waitDuration: const Duration(milliseconds: 500),
                  child: _SlotCell(
                    isBreak: false,
                    state:   state,
                    colors:  colors,
                    onTap:   disabled ? null : () => _handleTap(myIndex),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        if (hasSelection) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectionTimeLabel ?? '',
                style: AppTextStyles.labelSmall.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              GestureDetector(
                onTap: () => onRangeChanged(null, null),
                child: Text(
                  'Clear',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colors.textMuted,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

enum _CellState { normal, selected, disabled }

// ── Slot cell ─────────────────────────────────────────────────────────────
// Same sizing/animation/color-opacity pattern as Step 3's _SlotCell, plus a
// third (disabled) visual state Step 3 doesn't need.

class _SlotCell extends StatelessWidget {
  const _SlotCell({
    required this.isBreak,
    required this.state,
    required this.colors,
    required this.onTap,
  });

  final bool          isBreak;
  final _CellState    state;
  final AppColors     colors;
  final VoidCallback? onTap;

  Color get _bg {
    if (isBreak) return colors.warning.withOpacity(0.22);
    switch (state) {
      case _CellState.selected: return colors.primary.withOpacity(0.28);
      case _CellState.disabled: return colors.textDisabled.withOpacity(0.15);
      case _CellState.normal:   return colors.borderSubtle;
    }
  }

  Color get _border {
    if (isBreak) return colors.warning.withOpacity(0.35);
    switch (state) {
      case _CellState.selected: return colors.primary.withOpacity(0.45);
      case _CellState.disabled: return colors.textDisabled.withOpacity(0.35);
      case _CellState.normal:   return colors.borderDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        curve:    Curves.easeOut,
        height:   28,
        decoration: BoxDecoration(
          color:        _bg,
          borderRadius: BorderRadius.circular(4),
          border:       Border.all(color: _border, width: 0.5),
        ),
      ),
    );
  }
}
