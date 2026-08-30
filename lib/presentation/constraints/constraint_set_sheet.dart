// lib/presentation/constraints/constraint_set_sheet.dart
//
// Bottom sheet for saving/switching named "constraint sets" — a snapshot of
// all of a school's Hard+Soft constraints (ConstraintModel documents) plus
// its HARD daily limits (ClassroomSubjectModel fields), stored as
// ConstraintSetModel. Mirrors lib/presentation/schedule/version_sheet.dart's
// structure/styling closely. Two deliberate differences from that sheet:
//   - Saving is self-contained here (a plain Firestore write with no side
//     effect the parent screen needs to react to, unlike triggering a whole
//     schedule generation), so it doesn't bubble a sentinel result up.
//   - Each row has a third action (update the set with the current
//     constraints), so trailing uses a PopupMenuButton instead of two bare
//     icon buttons.
//
// Switching to a different set always confirms first and then atomically
// replaces the live constraints (ConstraintRepository.replaceAll) and any
// changed HARD daily limits (ClassroomSubjectRepository.saveMany) — see
// ConstraintSetRepository's doc comment for why applying spans two
// repositories.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/constraint_repository.dart';
import '../../data/repositories/constraint_set_repository.dart';
import '../../data/repositories/subject_repositories.dart'
    show ClassroomSubjectRepository;
import '../../l10n/generated/app_localizations.dart';
import '../../providers/auth_providers.dart';

class ConstraintSetSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final List<ConstraintSetModel> sets;
  final List<ConstraintModel> currentConstraints;
  final List<ClassroomSubjectModel> currentClassroomSubjects;

  /// Used only to work out how many of a saved set's daily-limit entries
  /// were actually customised (vs. every classroom-subject assignment,
  /// which is always fully snapshotted) — see `_hardCount`.
  final int lessonPeriodsCount;

  const ConstraintSetSheet({
    super.key,
    required this.schoolId,
    required this.sets,
    required this.currentConstraints,
    required this.currentClassroomSubjects,
    required this.lessonPeriodsCount,
  });

  @override
  ConsumerState<ConstraintSetSheet> createState() =>
      _ConstraintSetSheetState();
}

class _ConstraintSetSheetState extends ConsumerState<ConstraintSetSheet> {
  late List<ConstraintSetModel> _sets;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _sets = List.from(widget.sets);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.surfaceBg,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXl)),
        ),
        child: Column(children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderDefault,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(children: [
              Expanded(
                child: Text('Constraint Sets',
                    style: AppTextStyles.titleMedium
                        .copyWith(color: colors.textPrimary)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save current…'),
                onPressed: _busy ? null : () => _saveNew(context),
              ),
            ]),
          ),
          const Divider(height: 1),
          // Set list
          Expanded(
            child: _sets.isEmpty
                ? _EmptyState(colors: colors)
                : ListView.separated(
                    controller: scrollCtrl,
                    itemCount: _sets.length,
                    separatorBuilder: (_, __) =>
                        Divider(height: 1, color: colors.borderSubtle),
                    itemBuilder: (_, i) {
                      final s = _sets[i];
                      return Dismissible(
                        key: ValueKey(s.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          color: colors.error.withOpacity(0.15),
                          padding: const EdgeInsets.only(right: 20),
                          child: Icon(Icons.delete_outline_rounded,
                              color: colors.error),
                        ),
                        confirmDismiss: (_) =>
                            _confirmDelete(context, s.name),
                        onDismissed: (_) => _deleteSet(context, s),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 4),
                          leading: Icon(Icons.layers_outlined,
                              color: colors.textMuted, size: 22),
                          title: Text(s.name,
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.w500)),
                          subtitle: Text(
                            _subtitle(s),
                            style: AppTextStyles.labelSmall
                                .copyWith(color: colors.textMuted),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded,
                                color: colors.textMuted, size: 20),
                            padding: EdgeInsets.zero,
                            onSelected: (v) {
                              switch (v) {
                                case 'update':
                                  _updateSet(context, s);
                                case 'rename':
                                  _rename(context, s);
                                case 'delete':
                                  _confirmDelete(context, s.name).then((ok) {
                                    if (ok == true) _deleteSet(context, s);
                                  });
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'update',
                                child: Text('Update with current constraints'),
                              ),
                              PopupMenuItem(
                                  value: 'rename', child: Text(l10n.rename)),
                              PopupMenuItem(
                                  value: 'delete', child: Text(l10n.delete)),
                            ],
                          ),
                          onTap:
                              _busy ? null : () => _confirmApply(context, s),
                        ),
                      );
                    },
                  ),
          ),
        ]),
      ),
    );
  }

  /// Hard count = hard-rule ConstraintModel docs + customised daily limits
  /// (matching the exact definition constraints_screen.dart's Hard tab
  /// badge uses) — daily limits are always fully snapshotted (every
  /// classroom-subject assignment, not just customised ones), so counting
  /// `dailyLimits.length` directly would wildly overcount here.
  ({int hard, int soft}) _counts(ConstraintSetModel s) {
    final hardRules =
        s.constraints.where((j) => j['kind'] == 'HARD').length;
    final softCount =
        s.constraints.where((j) => j['kind'] == 'SOFT').length;
    final customDailyLimits = s.dailyLimits.where((e) =>
        (e['minDailyHours'] as int) > 0 ||
        (e['maxDailyHours'] as int) < widget.lessonPeriodsCount).length;
    return (hard: hardRules + customDailyLimits, soft: softCount);
  }

  String _subtitle(ConstraintSetModel s) {
    final date =
        DateFormat('d MMM yyyy, HH:mm').format(s.savedAt.toLocal());
    final c = _counts(s);
    return '$date · ${c.hard} hard · ${c.soft} soft';
  }

  // ── Save / update ─────────────────────────────────────────────────────

  Future<void> _saveNew(BuildContext context) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save current constraints'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Set name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(AppLocalizations.of(ctx).save),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;

    final repo = ref.read(constraintSetRepositoryProvider(widget.schoolId));
    final saved = await repo.create(
      name: name,
      constraints: widget.currentConstraints,
      dailyLimits: ConstraintSetRepository.snapshotDailyLimits(
          widget.currentClassroomSubjects),
    );
    if (!mounted) return;
    setState(() => _sets = [saved, ..._sets]);
    _showMessage(context, 'Saved "$name".');
  }

  Future<void> _updateSet(BuildContext context, ConstraintSetModel s) async {
    final repo = ref.read(constraintSetRepositoryProvider(widget.schoolId));
    await repo.update(
      s.id,
      constraints: widget.currentConstraints,
      dailyLimits: ConstraintSetRepository.snapshotDailyLimits(
          widget.currentClassroomSubjects),
    );
    if (!mounted) return;
    setState(() {
      final i = _sets.indexWhere((e) => e.id == s.id);
      if (i >= 0) {
        _sets[i] = s.copyWith(
          savedAt: DateTime.now(),
          constraints:
              widget.currentConstraints.map((c) => c.toJson()).toList(),
          dailyLimits: ConstraintSetRepository.snapshotDailyLimits(
              widget.currentClassroomSubjects),
        );
      }
    });
    _showMessage(context, 'Updated "${s.name}" with the current constraints.');
  }

  // ── Apply (switch) ────────────────────────────────────────────────────

  Future<void> _confirmApply(BuildContext context, ConstraintSetModel s) async {
    final c = _counts(s);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Switch to "${s.name}"?'),
        content: Text(
          'This replaces every current constraint and HARD daily limit '
          'with what was saved in "${s.name}" (${c.hard} hard · ${c.soft} '
          'soft). Anything not saved elsewhere will be lost.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(AppLocalizations.of(ctx).cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _applySet(context, s);
  }

  Future<void> _applySet(BuildContext context, ConstraintSetModel s) async {
    setState(() => _busy = true);
    try {
      final constraints =
          s.constraints.map((j) => ConstraintModel.fromJson(j)).toList();
      await ref
          .read(constraintRepositoryProvider(widget.schoolId))
          .replaceAll(constraints);

      final dailyLimitUpdates = ConstraintSetRepository.resolveDailyLimits(
          s.dailyLimits, widget.currentClassroomSubjects);
      if (dailyLimitUpdates.isNotEmpty) {
        final uid = ref.read(currentUserProvider)!.uid;
        await ClassroomSubjectRepository(uid: uid, schoolId: widget.schoolId)
            .saveMany(dailyLimitUpdates);
      }

      if (!mounted) return;
      Navigator.pop(context);
      _showMessage(context, 'Switched to "${s.name}".');
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _showMessage(context, 'Couldn\'t switch: $e');
    }
  }

  // ── Rename / delete ───────────────────────────────────────────────────

  Future<bool?> _confirmDelete(BuildContext context, String name) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delete constraint set'),
          content: Text('Delete "$name"? This can\'t be undone.'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(AppLocalizations.of(ctx).cancel)),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(AppLocalizations.of(ctx).delete),
            ),
          ],
        ),
      );

  Future<void> _deleteSet(BuildContext context, ConstraintSetModel s) async {
    await ref
        .read(constraintSetRepositoryProvider(widget.schoolId))
        .delete(s.id);
    if (!mounted) return;
    setState(() => _sets.removeWhere((e) => e.id == s.id));
    _showMessage(context, 'Deleted "${s.name}".');
  }

  Future<void> _rename(BuildContext context, ConstraintSetModel s) async {
    final ctrl = TextEditingController(text: s.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(ctx).rename),
        content: TextField(controller: ctrl, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(ctx).cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(AppLocalizations.of(ctx).save),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == s.name || !mounted) return;
    await ref
        .read(constraintSetRepositoryProvider(widget.schoolId))
        .rename(s.id, name);
    if (!mounted) return;
    setState(() {
      final i = _sets.indexWhere((e) => e.id == s.id);
      if (i >= 0) _sets[i] = s.copyWith(name: name);
    });
  }

  void _showMessage(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(message),
    ));
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  const _EmptyState({required this.colors});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.layers_outlined, size: 48, color: colors.textMuted),
              const SizedBox(height: 16),
              Text('No saved sets yet.',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text(
                'Save your current constraints to create one, then switch '
                'between saved sets any time.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textMuted),
              ),
            ],
          ),
        ),
      );
}
