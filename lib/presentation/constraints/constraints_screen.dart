// lib/presentation/constraints/constraints_screen.dart
//
// FR-HC-04, FR-SC-03: Constraint list with Hard | Soft tabs.
// Each constraint shown as a human-readable sentence (ConstraintLabelBuilder).
// Swipe-to-delete with undo snackbar. Conflict detection banner at top.

import 'package:flutter/material.dart';
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
import '../../l10n/generated/app_localizations.dart';

// ── Providers ──────────────────────────────────────────────────────────────

final _constraintsProvider =
    StreamProvider.family<List<ConstraintModel>, String>(
  (ref, schoolId) =>
      ref.watch(constraintRepositoryProvider(schoolId)).watchAll(),
);

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
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final constraintsAsync = ref.watch(_constraintsProvider(widget.schoolId));
    final subjectsAsync    = ref.watch(_subjectsProvider(widget.schoolId));
    final classroomsAsync  = ref.watch(_classroomsProvider(widget.schoolId));
    final periodsAsync     = ref.watch(_periodsProvider(widget.schoolId));

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
                _AddButton(schoolId: widget.schoolId, colors: colors, l10n: l10n),
              ]),
            ),
            const SizedBox(height: 16),

            // Conflict banner — only renders when all data ready
            constraintsAsync.whenOrNull(
              data: (constraints) => subjectsAsync.whenOrNull(
                data: (subjects) => classroomsAsync.whenOrNull(
                  data: (classrooms) => periodsAsync.whenOrNull(
                    data: (periods) => _ConflictBanner(
                      constraints: constraints,
                      subjects: subjects,
                      classrooms: classrooms,
                      periods: periods,
                      colors: colors,
                    ),
                  ),
                ),
              ),
            ) ?? const SizedBox.shrink(),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [colors.primary, colors.primaryLight]),
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd - 2),
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
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (all) {
                  final hard = all.where((c) => c.kind == 'HARD').toList();
                  final soft = all.where((c) => c.kind == 'SOFT').toList();

                  return subjectsAsync.whenOrNull(
                    data: (subjects) => classroomsAsync.whenOrNull(
                      data: (classrooms) => periodsAsync.whenOrNull(
                        data: (periods) {
                          final builder = ConstraintLabelBuilder(
                            subjects:   {for (final s in subjects)   s.id: s},
                            classrooms: {for (final c in classrooms) c.id: c},
                            periods:    {for (final p in periods)    p.id: p},
                          );
                          return TabBarView(
                            controller: _tabs,
                            children: [
                              _ConstraintList(
                                constraints:  hard,
                                schoolId:     widget.schoolId,
                                labelBuilder: builder,
                                isHard:       true,
                                colors:       colors,
                                l10n:         l10n,
                              ),
                              _ConstraintList(
                                constraints:  soft,
                                schoolId:     widget.schoolId,
                                labelBuilder: builder,
                                isHard:       false,
                                colors:       colors,
                                l10n:         l10n,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ) ?? const Center(child: CircularProgressIndicator());
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
  final List<ConstraintModel>  constraints;
  final List<SubjectModel>     subjects;
  final List<ClassroomModel>   classrooms;
  final List<PeriodModel>      periods;
  final AppColors              colors;
  const _ConflictBanner({
    required this.constraints, required this.subjects,
    required this.classrooms,  required this.periods,
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
      final days = p.dayApplicability ??
          ['MON', 'TUE', 'WED', 'THU', 'FRI'];
      for (final d in days) {
        byDay.putIfAbsent(d, () => []).add(p);
      }
    }

    final conflicts = ConstraintConflictDetector.detect(
      hardConstraints:     hardConstraints,
      periods:             widget.periods,
      subjects:            widget.subjects,
      classroomSubjects:   [],
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
                    color: colors.error, size: 18,
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
                            style: AppTextStyles.bodySmall.copyWith(
                                color: colors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('💡 ${c.suggestion}',
                            style: AppTextStyles.labelSmall.copyWith(
                                color: colors.textMuted)),
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
  final List<ConstraintModel>  constraints;
  final String                 schoolId;
  final ConstraintLabelBuilder labelBuilder;
  final bool                   isHard;
  final AppColors              colors;
  final AppLocalizations       l10n;

  const _ConstraintList({
    required this.constraints, required this.schoolId,
    required this.labelBuilder, required this.isHard,
    required this.colors, required this.l10n,
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
          constraint:   c,
          labelBuilder: labelBuilder,
          colors:       colors,
          l10n:         l10n,
          onDelete:     () => _delete(context, ref, c),
          onTap:        () => context.push(
              AppRoutes.constraintForm(c.id), extra: c),
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
            label: l10n.undoDelete,
            onPressed: () => repo.create(c)),
      ),
    );
  }
}

// ── Single tile ───────────────────────────────────────────────────────────

class _ConstraintTile extends StatelessWidget {
  final ConstraintModel        constraint;
  final ConstraintLabelBuilder labelBuilder;
  final AppColors              colors;
  final AppLocalizations       l10n;
  final VoidCallback           onDelete;
  final VoidCallback           onTap;

  const _ConstraintTile({
    required this.constraint, required this.labelBuilder,
    required this.colors,     required this.l10n,
    required this.onDelete,   required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHard    = constraint.kind == 'HARD';
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
                width: 4, height: 44,
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
                        style: AppTextStyles.overline
                            .copyWith(color: accentCol),
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
  final bool isHard; final AppColors colors; final AppLocalizations l10n;
  const _EmptyState({required this.isHard, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(48),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(
          isHard ? Icons.lock_outline_rounded : Icons.tune_outlined,
          size: 56, color: colors.textMuted,
        ),
        const SizedBox(height: 16),
        Text(
          isHard ? 'No hard constraints yet.'
                 : 'No preferences set yet.',
          style: AppTextStyles.titleMedium.copyWith(color: colors.textPrimary),
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
  final String schoolId; final AppColors colors; final AppLocalizations l10n;
  const _AddButton({required this.schoolId, required this.colors, required this.l10n});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push(AppRoutes.constraintForm('new'), extra: schoolId),
    child: Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [colors.primary, colors.primaryLight]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: colors.primary.withOpacity(0.4),
              blurRadius: 12, offset: const Offset(0, 4))
        ],
      ),
      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
    ),
  );
}
