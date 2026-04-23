// lib/presentation/constraints/constraint_form_screen.dart
//
// Add and edit hard + soft constraints via guided dropdowns only —
// no free-text fields for constraint parameters (§6.2.3, §5.3).
//
// Supports all 4 types:
//   MUST_ASSIGN      — subject, classroom, day, period (HARD only)
//   MUST_NOT_ASSIGN  — subject, classroom, day, period (HARD only)
//   AVOID_TIMESLOT   — subject, day (optional), start period, end period (SOFT)
//   PREFER_BLOCK     — subject only (SOFT)
//
// On save: creates or updates via ConstraintRepository.
// On load for edit: pre-fills all dropdowns from the existing ConstraintModel.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../data/repositories/subject_repositories.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/cs_button.dart';
import '../widgets/cs_dropdown.dart';

// ── Screen ─────────────────────────────────────────────────────────────────

class ConstraintFormScreen extends ConsumerStatefulWidget {
  /// Null when creating a new constraint; non-null when editing.
  final ConstraintModel? existing;
  final String schoolId;

  const ConstraintFormScreen({
    super.key,
    required this.schoolId,
    this.existing,
  });

  @override
  ConsumerState<ConstraintFormScreen> createState() =>
      _ConstraintFormScreenState();
}

class _ConstraintFormScreenState
    extends ConsumerState<ConstraintFormScreen> {

  // ── Form state ─────────────────────────────────────────────────────────

  // Kind toggle: 'HARD' | 'SOFT'
  late String _kind;

  // Type: one of the 4 values
  late String _type;

  // Shared fields
  String? _subjectId;
  String? _classroomId;
  String? _dayOfWeek;
  String? _periodId;
  String? _endPeriodId;
  String? _weight;

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _kind        = e?.kind        ?? 'HARD';
    _type        = e?.type        ?? 'MUST_ASSIGN';
    _subjectId   = e?.subjectId;
    _classroomId = e?.classroomId;
    _dayOfWeek   = e?.dayOfWeek;
    _periodId    = e?.periodId;
    _endPeriodId = e?.endPeriodId;
    _weight      = e?.weight ?? 'MEDIUM';
  }

  // ── Derived ────────────────────────────────────────────────────────────

  bool get _isEditing => widget.existing != null;

  /// Types available for the currently selected kind
  List<String> get _availableTypes {
    if (_kind == 'HARD') return ['MUST_ASSIGN', 'MUST_NOT_ASSIGN'];
    return ['AVOID_TIMESLOT', 'PREFER_BLOCK'];
  }

  // ── Save ───────────────────────────────────────────────────────────────

  Future<void> _save(
    List<SubjectModel> subjects,
    List<ClassroomModel> classrooms,
    List<PeriodModel> periods,
  ) async {
    final validationError = _validate(subjects, classrooms, periods);
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final repo = ref.read(constraintRepositoryProvider(widget.schoolId));
      final model = ConstraintModel(
        id:          widget.existing?.id ?? '',
        schoolId:    widget.schoolId,
        kind:        _kind,
        type:        _type,
        subjectId:   _subjectId,
        classroomId: _requiresClassroom ? _classroomId : null,
        dayOfWeek:   _requiresDay       ? _dayOfWeek   : null,
        periodId:    _requiresPeriod    ? _periodId    : null,
        endPeriodId: _type == 'AVOID_TIMESLOT' ? _endPeriodId : null,
        weight:      _kind == 'SOFT' ? _weight : null,
      );
      if (_isEditing) {
        await repo.update(model);
      } else {
        await repo.create(model);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _validate(
    List<SubjectModel> subjects,
    List<ClassroomModel> classrooms,
    List<PeriodModel> periods,
  ) {
    if (_subjectId == null) return 'Please select a subject.';
    if (_requiresClassroom && _classroomId == null) {
      return 'Please select a classroom.';
    }
    if (_requiresDay && _type != 'AVOID_TIMESLOT' && _dayOfWeek == null) {
      return 'Please select a day.';
    }
    if (_requiresPeriod && _periodId == null) return 'Please select a slot.';
    if (_type == 'AVOID_TIMESLOT') {
      if (_periodId == null) return 'Please select a start slot.';
      if (_endPeriodId == null) return 'Please select an end slot.';
    }
    return null;
  }

  // ── Field visibility helpers ───────────────────────────────────────────

  bool get _requiresClassroom =>
      _type == 'MUST_ASSIGN' || _type == 'MUST_NOT_ASSIGN';

  bool get _requiresDay =>
      _type == 'MUST_ASSIGN' || _type == 'MUST_NOT_ASSIGN' ||
      _type == 'AVOID_TIMESLOT';

  bool get _requiresPeriod =>
      _type == 'MUST_ASSIGN' || _type == 'MUST_NOT_ASSIGN' ||
      _type == 'AVOID_TIMESLOT';

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final subjectsAsync   = ref.watch(_subjectsProvider(widget.schoolId));
    final classroomsAsync = ref.watch(_classroomsProvider(widget.schoolId));
    final periodsAsync    = ref.watch(_periodsProvider(widget.schoolId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.edit : l10n.addConstraint,
          style: AppTextStyles.titleMedium
              .copyWith(color: colors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:   (e, _) => Center(child: Text('Error: $e')),
        data: (subjects) => classroomsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:   (e, _) => Center(child: Text('Error: $e')),
          data: (classrooms) => periodsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text('Error: $e')),
            data: (periods) => _Form(
              subjects:   subjects,
              classrooms: classrooms,
              periods:    periods,
              state:      this,
              colors:     colors,
              l10n:       l10n,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Form widget ────────────────────────────────────────────────────────────

class _Form extends StatelessWidget {
  final List<SubjectModel>   subjects;
  final List<ClassroomModel> classrooms;
  final List<PeriodModel>    periods;
  final _ConstraintFormScreenState state;
  final AppColors            colors;
  final AppLocalizations     l10n;

  const _Form({
    required this.subjects, required this.classrooms,
    required this.periods,  required this.state,
    required this.colors,   required this.l10n,
  });

  // Only LESSON-type periods can be target of constraints
  List<PeriodModel> get _lessonPeriods =>
      periods.where((p) => p.type == 'LESSON').toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Kind toggle: HARD | SOFT ────────────────────────────────
          _SectionLabel(label: 'Type', colors: colors),
          const SizedBox(height: 8),
          _KindToggle(state: state, colors: colors, l10n: l10n),
          const SizedBox(height: 20),

          // ── Constraint subtype ──────────────────────────────────────
          _SectionLabel(label: 'Rule', colors: colors),
          const SizedBox(height: 8),
          _TypeSelector(state: state, colors: colors, l10n: l10n),
          const SizedBox(height: 20),

          // ── Subject ────────────────────────────────────────────────
          _SectionLabel(label: l10n.subjects, colors: colors),
          const SizedBox(height: 8),
          CsDropdown<String>(
            value: state._subjectId,
            hint: 'Select subject',
            items: subjects.map((s) => DropdownMenuItem(
              value: s.id,
              child: Text(s.name),
            )).toList(),
            onChanged: (v) => state.setState(() => state._subjectId = v),
          ),
          const SizedBox(height: 16),

          // ── Classroom (MUST_ASSIGN / MUST_NOT_ASSIGN only) ──────────
          if (state._requiresClassroom) ...[
            _SectionLabel(label: l10n.classrooms, colors: colors),
            const SizedBox(height: 8),
            CsDropdown<String>(
              value: state._classroomId,
              hint: 'Select classroom',
              items: classrooms.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )).toList(),
              onChanged: (v) => state.setState(() => state._classroomId = v),
            ),
            const SizedBox(height: 16),
          ],

          // ── Day ─────────────────────────────────────────────────────
          if (state._requiresDay) ...[
            _SectionLabel(
              label: state._type == 'AVOID_TIMESLOT'
                  ? 'Day (optional)'
                  : l10n.activeDays,
              colors: colors,
            ),
            const SizedBox(height: 8),
            CsDropdown<String>(
              value: state._dayOfWeek,
              hint: state._type == 'AVOID_TIMESLOT'
                  ? 'Any day'
                  : 'Select day',
              items: [
                if (state._type == 'AVOID_TIMESLOT')
                  const DropdownMenuItem(value: null, child: Text('Any day')),
                ..._dayItems(l10n),
              ],
              onChanged: (v) =>
                  state.setState(() => state._dayOfWeek = v),
            ),
            const SizedBox(height: 16),
          ],

          // ── Period / start slot ─────────────────────────────────────
          if (state._requiresPeriod) ...[
            _SectionLabel(
              label: state._type == 'AVOID_TIMESLOT'
                  ? 'Start slot'
                  : 'Lesson slot',
              colors: colors,
            ),
            const SizedBox(height: 8),
            CsDropdown<String>(
              value: state._periodId,
              hint: 'Select slot',
              items: _lessonPeriods.map((p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.startTime}–${p.endTime}'),
              )).toList(),
              onChanged: (v) => state.setState(() => state._periodId = v),
            ),
            const SizedBox(height: 16),
          ],

          // ── End slot (AVOID_TIMESLOT only) ──────────────────────────
          if (state._type == 'AVOID_TIMESLOT') ...[
            _SectionLabel(label: 'End slot', colors: colors),
            const SizedBox(height: 8),
            CsDropdown<String>(
              value: state._endPeriodId,
              hint: 'Select end slot',
              items: _lessonPeriods.map((p) => DropdownMenuItem(
                value: p.id,
                child: Text('${p.startTime}–${p.endTime}'),
              )).toList(),
              onChanged: (v) =>
                  state.setState(() => state._endPeriodId = v),
            ),
            const SizedBox(height: 16),
          ],

          // ── Weight (SOFT only) ──────────────────────────────────────
          if (state._kind == 'SOFT') ...[
            _SectionLabel(label: 'Priority', colors: colors),
            const SizedBox(height: 8),
            _WeightSelector(state: state, colors: colors, l10n: l10n),
            const SizedBox(height: 16),
          ],

          // ── Error ───────────────────────────────────────────────────
          if (state._error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorBg,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                border:
                    Border.all(color: colors.error.withOpacity(0.3)),
              ),
              child: Text(state._error!,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: colors.error)),
            ),
            const SizedBox(height: 16),
          ],

          // ── Save ────────────────────────────────────────────────────
          CsButton(
            label: l10n.save,
            loading: state._saving,
            onPressed: () =>
                state._save(subjects, classrooms, periods),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  static List<DropdownMenuItem<String>> _dayItems(AppLocalizations l10n) => [
    DropdownMenuItem(value: 'MON', child: Text(l10n.monday)),
    DropdownMenuItem(value: 'TUE', child: Text(l10n.tuesday)),
    DropdownMenuItem(value: 'WED', child: Text(l10n.wednesday)),
    DropdownMenuItem(value: 'THU', child: Text(l10n.thursday)),
    DropdownMenuItem(value: 'FRI', child: Text(l10n.friday)),
    DropdownMenuItem(value: 'SAT', child: Text(l10n.saturday)),
    DropdownMenuItem(value: 'SUN', child: Text(l10n.sunday)),
  ];
}

// ── Kind toggle ────────────────────────────────────────────────────────────

class _KindToggle extends StatelessWidget {
  final _ConstraintFormScreenState state;
  final AppColors colors; final AppLocalizations l10n;
  const _KindToggle({required this.state, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _KindChip(
        label: l10n.hardConstraints,
        selected: state._kind == 'HARD',
        color: colors.error,
        colors: colors,
        onTap: () => state.setState(() {
          state._kind = 'HARD';
          state._type = 'MUST_ASSIGN';
        }),
      ),
      const SizedBox(width: 10),
      _KindChip(
        label: l10n.softConstraints,
        selected: state._kind == 'SOFT',
        color: colors.warning,
        colors: colors,
        onTap: () => state.setState(() {
          state._kind = 'SOFT';
          state._type = 'AVOID_TIMESLOT';
        }),
      ),
    ]);
  }
}

class _KindChip extends StatelessWidget {
  final String label; final bool selected;
  final Color color; final AppColors colors;
  final VoidCallback onTap;
  const _KindChip({
    required this.label, required this.selected,
    required this.color, required this.colors,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.15) : colors.surfaceVariant,
        border: Border.all(
            color: selected ? color : colors.borderDefault, width: 1.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(label,
          style: AppTextStyles.labelMedium.copyWith(
              color: selected ? color : colors.textMuted)),
    ),
  );
}

// ── Type selector ──────────────────────────────────────────────────────────

class _TypeSelector extends StatelessWidget {
  final _ConstraintFormScreenState state;
  final AppColors colors; final AppLocalizations l10n;
  const _TypeSelector({required this.state, required this.colors, required this.l10n});

  String _label(String type, AppLocalizations l10n) {
    switch (type) {
      case 'MUST_ASSIGN':     return l10n.mustAssign;
      case 'MUST_NOT_ASSIGN': return l10n.mustNotAssign;
      case 'AVOID_TIMESLOT':  return l10n.avoidTimeslot;
      case 'PREFER_BLOCK':    return l10n.preferBlock;
      default:                return type;
    }
  }

  String _description(String type) {
    switch (type) {
      case 'MUST_ASSIGN':
        return 'Force a subject into a specific classroom slot.';
      case 'MUST_NOT_ASSIGN':
        return 'Block a subject from a specific classroom slot.';
      case 'AVOID_TIMESLOT':
        return 'Discourage a subject during a time range.';
      case 'PREFER_BLOCK':
        return 'Encourage consecutive lessons for a subject.';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: state._availableTypes.map((type) {
      final selected = state._type == type;
      return GestureDetector(
        onTap: () => state.setState(() => state._type = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colors.primary.withOpacity(0.1)
                : colors.cardBg,
            border: Border.all(
              color: selected ? colors.primary : colors.borderDefault,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(children: [
            Radio<String>(
              value: type,
              groupValue: state._type,
              activeColor: colors.primary,
              onChanged: (v) => state.setState(() => state._type = v!),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_label(type, l10n),
                      style: AppTextStyles.labelMedium.copyWith(
                          color: selected
                              ? colors.primary
                              : colors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(_description(type),
                      style: AppTextStyles.bodySmall.copyWith(
                          color: colors.textMuted)),
                ],
              ),
            ),
          ]),
        ),
      );
    }).toList(),
  );
}

// ── Weight selector ────────────────────────────────────────────────────────

class _WeightSelector extends StatelessWidget {
  final _ConstraintFormScreenState state;
  final AppColors colors; final AppLocalizations l10n;
  const _WeightSelector({required this.state, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) => Row(
    children: ['LOW', 'MEDIUM', 'HIGH'].map((w) {
      final selected = state._weight == w;
      final label    = w == 'LOW' ? l10n.weightLow
                     : w == 'HIGH' ? l10n.weightHigh
                     : l10n.weightMedium;
      return Expanded(
        child: GestureDetector(
          onTap: () => state.setState(() => state._weight = w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? colors.warning.withOpacity(0.15)
                  : colors.surfaceVariant,
              border: Border.all(
                  color: selected ? colors.warning : colors.borderDefault,
                  width: 1.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? colors.warning : colors.textMuted)),
            ),
          ),
        ),
      );
    }).toList(),
  );
}

// ── Section label ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label; final AppColors colors;
  const _SectionLabel({required this.label, required this.colors});
  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: AppTextStyles.overline.copyWith(color: colors.textMuted),
  );
}

// ── Local providers ────────────────────────────────────────────────────────

final _subjectsProvider =
    StreamProvider.family<List<SubjectModel>, String>(
  (ref, schoolId) =>
      ref.watch(subjectRepositoryProvider(schoolId)).watchAll(),
);

final _classroomsProvider =
    StreamProvider.family<List<ClassroomModel>, String>(
  (ref, schoolId) =>
      ref.watch(classroomRepositoryProvider(schoolId)).watchAll(),
);

final _periodsProvider =
    StreamProvider.family<List<PeriodModel>, String>(
  (ref, schoolId) =>
      ref.watch(periodRepositoryProvider(schoolId)).watchAll(),
);
