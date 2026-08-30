// lib/presentation/constraints/constraint_form_screen.dart
//
// Add and edit constraints via guided dropdowns only — no free-text fields
// for constraint parameters (§6.2.3, §5.3).
//
// A constraint is chosen along two independent axes:
//   1. Kind   — HARD (must be respected) or SOFT (preference, may be broken)
//   2. Family — "Scheduling rule" (targets a specific slot) or "Daily limit"
//               (min/max hours/day for a subject in a classroom).
//
// Scheduling rules unify MUST_ASSIGN/MUST_NOT_ASSIGN (hard) and
// PREFER_BLOCK/AVOID_TIMESLOT (soft) behind a single Must/Must-not ↔
// Prefer/Avoid polarity toggle, since both pairs express the same
// "positive/negative" idea at a different strictness:
//   HARD + positive → MUST_ASSIGN       SOFT + positive → PREFER_BLOCK
//   HARD + negative → MUST_NOT_ASSIGN   SOFT + negative → AVOID_TIMESLOT
//
// Daily limits work differently depending on kind because the scheduler
// engine represents them differently:
//   HARD — updates the existing minDailyHours/maxDailyHours fields already
//          on ClassroomSubjectModel (HC-4/HC-5), via ClassroomSubjectRepository.
//          These are structural fields of the assignment, not a document you
//          create/delete, and generation fails if they can't be met.
//   SOFT — a ConstraintModel (type 'DAILY_LIMIT') like any other soft rule,
//          penalised but never blocking — see SoftType.dailyLimit in
//          scheduler_input.dart / phase2_sa.dart.
// "Minimum" means conditional either way: if the subject is scheduled at all
// on a given day, it must reach the minimum — a day with zero lessons is
// still allowed (§SchedulerInput.minDaily, "0 = disabled" only turns the
// limit itself off, it doesn't mean a day can't be skipped).

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/school_repository.dart';
import '../../data/repositories/subject_repositories.dart' show ClassroomSubjectRepository;
import '../../domain/constraints/constraint_conflict_detector.dart';
import '../../domain/validation/subject_validator.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_providers.dart';
import '../setup/step1_periods/step1_periods_screen.dart' show activeDaysProvider;
import '../widgets/cs_button.dart';
import '../widgets/cs_dropdown.dart';
import '../widgets/cs_text_field.dart';
import 'constraint_data_providers.dart';
import 'slot_range_picker.dart';

// ── Form family ───────────────────────────────────────────────────────────

enum _Family { rule, dailyLimit }

// Sentinel dropdown values for "apply to every X" — distinct from any real
// Firestore ID so they can't collide. Only offered when creating (not
// editing) a MUST_ASSIGN/MUST_NOT_ASSIGN rule, since a single ConstraintModel
// can only carry one classroomId/dayOfWeek — picking one fans out into
// several documents at save time instead of mutating what "editing this
// constraint" means.
const _kAllClassrooms = '__ALL_CLASSROOMS__';
const _kAllDays = '__ALL_DAYS__';

// Sentinel dropdown values for "no specific X" on AVOID_TIMESLOT/PREFER_BLOCK
// — unlike the fan-out sentinels above, these resolve to a plain `null` on
// the single document being created/edited (no fan-out involved), so —
// unlike _kAllClassrooms/_kAllDays — they're offered whether creating or
// editing.
const _kAnyClassroom = '__ANY_CLASSROOM__';
const _kAnyDay = '__ANY_DAY__';

// ── Screen ─────────────────────────────────────────────────────────────────

class ConstraintFormScreen extends ConsumerStatefulWidget {
  /// Null when creating a new constraint; non-null when editing an existing
  /// scheduling rule or SOFT daily limit (both are ConstraintModel documents).
  final ConstraintModel? existing;

  /// Non-null when editing a HARD daily limit instead — those live on
  /// ClassroomSubjectModel, not as a ConstraintModel document (see class
  /// doc), so they need their own way in.
  final ClassroomSubjectModel? existingDailyLimit;

  final String schoolId;

  const ConstraintFormScreen({
    super.key,
    required this.schoolId,
    this.existing,
    this.existingDailyLimit,
  });

  @override
  ConsumerState<ConstraintFormScreen> createState() =>
      _ConstraintFormScreenState();
}

class _ConstraintFormScreenState extends ConsumerState<ConstraintFormScreen> {

  // ── Form state ─────────────────────────────────────────────────────────

  // Kind toggle: 'HARD' | 'SOFT'
  late String _kind;

  // Which section of the form is active.
  late _Family _family;

  // Polarity within the "rule" family:
  // true  = MUST_ASSIGN (hard) / PREFER_BLOCK (soft)
  // false = MUST_NOT_ASSIGN (hard) / AVOID_TIMESLOT (soft)
  late bool _positive;

  // Rule fields
  String? _subjectId;
  String? _classroomId;
  String? _dayOfWeek;
  String? _periodId;
  String? _endPeriodId;
  String? _weight;

  // Daily-limit fields
  String? _dlSubjectId;
  String? _dlClassroomId;
  final _minCtrl = TextEditingController(text: '0');
  final _maxCtrl = TextEditingController(text: '1');
  // "No maximum": HARD writes the physical per-day slot count (no artificial
  // cap beyond what a day can hold); SOFT just omits maxHours (nullable).
  bool _dlNoMax = false;
  // Whether _dlNoMax has been derived yet from existingDailyLimit's stored
  // value — deferred because it needs lessonPeriodsCount, which isn't known
  // until periods finish loading (initState runs before that).
  bool _dlNoMaxDetected = false;
  List<String> _dlErrors = [];

  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final dl = widget.existingDailyLimit;
    if (dl != null) {
      // Editing a HARD daily limit reached via its own tile — see class doc.
      _kind          = 'HARD';
      _family        = _Family.dailyLimit;
      _positive      = true;
      _weight        = 'MEDIUM';
      _dlSubjectId   = dl.subjectId;
      _dlClassroomId = dl.classroomId;
      _minCtrl.text  = '${dl.minDailyHours}';
      _maxCtrl.text  = '${dl.maxDailyHours}';
      // _dlNoMax is derived once periods load — see _buildForm.
      return;
    }

    final e = widget.existing;
    _kind   = e?.kind ?? 'HARD';
    final type = e?.type ?? 'MUST_ASSIGN';
    _weight = e?.weight ?? 'MEDIUM';

    if (type == 'DAILY_LIMIT') {
      _family        = _Family.dailyLimit;
      _positive      = true;
      _dlSubjectId   = e?.subjectId;
      _dlClassroomId = e?.classroomId;
      _minCtrl.text  = '${e?.minHours ?? 0}';
      _dlNoMax       = e != null && e.maxHours == null;
      _maxCtrl.text  = '${e?.maxHours ?? 1}';
    } else {
      _family      = _Family.rule;
      _positive    = type == 'MUST_ASSIGN' || type == 'PREFER_BLOCK';
      _subjectId   = e?.subjectId;
      _classroomId = e?.classroomId;
      _dayOfWeek   = e?.dayOfWeek;
      _periodId    = e?.periodId;
      _endPeriodId = e?.endPeriodId;
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  // ── Derived ────────────────────────────────────────────────────────────

  bool get _isEditing =>
      widget.existing != null || widget.existingDailyLimit != null;

  /// The 4 underlying ConstraintModel types, derived from (kind, polarity).
  String get _type {
    if (_kind == 'HARD') return _positive ? 'MUST_ASSIGN' : 'MUST_NOT_ASSIGN';
    return _positive ? 'PREFER_BLOCK' : 'AVOID_TIMESLOT';
  }

  /// _classroomId/_dayOfWeek with the "any"/"all" sentinels resolved to the
  /// real value actually persisted: `_kAnyClassroom`/`_kAnyDay` (offered for
  /// AVOID_TIMESLOT/PREFER_BLOCK) always mean null; `_kAllClassrooms`/
  /// `_kAllDays` (offered only when creating a MUST_ASSIGN/MUST_NOT_ASSIGN)
  /// are handled by their own fan-out branch in _saveRule before these
  /// getters would ever see them, but resolving them to null here too is a
  /// harmless safety net rather than relying on that being airtight forever.
  String? get _resolvedClassroomId =>
      (_classroomId == _kAnyClassroom || _classroomId == _kAllClassrooms)
          ? null
          : _classroomId;

  String? get _resolvedDayOfWeek =>
      (_dayOfWeek == _kAnyDay || _dayOfWeek == _kAllDays) ? null : _dayOfWeek;

  void _setKind(String kind) {
    setState(() {
      _kind = kind;
      _error = null;
      _dlErrors = [];
    });
  }

  // ── Save (rule) ────────────────────────────────────────────────────────

  /// Classrooms this subject actually has a (nonzero) weekly target in —
  /// what "all classrooms" expands to. A MUST_ASSIGN for a classroom the
  /// subject isn't assigned to would just be an unsatisfiable constraint.
  List<String> _classroomIdsForSubject(
    List<ClassroomModel> classrooms,
    List<ClassroomSubjectModel> classroomSubjects,
  ) {
    final validIds = classroomSubjects
        .where((cs) => cs.subjectId == _subjectId && cs.weeklyTargetHours > 0)
        .map((cs) => cs.classroomId)
        .toSet();
    return classrooms.map((c) => c.id).where(validIds.contains).toList();
  }

  Future<void> _saveRule(
    List<SubjectModel> subjects,
    List<ClassroomModel> classrooms,
    List<PeriodModel> periods,
    List<ClassroomSubjectModel> classroomSubjects,
  ) async {
    final validationError = _validateRule();
    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final repo = ref.read(constraintRepositoryProvider(widget.schoolId));
      final type = _type;

      if (widget.existing != null) {
        // Editing an existing ConstraintModel always targets exactly one
        // document — the fan-out "all classrooms" / "all days" options
        // aren't offered in this mode. Classroom/day/slot-range are now the
        // same four fields regardless of type; the "any"/"all" sentinels
        // resolve to null via the getters above.
        final model = ConstraintModel(
          id:          widget.existing!.id,
          schoolId:    widget.schoolId,
          kind:        _kind,
          type:        type,
          subjectId:   _subjectId,
          classroomId: _resolvedClassroomId,
          dayOfWeek:   _resolvedDayOfWeek,
          periodId:    _periodId,
          endPeriodId: _endPeriodId,
          weight:      _kind == 'SOFT' ? _weight : null,
        );
        await repo.update(model);
      } else if (type == 'MUST_ASSIGN' || type == 'MUST_NOT_ASSIGN') {
        final classroomIds = _classroomId == _kAllClassrooms
            ? _classroomIdsForSubject(classrooms, classroomSubjects)
            : [_classroomId!];
        final dayCodes = _dayOfWeek == _kAllDays
            ? ref.read(activeDaysProvider)
            : [_dayOfWeek!];

        if (classroomIds.isEmpty) {
          setState(() {
            _error = 'This subject isn\'t assigned to any classroom yet.';
            _saving = false;
          });
          return;
        }

        await repo.createMany([
          for (final c in classroomIds)
            for (final d in dayCodes)
              ConstraintModel(
                id: '',
                schoolId: widget.schoolId,
                kind: _kind,
                type: type,
                subjectId: _subjectId,
                classroomId: c,
                dayOfWeek: d,
                periodId: _periodId,
                // The slot range itself doesn't fan out — only classroom
                // and day do — so every generated document keeps the same
                // start/end.
                endPeriodId: _endPeriodId,
              ),
        ]);
        // Arrived via existingDailyLimit (a HARD daily limit) but switched
        // to the Rule family — that's a different representation with
        // nothing to "update", so the old one has to be cleared explicitly
        // or it's left behind as a stale duplicate.
        await _clearExistingDailyLimit(_lessonPeriods(periods).length);
      } else {
        // AVOID_TIMESLOT / PREFER_BLOCK — always a single document, both
        // when creating and editing: there's no fan-out for these two
        // types, "any classroom"/"any day" are just plain null values on
        // the one document. For PREFER_BLOCK the whole classroom/day/slot
        // range is additionally optional (unlike AVOID_TIMESLOT, which
        // requires a classroom-independent start/end range).
        final model = ConstraintModel(
          id: '',
          schoolId: widget.schoolId,
          kind: _kind,
          type: type,
          subjectId: _subjectId,
          classroomId: _resolvedClassroomId,
          dayOfWeek: _resolvedDayOfWeek,
          periodId: _periodId,
          endPeriodId: _endPeriodId,
          weight: _kind == 'SOFT' ? _weight : null,
        );
        await repo.create(model);
        // Same reasoning as the MUST_ASSIGN/MUST_NOT_ASSIGN branch above.
        await _clearExistingDailyLimit(_lessonPeriods(periods).length);
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Resets the HARD daily limit this form was opened to edit (if any) back
  /// to its defaults. Called whenever a save ends up creating a different
  /// kind of representation instead of updating this one in place — without
  /// this, the old limit stays set on the classroom-subject assignment and
  /// shows up as a stale duplicate alongside the newly-saved constraint.
  Future<void> _clearExistingDailyLimit(int lessonPeriodsCount) async {
    final dl = widget.existingDailyLimit;
    if (dl == null) return;
    final uid = ref.read(currentUserProvider)!.uid;
    final repo = ClassroomSubjectRepository(uid: uid, schoolId: widget.schoolId);
    await repo.save(dl.copyWith(minDailyHours: 0, maxDailyHours: lessonPeriodsCount));
  }

  String? _validateRule() {
    if (_subjectId == null) return 'Please select a subject.';
    final type = _type;
    if (type == 'MUST_ASSIGN' || type == 'MUST_NOT_ASSIGN') {
      if (_classroomId == null) return 'Please select a classroom.';
      if (_dayOfWeek == null) return 'Please select a day.';
      if (_periodId == null) return 'Please select a slot.';
    } else if (type == 'AVOID_TIMESLOT') {
      if (_periodId == null) return 'Please select a start slot.';
      if (_endPeriodId == null) return 'Please select an end slot.';
    }
    // PREFER_BLOCK: only subject is required (checked above) — its
    // day/start/end slot fields are an optional scope, unlike AVOID_TIMESLOT
    // where start/end are mandatory.
    return null;
  }

  // ── Save (daily limit) ────────────────────────────────────────────────

  ClassroomSubjectModel? _matchingAssignment(
      List<ClassroomSubjectModel> classroomSubjects) {
    if (_dlSubjectId == null || _dlClassroomId == null) return null;
    return classroomSubjects.firstWhereOrNull((cs) =>
        cs.subjectId == _dlSubjectId && cs.classroomId == _dlClassroomId);
  }

  /// The assignment(s) this daily limit will apply to: either the one
  /// selected classroom, or — if "All classrooms" was picked — every
  /// classroom the subject is actually assigned to.
  List<ClassroomSubjectModel> _dlAssignments(
      List<ClassroomSubjectModel> classroomSubjects) {
    if (_dlSubjectId == null) return const [];
    if (_dlClassroomId == _kAllClassrooms) {
      return classroomSubjects
          .where((cs) => cs.subjectId == _dlSubjectId)
          .toList();
    }
    final single = _matchingAssignment(classroomSubjects);
    return single == null ? const [] : [single];
  }

  void _validateDailyLimit(
    List<ClassroomSubjectModel> assignments,
    Map<String, int> totalSlotsByClassroom,
    Map<String, String> classroomNames,
    int lessonPeriodsCount,
  ) {
    if (assignments.isEmpty) {
      setState(() => _dlErrors = []);
      return;
    }
    // SOFT is a preference, never a feasibility constraint — it can't make
    // generation impossible, so it only needs a basic min ≤ max sanity check
    // (skipped entirely once there's no max to compare against).
    if (_kind == 'SOFT') {
      setState(() {
        _dlErrors = (!_dlNoMax && _dlMin > 0 && _dlMin > _dlMax)
            ? ['Minimum daily hours cannot be greater than maximum.']
            : [];
      });
      return;
    }
    final l10n = AppLocalizations.of(context);
    final activeDayCount = ref.read(activeDaysProvider).length;
    final multi = assignments.length > 1;
    // "No maximum" for a hard limit means no cap beyond what a day can
    // physically hold — not literally infinite, since the validator still
    // needs a real bound to check feasibility against.
    final effectiveMax = _dlNoMax ? lessonPeriodsCount : _dlMax;
    final errors = <String>[];
    for (final cs in assignments) {
      final totalSlots = totalSlotsByClassroom[cs.classroomId] ?? 0;
      final result = SubjectValidator.validate(
        weeklyTarget: cs.weeklyTargetHours,
        minDaily: _dlMin,
        maxDaily: effectiveMax,
        activeDayCount: activeDayCount,
        totalLessonSlots: totalSlots,
      );
      final prefix = multi ? '${classroomNames[cs.classroomId] ?? cs.classroomId}: ' : '';
      for (final e in result.errors) {
        final message = switch (e) {
          SubjectValidationError.weeklyMustBePositive =>
            l10n.validationWeeklyMustBePositive,
          SubjectValidationError.minGtMax => l10n.validationMinGtMax,
          SubjectValidationError.maxDaysInsufficient =>
            l10n.validationMaxDaysInsufficient(
              effectiveMax * activeDayCount, cs.weeklyTargetHours),
          SubjectValidationError.weeklyExceedsSlots =>
            l10n.validationWeeklyExceedsSlots(cs.weeklyTargetHours, totalSlots),
          SubjectValidationError.minDailyInfeasible =>
            l10n.validationMinDailyInfeasible(cs.weeklyTargetHours, _dlMin),
        };
        errors.add('$prefix$message');
      }
    }
    setState(() => _dlErrors = errors);
  }

  int get _dlMin => int.tryParse(_minCtrl.text) ?? 0;
  int get _dlMax => int.tryParse(_maxCtrl.text) ?? 1;

  Future<void> _saveDailyLimit(
    List<ClassroomSubjectModel> assignments,
    int lessonPeriodsCount,
  ) async {
    setState(() { _saving = true; _error = null; });
    try {
      if (_kind == 'HARD') {
        final uid = ref.read(currentUserProvider)!.uid;
        final csRepo = ClassroomSubjectRepository(uid: uid, schoolId: widget.schoolId);
        final effectiveMax = _dlNoMax ? lessonPeriodsCount : _dlMax;
        await csRepo.saveMany([
          for (final cs in assignments)
            cs.copyWith(minDailyHours: _dlMin, maxDailyHours: effectiveMax),
        ]);
        // Editing moved this limit onto a different subject/classroom
        // assignment — the one we were opened to edit isn't in the set we
        // just saved, so its old min/max would otherwise stay set and show
        // up as a stale duplicate.
        final dl = widget.existingDailyLimit;
        if (dl != null && !assignments.any((cs) => cs.id == dl.id)) {
          await csRepo.save(dl.copyWith(
              minDailyHours: 0, maxDailyHours: lessonPeriodsCount));
        }
        // Was previously a SOFT DAILY_LIMIT ConstraintModel — that document
        // has no relation to the classroom-subject fields just written, so
        // it has to be deleted explicitly or it's left behind.
        if (widget.existing != null) {
          await ref
              .read(constraintRepositoryProvider(widget.schoolId))
              .delete(widget.existing!.id);
        }
      } else {
        final repo = ref.read(constraintRepositoryProvider(widget.schoolId));
        if (widget.existing != null) {
          // Editing an existing SOFT DAILY_LIMIT ConstraintModel always
          // targets exactly one document.
          final model = ConstraintModel(
            id:          widget.existing!.id,
            schoolId:    widget.schoolId,
            kind:        'SOFT',
            type:        'DAILY_LIMIT',
            subjectId:   _dlSubjectId,
            classroomId: _dlClassroomId,
            weight:      _weight,
            minHours:    _dlMin > 0 ? _dlMin : null,
            maxHours:    _dlNoMax ? null : _dlMax,
          );
          await repo.update(model);
        } else {
          await repo.createMany([
            for (final cs in assignments)
              ConstraintModel(
                id: '',
                schoolId: widget.schoolId,
                kind: 'SOFT',
                type: 'DAILY_LIMIT',
                subjectId: _dlSubjectId,
                classroomId: cs.classroomId,
                weight: _weight,
                minHours: _dlMin > 0 ? _dlMin : null,
                maxHours: _dlNoMax ? null : _dlMax,
              ),
          ]);
          // Arrived via existingDailyLimit (a HARD limit) but switched to
          // SOFT — see _clearExistingDailyLimit doc.
          await _clearExistingDailyLimit(lessonPeriodsCount);
        }
      }
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final subjectsAsync          = ref.watch(_subjectsProvider(widget.schoolId));
    final classroomsAsync        = ref.watch(_classroomsProvider(widget.schoolId));
    final periodsAsync           = ref.watch(_periodsProvider(widget.schoolId));
    final classroomSubjectsAsync = ref.watch(_classroomSubjectsProvider(widget.schoolId));
    final dayCapsAsync           = ref.watch(_dayCapacitiesProvider(widget.schoolId));
    // Only used to grey out slots a MUST_ASSIGN would immediately conflict
    // on (see _buildRuleFields) — a nice-to-have, not core form data, so it
    // doesn't gate the rest of the form behind another loading state; while
    // still loading, disabling simply doesn't kick in yet.
    final hardConstraints = (ref.watch(_constraintsProvider(widget.schoolId)).valueOrNull ?? const [])
        .where((c) => c.kind == 'HARD')
        .toList();
    final schoolName = ref.watch(schoolsStreamProvider).whenOrNull(
          data: (schools) => schools
              .firstWhereOrNull((s) => s.id == widget.schoolId)
              ?.name,
        );

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing ? l10n.edit : l10n.addConstraint,
              style: AppTextStyles.titleMedium
                  .copyWith(color: colors.textPrimary),
            ),
            if (schoolName != null)
              Text(
                schoolName,
                style: AppTextStyles.titleSmall.copyWith(color: colors.textMuted),
              ),
          ],
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text('Error: $e')),
            data: (periods) => classroomSubjectsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text('Error: $e')),
              data: (classroomSubjects) => dayCapsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error:   (e, _) => Center(child: Text('Error: $e')),
                data: (dayCaps) => _buildForm(
                  colors, l10n, subjects, classrooms, periods,
                  classroomSubjects, dayCaps, hardConstraints,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<PeriodModel> _lessonPeriods(List<PeriodModel> periods) =>
      periods.where((p) => p.type == PeriodType.lesson).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  int _totalSlotsFor(
    String classroomId,
    List<PeriodModel> periods,
    List<DayCapacityModel> dayCaps,
    List<String> activeDays,
  ) {
    final lessonsPerDay = _lessonPeriods(periods).length;
    final capacityByDay = <String, int>{};
    for (final cap in dayCaps.where((c) => c.classroomId == classroomId)) {
      capacityByDay[cap.dayOfWeek] = cap.activeSlots.length;
    }
    return activeDays.fold<int>(
      0,
      (sum, day) => sum + (capacityByDay[day] ?? lessonsPerDay),
    );
  }

  Widget _buildForm(
    AppColors colors,
    AppLocalizations l10n,
    List<SubjectModel> subjects,
    List<ClassroomModel> classrooms,
    List<PeriodModel> periods,
    List<ClassroomSubjectModel> classroomSubjects,
    List<DayCapacityModel> dayCaps,
    List<ConstraintModel> hardConstraints,
  ) {
    final lessonPeriods = _lessonPeriods(periods);
    final type = _type;
    final activeDays = ref.watch(activeDaysProvider);

    // Derive "no maximum" from the stored value now that lessonPeriods is
    // available (initState ran before this data existed). Guarded so it
    // only runs once — otherwise it would fight the user's own toggle.
    final dl = widget.existingDailyLimit;
    if (dl != null && !_dlNoMaxDetected) {
      _dlNoMaxDetected = true;
      _dlNoMax = dl.maxDailyHours >= lessonPeriods.length;
    }

    // Daily-limit derived state
    final dlClassroomsForSubject = _dlSubjectId == null
        ? const <ClassroomModel>[]
        : classrooms.where((c) => classroomSubjects.any(
            (cs) => cs.classroomId == c.id && cs.subjectId == _dlSubjectId)).toList();
    final dlAssignments = _dlAssignments(classroomSubjects);
    final dlClassroomNames = {for (final c in classrooms) c.id: c.name};
    final dlTotalSlotsByClassroom = {
      for (final cs in dlAssignments)
        cs.classroomId: _totalSlotsFor(cs.classroomId, periods, dayCaps, activeDays),
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Kind toggle: HARD | SOFT ────────────────────────────────
          _SectionLabel(label: 'Constraint Type', colors: colors),
          const SizedBox(height: 8),
          _KindToggle(
            kind: _kind,
            onChanged: _setKind,
            colors: colors,
            l10n: l10n,
          ),
          const SizedBox(height: 20),

          // ── Family + polarity ────────────────────────────────────────
          _SectionLabel(label: 'Rule', colors: colors),
          const SizedBox(height: 8),
          _RuleFamilySelector(
            kind: _kind,
            family: _family,
            positive: _positive,
            onSelectRule: (positive) => setState(() {
              _family = _Family.rule;
              _positive = positive;
              _error = null;
            }),
            onSelectDailyLimit: () => setState(() {
              _family = _Family.dailyLimit;
              _error = null;
            }),
          ),
          const SizedBox(height: 20),

          if (_family == _Family.rule)
            ..._buildRuleFields(colors, l10n, type, subjects, classrooms,
                periods, lessonPeriods, dayCaps, hardConstraints)
          else
            ..._buildDailyLimitFields(
              colors, l10n, subjects, dlClassroomsForSubject,
              dlAssignments, dlTotalSlotsByClassroom, dlClassroomNames,
              classroomSubjects, lessonPeriods.length,
            ),

          // ── Error ───────────────────────────────────────────────────
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.errorBg,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: colors.error.withOpacity(0.3)),
              ),
              child: Text(_error!,
                  style: AppTextStyles.bodySmall.copyWith(color: colors.error)),
            ),
            const SizedBox(height: 16),
          ],

          // ── Save ────────────────────────────────────────────────────
          CsButton(
            label: l10n.save,
            loading: _saving,
            onPressed: _family == _Family.rule
                ? () => _saveRule(subjects, classrooms, periods, classroomSubjects)
                : (dlAssignments.isNotEmpty && _dlErrors.isEmpty
                    ? () => _saveDailyLimit(dlAssignments, lessonPeriods.length)
                    : null),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// All 4 rule types (Must/Must-not/Prefer/Avoid) now share the exact same
  /// field set — Subject → Classroom → Day → Slot(s) — so switching between
  /// them never reshuffles the form; only which fields are *required* vs.
  /// "any X" differs:
  ///   MUST_ASSIGN/MUST_NOT_ASSIGN — classroom, day and slot all required.
  ///   AVOID_TIMESLOT              — classroom/day optional, slot required.
  ///   PREFER_BLOCK                — everything but subject is optional.
  List<Widget> _buildRuleFields(
    AppColors colors,
    AppLocalizations l10n,
    String type,
    List<SubjectModel> subjects,
    List<ClassroomModel> classrooms,
    List<PeriodModel> allPeriods,
    List<PeriodModel> lessonPeriods,
    List<DayCapacityModel> dayCaps,
    List<ConstraintModel> hardConstraints,
  ) {
    final classroomDayRequired =
        type == 'MUST_ASSIGN' || type == 'MUST_NOT_ASSIGN';

    final resolvedClassroomId = _resolvedClassroomId;
    final resolvedDay = _resolvedDayOfWeek;

    // ── Dynamic slot disabling ──────────────────────────────────────────
    // Reason strings double as the cell's tooltip.
    final disabledReasons = <int, String>{};

    // Structurally blocked for this classroom on this day — only checkable
    // once both are a concrete (non-"any") value.
    if (resolvedClassroomId != null && resolvedDay != null) {
      final cap = dayCaps.firstWhereOrNull((d) =>
          d.classroomId == resolvedClassroomId && d.dayOfWeek == resolvedDay);
      if (cap != null) {
        for (var i = 0; i < lessonPeriods.length; i++) {
          if (!cap.activeSlots.contains(i)) {
            disabledReasons[i] = 'Not available for this classroom on this day.';
          }
        }
      }
    }

    // MUST_ASSIGN only: the subject's teacher is already forced elsewhere
    // at this day/slot by another existing MUST_ASSIGN.
    if (type == 'MUST_ASSIGN' && _subjectId != null && resolvedDay != null) {
      final busyPeriodIds = ConstraintConflictDetector.teacherBusySlots(
        hardConstraints: hardConstraints,
        subjects: subjects,
        periods: allPeriods,
        subjectId: _subjectId!,
        dayOfWeek: resolvedDay,
        excludeConstraintId: widget.existing?.id,
      );
      for (var i = 0; i < lessonPeriods.length; i++) {
        if (busyPeriodIds.contains(lessonPeriods[i].id)) {
          disabledReasons[i] = 'Teacher already assigned elsewhere at this time.';
        }
      }
    }

    final startIdx = _lessonIndexOf(_periodId, lessonPeriods);
    final endIdx   = _lessonIndexOf(_endPeriodId, lessonPeriods);

    return [
      // ── Subject (always required) ─────────────────────────────────
      _SectionLabel(label: l10n.subjects, colors: colors),
      const SizedBox(height: 8),
      CsDropdown<String>(
        key: const ValueKey('subject'),
        value: _subjectId,
        hint: 'Select subject',
        items: subjects.map((s) => DropdownMenuItem(
          value: s.id,
          child: Text(s.name),
        )).toList(),
        onChanged: (v) => setState(() => _subjectId = v),
      ),
      const SizedBox(height: 16),

      // ── Classroom ────────────────────────────────────────────────
      // Label AND hint text stay the same regardless of type, so Hard and
      // Soft rules read identically — "Any classroom"/"Any day" is just the
      // placeholder shown before a choice is made; for Must/Must-not a
      // concrete classroom/day is still required at save time (_validateRule).
      _SectionLabel(label: l10n.classrooms, colors: colors),
      const SizedBox(height: 8),
      CsDropdown<String>(
        key: const ValueKey('classroom'),
        value: _classroomId,
        hint: 'Any classroom',
        items: classroomDayRequired
            ? _classroomItems(classrooms, colors)
            : _classroomItemsOptional(classrooms, colors),
        onChanged: (v) => setState(() => _classroomId = v),
      ),
      const SizedBox(height: 16),

      // ── Day ──────────────────────────────────────────────────────
      _SectionLabel(label: 'Day', colors: colors),
      const SizedBox(height: 8),
      CsDropdown<String>(
        key: const ValueKey('day'),
        value: _dayOfWeek,
        hint: 'Any day',
        items: classroomDayRequired
            ? _dayItemsForRule(l10n, colors)
            : _dayItemsOptional(l10n, colors),
        onChanged: (v) => setState(() => _dayOfWeek = v),
      ),
      const SizedBox(height: 16),

      // ── Slot(s) — visual picker instead of dropdowns ────────────────
      _SectionLabel(label: 'Slot', colors: colors),
      const SizedBox(height: 8),
      SlotRangePicker(
        allPeriods: allPeriods,
        startSlotIdx: startIdx,
        endSlotIdx: endIdx,
        disabledLessonIndices: disabledReasons.keys.toSet(),
        disabledReasons: disabledReasons,
        colors: colors,
        onRangeChanged: (start, end) => setState(() {
          _periodId = start != null ? lessonPeriods[start].id : null;
          _endPeriodId = end != null ? lessonPeriods[end].id : null;
        }),
      ),
      const SizedBox(height: 4),
      Text(
        'Tap a slot to select it, tap another to select a range.',
        style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted),
      ),
      const SizedBox(height: 16),

      // ── Weight (SOFT only) ──────────────────────────────────────
      if (_kind == 'SOFT') ...[
        _SectionLabel(label: 'Priority', colors: colors),
        const SizedBox(height: 8),
        _WeightSelector(
          weight: _weight,
          onChanged: (w) => setState(() => _weight = w),
          colors: colors,
          l10n: l10n,
        ),
        const SizedBox(height: 16),
      ],
    ];
  }

  int? _lessonIndexOf(String? periodId, List<PeriodModel> lessonPeriods) {
    if (periodId == null) return null;
    final idx = lessonPeriods.indexWhere((p) => p.id == periodId);
    return idx == -1 ? null : idx;
  }

  List<Widget> _buildDailyLimitFields(
    AppColors colors,
    AppLocalizations l10n,
    List<SubjectModel> subjects,
    List<ClassroomModel> availableClassrooms,
    List<ClassroomSubjectModel> assignments,
    Map<String, int> totalSlotsByClassroom,
    Map<String, String> classroomNames,
    List<ClassroomSubjectModel> classroomSubjects,
    int lessonPeriodsCount,
  ) {
    return [
      _SectionLabel(label: l10n.subjects, colors: colors),
      const SizedBox(height: 8),
      CsDropdown<String>(
        key: const ValueKey('dl-subject'),
        value: _dlSubjectId,
        hint: 'Select subject',
        items: subjects.map((s) => DropdownMenuItem(
          value: s.id,
          child: Text(s.name),
        )).toList(),
        onChanged: (v) => setState(() {
          _dlSubjectId = v;
          _dlClassroomId = null;
          _dlErrors = [];
        }),
      ),
      const SizedBox(height: 16),

      _SectionLabel(label: l10n.classrooms, colors: colors),
      const SizedBox(height: 8),
      CsDropdown<String>(
        key: const ValueKey('dl-classroom'),
        value: _dlClassroomId,
        hint: _dlSubjectId == null
            ? 'Select a subject first'
            : (availableClassrooms.isEmpty
                ? 'Not assigned to any classroom yet'
                : 'Select classroom'),
        items: [
          if (!_isEditing && availableClassrooms.length > 1)
            DropdownMenuItem(
              value: _kAllClassrooms,
              child: Text('All classrooms',
                  style: TextStyle(
                      color: colors.primary, fontWeight: FontWeight.w600)),
            ),
          ...availableClassrooms.map((c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              )),
        ],
        onChanged: (v) => setState(() {
          _dlClassroomId = v;
          if (v == _kAllClassrooms) {
            // No single source to prefill from — reset to defaults.
            _minCtrl.text = '0';
            _maxCtrl.text = '1';
            _dlNoMax = false;
          } else {
            final cs = _matchingAssignment(classroomSubjects);
            if (cs != null) {
              _minCtrl.text = '${cs.minDailyHours}';
              _maxCtrl.text = '${cs.maxDailyHours}';
              _dlNoMax = cs.maxDailyHours >= lessonPeriodsCount;
            }
          }
          _dlErrors = [];
        }),
      ),
      const SizedBox(height: 16),

      if (_dlSubjectId != null && availableClassrooms.isEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'This subject isn\'t assigned to any classroom yet. '
            'Assign it first in Setup → Subjects.',
            style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted),
          ),
        ),

      if (assignments.isNotEmpty) ...[
        CsTextField(
          controller: _minCtrl,
          label: l10n.minDailyHours,
          hint: '0',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _validateDailyLimit(assignments,
              totalSlotsByClassroom, classroomNames, lessonPeriodsCount),
        ),
        const SizedBox(height: 4),
        Text(
          'Applies only on days this subject is actually scheduled — a day '
          'with no lesson at all is still allowed. 0 disables the minimum.',
          style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: 12),
        Opacity(
          opacity: _dlNoMax ? 0.4 : 1.0,
          child: IgnorePointer(
            ignoring: _dlNoMax,
            child: CsTextField(
              controller: _maxCtrl,
              label: l10n.maxDailyHours,
              hint: '2',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => _validateDailyLimit(assignments,
                  totalSlotsByClassroom, classroomNames, lessonPeriodsCount),
            ),
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => setState(() {
            _dlNoMax = !_dlNoMax;
            _validateDailyLimit(assignments, totalSlotsByClassroom,
                classroomNames, lessonPeriodsCount);
          }),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _dlNoMax,
                activeColor: colors.primary,
                onChanged: (v) => setState(() {
                  _dlNoMax = v ?? false;
                  _validateDailyLimit(assignments, totalSlotsByClassroom,
                      classroomNames, lessonPeriodsCount);
                }),
              ),
              Text('No maximum (up to a full day)',
                  style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (assignments.length == 1)
          Text(
            'Weekly target: ${assignments.first.weeklyTargetHours}h · '
            '${ref.watch(activeDaysProvider).length} active days · '
            'max capacity: ${totalSlotsByClassroom[assignments.first.classroomId] ?? 0} slots',
            style: AppTextStyles.bodySmall.copyWith(color: colors.textDisabled),
          )
        else
          Text(
            '${assignments.length} classrooms: ' +
                assignments
                    .map((cs) =>
                        '${classroomNames[cs.classroomId] ?? cs.classroomId} '
                        '(${cs.weeklyTargetHours}h/wk)')
                    .join(', '),
            style: AppTextStyles.bodySmall.copyWith(color: colors.textDisabled),
          ),
        const SizedBox(height: 12),
        if (_kind == 'SOFT') ...[
          _SectionLabel(label: 'Priority', colors: colors),
          const SizedBox(height: 8),
          _WeightSelector(
            weight: _weight,
            onChanged: (w) => setState(() => _weight = w),
            colors: colors,
            l10n: l10n,
          ),
          const SizedBox(height: 12),
        ],
        if (_dlErrors.isNotEmpty)
          ..._dlErrors.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline, size: 14, color: colors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(e,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colors.error)),
                    ),
                  ],
                ),
              )),
        const SizedBox(height: 4),
      ],
    ];
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

  /// Day items with an "All days" option prepended — only when creating,
  /// since editing always targets the one day the existing document has.
  List<DropdownMenuItem<String>> _dayItemsForRule(
    AppLocalizations l10n,
    AppColors colors,
  ) => [
    if (!_isEditing)
      DropdownMenuItem(
        value: _kAllDays,
        child: Text('All days',
            style: TextStyle(
                color: colors.primary, fontWeight: FontWeight.w600)),
      ),
    ..._dayItems(l10n),
  ];

  /// Classroom items with an "All classrooms" option prepended — only when
  /// creating, for the same reason as _dayItemsForRule.
  List<DropdownMenuItem<String>> _classroomItems(
    List<ClassroomModel> classrooms,
    AppColors colors,
  ) => [
    if (!_isEditing)
      DropdownMenuItem(
        value: _kAllClassrooms,
        child: Text('All classrooms',
            style: TextStyle(
                color: colors.primary, fontWeight: FontWeight.w600)),
      ),
    ...classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
  ];

  /// Day items for AVOID_TIMESLOT/PREFER_BLOCK — an "Any day" item is always
  /// offered (create or edit), unlike _dayItemsForRule's create-only "All
  /// days": here it resolves to a plain `null` on the one document rather
  /// than fanning out into several, so there's no reason to hide it while
  /// editing.
  List<DropdownMenuItem<String>> _dayItemsOptional(
    AppLocalizations l10n,
    AppColors colors,
  ) => [
    DropdownMenuItem(
      value: _kAnyDay,
      child: Text('Any day',
          style: TextStyle(
              color: colors.primary, fontWeight: FontWeight.w600)),
    ),
    ..._dayItems(l10n),
  ];

  /// Classroom items for AVOID_TIMESLOT/PREFER_BLOCK — see _dayItemsOptional.
  List<DropdownMenuItem<String>> _classroomItemsOptional(
    List<ClassroomModel> classrooms,
    AppColors colors,
  ) => [
    DropdownMenuItem(
      value: _kAnyClassroom,
      child: Text('Any classroom',
          style: TextStyle(
              color: colors.primary, fontWeight: FontWeight.w600)),
    ),
    ...classrooms.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
  ];
}

// ── Kind toggle ────────────────────────────────────────────────────────────

class _KindToggle extends StatelessWidget {
  final String kind;
  final ValueChanged<String> onChanged;
  final AppColors colors; final AppLocalizations l10n;
  const _KindToggle({
    required this.kind, required this.onChanged,
    required this.colors, required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _KindChip(
        label: l10n.hardConstraints,
        selected: kind == 'HARD',
        color: colors.error,
        colors: colors,
        onTap: () => onChanged('HARD'),
      ),
      const SizedBox(width: 10),
      _KindChip(
        label: l10n.softConstraints,
        selected: kind == 'SOFT',
        color: colors.warning,
        colors: colors,
        onTap: () => onChanged('SOFT'),
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

// ── Rule family + polarity selector ─────────────────────────────────────────

class _RuleFamilySelector extends StatelessWidget {
  final String kind;
  final _Family family;
  final bool positive;
  final ValueChanged<bool> onSelectRule;
  final VoidCallback onSelectDailyLimit;

  const _RuleFamilySelector({
    required this.kind,
    required this.family,
    required this.positive,
    required this.onSelectRule,
    required this.onSelectDailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isHard = kind == 'HARD';

    final positiveLabel = isHard ? 'Must' : 'Prefer';
    final negativeLabel = isHard ? 'Must not' : 'Avoid';
    final positiveDesc  = isHard
        ? 'Force a subject into a specific classroom slot.'
        : 'Encourage consecutive lessons for a subject, optionally '
            'limited to a day/time range.';
    final negativeDesc  = isHard
        ? 'Block a subject from a specific classroom slot.'
        : 'Discourage a subject during a time range.';

    return Column(
      children: [
        _RuleCard(
          label: positiveLabel,
          description: positiveDesc,
          selected: family == _Family.rule && positive,
          colors: colors,
          onTap: () => onSelectRule(true),
        ),
        const SizedBox(height: 8),
        _RuleCard(
          label: negativeLabel,
          description: negativeDesc,
          selected: family == _Family.rule && !positive,
          colors: colors,
          onTap: () => onSelectRule(false),
        ),
        const SizedBox(height: 8),
        _RuleCard(
          label: 'Daily limit',
          description: isHard
              ? 'Require a minimum and/or maximum number of daily hours '
                  'for a subject — blocks generation if unmet.'
              : 'Prefer a minimum and/or maximum number of daily hours '
                  'for a subject — a guideline, never blocks generation.',
          selected: family == _Family.dailyLimit,
          colors: colors,
          onTap: onSelectDailyLimit,
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  final String label;
  final String description;
  final bool selected;
  final AppColors colors;
  final VoidCallback onTap;

  const _RuleCard({
    required this.label,
    required this.description,
    required this.selected,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected ? colors.primary.withOpacity(0.1) : colors.cardBg,
        border: Border.all(
          color: selected ? colors.primary : colors.borderDefault,
          width: selected ? 1.5 : 1,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(children: [
        Radio<bool>(
          value: true,
          groupValue: selected,
          toggleable: true,
          activeColor: colors.primary,
          onChanged: (_) => onTap(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.labelMedium.copyWith(
                      color: selected ? colors.primary : colors.textPrimary)),
              const SizedBox(height: 2),
              Text(description,
                  style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted)),
            ],
          ),
        ),
      ]),
    ),
  );
}

// ── Weight selector ────────────────────────────────────────────────────────

class _WeightSelector extends StatelessWidget {
  final String? weight;
  final ValueChanged<String> onChanged;
  final AppColors colors; final AppLocalizations l10n;
  const _WeightSelector({
    required this.weight, required this.onChanged,
    required this.colors, required this.l10n,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: ['LOW', 'MEDIUM', 'HIGH'].map((w) {
      final selected = weight == w;
      final label    = w == 'LOW' ? l10n.weightLow
                     : w == 'HIGH' ? l10n.weightHigh
                     : l10n.weightMedium;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(w),
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
//
// Shared with constraints_screen.dart — see constraint_data_providers.dart.
// Local aliases keep the rest of this file's call sites unchanged. This
// screen used to declare its own private copies of these providers; that
// meant it opened a second, independent set of Firestore listeners instead
// of reusing the ones the list screen already has warmed up, which is worth
// ruling out entirely rather than trusting it was harmless.

final _subjectsProvider = constraintSubjectsProvider;
final _classroomsProvider = constraintClassroomsProvider;
final _periodsProvider = constraintPeriodsProvider;
final _classroomSubjectsProvider = constraintClassroomSubjectsProvider;
final _dayCapacitiesProvider = constraintDayCapacitiesProvider;
final _constraintsProvider = constraintsListProvider;
