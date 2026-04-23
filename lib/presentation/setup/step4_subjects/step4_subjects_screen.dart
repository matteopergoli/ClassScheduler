// lib/presentation/setup/step4_subjects/step4_subjects_screen.dart
//
// Step 4: Subjects — FR-SUB-01..06, FR-SUB-04 (feasibility estimator).
//
// What this screen covers:
//   • List all subjects for the school (name, teacher, colour dot).
//   • Add / edit a subject (name, teacher name, colour picker).
//   • Per-subject: show which classrooms it is assigned to, with weekly
//     target, minDaily, and maxDaily for each assignment.
//   • Add / edit a classroom–subject assignment with full FR-SUB-06 inline
//     validation before saving.
//   • Unassign a subject from a classroom (with constraint-warning).
//   • Delete a subject (with constraint-warning).
//   • Feasibility estimator panel at the bottom (FR-SUB-04).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_models.dart';
import '../../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../../data/repositories/subject_repositories.dart';
import '../../../domain/validation/subject_validator.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/cs_button.dart';
import '../../widgets/cs_text_field.dart';
import '../setup_screen.dart';
import '../step1_periods/step1_periods_screen.dart';
import '../step2_classrooms/step2_classrooms_screen.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _subjectsStreamProvider =
    StreamProvider.family<List<SubjectModel>, String>((ref, schoolId) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return SubjectRepository(uid: uid, schoolId: schoolId).watchAll();
});

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

final _classroomSubjectsStreamProvider =
    StreamProvider.family<List<ClassroomSubjectModel>, String>((ref, schoolId) {
  final uid = ref.watch(currentUserProvider)!.uid;
  // watchAll() streams the entire classroomSubjects collection so the UI
  // refreshes automatically whenever any assignment is saved or deleted.
  return ClassroomSubjectRepository(uid: uid, schoolId: schoolId).watchAll();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class Step4SubjectsScreen extends ConsumerWidget {
  const Step4SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n       = AppLocalizations.of(context);
    final colors     = AppColors.of(context);
    final school     = ref.watch(activeSchoolProvider);
    final activeDays = ref.watch(activeDaysProvider);

    if (school == null) return const SizedBox.shrink();

    final subjectsAsync   = ref.watch(_subjectsStreamProvider(school.id));
    final classroomsAsync = ref.watch(classroomsStreamProvider(school.id));
    final periodsAsync    = ref.watch(_periodsStreamProvider(school.id));
    final capacitiesAsync = ref.watch(_dayCapacitiesStreamProvider(school.id));
    final csAsync         = ref.watch(_classroomSubjectsStreamProvider(school.id));

    // All five streams are unwrapped with nested .when() so that every stream
    // update — including Step 3 capacity changes — triggers a full rebuild and
    // the derived maps are always recomputed from fresh data in the same frame.
    return periodsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (periods) {
        final lessonPeriodCount =
            periods.where((p) => p.type == PeriodType.lesson).length;

        return capacitiesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
          data: (caps) {
            // Build dayCapacityMap synchronously from the latest stream value.
            final dayCapacityMap = <String, Map<String, int>>{};
            for (final c in caps) {
              dayCapacityMap
                  .putIfAbsent(c.classroomId, () => {})[c.dayOfWeek] =
                  c.activeSlots.length;
            }

            return subjectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (subjects) => classroomsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
                data: (classrooms) {
                  // Compute totalSlotsByClassroom per classroom.
                  //
                  // Mirrors exactly what Step 3 displays:
                  //   - Days WITH a DayCapacity record → activeSlots.length
                  //   - Days WITHOUT a record (never configured) → all slots
                  //     active = lessonPeriodCount
                  //
                  // A record only exists for a day if the user tapped at
                  // least one cell on that day in Step 3. Untouched days
                  // default to fully active.
                  final totalSlotsByClassroom = <String, int>{};
                  for (final cls in classrooms) {
                    // Build a map of dayCode → slot count from Firestore records.
                    final recordsByDay = <String, int>{
                      for (final c in caps.where((c) => c.classroomId == cls.id))
                        c.dayOfWeek: c.activeSlots.length,
                    };
                    // Sum over activeDays: use record if present, else full capacity.
                    final total = activeDays.fold<int>(
                      0,
                      (sum, day) => sum + (recordsByDay[day] ?? lessonPeriodCount),
                    );
                    totalSlotsByClassroom[cls.id] = total;
                  }

                  return csAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text(e.toString())),
                    data: (allCs) => _Body(
                      school:                school,
                      subjects:              subjects,
                      classrooms:            classrooms,
                      allCs:                 allCs,
                      activeDays:            activeDays,
                      totalSlotsByClassroom: totalSlotsByClassroom,
                      lessonPeriodCount:     lessonPeriodCount,
                      dayCapacityMap:        dayCapacityMap,
                      colors:                colors,
                      l10n:                  l10n,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _Body extends ConsumerWidget {
  const _Body({
    required this.school,
    required this.subjects,
    required this.classrooms,
    required this.allCs,
    required this.activeDays,
    required this.totalSlotsByClassroom,
    required this.lessonPeriodCount,
    required this.dayCapacityMap,
    required this.colors,
    required this.l10n,
  });

  final SchoolModel                        school;
  final List<SubjectModel>                 subjects;
  final List<ClassroomModel>               classrooms;
  final List<ClassroomSubjectModel>        allCs;
  final List<String>                       activeDays;
  final Map<String, int>                   totalSlotsByClassroom;
  final int                                lessonPeriodCount;
  final Map<String, Map<String, int>>      dayCapacityMap;
  final AppColors                          colors;
  final AppLocalizations                   l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Build feasibility data — per-classroom weekly check.
    final feasRows = FeasibilityEstimator.estimateByClassroom(
      classroomNames:        {for (final c in classrooms) c.id: c.name},
      totalSlotsByClassroom: totalSlotsByClassroom,
      classroomSubjects:     allCs,
    );
    final hasCritical = feasRows.any((r) => r.isCritical);

    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadH, vertical: 16),
      children: [
        // Description banner
        Text(
          l10n.step4Description,
          style: AppTextStyles.bodyMedium.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 20),

        // Subject list
        if (subjects.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No subjects added yet',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: colors.textDisabled),
              ),
            ),
          ),

        ...subjects.map((subject) => _SubjectCard(
              subject:               subject,
              school:                school,
              classrooms:            classrooms,
              allCs:                 allCs.where((cs) =>
                  cs.subjectId == subject.id).toList(),
              activeDays:            activeDays,
              totalSlotsByClassroom: totalSlotsByClassroom,
              colors:                colors,
              l10n:                  l10n,
            )),

        const SizedBox(height: 8),

        // Add subject button
        CsButton(
          label: l10n.addSubject,
          prefixIcon: Icons.add,
          onPressed: () => _showSubjectForm(context, ref, school.id),
        ),

        const SizedBox(height: 28),

        // ── Feasibility estimator panel (FR-SUB-04) ──────────────────────
        _FeasibilityPanel(
          feasRows:    feasRows,
          hasCritical: hasCritical,
          colors:      colors,
          l10n:        l10n,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _showSubjectForm(
      BuildContext context, WidgetRef ref, String schoolId,
      [SubjectModel? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SubjectFormSheet(
          schoolId: schoolId, existing: existing),
    );
  }
}

// ── Subject card ──────────────────────────────────────────────────────────────

class _SubjectCard extends ConsumerWidget {
  const _SubjectCard({
    required this.subject,
    required this.school,
    required this.classrooms,
    required this.allCs,
    required this.activeDays,
    required this.totalSlotsByClassroom,
    required this.colors,
    required this.l10n,
  });

  final SubjectModel                   subject;
  final SchoolModel                    school;
  final List<ClassroomModel>           classrooms;
  final List<ClassroomSubjectModel>    allCs; // only for this subject
  final List<String>                   activeDays;
  final Map<String, int>               totalSlotsByClassroom;
  final AppColors                      colors;
  final AppLocalizations               l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color subjectColor;
    try {
      subjectColor =
          Color(int.parse(subject.colourHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      subjectColor = colors.primary;
    }

    // Build a quick lookup: classroomId → ClassroomSubjectModel
    final csMap = {for (final cs in allCs) cs.classroomId: cs};

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.cardGap),
      decoration: BoxDecoration(
        color:        colors.cardBg,
        border:       Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                // Colour dot
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:        subjectColor,
                    shape:        BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:      subjectColor.withOpacity(0.45),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(subject.name,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: colors.textPrimary)),
                      Text(subject.teacherName,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colors.textMuted)),
                    ],
                  ),
                ),
                // Edit subject button
                IconButton(
                  icon:  Icon(Icons.edit_outlined,
                      size: 18, color: colors.textDisabled),
                  tooltip: l10n.edit,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => _SubjectFormSheet(
                        schoolId: school.id, existing: subject),
                  ),
                ),
                // Delete subject button
                IconButton(
                  icon:  Icon(Icons.delete_outline,
                      size: 18, color: colors.error),
                  tooltip: l10n.delete,
                  onPressed: () =>
                      _confirmDelete(context, ref),
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────────────
          Divider(
              height: 16,
              thickness: 0.5,
              color: colors.borderSubtle,
              indent: 16,
              endIndent: 16),

          // ── Classroom assignments ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              l10n.classrooms,
              style: AppTextStyles.overline
                  .copyWith(color: colors.textDisabled),
            ),
          ),

          ...classrooms.map((cls) {
            final cs = csMap[cls.id];
            return _ClassroomAssignmentRow(
              classroom:   cls,
              cs:          cs,
              subject:     subject,
              school:      school,
              activeDays:  activeDays,
              totalSlots:  totalSlotsByClassroom[cls.id] ?? 0,
              colors:      colors,
              l10n:        l10n,
            );
          }),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        title: Text(l10n.delete,
            style: AppTextStyles.titleSmall
                .copyWith(color: colors.textPrimary)),
        content: Text(
          l10n.subjectDeleteConstraintWarning(allCs.length),
          style: AppTextStyles.bodyMedium
              .copyWith(color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete,
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final uid = ref.read(currentUserProvider)!.uid;
    await SubjectRepository(uid: uid, schoolId: school.id)
        .delete(subject.id);
    await ClassroomSubjectRepository(uid: uid, schoolId: school.id)
        .deleteForSubject(subject.id);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.subjectDeleted)),
      );
    }
  }
}

// ── Classroom assignment row ──────────────────────────────────────────────────

class _ClassroomAssignmentRow extends StatelessWidget {
  const _ClassroomAssignmentRow({
    required this.classroom,
    required this.cs,
    required this.subject,
    required this.school,
    required this.activeDays,
    required this.totalSlots,
    required this.colors,
    required this.l10n,
  });

  final ClassroomModel          classroom;
  final ClassroomSubjectModel?  cs;       // null = not assigned
  final SubjectModel            subject;
  final SchoolModel             school;
  final List<String>            activeDays;
  final int                     totalSlots;
  final AppColors               colors;
  final AppLocalizations        l10n;

  bool get _isAssigned => cs != null;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AssignmentFormSheet(
          classroom:  classroom,
          subject:    subject,
          school:     school,
          existing:   cs,
          activeDays: activeDays,
          totalSlots: totalSlots,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        child: Row(
          children: [
            // Classroom name
            SizedBox(
              width: 72,
              child: Text(
                classroom.name,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: colors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),

            if (_isAssigned) ...[
              // Weekly target chip
              _StatChip(
                icon:   Icons.calendar_today_outlined,
                label:  '${cs!.weeklyTargetHours}h/wk',
                color:  colors.primary,
                colors: colors,
              ),
              const SizedBox(width: 6),
              // MinDaily chip (only if > 0)
              if (cs!.minDailyHours > 0) ...[
                _StatChip(
                  icon:   Icons.arrow_downward,
                  label:  'min ${cs!.minDailyHours}/d',
                  color:  colors.success,
                  colors: colors,
                ),
                const SizedBox(width: 6),
              ],
              // MaxDaily chip
              _StatChip(
                icon:   Icons.arrow_upward,
                label:  'max ${cs!.maxDailyHours}/d',
                color:  colors.warning,
                colors: colors,
              ),
              const Spacer(),
              Icon(Icons.edit_outlined,
                  size: 14, color: colors.textDisabled),
            ] else ...[
              Text(
                '— ${l10n.assignToClassroom}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textDisabled),
              ),
              const Spacer(),
              Icon(Icons.add, size: 16, color: colors.primary),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
  });
  final IconData  icon;
  final String    label;
  final Color     color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border:       Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: color)),
        ],
      ),
    );
  }
}

// ── Subject form sheet (add / edit subject) ───────────────────────────────────

class _SubjectFormSheet extends ConsumerStatefulWidget {
  const _SubjectFormSheet({required this.schoolId, this.existing});
  final String        schoolId;
  final SubjectModel? existing;

  @override
  ConsumerState<_SubjectFormSheet> createState() =>
      _SubjectFormSheetState();
}

class _SubjectFormSheetState extends ConsumerState<_SubjectFormSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _teacherCtrl;
  late Color _selectedColor;
  bool _saving = false;

  // 12 perceptually distinct colours — chosen to be visually separable on
  // both dark and light backgrounds and clearly different from each other.
  static const List<Color> _palette = [
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

  @override
  void initState() {
    super.initState();
    _nameCtrl    = TextEditingController(text: widget.existing?.name ?? '');
    _teacherCtrl =
        TextEditingController(text: widget.existing?.teacherName ?? '');
    // Rebuild on every keystroke so the Save button enable-state stays in sync.
    _nameCtrl.addListener(_onTextChanged);
    _teacherCtrl.addListener(_onTextChanged);
    try {
      _selectedColor = widget.existing != null
          ? Color(int.parse(
              widget.existing!.colourHex.replaceFirst('#', '0xFF')))
          : _palette.first;
    } catch (_) {
      _selectedColor = _palette.first;
    }
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _nameCtrl.removeListener(_onTextChanged);
    _teacherCtrl.removeListener(_onTextChanged);
    _nameCtrl.dispose();
    _teacherCtrl.dispose();
    super.dispose();
  }

  String get _colorHex =>
      '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n   = AppLocalizations.of(context);

    return _BottomSheet(
      title: widget.existing == null ? l10n.addSubject : l10n.edit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CsTextField(
            controller: _nameCtrl,
            label:      l10n.subjectName,
            autofocus:  widget.existing == null,
          ),
          const SizedBox(height: 14),
          CsTextField(
            controller: _teacherCtrl,
            label:      l10n.teacherName,
          ),
          const SizedBox(height: 18),

          // Colour picker
          Text(l10n.colour,
              style: AppTextStyles.labelMedium
                  .copyWith(color: colors.textMuted)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _palette.map((color) {
              final selected = _selectedColor.value == color.value;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width:  32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:  color,
                    shape:  BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? colors.textPrimary
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: selected
                        ? [BoxShadow(
                            color:      color.withOpacity(0.55),
                            blurRadius: 8)]
                        : null,
                  ),
                  child: selected
                      ? const Icon(Icons.check,
                          size: 16, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),
          CsButton(
            label:     l10n.save,
            loading:   _saving,
            onPressed: _nameCtrl.text.trim().isEmpty ||
                    _teacherCtrl.text.trim().isEmpty
                ? null
                : _save,
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final uid     = ref.read(currentUserProvider)!.uid;
    final subject = SubjectModel(
      id:          widget.existing?.id ?? const Uuid().v4(),
      schoolId:    widget.schoolId,
      name:        _nameCtrl.text.trim(),
      teacherName: _teacherCtrl.text.trim(),
      colourHex:   _colorHex,
    );
    await SubjectRepository(uid: uid, schoolId: widget.schoolId)
        .save(subject);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(AppLocalizations.of(context).subjectSaved)),
      );
    }
  }
}

// ── Assignment form sheet ─────────────────────────────────────────────────────
// Lets the user set weeklyTarget, minDaily, maxDaily for one
// classroom–subject pair. Runs FR-SUB-06 validation before saving.

class _AssignmentFormSheet extends ConsumerStatefulWidget {
  const _AssignmentFormSheet({
    required this.classroom,
    required this.subject,
    required this.school,
    required this.activeDays,
    required this.totalSlots,
    this.existing,
  });

  final ClassroomModel          classroom;
  final SubjectModel            subject;
  final SchoolModel             school;
  final List<String>            activeDays;
  final int                     totalSlots;
  final ClassroomSubjectModel?  existing;

  @override
  ConsumerState<_AssignmentFormSheet> createState() =>
      _AssignmentFormSheetState();
}

class _AssignmentFormSheetState
    extends ConsumerState<_AssignmentFormSheet> {
  late TextEditingController _weeklyCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;

  List<String> _errors = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _weeklyCtrl =
        TextEditingController(text: '${widget.existing?.weeklyTargetHours ?? 1}');
    _minCtrl =
        TextEditingController(text: '${widget.existing?.minDailyHours ?? 0}');
    _maxCtrl =
        TextEditingController(text: '${widget.existing?.maxDailyHours ?? 2}');
  }

  @override
  void dispose() {
    _weeklyCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  int get _weekly  => int.tryParse(_weeklyCtrl.text) ?? 0;
  int get _minD    => int.tryParse(_minCtrl.text) ?? 0;
  int get _maxD    => int.tryParse(_maxCtrl.text) ?? 1;

  void _validate() {
    final l10n    = AppLocalizations.of(context);
    final result  = SubjectValidator.validate(
      weeklyTarget:     _weekly,
      minDaily:         _minD,
      maxDaily:         _maxD,
      activeDayCount:   widget.activeDays.length,
      totalLessonSlots: widget.totalSlots,
    );

    setState(() {
      _errors = result.errors.map((e) {
        switch (e) {
          case SubjectValidationError.weeklyMustBePositive:
            return l10n.validationWeeklyMustBePositive;
          case SubjectValidationError.minGtMax:
            return l10n.validationMinGtMax;
          case SubjectValidationError.maxDaysInsufficient:
            return l10n.validationMaxDaysInsufficient(
                _maxD * widget.activeDays.length, _weekly);
          case SubjectValidationError.weeklyExceedsSlots:
            return l10n.validationWeeklyExceedsSlots(
                _weekly, widget.totalSlots);
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final l10n   = AppLocalizations.of(context);
    final isEdit = widget.existing != null;

    return _BottomSheet(
      title: isEdit ? l10n.edit : l10n.assignToClassroom,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Subject + classroom labels
          _AssignmentHeader(
              subject: widget.subject, classroom: widget.classroom,
              colors: colors),
          const SizedBox(height: 12),

          // ── Contextual hint ──────────────────────────────────────────────
          // Explain the assign / don't-assign model so users understand
          // they should simply close this sheet for classrooms where the
          // subject is not taught.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color:        colors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border:       Border.all(color: colors.primary.withOpacity(0.16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 14, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEdit
                        ? 'Set the weekly lesson count for this classroom. '
                          'To remove the subject from this classroom, '
                          'tap "Unassign" below.'
                        : 'Only assign if this subject is actually taught in '
                          '${widget.classroom.name}. '
                          'If it is not taught here, just close this sheet — '
                          'leaving it unassigned is correct.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: colors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Weekly target
          _NumericField(
            controller: _weeklyCtrl,
            label:      l10n.weeklyTarget,
            hint:       'e.g. 4',
            onChanged:  (_) => _validate(),
            colors:     colors,
          ),
          const SizedBox(height: 4),
          Text(
            'Number of lesson slots per week. Must be ≥ 1.',
            style: AppTextStyles.bodySmall
                .copyWith(color: colors.textDisabled),
          ),
          const SizedBox(height: 14),

          // Min daily / Max daily side by side
          Row(
            children: [
              Expanded(
                child: _NumericField(
                  controller: _minCtrl,
                  label:      l10n.minDailyHours,
                  hint:       '0',
                  onChanged:  (_) => _validate(),
                  colors:     colors,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumericField(
                  controller: _maxCtrl,
                  label:      l10n.maxDailyHours,
                  hint:       '2',
                  onChanged:  (_) => _validate(),
                  colors:     colors,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Helper: active days × max = cap
          Text(
            '${widget.activeDays.length} active days  ·  '
            'max capacity: ${_maxD * widget.activeDays.length} slots',
            style: AppTextStyles.bodySmall
                .copyWith(color: colors.textDisabled),
          ),
          const SizedBox(height: 12),

          // Validation errors
          if (_errors.isNotEmpty)
            ..._errors.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_outline,
                          size: 14, color: colors.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(e,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: colors.error)),
                      ),
                    ],
                  ),
                )),

          const SizedBox(height: 20),

          // Save button
          CsButton(
            label:     l10n.save,
            loading:   _saving,
            onPressed: _errors.isEmpty ? _save : null,
          ),

          // Unassign (edit) or Not-taught-here / close (new assignment)
          const SizedBox(height: 10),
          if (isEdit)
            CsButton(
              label:     l10n.unassignSubject,
              outline:   true,
              onPressed: _saving ? null : _unassign,
            )
          else
            CsButton(
              label:     'Not taught in ${widget.classroom.name} — close',
              outline:   true,
              onPressed: _saving ? null : () => Navigator.pop(context),
            ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    _validate();
    if (_errors.isNotEmpty) return;
    setState(() => _saving = true);
    final uid  = ref.read(currentUserProvider)!.uid;
    final repo = ClassroomSubjectRepository(
        uid: uid, schoolId: widget.school.id);
    final cs = ClassroomSubjectModel(
      id:               widget.existing?.id ?? const Uuid().v4(),
      classroomId:      widget.classroom.id,
      subjectId:        widget.subject.id,
      weeklyTargetHours: _weekly,
      minDailyHours:    _minD,
      maxDailyHours:    _maxD,
    );
    await repo.save(cs);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).subjectSaved)),
      );
    }
  }

  Future<void> _unassign() async {
    if (widget.existing == null) return;
    setState(() => _saving = true);
    final uid = ref.read(currentUserProvider)!.uid;
    await ClassroomSubjectRepository(uid: uid, schoolId: widget.school.id)
        .delete(widget.existing!.id);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).subjectDeleted)),
      );
    }
  }
}

// ── Assignment header ─────────────────────────────────────────────────────────

class _AssignmentHeader extends StatelessWidget {
  const _AssignmentHeader({
    required this.subject,
    required this.classroom,
    required this.colors,
  });
  final SubjectModel   subject;
  final ClassroomModel classroom;
  final AppColors      colors;

  @override
  Widget build(BuildContext context) {
    Color subjectColor;
    try {
      subjectColor =
          Color(int.parse(subject.colourHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      subjectColor = colors.primary;
    }

    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: subjectColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(subject.name,
            style: AppTextStyles.titleSmall
                .copyWith(color: colors.textPrimary)),
        const SizedBox(width: 6),
        Text('→',
            style: AppTextStyles.bodyMedium
                .copyWith(color: colors.textDisabled)),
        const SizedBox(width: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color:        colors.primary.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(AppDimensions.radiusFull),
            border:
                Border.all(color: colors.primary.withOpacity(0.25)),
          ),
          child: Text(classroom.name,
              style: AppTextStyles.labelMedium
                  .copyWith(color: colors.primaryLight)),
        ),
      ],
    );
  }
}

// ── Numeric input field ───────────────────────────────────────────────────────

class _NumericField extends StatelessWidget {
  const _NumericField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    required this.colors,
  });

  final TextEditingController controller;
  final String                label;
  final String                hint;
  final ValueChanged<String>  onChanged;
  final AppColors             colors;

  @override
  Widget build(BuildContext context) {
    return CsTextField(
      controller:      controller,
      label:           label,
      hint:            hint,
      keyboardType:    TextInputType.number,
      textInputAction: TextInputAction.next,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged:       onChanged,
    );
  }
}

// ── Feasibility estimator panel (FR-SUB-04) ───────────────────────────────────
//
// Shows one row per classroom: available slots this week vs needed slots.
// This is the only meaningful feasibility check — weekly targets are not
// pinned to specific days so a per-day breakdown would be misleading.

class _FeasibilityPanel extends StatelessWidget {
  const _FeasibilityPanel({
    required this.feasRows,
    required this.hasCritical,
    required this.colors,
    required this.l10n,
  });

  final List<FeasibilityClassroom> feasRows;
  final bool                       hasCritical;
  final AppColors                  colors;
  final AppLocalizations           l10n;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasCritical
        ? colors.error.withOpacity(0.35)
        : colors.success.withOpacity(0.35);
    final bgColor = hasCritical
        ? colors.error.withOpacity(0.06)
        : colors.success.withOpacity(0.06);
    final accentColor = hasCritical ? colors.error : colors.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        bgColor,
        border:       Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            children: [
              Icon(
                hasCritical
                    ? Icons.warning_amber_outlined
                    : Icons.check_circle_outline,
                size:  16,
                color: accentColor,
              ),
              const SizedBox(width: 7),
              Text(
                l10n.feasibilityTitle,
                style: AppTextStyles.labelLarge
                    .copyWith(color: accentColor),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            hasCritical
                ? l10n.feasibilityInsufficient
                : l10n.feasibilityOk,
            style: AppTextStyles.bodySmall
                .copyWith(color: colors.textMuted),
          ),

          if (feasRows.isNotEmpty) ...[
            const SizedBox(height: 14),

            // Explanation of what the numbers mean
            Text(
              'Needed = timetable slots to fill (Step 3)\n'
              'Available = total lessons to be assigned (Step 4)\n'
              'Available must be more or equal than Needed',
              style: AppTextStyles.bodySmall
                  .copyWith(color: colors.textDisabled),
            ),
            const SizedBox(height: 10),

            // Column headers
            Row(
              children: [
                SizedBox(
                  width: 64,
                  child: Text('Class',
                      style: AppTextStyles.overline
                          .copyWith(color: colors.textDisabled)),
                ),
                Expanded(
                  child: Text('Needed',
                      style: AppTextStyles.overline
                          .copyWith(color: colors.textDisabled)),
                ),
                Expanded(
                  child: Text('Available',
                      style: AppTextStyles.overline
                          .copyWith(color: colors.textDisabled)),
                ),
                SizedBox(
                  width: 44,
                  child: Text(l10n.feasibilitySlack,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.overline
                          .copyWith(color: colors.textDisabled)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ...feasRows.map((fr) {
              final slackColor = fr.isCritical
                  ? colors.error
                  : fr.slack < 3
                      ? colors.warning
                      : colors.success;
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  children: [
                    SizedBox(
                      width: 64,
                      child: Text(
                        fr.classroomName,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: colors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Needed bar (Step 3 slots — fixed reference)
                    Expanded(
                      child: _FeasBar(
                        value:  fr.needed,
                        max:    fr.needed > fr.available ? fr.needed : fr.available > 0 ? fr.available : 1,
                        color:  colors.textDisabled,
                        colors: colors,
                      ),
                    ),
                    // Available bar (Step 4 lessons — must reach or exceed needed)
                    Expanded(
                      child: _FeasBar(
                        value:    fr.available,
                        max:      fr.needed > fr.available ? fr.needed : fr.available > 0 ? fr.available : 1,
                        color:    fr.isCritical
                            ? colors.error
                            : colors.success,
                        colors:   colors,
                        showFill: fr.available > 0,
                      ),
                    ),
                    SizedBox(
                      width: 44,
                      child: Text(
                        '${fr.slack >= 0 ? '+' : ''}${fr.slack}',
                        textAlign: TextAlign.right,
                        style: AppTextStyles.numericSmall
                            .copyWith(color: slackColor),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}


class _FeasBar extends StatelessWidget {
  const _FeasBar({
    required this.value,
    required this.max,
    required this.color,
    required this.colors,
    this.showFill = true,
  });
  final int       value;
  final int       max;
  final Color     color;
  final AppColors colors;
  final bool      showFill;

  @override
  Widget build(BuildContext context) {
    final fraction = max > 0 ? (value / max).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color:        colors.borderSubtle,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              if (showFill)
                FractionallySizedBox(
                  widthFactor: fraction,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color:        color.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 22,
          child: Text(
            '$value',
            style: AppTextStyles.labelSmall
                .copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );
  }
}

// ── Shared bottom sheet chrome ────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color:        colors.cardBg,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXxl)),
        border: Border.all(color: colors.borderDefault),
      ),
      padding: EdgeInsets.only(
        left:   24,
        right:  24,
        top:    20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color:        colors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(title,
                style: AppTextStyles.titleSmall
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 20),

            child,
          ],
        ),
      ),
    );
  }
}
