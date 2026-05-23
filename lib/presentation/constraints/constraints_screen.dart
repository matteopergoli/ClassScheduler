// lib/presentation/constraints/constraints_screen.dart
//
// FR-HC-04, FR-SC-03: Constraint list with Hard | Soft tabs.
// Each constraint shown as a human-readable sentence (ConstraintLabelBuilder).
// Swipe-to-delete with undo snackbar. Conflict detection banner at top.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../data/repositories/subject_repositories.dart';
import '../../domain/constraints/constraint_conflict_detector.dart';
import '../../domain/constraints/constraint_label_builder.dart';
import '../../domain/validation/subject_validator.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_providers.dart';
import '../widgets/cs_button.dart';
import '../widgets/cs_text_field.dart';
import '../setup/step1_periods/step1_periods_screen.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final _constraintsProvider =
    StreamProvider.family<List<ConstraintModel>, String>(
  (ref, schoolId) =>
      ref.watch(constraintRepositoryProvider(schoolId)).watchAll(),
);

final _subjectsProvider = StreamProvider.family<List<SubjectModel>, String>(
  (ref, schoolId) => ref.watch(subjectRepositoryProvider(schoolId)).watchAll(),
);

final _classroomsProvider = StreamProvider.family<List<ClassroomModel>, String>(
  (ref, schoolId) =>
      ref.watch(classroomRepositoryProvider(schoolId)).watchAll(),
);

final _periodsProvider = StreamProvider.family<List<PeriodModel>, String>(
  (ref, schoolId) => ref.watch(periodRepositoryProvider(schoolId)).watchAll(),
);

final _classroomSubjectsProvider =
    StreamProvider.family<List<ClassroomSubjectModel>, String>(
  (ref, schoolId) =>
      ref.watch(classroomSubjectRepositoryProvider(schoolId)).watchAll(),
);

final _dayCapacitiesProvider =
    StreamProvider.family<List<DayCapacityModel>, String>(
  (ref, schoolId) =>
      ref.watch(dayCapacityRepositoryProvider(schoolId)).watchAll(),
);

// ── Screen ─────────────────────────────────────────────────────────────────

class ConstraintsScreen extends ConsumerStatefulWidget {
  final String schoolId;
  const ConstraintsScreen({super.key, required this.schoolId});

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

    final constraintsAsync = ref.watch(_constraintsProvider(widget.schoolId));
    final subjectsAsync = ref.watch(_subjectsProvider(widget.schoolId));
    final classroomsAsync = ref.watch(_classroomsProvider(widget.schoolId));
    final periodsAsync = ref.watch(_periodsProvider(widget.schoolId));
    final classroomSubjectsAsync =
        ref.watch(_classroomSubjectsProvider(widget.schoolId));
    final activeDays = ref.watch(activeDaysProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Text(l10n.constraints,
                      style: AppTextStyles.displayMedium
                          .copyWith(color: colors.textPrimary)),
                ),
                _DailyLimitsButton(
                  schoolId: widget.schoolId,
                  colors: colors,
                  l10n: l10n,
                  activeDays: activeDays,
                ),
                const SizedBox(width: 12),
                _AddButton(
                    schoolId: widget.schoolId, colors: colors, l10n: l10n),
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
                            return TabBarView(
                              controller: _tabs,
                              children: [
                                _ConstraintList(
                                  constraints: hard,
                                  schoolId: widget.schoolId,
                                  labelBuilder: builder,
                                  isHard: true,
                                  colors: colors,
                                  l10n: l10n,
                                ),
                                _ConstraintList(
                                  constraints: soft,
                                  schoolId: widget.schoolId,
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
  final String schoolId;
  final ConstraintLabelBuilder labelBuilder;
  final bool isHard;
  final AppColors colors;
  final AppLocalizations l10n;

  const _ConstraintList({
    required this.constraints,
    required this.schoolId,
    required this.labelBuilder,
    required this.isHard,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (constraints.isEmpty) {
      return _EmptyState(isHard: isHard, colors: colors, l10n: l10n);
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: constraints.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final c = constraints[i];
        return _ConstraintTile(
          constraint: c,
          labelBuilder: labelBuilder,
          colors: colors,
          l10n: l10n,
          onDelete: () => _delete(context, ref, c),
          onTap: () => context.push(AppRoutes.constraintForm(c.id), extra: c),
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

// ── Daily limits button / sheet ───────────────────────────────────────────

class _DailyLimitsButton extends StatelessWidget {
  final String schoolId;
  final AppColors colors;
  final AppLocalizations l10n;
  final List<String> activeDays;

  const _DailyLimitsButton({
    required this.schoolId,
    required this.colors,
    required this.l10n,
    required this.activeDays,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _DailyLimitsSheet(
            schoolId: schoolId,
            activeDays: activeDays,
            colors: colors,
            l10n: l10n,
          ),
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
                  color: colors.primary.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: const Icon(Icons.tune, color: Colors.white, size: 22),
        ),
      );
}

class _DailyLimitsSheet extends ConsumerWidget {
  final String schoolId;
  final List<String> activeDays;
  final AppColors colors;
  final AppLocalizations l10n;

  const _DailyLimitsSheet({
    required this.schoolId,
    required this.activeDays,
    required this.colors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classroomSubjectsAsync =
        ref.watch(_classroomSubjectsProvider(schoolId));
    final subjectsAsync = ref.watch(_subjectsProvider(schoolId));
    final classroomsAsync = ref.watch(_classroomsProvider(schoolId));
    final periodsAsync = ref.watch(_periodsProvider(schoolId));
    final dayCapsAsync = ref.watch(_dayCapacitiesProvider(schoolId));

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Daily limits',
                      style: AppTextStyles.headingLarge
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Edit daily min/max hours for classroom subject assignments.',
                style:
                    AppTextStyles.bodySmall.copyWith(color: colors.textMuted),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: classroomSubjectsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (classroomSubjects) => subjectsAsync.when(
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
                      data: (periods) => dayCapsAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text('Error: $e')),
                        data: (dayCaps) {
                          final lessonsPerDay = periods
                              .where((p) => p.type == PeriodType.lesson)
                              .length;
                          final capacityByClassroom =
                              <String, Map<String, int>>{};
                          for (final cap in dayCaps) {
                            capacityByClassroom.putIfAbsent(
                                    cap.classroomId, () => {})[cap.dayOfWeek] =
                                cap.activeSlots.length;
                          }

                          final totalSlotsByClassroom = <String, int>{};
                          for (final classroom in classrooms) {
                            totalSlotsByClassroom[classroom.id] =
                                activeDays.fold<int>(
                              0,
                              (sum, day) =>
                                  sum +
                                  (capacityByClassroom[classroom.id]?[day] ??
                                      lessonsPerDay),
                            );
                          }

                          final assignments = classroomSubjects.toList()
                            ..sort((a, b) {
                              final roomA = classrooms
                                  .firstWhere((c) => c.id == a.classroomId)
                                  .name;
                              final roomB = classrooms
                                  .firstWhere((c) => c.id == b.classroomId)
                                  .name;
                              final subjectA = subjects
                                  .firstWhere((s) => s.id == a.subjectId)
                                  .name;
                              final subjectB = subjects
                                  .firstWhere((s) => s.id == b.subjectId)
                                  .name;
                              final cmp = roomA.compareTo(roomB);
                              return cmp != 0
                                  ? cmp
                                  : subjectA.compareTo(subjectB);
                            });

                          if (assignments.isEmpty) {
                            return Center(
                              child: Text(
                                'No classroom subject assignments yet.',
                                style: AppTextStyles.bodyMedium
                                    .copyWith(color: colors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }

                          return ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                            itemCount: assignments.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final cs = assignments[index];
                              final classroom = classrooms
                                  .firstWhere((c) => c.id == cs.classroomId);
                              final subject = subjects
                                  .firstWhere((s) => s.id == cs.subjectId);
                              final totalSlots =
                                  totalSlotsByClassroom[cs.classroomId] ??
                                      lessonsPerDay * activeDays.length;

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  '${subject.name} — ${classroom.name}',
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(color: colors.textPrimary),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'weekly ${cs.weeklyTargetHours}h · min ${cs.minDailyHours}/d · max ${cs.maxDailyHours}/d',
                                    style: AppTextStyles.bodySmall
                                        .copyWith(color: colors.textSecondary),
                                  ),
                                ),
                                trailing: Icon(Icons.edit_outlined,
                                    color: colors.textMuted),
                                onTap: () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (_) => _DailyLimitFormSheet(
                                    schoolId: schoolId,
                                    cs: cs,
                                    totalSlots: totalSlots,
                                    activeDays: activeDays,
                                    colors: colors,
                                    l10n: l10n,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyLimitFormSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final ClassroomSubjectModel cs;
  final int totalSlots;
  final List<String> activeDays;
  final AppColors colors;
  final AppLocalizations l10n;

  const _DailyLimitFormSheet({
    required this.schoolId,
    required this.cs,
    required this.totalSlots,
    required this.activeDays,
    required this.colors,
    required this.l10n,
  });

  @override
  ConsumerState<_DailyLimitFormSheet> createState() =>
      _DailyLimitFormSheetState();
}

class _DailyLimitFormSheetState extends ConsumerState<_DailyLimitFormSheet> {
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;
  List<String> _errors = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _minCtrl = TextEditingController(text: '${widget.cs.minDailyHours}');
    _maxCtrl = TextEditingController(text: '${widget.cs.maxDailyHours}');
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  int get _minD => int.tryParse(_minCtrl.text) ?? 0;
  int get _maxD => int.tryParse(_maxCtrl.text) ?? 1;

  void _validate() {
    final l10n = widget.l10n;
    final result = SubjectValidator.validate(
      weeklyTarget: widget.cs.weeklyTargetHours,
      minDaily: _minD,
      maxDaily: _maxD,
      activeDayCount: widget.activeDays.length,
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
              _maxD * widget.activeDays.length,
              widget.cs.weeklyTargetHours,
            );
          case SubjectValidationError.weeklyExceedsSlots:
            return l10n.validationWeeklyExceedsSlots(
              widget.cs.weeklyTargetHours,
              widget.totalSlots,
            );
        }
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final l10n = widget.l10n;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit daily limits',
                      style: AppTextStyles.headingLarge
                          .copyWith(color: colors.textPrimary),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CsTextField(
                controller: _minCtrl,
                label: l10n.minDailyHours,
                hint: '0',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _validate(),
              ),
              const SizedBox(height: 12),
              CsTextField(
                controller: _maxCtrl,
                label: l10n.maxDailyHours,
                hint: '2',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _validate(),
              ),
              const SizedBox(height: 12),
              Text(
                '${widget.activeDays.length} active days · max capacity: ${widget.totalSlots} slots',
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textDisabled),
              ),
              const SizedBox(height: 12),
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
              CsButton(
                label: l10n.save,
                loading: _saving,
                onPressed: _errors.isEmpty ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    _validate();
    if (_errors.isNotEmpty) return;
    setState(() => _saving = true);
    final uid = ref.read(currentUserProvider)!.uid;
    final repo =
        ClassroomSubjectRepository(uid: uid, schoolId: widget.schoolId);
    final updated = widget.cs.copyWith(
      minDailyHours: _minD,
      maxDailyHours: _maxD,
    );
    await repo.save(updated);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.l10n.subjectSaved)),
      );
    }
  }
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
        onTap: () =>
            context.push(AppRoutes.constraintForm('new'), extra: schoolId),
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
