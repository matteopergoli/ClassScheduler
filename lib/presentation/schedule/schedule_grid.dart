// lib/presentation/schedule/schedule_grid.dart
//
// FR-VIEW-01..05: Timetable grid.
//   - Rows = periods (LESSON slots + shaded non-interactive BREAK rows)
//   - Columns = classrooms (horizontal scroll)
//   - Day tabs at top
//   - Subject cells colour-coded; tap for detail popup (FR-VIEW-02)
//   - Hard-violation cells outlined in red + warning icon (FR-GEN-04)
//   - Drag-and-drop with live HC validation (FR-VIEW-04)
//   - View modes: All Classrooms | Single Classroom | Per Teacher

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/subject_repositories.dart';
import '../../domain/scheduler/drag_drop_validator.dart';
import '../../l10n/generated/app_localizations.dart';
import 'schedule_screen.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final _cellsProvider = StreamProvider.family<List<ScheduleCellModel>, String>(
  (ref, scheduleId) => ref
      .watch(scheduleRepositoryProvider(scheduleId.split('::').first))
      .watchCells(scheduleId.split('::').last),
);

// ── Grid ───────────────────────────────────────────────────────────────────

class ScheduleGrid extends ConsumerStatefulWidget {
  final String scheduleId;
  final String schoolId;
  final ScheduleViewMode viewMode;

  const ScheduleGrid({
    super.key,
    required this.scheduleId,
    required this.schoolId,
    required this.viewMode,
  });

  @override
  ConsumerState<ScheduleGrid> createState() => _ScheduleGridState();
}

class _ScheduleGridState extends ConsumerState<ScheduleGrid> {
  String? _selectedClassroomId;
  String? _selectedTeacherName; // for per-teacher view

  // Drag state
  ScheduleCellModel? _dragging;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final periodsAsync = ref.watch(_periodsProvider(widget.schoolId));
    final classroomsAsync = ref.watch(_classroomsProvider(widget.schoolId));
    final subjectsAsync = ref.watch(_subjectsProvider(widget.schoolId));
    // Key: schoolId::scheduleId so provider family is unique per schedule
    final cellsAsync =
        ref.watch(_cellsProvider('${widget.schoolId}::${widget.scheduleId}'));

    return periodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (periods) => classroomsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (classrooms) => subjectsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (subjects) => cellsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (cells) {
              // Derive active days from periods
              final lessonPeriods = periods
                  .where((p) => p.type == 'LESSON')
                  .toList()
                ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

              // Update tab count if needed
              if (_selectedClassroomId == null && classrooms.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() => _selectedClassroomId = classrooms.first.id);
                  }
                });
              }

              final selectedClassroom = classrooms.firstWhere(
                (c) => c.id == _selectedClassroomId,
                orElse: () => classrooms.first,
              );
              final activeDays = _deriveActiveDays(periods);

              return Column(children: [
                // ── Classroom tabs ────────────────────────────────
                _ClassroomSelector(
                  classrooms: classrooms,
                  selected: selectedClassroom.id,
                  colors: colors,
                  onSelect: (id) => setState(() => _selectedClassroomId = id),
                ),
                if (widget.viewMode == ScheduleViewMode.perTeacher)
                  _TeacherSelector(
                    subjects: subjects,
                    selected: _selectedTeacherName,
                    colors: colors,
                    onSelect: (name) =>
                        setState(() => _selectedTeacherName = name),
                  ),
                // ── Grid body ─────────────────────────────────────
                Expanded(
                  child: _GridBody(
                    classroom: selectedClassroom,
                    activeDays: activeDays,
                    periods: periods,
                    lessonPeriods: lessonPeriods,
                    subjects: subjects,
                    cells: cells,
                    scheduleId: widget.scheduleId,
                    schoolId: widget.schoolId,
                    dragging: _dragging,
                    onDragStart: (c) => setState(() => _dragging = c),
                    onDragEnd: () => setState(() => _dragging = null),
                    colors: colors,
                    l10n: l10n,
                  ),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  List<String> _deriveActiveDays(List<PeriodModel> periods) {
    const ordered = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final found = <String>{};
    for (final p in periods) {
      if (p.dayApplicability != null) {
        found.addAll(p.dayApplicability!);
      }
    }
    final active = ordered.where((d) => found.isEmpty || found.contains(d));
    return found.isEmpty
        ? ['MON', 'TUE', 'WED', 'THU', 'FRI']
        : active.toList();
  }
}

// ── Classroom selector (single-classroom mode) ────────────────────────────

class _ClassroomSelector extends StatelessWidget {
  final List<ClassroomModel> classrooms;
  final String? selected;
  final AppColors colors;
  final ValueChanged<String> onSelect;

  const _ClassroomSelector({
    required this.classrooms,
    required this.selected,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: classrooms.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final c = classrooms[i];
            final active = c.id == selected;
            return GestureDetector(
              onTap: () => onSelect(c.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active
                      ? colors.primary.withOpacity(0.15)
                      : colors.surfaceVariant,
                  border: Border.all(
                      color: active ? colors.primary : colors.borderDefault),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c.name,
                    style: AppTextStyles.labelMedium.copyWith(
                        color: active ? colors.primary : colors.textMuted)),
              ),
            );
          },
        ),
      );
}

// ── Teacher selector (per-teacher mode) ──────────────────────────────────

class _TeacherSelector extends StatelessWidget {
  final List<SubjectModel> subjects;
  final String? selected;
  final AppColors colors;
  final ValueChanged<String> onSelect;

  const _TeacherSelector({
    required this.subjects,
    required this.selected,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final teachers = subjects.map((s) => s.teacherName).toSet().toList()
      ..sort();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: teachers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final t = teachers[i];
          final active = t == selected;
          return GestureDetector(
            onTap: () => onSelect(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? colors.primaryLight.withOpacity(0.15)
                    : colors.surfaceVariant,
                border: Border.all(
                    color: active ? colors.primaryLight : colors.borderDefault),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(t,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: active ? colors.primaryLight : colors.textMuted)),
            ),
          );
        },
      ),
    );
  }
}

// ── Grid body ─────────────────────────────────────────────────────────────

class _GridBody extends ConsumerWidget {
  final ClassroomModel classroom;
  final List<String> activeDays;
  final List<PeriodModel> periods;
  final List<PeriodModel> lessonPeriods;
  final List<SubjectModel> subjects;
  final List<ScheduleCellModel> cells;
  final String scheduleId;
  final String schoolId;
  final ScheduleCellModel? dragging;
  final ValueChanged<ScheduleCellModel> onDragStart;
  final VoidCallback onDragEnd;
  final AppColors colors;
  final AppLocalizations l10n;

  const _GridBody({
    required this.classroom,
    required this.activeDays,
    required this.periods,
    required this.lessonPeriods,
    required this.subjects,
    required this.cells,
    required this.scheduleId,
    required this.schoolId,
    required this.dragging,
    required this.onDragStart,
    required this.onDragEnd,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectById = {for (final s in subjects) s.id: s};

    // Index cells: dayCode → periodId → cell for the selected classroom
    final cellIndex = <String, Map<String, ScheduleCellModel>>{};
    for (final cell in cells) {
      if (cell.classroomId != classroom.id) continue;
      final dayCode = _dayCodeFromCellId(cell.id);
      cellIndex.putIfAbsent(dayCode, () => {})[cell.periodId] = cell;
    }

    const rowH = AppDimensions.gridRowHeight;
    const colW = AppDimensions.gridColWidth;
    const timeW = 52.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Day header row ────────────────────────────────
              Row(children: [
                const SizedBox(width: timeW),
                ...activeDays.map((day) => SizedBox(
                      width: colW,
                      child: Center(
                        child: Text(_dayLabel(day),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: colors.textMuted),
                            overflow: TextOverflow.ellipsis),
                      ),
                    )),
              ]),
              const SizedBox(height: 6),

              // ── Period rows ────────────────────────────────────
              ...periods.map((period) {
                final isBreak = period.type == 'BREAK';
                if (isBreak) {
                  return _BreakRow(
                    period: period,
                    totalWidth: timeW + colW * activeDays.length,
                    colors: colors,
                  );
                }
                return Row(children: [
                  // Time label
                  SizedBox(
                    width: timeW,
                    height: rowH,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(period.startTime,
                            style: AppTextStyles.labelSmall
                                .copyWith(color: colors.textMuted)),
                      ),
                    ),
                  ),
                  // Day cells for the selected classroom
                  ...activeDays.map((day) {
                    final cell = cellIndex[day]?[period.id];
                    if (cell == null) {
                      return _FreeCell(
                          width: colW, height: rowH, colors: colors);
                    }
                    final subject = cell.subjectId != null
                        ? subjectById[cell.subjectId!]
                        : null;
                    return _LessonCell(
                      cell: cell,
                      subject: subject,
                      width: colW,
                      height: rowH,
                      isDragging: dragging?.id == cell.id,
                      colors: colors,
                      onTap: () => _showCellDetail(
                          context, cell, subject, classroom, period, day),
                      onDragStart: () => onDragStart(cell),
                      onDragEnd: onDragEnd,
                      onAccept: (src) => _handleDrop(context, ref, src, cell),
                      dragging: dragging,
                    );
                  }),
                ]);
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _showCellDetail(
    BuildContext context,
    ScheduleCellModel cell,
    SubjectModel? subject,
    ClassroomModel classroom,
    PeriodModel period,
    String day,
  ) {
    if (subject == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(subject.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DetailRow(label: 'Teacher', value: subject.teacherName),
            _DetailRow(label: 'Class', value: classroom.name),
            _DetailRow(label: 'Day', value: _dayLabel(day)),
            _DetailRow(
                label: 'Time', value: '${period.startTime}–${period.endTime}'),
            if (cell.isViolation && cell.violationDescription != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('⚠ ${cell.violationDescription}',
                    style: const TextStyle(color: Colors.red, fontSize: 12)),
              ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }

  String _dayCodeFromCellId(String id) {
    final parts = id.split('_');
    if (parts.length < 3) return 'MON';
    return parts[parts.length - 2];
  }

  String _dayLabel(String code) {
    const labels = {
      'MON': 'Mon',
      'TUE': 'Tue',
      'WED': 'Wed',
      'THU': 'Thu',
      'FRI': 'Fri',
      'SAT': 'Sat',
      'SUN': 'Sun',
    };
    return labels[code] ?? code;
  }

  Future<void> _handleDrop(
    BuildContext context,
    WidgetRef ref,
    ScheduleCellModel source,
    ScheduleCellModel target,
  ) async {
    // Validate
    final repo = ref.read(scheduleRepositoryProvider(schoolId));

    // Build minimal context for validation
    // (In production, pass full classroomSubjects / dayCapacities)
    final result = DragDropValidator.validate(
      sourceCell: source,
      targetCell: target,
      allCells: cells,
      subjects: subjects,
      classroomSubjects: const [],
      dailyCapacities: const [],
      periods: lessonPeriods,
      activeDayCodes: activeDays,
    );

    if (!result.allowed) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.violationMessage ?? 'Move not allowed'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
      return;
    }

    // Both cells occupied → swap
    if (source.subjectId != null && target.subjectId != null) {
      await repo.swapCells(
        scheduleId: scheduleId,
        source: source,
        destination: target,
      );
    } else {
      // Target free → move
      await repo.moveCell(
        scheduleId: scheduleId,
        source: source,
        destinationCellId: target.id,
      );
    }
  }
}

// ── Break row ─────────────────────────────────────────────────────────────

class _BreakRow extends StatelessWidget {
  final PeriodModel period;
  final double totalWidth;
  final AppColors colors;

  const _BreakRow({
    required this.period,
    required this.totalWidth,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: totalWidth,
        height: AppDimensions.gridBreakRowHeight,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: colors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            period.name != null
                ? '${period.name}  ${period.startTime}–${period.endTime}'
                : '${period.startTime}–${period.endTime}',
            style: AppTextStyles.labelSmall.copyWith(color: colors.textMuted),
          ),
        ),
      );
}

// ── Lesson cell ───────────────────────────────────────────────────────────

class _LessonCell extends StatelessWidget {
  final ScheduleCellModel cell;
  final SubjectModel? subject;
  final double width;
  final double height;
  final bool isDragging;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final Function(ScheduleCellModel) onAccept;
  final ScheduleCellModel? dragging;

  const _LessonCell({
    required this.cell,
    required this.subject,
    required this.width,
    required this.height,
    required this.isDragging,
    required this.colors,
    required this.onTap,
    required this.onDragStart,
    required this.onDragEnd,
    required this.onAccept,
    required this.dragging,
  });

  Color _subjectColor() {
    if (subject == null) return colors.surfaceVariant;
    return _hexColor(subject!.colourHex).withOpacity(0.85);
  }

  Color _subjectBg() {
    if (subject == null) return colors.surfaceVariant;
    return _hexColor(subject!.colourHex).withOpacity(0.18);
  }

  @override
  Widget build(BuildContext context) {
    final hasSubject = subject != null;
    final isViolation = cell.isViolation;

    Widget cellContent = GestureDetector(
      onTap: onTap,
      child: Container(
        width: width - 4,
        height: height - 4,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: hasSubject ? _subjectBg() : colors.surfaceVariant,
          border: Border.all(
            color: isViolation
                ? colors.error
                : hasSubject
                    ? _subjectColor().withOpacity(0.4)
                    : colors.borderSubtle,
            width: isViolation ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: hasSubject
            ? Stack(children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(
                      subject!.name,
                      style: AppTextStyles.labelSmall.copyWith(
                          color: _subjectColor(), fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (isViolation)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Icon(Icons.warning_amber_rounded,
                        size: 12, color: colors.error),
                  ),
              ])
            : const SizedBox.shrink(),
      ),
    );

    if (!hasSubject) {
      // Free cell — only accept drops
      return DragTarget<ScheduleCellModel>(
        onWillAcceptWithDetails: (details) => dragging != null,
        onAcceptWithDetails: (details) => onAccept(details.data),
        builder: (ctx, cand, rej) => AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: width,
          height: height,
          decoration: cand.isNotEmpty
              ? BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  border: Border.all(color: colors.primary, width: 2),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: cellContent,
        ),
      );
    }

    // Occupied cell — draggable + drop target (for swap)
    return Draggable<ScheduleCellModel>(
      data: cell,
      onDragStarted: onDragStart,
      onDragEnd: (_) => onDragEnd(),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.85,
          child: Container(
            width: width - 4,
            height: height - 4,
            decoration: BoxDecoration(
              color: _subjectBg(),
              border: Border.all(color: _subjectColor()),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                    color: _subjectColor().withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6)),
              ],
            ),
            child: Center(
              child: Text(subject!.name,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: _subjectColor(), fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: cellContent),
      child: DragTarget<ScheduleCellModel>(
        onWillAcceptWithDetails: (details) =>
            dragging != null && dragging!.id != cell.id,
        onAcceptWithDetails: (details) => onAccept(details.data),
        builder: (ctx, cand, rej) => AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: cand.isNotEmpty
              ? BoxDecoration(
                  border: Border.all(color: colors.primary, width: 2),
                  borderRadius: BorderRadius.circular(10),
                )
              : null,
          child: cellContent,
        ),
      ),
    );
  }
}

// ── Free cell ─────────────────────────────────────────────────────────────

class _FreeCell extends StatelessWidget {
  final double width;
  final double height;
  final AppColors colors;
  const _FreeCell(
      {required this.width, required this.height, required this.colors});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.borderSubtle),
          ),
        ),
      );
}

// ── Detail row ────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(
            width: 60,
            child: Text('$label:',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey)),
          ),
          Flexible(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ]),
      );
}

// ── Hex colour helper ─────────────────────────────────────────────────────

Color _hexColor(String hex) {
  final h = hex.replaceAll('#', '');
  return Color(int.parse('FF$h', radix: 16));
}

// ── Providers ─────────────────────────────────────────────────────────────

final _periodsProvider = StreamProvider.family<List<PeriodModel>, String>(
  (ref, schoolId) => ref.watch(periodRepositoryProvider(schoolId)).watchAll(),
);

final _classroomsProvider = StreamProvider.family<List<ClassroomModel>, String>(
  (ref, schoolId) =>
      ref.watch(classroomRepositoryProvider(schoolId)).watchAll(),
);

final _subjectsProvider = StreamProvider.family<List<SubjectModel>, String>(
  (ref, schoolId) => ref.watch(subjectRepositoryProvider(schoolId)).watchAll(),
);
