// lib/presentation/constraints/constraints_screen.dart
//
// FR-HC-04, FR-SC-03: Constraint list with Hard | Soft tabs.
// Each constraint shown as a human-readable sentence (ConstraintLabelBuilder).
// Swipe-to-delete with undo snackbar. Conflict detection banner at top.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/school_repository.dart';
import '../../data/repositories/subject_repositories.dart' show ClassroomSubjectRepository;
import '../../domain/constraints/constraint_conflict_detector.dart';
import '../../domain/constraints/constraint_label_builder.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_providers.dart';
import 'constraint_data_providers.dart';

// ── Providers ──────────────────────────────────────────────────────────────
//
// Shared with constraint_form_screen.dart — see constraint_data_providers.dart.
// Local aliases keep the rest of this file's call sites unchanged.

final _constraintsProvider = constraintsListProvider;
final _subjectsProvider = constraintSubjectsProvider;
final _classroomsProvider = constraintClassroomsProvider;
final _periodsProvider = constraintPeriodsProvider;
final _classroomSubjectsProvider = constraintClassroomSubjectsProvider;

// ── Screen ─────────────────────────────────────────────────────────────────

class ConstraintsScreen extends ConsumerStatefulWidget {
  const ConstraintsScreen({super.key});

  @override
  ConsumerState<ConstraintsScreen> createState() => _ConstraintsScreenState();
}

class _ConstraintsScreenState extends ConsumerState<ConstraintsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);
    final schoolId = ref.watch(constraintsActiveSchoolProvider);

    // Mirrors SetupScreen: prompt for a school right here instead of
    // bouncing the user to the Schools tab first. Uses its own selection
    // state (constraintsActiveSchoolProvider), not the app-wide
    // selectedSchoolIdProvider — that one gets auto-set to the first school
    // as soon as the Schools tab loads, which would otherwise skip this
    // picker on every first visit.
    if (schoolId == null || schoolId.isEmpty) {
      final schools = ref.watch(schoolsStreamProvider);
      return Scaffold(
        body: SafeArea(
          child: schools.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:   (e, _) => Center(child: Text(e.toString())),
            data:    (list) => list.isEmpty
                ? _NoSchoolPrompt(colors: colors)
                : _SchoolPicker(
                    schools: list,
                    colors: colors,
                    onSelect: (s) => ref
                        .read(constraintsActiveSchoolProvider.notifier)
                        .state = s.id,
                  ),
          ),
        ),
      );
    }

    final constraintsAsync = ref.watch(_constraintsProvider(schoolId));
    final subjectsAsync = ref.watch(_subjectsProvider(schoolId));
    final classroomsAsync = ref.watch(_classroomsProvider(schoolId));
    final periodsAsync = ref.watch(_periodsProvider(schoolId));
    final classroomSubjectsAsync =
        ref.watch(_classroomSubjectsProvider(schoolId));
    final schoolName = ref.watch(schoolsStreamProvider).whenOrNull(
          data: (schools) =>
              schools.firstWhereOrNull((s) => s.id == schoolId)?.name,
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.constraints,
                          style: AppTextStyles.headingLarge
                              .copyWith(color: colors.textPrimary)),
                      if (schoolName != null)
                        Row(children: [
                          Flexible(
                            child: Text(schoolName,
                                style: AppTextStyles.titleSmall
                                    .copyWith(color: colors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => ref
                                .read(constraintsActiveSchoolProvider.notifier)
                                .state = null,
                            child: Text('Change',
                                style: AppTextStyles.labelSmall
                                    .copyWith(color: colors.primaryLight)),
                          ),
                        ]),
                    ],
                  ),
                ),
                _AddButton(
                    schoolId: schoolId, colors: colors, l10n: l10n),
              ]),
            ),
            const SizedBox(height: 16),

            // Conflict banner — only renders when all data ready
            constraintsAsync.whenOrNull(
                  data: (constraints) => subjectsAsync.whenOrNull(
                    data: (subjects) => classroomsAsync.whenOrNull(
                      data: (classrooms) => periodsAsync.whenOrNull(
                        data: (periods) => classroomSubjectsAsync.whenOrNull(
                          data: (classroomSubjects) => _ConflictBanner(
                            constraints: constraints,
                            subjects: subjects,
                            classrooms: classrooms,
                            periods: periods,
                            classroomSubjects: classroomSubjects,
                            colors: colors,
                          ),
                        ),
                      ),
                    ),
                  ),
                ) ??
                const SizedBox.shrink(),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [colors.primary, colors.primaryLight]),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd - 2),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: AppTextStyles.labelMedium,
                  labelColor: Colors.white,
                  unselectedLabelColor: colors.textMuted,
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: l10n.hardConstraints),
                    Tab(text: l10n.softConstraints),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Tab views
            Expanded(
              child: constraintsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (all) {
                  final hard = all.where((c) => c.kind == 'HARD').toList();
                  final soft = all.where((c) => c.kind == 'SOFT').toList();

                  return subjectsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (subjects) => classroomsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (classrooms) => periodsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (periods) => classroomSubjectsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (e, _) => Center(child: Text('Error: $e')),
                          data: (classroomSubjects) {
                            final builder = ConstraintLabelBuilder(
                              subjects: {for (final s in subjects) s.id: s},
                              classrooms: {for (final c in classrooms) c.id: c},
                              periods: {for (final p in periods) p.id: p},
                            );
                            // Hard daily limits aren't ConstraintModel
                            // documents (see class doc in
                            // constraint_form_screen.dart) — they're
                            // structural fields on the classroom-subject
                            // assignment, so they'd otherwise be invisible
                            // here even after being "created". Surface any
                            // assignment with a non-default min/max as a
                            // tile too.
                            final lessonPeriodsCount = periods
                                .where((p) => p.type == PeriodType.lesson)
                                .length;
                            final customizedDailyLimits = classroomSubjects
                                .where((cs) =>
                                    cs.minDailyHours > 0 ||
                                    cs.maxDailyHours < lessonPeriodsCount)
                                .toList();
                            return TabBarView(
                              controller: _tabs,
                              children: [
                                _ConstraintList(
                                  constraints: hard,
                                  dailyLimits: customizedDailyLimits,
                                  subjectsById: builder.subjects,
                                  classroomsById: builder.classrooms,
                                  lessonPeriodsCount: lessonPeriodsCount,
                                  schoolId: schoolId,
                                  labelBuilder: builder,
                                  isHard: true,
                                  colors: colors,
                                  l10n: l10n,
                                ),
                                _ConstraintList(
                                  constraints: soft,
                                  dailyLimits: const [],
                                  subjectsById: const {},
                                  classroomsById: const {},
                                  lessonPeriodsCount: lessonPeriodsCount,
                                  schoolId: schoolId,
                                  labelBuilder: builder,
                                  isHard: false,
                                  colors: colors,
                                  l10n: l10n,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Conflict banner ───────────────────────────────────────────────────────

class _ConflictBanner extends StatefulWidget {
  final List<ConstraintModel> constraints;
  final List<SubjectModel> subjects;
  final List<ClassroomModel> classrooms;
  final List<PeriodModel> periods;
  final List<ClassroomSubjectModel> classroomSubjects;
  final AppColors colors;
  const _ConflictBanner({
    required this.constraints,
    required this.subjects,
    required this.classrooms,
    required this.periods,
    required this.classroomSubjects,
    required this.colors,
  });
  @override
  State<_ConflictBanner> createState() => _ConflictBannerState();
}

class _ConflictBannerState extends State<_ConflictBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final hardConstraints =
        widget.constraints.where((c) => c.kind == 'HARD').toList();

    // Build per-day lesson period map
    final Map<String, List<PeriodModel>> byDay = {};
    for (final p in widget.periods.where((p) => p.type == 'LESSON')) {
      final days = p.dayApplicability ?? ['MON', 'TUE', 'WED', 'THU', 'FRI'];
      for (final d in days) {
        byDay.putIfAbsent(d, () => []).add(p);
      }
    }

    final conflicts = ConstraintConflictDetector.detect(
      hardConstraints: hardConstraints,
      periods: widget.periods,
      subjects: widget.subjects,
      classroomSubjects: widget.classroomSubjects,
      lessonPeriodsPerDay: byDay,
    );

    if (conflicts.isEmpty) return const SizedBox.shrink();

    final colors = widget.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: colors.errorBg,
          border: Border.all(color: colors.error.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(children: [
                  Icon(Icons.warning_amber_rounded,
                      color: colors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${conflicts.length} constraint conflict'
                      '${conflicts.length == 1 ? '' : 's'} detected — '
                      'tap to ${_expanded ? 'hide' : 'view'}',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: colors.error),
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: colors.error,
                    size: 18,
                  ),
                ]),
              ),
            ),
            if (_expanded)
              ...conflicts.map((c) => Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.description,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: colors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('💡 ${c.suggestion}',
                            style: AppTextStyles.labelSmall
                                .copyWith(color: colors.textMuted)),
                        Divider(color: colors.borderSubtle, height: 16),
                      ],
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}

// ── Constraint list ───────────────────────────────────────────────────────

class _ConstraintList extends ConsumerWidget {
  final List<ConstraintModel> constraints;
  final List<ClassroomSubjectModel> dailyLimits;
  final Map<String, SubjectModel> subjectsById;
  final Map<String, ClassroomModel> classroomsById;
  final int lessonPeriodsCount;
  final String schoolId;
  final ConstraintLabelBuilder labelBuilder;
  final bool isHard;
  final AppColors colors;
  final AppLocalizations l10n;

  const _ConstraintList({
    required this.constraints,
    required this.dailyLimits,
    required this.subjectsById,
    required this.classroomsById,
    required this.lessonPeriodsCount,
    required this.schoolId,
    required this.labelBuilder,
    required this.isHard,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (constraints.isEmpty && dailyLimits.isEmpty) {
      return _EmptyState(isHard: isHard, colors: colors, l10n: l10n);
    }
    final itemCount = dailyLimits.length + constraints.length;
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        if (i < dailyLimits.length) {
          final cs = dailyLimits[i];
          return _DailyLimitAssignmentTile(
            assignment: cs,
            subjectName: subjectsById[cs.subjectId]?.name ?? cs.subjectId,
            classroomName: classroomsById[cs.classroomId]?.name ?? cs.classroomId,
            colors: colors,
            onTap: () => context.push(
              AppRoutes.constraintForm(cs.id),
              extra: ConstraintFormRouteArgs(
                schoolId: schoolId,
                existingDailyLimit: cs,
              ),
            ),
            onDelete: () => _resetDailyLimit(context, ref, cs),
          );
        }
        final c = constraints[i - dailyLimits.length];
        return _ConstraintTile(
          constraint: c,
          labelBuilder: labelBuilder,
          colors: colors,
          l10n: l10n,
          onDelete: () => _delete(context, ref, c),
          onTap: () => context.push(
            AppRoutes.constraintForm(c.id),
            extra: ConstraintFormRouteArgs(
              schoolId: schoolId,
              existing: c,
            ),
          ),
        );
      },
    );
  }

  Future<void> _delete(
      BuildContext ctx, WidgetRef ref, ConstraintModel c) async {
    final repo = ref.read(constraintRepositoryProvider(schoolId));
    await repo.delete(c.id);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(l10n.constraintDeleted),
        action: SnackBarAction(
            label: l10n.undoDelete, onPressed: () => repo.create(c)),
      ),
    );
  }

  /// A hard daily limit isn't a document you can delete — it's structural
  /// fields on the classroom-subject assignment (see class doc above) — so
  /// "removing" it means resetting those fields back to their defaults
  /// (no minimum, capped only by the day's physical slot count).
  Future<void> _resetDailyLimit(
      BuildContext ctx, WidgetRef ref, ClassroomSubjectModel cs) async {
    final uid = ref.read(currentUserProvider)!.uid;
    final repo = ClassroomSubjectRepository(uid: uid, schoolId: schoolId);
    await repo.save(cs.copyWith(
      minDailyHours: 0,
      maxDailyHours: lessonPeriodsCount,
    ));
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(l10n.constraintDeleted),
        action: SnackBarAction(
          label: l10n.undoDelete,
          onPressed: () => repo.save(cs),
        ),
      ),
    );
  }
}

// ── Daily-limit assignment tile (hard limits only — see class doc above) ───

class _DailyLimitAssignmentTile extends StatelessWidget {
  final ClassroomSubjectModel assignment;
  final String subjectName;
  final String classroomName;
  final AppColors colors;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DailyLimitAssignmentTile({
    required this.assignment,
    required this.subjectName,
    required this.classroomName,
    required this.colors,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final min = assignment.minDailyHours;
    final max = assignment.maxDailyHours;
    final desc = min > 0
        ? '$subjectName in $classroomName: min ${min}h/day, max ${max}h/day.'
        : '$subjectName in $classroomName: max ${max}h/day.';

    return Dismissible(
      key: ValueKey(assignment.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.errorBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.error),
      ),
      child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.cardBg,
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 44,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: colors.error,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.error.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('HARD · DAILY LIMIT',
                        style: AppTextStyles.overline.copyWith(color: colors.error)),
                  ),
                  const SizedBox(height: 6),
                  Text(desc,
                      style: AppTextStyles.bodyMedium.copyWith(color: colors.textPrimary)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline_rounded,
                  color: colors.textMuted, size: 20),
              tooltip: 'Delete',
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted, size: 20),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Single tile ───────────────────────────────────────────────────────────

class _ConstraintTile extends StatelessWidget {
  final ConstraintModel constraint;
  final ConstraintLabelBuilder labelBuilder;
  final AppColors colors;
  final AppLocalizations l10n;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ConstraintTile({
    required this.constraint,
    required this.labelBuilder,
    required this.colors,
    required this.l10n,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHard = constraint.kind == 'HARD';
    final accentCol = isHard ? colors.error : colors.warning;

    return Dismissible(
      key: ValueKey(constraint.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.errorBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Icon(Icons.delete_outline_rounded, color: colors.error),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.cardBg,
            border: Border.all(color: colors.borderDefault),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Accent bar
              Container(
                width: 4,
                height: 44,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: accentCol,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kind + weight badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentCol.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isHard
                            ? 'HARD'
                            : 'SOFT · ${constraint.weight ?? 'MEDIUM'}',
                        style:
                            AppTextStyles.overline.copyWith(color: accentCol),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labelBuilder.label(constraint),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded,
                    color: colors.textMuted, size: 20),
                tooltip: 'Delete',
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: colors.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isHard;
  final AppColors colors;
  final AppLocalizations l10n;
  const _EmptyState(
      {required this.isHard, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isHard ? Icons.lock_outline_rounded : Icons.tune_outlined,
              size: 56,
              color: colors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              isHard ? 'No hard constraints yet.' : 'No preferences set yet.',
              style:
                  AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              isHard
                  ? 'Hard constraints force or block\nspecific slot assignments.'
                  : 'Preferences guide the scheduler\nbut never block a solution.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(color: colors.textMuted),
            ),
          ]),
        ),
      );
}

// ── Add button ────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  final String schoolId;
  final AppColors colors;
  final AppLocalizations l10n;

  const _AddButton({
    required this.schoolId,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push(
          AppRoutes.constraintForm('new'),
          extra: ConstraintFormRouteArgs(schoolId: schoolId),
        ),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [colors.primary, colors.primaryLight]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: colors.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        ),
      );
}

// ── School picker (mirrors SetupScreen's) ─────────────────────────────────

class _NoSchoolPrompt extends StatelessWidget {
  final AppColors colors;
  const _NoSchoolPrompt({required this.colors});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.school_outlined, size: 64, color: colors.textMuted),
              const SizedBox(height: 16),
              Text('No schools yet.',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text('Go to the Schools tab to create your first school.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: colors.textMuted)),
            ],
          ),
        ),
      );
}

class _SchoolPicker extends StatelessWidget {
  final List<SchoolModel> schools;
  final AppColors colors;
  final void Function(SchoolModel) onSelect;

  const _SchoolPicker({
    required this.schools,
    required this.colors,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text('Select a school for constraints',
                style: AppTextStyles.titleMedium
                    .copyWith(color: colors.textPrimary)),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: schools.length,
              itemBuilder: (_, i) => ListTile(
                leading: Icon(Icons.school_outlined, color: colors.primary),
                title: Text(schools[i].name,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: colors.textPrimary)),
                trailing: Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: colors.textMuted),
                onTap: () => onSelect(schools[i]),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      );
}
