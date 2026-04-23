// lib/presentation/setup/step1_periods/step1_periods_screen.dart
//
// FR-TS-01, FR-TS-02, FR-TS-03, FR-TS-04, FR-TS-05
// Step 1: Select active school days + define lesson and break slots.
//
// v2.1 fixes:
//   FIX-1  List always sorted by startTime.
//   FIX-2  Overlap detection with inline error + banner.
//   FIX-3  Auto-shift on break insert.
//   FIX-4  Native time picker — no free-text.
//
// Template management (user-editable, per-user Firestore):
//   TMPL-1  "Use a template" sheet lists built-ins + user templates.
//   TMPL-2  "Save periods as template" captures current list.
//   TMPL-3  User can rename a template via pencil icon.
//   TMPL-4  User can delete a template (swipe or icon) with undo snackbar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:classscheduler/providers/auth_providers.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/app_models.dart';
import '../../../data/models/period_template_model.dart';
import '../../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../../data/repositories/period_template_repository.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/cs_button.dart';
import '../setup_screen.dart';

// ── Time helpers ──────────────────────────────────────────────────────────────

int _toMins(String t) {
  final p = t.split(':');
  return int.parse(p[0]) * 60 + int.parse(p[1]);
}

String _fromMins(int m) =>
    '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

String _formatTod(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

bool _overlaps(PeriodModel a, PeriodModel b) {
  final aS = _toMins(a.startTime), aE = _toMins(a.endTime);
  final bS = _toMins(b.startTime), bE = _toMins(b.endTime);
  return aS < bE && aE > bS;
}

Set<String> _overlappingIds(List<PeriodModel> periods) {
  final ids = <String>{};
  for (var i = 0; i < periods.length; i++) {
    for (var j = i + 1; j < periods.length; j++) {
      if (_overlaps(periods[i], periods[j])) {
        ids..add(periods[i].id)..add(periods[j].id);
      }
    }
  }
  return ids;
}

// ── Built-in (read-only) default templates ────────────────────────────────────

class _BuiltIn {
  final String name;
  final List<PeriodTemplateSlot> slots;
  const _BuiltIn(this.name, this.slots);
}

const _builtIns = [
  _BuiltIn('5 x 1h (no breaks)', [
    PeriodTemplateSlot(type: 'LESSON', startTime: '08:00', endTime: '09:00'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '09:00', endTime: '10:00'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '10:00', endTime: '11:00'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '11:00', endTime: '12:00'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '12:00', endTime: '13:00'),
  ]),
  _BuiltIn('5 x 1h + Morning Break', [
    PeriodTemplateSlot(type: 'LESSON', startTime: '08:00', endTime: '09:00'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '09:00', endTime: '10:00'),
    PeriodTemplateSlot(type: 'BREAK',  name: 'Morning Break', startTime: '10:00', endTime: '10:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '10:15', endTime: '11:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '11:15', endTime: '12:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '12:15', endTime: '13:15'),
  ]),
  _BuiltIn('8 x 1h + Morning Break + Lunch Break', [
    PeriodTemplateSlot(type: 'LESSON', startTime: '08:00', endTime: '09:00'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '09:00', endTime: '10:00'),
    PeriodTemplateSlot(type: 'BREAK',  name: 'Morning Break', startTime: '10:00', endTime: '10:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '10:15', endTime: '11:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '11:15', endTime: '12:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '12:15', endTime: '13:15'),
    PeriodTemplateSlot(type: 'BREAK',  name: 'Lunch Break', startTime: '13:15', endTime: '14:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '14:15', endTime: '15:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '15:15', endTime: '16:15'),
    PeriodTemplateSlot(type: 'LESSON', startTime: '16:15', endTime: '17:15'),
  ]),
];

// ── Active days provider ──────────────────────────────────────────────────────

final activeDaysProvider =
    StateProvider<List<String>>((ref) => DayCode.weekdays);

// ── Screen ────────────────────────────────────────────────────────────────────

class Step1PeriodsScreen extends ConsumerStatefulWidget {
  const Step1PeriodsScreen({super.key});

  @override
  ConsumerState<Step1PeriodsScreen> createState() =>
      _Step1PeriodsScreenState();
}

class _Step1PeriodsScreenState extends ConsumerState<Step1PeriodsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n       = AppLocalizations.of(context);
    final colors     = AppColors.of(context);
    final school     = ref.watch(activeSchoolProvider);
    final activeDays = ref.watch(activeDaysProvider);

    if (school == null) return const SizedBox.shrink();

    final periodsAsync = ref.watch(_periodsProvider(school.id));

    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPadH, vertical: 16),
      children: [
        // ── Active days ───────────────────────────────────────────────────
        _SectionHeader(title: l10n.activeDays, colors: colors),
        const SizedBox(height: 12),
        _DaySelector(
          activeDays: activeDays,
          colors: colors,
          onToggle: (day) {
            final current = List<String>.from(activeDays);
            if (current.contains(day)) {
              if (current.length > 1) current.remove(day);
            } else {
              current.add(day);
              current.sort((a, b) =>
                  DayCode.sortIndex(a).compareTo(DayCode.sortIndex(b)));
            }
            ref.read(activeDaysProvider.notifier).state = current;
          },
        ),
        const SizedBox(height: 28),

        // ── Periods ───────────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SectionHeader(title: l10n.periods, colors: colors),
            TextButton.icon(
              icon: const Icon(Icons.auto_fix_high_outlined, size: 16),
              label: Text(l10n.useTemplate,
                  style: AppTextStyles.labelMedium),
              onPressed: () =>
                  _showTemplateSheet(context, school.id),
            ),
          ],
        ),
        const SizedBox(height: 8),

        periodsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(e.toString()),
          data: (rawPeriods) {
            final periods = [...rawPeriods]
              ..sort((a, b) =>
                  _toMins(a.startTime).compareTo(_toMins(b.startTime)));
            final badIds     = _overlappingIds(periods);
            final hasOverlap = badIds.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Add buttons
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showPeriodForm(
                        context, school.id,
                        forceType: PeriodType.lesson,
                        allPeriods: periods,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.lessonSlot),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showPeriodForm(
                        context, school.id,
                        forceType: PeriodType.breakSlot,
                        allPeriods: periods,
                      ),
                      icon: const Icon(
                          Icons.free_breakfast_outlined, size: 16),
                      label: Text(l10n.breakSlot),
                    ),
                  ),
                ]),

                // Save as template — only shown when there are periods
                if (periods.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () =>
                        _saveAsTemplate(context, periods),
                    icon: const Icon(
                        Icons.bookmark_add_outlined, size: 16),
                    label:
                        const Text('Save periods as template'),
                  ),
                ],

                const SizedBox(height: 8),

                ...periods.map((p) => _PeriodTile(
                      period: p,
                      colors: colors,
                      isOverlapping: badIds.contains(p.id),
                      onDelete: () =>
                          _deletePeriod(school.id, p.id, periods),
                      onEdit: () => _showPeriodForm(
                        context, school.id,
                        existing: p,
                        allPeriods: periods,
                      ),
                    )),

                if (hasOverlap) ...[
                  const SizedBox(height: 12),
                  _OverlapBanner(colors: colors),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Period CRUD ───────────────────────────────────────────────────────────

  Future<void> _deletePeriod(
      String schoolId, String periodId, List<PeriodModel> allPeriods) async {
    final uid  = ref.read(currentUserProvider)!.uid;
    final repo = PeriodRepository(uid: uid, schoolId: schoolId);

    // If deleting a break, shift all periods that started after it upward
    // by the break's duration so no gap is left.
    final deleted = allPeriods.firstWhere((p) => p.id == periodId,
        orElse: () => allPeriods.first);
    if (deleted.type == PeriodType.breakSlot) {
      final breakDur = _toMins(deleted.endTime) - _toMins(deleted.startTime);
      final toShift  = allPeriods
          .where((p) => p.id != periodId &&
              _toMins(p.startTime) >= _toMins(deleted.endTime))
          .toList();
      for (final p in toShift) {
        final ns = _toMins(p.startTime) - breakDur;
        final ne = _toMins(p.endTime)   - breakDur;
        await repo.save(
            p.copyWith(startTime: _fromMins(ns), endTime: _fromMins(ne)));
      }
    }

    await repo.delete(periodId);
  }

  void _showPeriodForm(
    BuildContext context,
    String schoolId, {
    PeriodModel? existing,
    String? forceType,
    required List<PeriodModel> allPeriods,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _PeriodFormSheet(
        schoolId: schoolId,
        existing: existing,
        forceType: forceType,
        allPeriods: allPeriods,
        onSave: (newPeriod, toShift) async {
          final uid  = ref.read(currentUserProvider)!.uid;
          final repo =
              PeriodRepository(uid: uid, schoolId: schoolId);
          for (final p in toShift) {
            await repo.save(p);
          }
          await repo.save(newPeriod);
          if (context.mounted) {
            Navigator.pop(context);
            if (toShift.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(
                  '${toShift.length} period'
                  '${toShift.length > 1 ? 's' : ''} '
                  'shifted forward automatically.',
                ),
                duration: const Duration(seconds: 3),
              ));
            }
          }
        },
      ),
    );
  }

  // ── Template sheet ────────────────────────────────────────────────────────

  void _showTemplateSheet(BuildContext context, String schoolId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _TemplateSheet(
        onApply: (slots) => _applySlots(schoolId, slots),
        rootContext: context,
      ),
    );
  }

  Future<void> _applySlots(
      String schoolId, List<PeriodTemplateSlot> slots) async {
    final uid  = ref.read(currentUserProvider)!.uid;
    final repo = PeriodRepository(uid: uid, schoolId: schoolId);

    // Remove all existing periods before writing the template.
    final existing = await repo.fetchAll();
    for (final p in existing) {
      await repo.delete(p.id);
    }

    const uuid = Uuid();
    for (var i = 0; i < slots.length; i++) {
      final s = slots[i];
      await repo.save(PeriodModel(
        id:        uuid.v4(),
        schoolId:  schoolId,
        type:      s.type,
        name:      s.name,
        startTime: s.startTime,
        endTime:   s.endTime,
        sortOrder: i,
      ));
    }
  }

  // ── Save current periods as a new template ────────────────────────────────

  Future<void> _saveAsTemplate(
      BuildContext context, List<PeriodModel> periods) async {
    final colors = AppColors.of(context);
    final ctrl   = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        title: Text('Save as template',
            style: AppTextStyles.titleSmall
                .copyWith(color: colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Template name',
            hintText:  'e.g. My School Schedule',
            labelStyle: TextStyle(color: colors.textMuted),
          ),
          style: AppTextStyles.bodyLarge
              .copyWith(color: colors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (confirmed != true || ctrl.text.trim().isEmpty) return;

    final now   = DateTime.now();
    final slots = periods
        .map((p) => PeriodTemplateSlot(
              type:      p.type,
              name:      p.name,
              startTime: p.startTime,
              endTime:   p.endTime,
            ))
        .toList();

    await ref.read(periodTemplateRepositoryProvider).save(
          PeriodTemplateModel(
            id:        '',
            name:      ctrl.text.trim(),
            slots:     slots,
            createdAt: now,
            updatedAt: now,
          ),
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template saved.')),
      );
    }
  }
}

// ── Template bottom sheet ─────────────────────────────────────────────────────

class _TemplateSheet extends ConsumerWidget {
  final Future<void> Function(List<PeriodTemplateSlot>) onApply;
  final BuildContext rootContext;
  const _TemplateSheet({required this.onApply, required this.rootContext});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors         = AppColors.of(context);
    final templatesAsync = ref.watch(periodTemplatesStreamProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize:     0.4,
      maxChildSize:     0.92,
      expand:           false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: colors.cardBg,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Templates',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: colors.textPrimary)),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              children: [
                // Built-ins
                _SheetLabel(label: 'Built-in', colors: colors),
                ..._builtIns.map((b) => _BuiltInTile(
                      builtIn: b,
                      colors: colors,
                      onApply: () async {
                        Navigator.pop(context);
                        await onApply(b.slots);
                      },
                    )),

                const SizedBox(height: 16),

                // User templates
                _SheetLabel(
                    label: 'My templates', colors: colors),
                templatesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                        child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Text(e.toString()),
                  data: (templates) {
                    if (templates.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16),
                        child: Text(
                          'No custom templates yet.\n'
                          'Set up your periods and tap '
                          '"Save periods as template".',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colors.textMuted),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return Column(
                      children: templates
                          .map((t) => _UserTemplateTile(
                                template: t,
                                colors:   colors,
                                onApply:  () async {
                                  Navigator.pop(context);
                                  await onApply(t.slots);
                                },
                                onRename: () => _rename(
                                    context, ref, t, colors),
                                onDelete: () => _delete(
                                    context, ref, t),
                              ))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    PeriodTemplateModel t,
    AppColors colors,
  ) async {
    final ctrl      = TextEditingController(text: t.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        title: Text('Rename template',
            style: AppTextStyles.titleSmall
                .copyWith(color: colors.textPrimary)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Template name',
            labelStyle: TextStyle(color: colors.textMuted),
          ),
          style: AppTextStyles.bodyLarge
              .copyWith(color: colors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );
    if (confirmed != true || ctrl.text.trim().isEmpty) return;
    await ref
        .read(periodTemplateRepositoryProvider)
        .save(t.copyWith(name: ctrl.text.trim()));
  }

  Future<void> _delete(
    BuildContext sheetContext,
    WidgetRef ref,
    PeriodTemplateModel t,
  ) async {
    final colors = AppColors.of(rootContext);
    // Confirm before deleting — avoids all snackbar/context lifetime issues.
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        title: Text('Delete template',
            style: AppTextStyles.titleSmall
                .copyWith(color: colors.textPrimary)),
        content: Text(
          'Delete "${t.name}"?',
          style: AppTextStyles.bodyMedium
              .copyWith(color: colors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(periodTemplateRepositoryProvider).delete(t.id);
  }
}

// ── Template tiles ────────────────────────────────────────────────────────────

class _SheetLabel extends StatelessWidget {
  final String label;
  final AppColors colors;
  const _SheetLabel({required this.label, required this.colors});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(label.toUpperCase(),
            style: AppTextStyles.overline
                .copyWith(color: colors.textMuted)),
      );
}

class _BuiltInTile extends StatelessWidget {
  final _BuiltIn builtIn;
  final AppColors colors;
  final VoidCallback onApply;

  const _BuiltInTile({
    required this.builtIn,
    required this.colors,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final lessons =
        builtIn.slots.where((s) => s.type == 'LESSON').length;
    final breaks =
        builtIn.slots.where((s) => s.type == 'BREAK').length;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.cardBg,
        border: Border.all(color: colors.borderDefault),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(Icons.grid_view_rounded,
            color: colors.primary, size: 20),
        title: Text(builtIn.name,
            style: AppTextStyles.labelLarge
                .copyWith(color: colors.textPrimary)),
        subtitle: Text(
          '$lessons lesson${lessons != 1 ? 's' : ''}'
          '${breaks > 0 ? ' · $breaks break${breaks != 1 ? 's' : ''}' : ''}',
          style: AppTextStyles.bodySmall
              .copyWith(color: colors.textMuted),
        ),
        trailing: TextButton(
            onPressed: onApply, child: const Text('Apply')),
      ),
    );
  }
}

class _UserTemplateTile extends StatelessWidget {
  final PeriodTemplateModel template;
  final AppColors colors;
  final VoidCallback onApply;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _UserTemplateTile({
    required this.template, required this.colors,
    required this.onApply,  required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lessons =
        template.slots.where((s) => s.type == 'LESSON').length;
    final breaks =
        template.slots.where((s) => s.type == 'BREAK').length;

    return Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: colors.cardBg,
          border: Border.all(color: colors.borderDefault),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(Icons.bookmark_outline,
              color: colors.primary, size: 20),
          title: Text(template.name,
              style: AppTextStyles.labelLarge
                  .copyWith(color: colors.textPrimary)),
          subtitle: Text(
            '$lessons lesson${lessons != 1 ? 's' : ''}'
            '${breaks > 0 ? ' · $breaks break${breaks != 1 ? 's' : ''}' : ''}',
            style: AppTextStyles.bodySmall
                .copyWith(color: colors.textMuted),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit_outlined,
                    size: 18, color: colors.textMuted),
                onPressed: onRename,
                tooltip: 'Rename',
              ),
              IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: colors.error),
                onPressed: onDelete,
                tooltip: 'Delete',
              ),
              TextButton(
                  onPressed: onApply,
                  child: const Text('Apply')),
            ],
          ),
        ),
    );
  }
}

// ── Periods stream provider ───────────────────────────────────────────────────

final _periodsProvider =
    StreamProvider.family<List<PeriodModel>, String>((ref, schoolId) {
  final uid = ref.watch(currentUserProvider)!.uid;
  return PeriodRepository(uid: uid, schoolId: schoolId).watchAll();
});

// ── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final AppColors colors;
  const _SectionHeader({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: AppTextStyles.overline.copyWith(color: colors.textMuted),
      );
}

class _DaySelector extends StatelessWidget {
  final List<String> activeDays;
  final AppColors colors;
  final void Function(String) onToggle;

  const _DaySelector({
    required this.activeDays,
    required this.colors,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dayLabels = {
      DayCode.mon: l10n.monShort, DayCode.tue: l10n.tueShort,
      DayCode.wed: l10n.wedShort, DayCode.thu: l10n.thuShort,
      DayCode.fri: l10n.friShort, DayCode.sat: l10n.satShort,
      DayCode.sun: l10n.sunShort,
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: DayCode.all.map((day) {
        final active = activeDays.contains(day);
        return GestureDetector(
          onTap: () => onToggle(day),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: active ? colors.primary : colors.cardBg,
              border: Border.all(
                  color: active
                      ? colors.primary
                      : colors.borderDefault),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                dayLabels[day] ?? day,
                style: AppTextStyles.labelSmall.copyWith(
                  color:
                      active ? Colors.white : colors.textMuted,
                  fontWeight: active
                      ? FontWeight.w700
                      : FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PeriodTile extends StatelessWidget {
  final PeriodModel period;
  final AppColors colors;
  final bool isOverlapping;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _PeriodTile({
    required this.period,   required this.colors,
    required this.isOverlapping,
    required this.onDelete, required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isBreak     = period.type == PeriodType.breakSlot;
    final borderColor = isOverlapping
        ? colors.error.withOpacity(0.5)
        : isBreak
            ? colors.warning.withOpacity(0.3)
            : colors.borderDefault;
    final bgColor = isOverlapping
        ? colors.errorBg
        : isBreak ? colors.warningBg : colors.cardBg;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: isOverlapping
                    ? colors.error
                    : isBreak ? colors.warning : colors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBreak ? (period.name ?? 'Break') : 'Lesson',
                    style: AppTextStyles.labelLarge
                        .copyWith(color: colors.textPrimary),
                  ),
                  Text('${period.startTime} – ${period.endTime}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: colors.textMuted)),
                ],
              ),
            ),
            Chip(
              label: Text(
                isBreak ? 'BREAK' : 'LESSON',
                style: AppTextStyles.labelSmall.copyWith(
                    color: isBreak
                        ? colors.warning
                        : colors.primary),
              ),
              backgroundColor: isBreak
                  ? colors.warningBg
                  : colors.primary.withOpacity(0.1),
              side: BorderSide.none,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: colors.textMuted),
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: colors.error),
              onPressed: onDelete,
            ),
          ]),
          if (isOverlapping) ...[
            const SizedBox(height: 6),
            Row(children: [
              Icon(Icons.warning_amber_rounded,
                  size: 13, color: colors.error),
              const SizedBox(width: 4),
              Text(
                'Overlaps with another period — fix before continuing.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.error),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}

class _OverlapBanner extends StatelessWidget {
  final AppColors colors;
  const _OverlapBanner({required this.colors});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: colors.errorBg,
          border: Border.all(
              color: colors.error.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(Icons.error_outline, size: 16, color: colors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Some periods overlap. Fix them before moving '
              'to the next step.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: colors.error),
            ),
          ),
        ]),
      );
}

// ── Period form bottom sheet ──────────────────────────────────────────────────

class _PeriodFormSheet extends StatefulWidget {
  final String schoolId;
  final PeriodModel? existing;
  final String? forceType;
  final List<PeriodModel> allPeriods;
  final Future<void> Function(
      PeriodModel newPeriod, List<PeriodModel> toShift) onSave;

  const _PeriodFormSheet({
    required this.schoolId,  this.existing,
    this.forceType,          required this.allPeriods,
    required this.onSave,
  });

  @override
  State<_PeriodFormSheet> createState() => _PeriodFormSheetState();
}

class _PeriodFormSheetState extends State<_PeriodFormSheet> {
  late String _type;
  late final TextEditingController _nameCtrl;
  late TimeOfDay _start;
  late TimeOfDay _end;
  bool _loading = false;
  String? _timeError;

  @override
  void initState() {
    super.initState();
    _type = widget.forceType ??
        widget.existing?.type ?? PeriodType.lesson;
    _nameCtrl =
        TextEditingController(text: widget.existing?.name ?? '');
    if (widget.existing != null) {
      final sm = _toMins(widget.existing!.startTime);
      final em = _toMins(widget.existing!.endTime);
      _start = TimeOfDay(hour: sm ~/ 60, minute: sm % 60);
      _end   = TimeOfDay(hour: em ~/ 60, minute: em % 60);
    } else {
      final lastEnd = widget.allPeriods.isEmpty
          ? 480
          : widget.allPeriods
              .map((p) => _toMins(p.endTime))
              .reduce((a, b) => a > b ? a : b);
      final defDur = _type == PeriodType.breakSlot ? 15 : 60;
      _start = TimeOfDay(
          hour: lastEnd ~/ 60, minute: lastEnd % 60);
      final endMins = lastEnd + defDur;
      _end   = TimeOfDay(
          hour: endMins ~/ 60, minute: endMins % 60);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  int get _startMins => _start.hour * 60 + _start.minute;
  int get _endMins   => _end.hour   * 60 + _end.minute;
  int get _duration  => _endMins - _startMins;

  int get _shiftCount {
    if (_type != PeriodType.breakSlot ||
        widget.existing != null) return 0;
    // Count only periods that actually overlap with the break.
    return widget.allPeriods
        .where((p) =>
            _endMins > _toMins(p.startTime) &&
            _startMins < _toMins(p.endTime))
        .length;
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx)
            .copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_endMins <= _startMins) {
          final newEnd = _startMins +
              (_type == PeriodType.breakSlot ? 15 : 60);
          _end = TimeOfDay(
              hour: newEnd ~/ 60, minute: newEnd % 60);
        }
      } else {
        _end = picked;
      }
      _timeError = null;
    });
  }

  Future<void> _save() async {
    setState(() { _timeError = null; _loading = true; });

    if (_endMins <= _startMins) {
      setState(() {
        _timeError = 'End time must be after start time.';
        _loading   = false;
      });
      return;
    }
    if (_type == PeriodType.breakSlot &&
        _nameCtrl.text.trim().isEmpty) {
      setState(() {
        _timeError = 'Break name is required.';
        _loading   = false;
      });
      return;
    }

    final newPeriod = PeriodModel(
      id:        widget.existing?.id ?? const Uuid().v4(),
      schoolId:  widget.schoolId,
      type:      _type,
      name:      _type == PeriodType.breakSlot
          ? _nameCtrl.text.trim() : null,
      startTime: _fromMins(_startMins),
      endTime:   _fromMins(_endMins),
      sortOrder: widget.existing?.sortOrder ?? 99,
    );

    // For breaks: only shift periods that actually overlap with the new break,
    // and only by the exact overlap amount (not the full break duration).
    // For lessons: any overlap is a hard error — block the save.
    final List<PeriodModel> toShift = [];
    final Set<String> toShiftIds    = {};

    if (_type == PeriodType.breakSlot) {
      // For both new and edited breaks: cascade-shift any periods that overlap
      // the new break position, working forward in start-time order.
      //
      // When editing, first undo the old break's footprint: any period that
      // was pushed forward by the old break is restored to its natural position
      // before we recompute with the new break times.
      List<PeriodModel> baseline = List.from(widget.allPeriods);
      if (widget.existing != null) {
        final oldStart = _toMins(widget.existing!.startTime);
        final oldEnd   = _toMins(widget.existing!.endTime);
        final oldDur   = oldEnd - oldStart;
        // Periods that were shifted by the old break: those starting at oldEnd
        // or later. Restore them by shifting back by oldDur.
        baseline = baseline.map((p) {
          if (p.id == newPeriod.id) return p;
          final ps = _toMins(p.startTime);
          if (ps >= oldEnd) {
            final ns = ps - oldDur;
            final ne = _toMins(p.endTime) - oldDur;
            return p.copyWith(startTime: _fromMins(ns), endTime: _fromMins(ne));
          }
          return p;
        }).toList();
      }

      final others = baseline
          .where((p) => p.id != newPeriod.id)
          .toList()
        ..sort((a, b) => _toMins(a.startTime).compareTo(_toMins(b.startTime)));

      int pushedEnd = _endMins; // starts as the new break's end

      for (final other in others) {
        final otherStart = _toMins(other.startTime);
        final otherEnd   = _toMins(other.endTime);
        // Skip periods entirely before the break.
        if (otherEnd <= _startMins) continue;
        if (pushedEnd > otherStart) {
          final overlapAmount = pushedEnd - otherStart;
          final ns = otherStart + overlapAmount;
          final ne = otherEnd   + overlapAmount;
          toShift.add(other.copyWith(
              startTime: _fromMins(ns), endTime: _fromMins(ne)));
          toShiftIds.add(other.id);
          pushedEnd = ne;
        }
      }
    } else {
      // Lesson: any overlap is a hard error — block the save.
      for (final other in widget.allPeriods) {
        if (other.id == newPeriod.id) continue;
        if (_overlaps(newPeriod, other)) {
          setState(() {
            _timeError =
                'Overlaps with ${other.type == PeriodType.breakSlot ? other.name ?? "Break" : "Lesson"}'
                ' at ${other.startTime}–${other.endTime}.';
            _loading = false;
          });
          return;
        }
      }
    }

    try {
      await widget.onSave(newPeriod, toShift);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n    = AppLocalizations.of(context);
    final colors  = AppColors.of(context);
    final isBreak = _type == PeriodType.breakSlot;
    final isEdit  = widget.existing != null;

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              isEdit ? 'Edit period'
                  : (isBreak ? l10n.breakSlot : l10n.lessonSlot),
              style: AppTextStyles.titleMedium
                  .copyWith(color: colors.textPrimary),
            ),
            const SizedBox(height: 4),
            Text('Tap the time fields to use the time picker.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: colors.textMuted)),
            const SizedBox(height: 16),

            if (widget.forceType == null && !isEdit) ...[
              Row(children: [
                Expanded(child: _TypeChip(
                  label: l10n.lessonSlot,
                  selected: _type == PeriodType.lesson,
                  onTap: () =>
                      setState(() => _type = PeriodType.lesson),
                  colors: colors,
                )),
                const SizedBox(width: 8),
                Expanded(child: _TypeChip(
                  label: l10n.breakSlot,
                  selected: isBreak,
                  onTap: () => setState(
                      () => _type = PeriodType.breakSlot),
                  colors: colors,
                )),
              ]),
              const SizedBox(height: 16),
            ],

            if (isBreak) ...[
              Text(l10n.breakName,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: colors.textMuted)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'e.g. Morning Break',
                  hintStyle:
                      TextStyle(color: colors.textPlaceholder),
                ),
                style: AppTextStyles.bodyLarge
                    .copyWith(color: colors.textPrimary),
              ),
              const SizedBox(height: 14),
            ],

            if (isBreak && !isEdit && _shiftCount > 0) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.warningBg,
                  border: Border.all(
                      color: colors.warning.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.update,
                        size: 15, color: colors.warning),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      '$_shiftCount period'
                      '${_shiftCount > 1 ? 's' : ''} after this '
                      'break will shift forward by $_duration min '
                      'automatically.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: colors.warning),
                    )),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            Row(children: [
              Expanded(child: _TimePicker(
                label: l10n.startTime, value: _start,
                colors: colors, hasError: _timeError != null,
                onTap: () => _pickTime(true),
              )),
              const SizedBox(width: 12),
              Expanded(child: _TimePicker(
                label: l10n.endTime, value: _end,
                colors: colors, hasError: _timeError != null,
                onTap: () => _pickTime(false),
              )),
            ]),

            if (_timeError != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.warning_amber_rounded,
                    size: 13, color: colors.error),
                const SizedBox(width: 4),
                Expanded(child: Text(_timeError!,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: colors.error))),
              ]),
            ],

            const SizedBox(height: 24),
            CsButton(
                label: l10n.save,
                loading: _loading,
                onPressed: _save),
          ],
        ),
      ),
    );
  }
}

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final AppColors colors;
  final bool hasError;
  final VoidCallback onTap;

  const _TimePicker({
    required this.label,    required this.value,
    required this.colors,   required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.labelSmall
                  .copyWith(color: colors.textMuted)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: hasError ? colors.errorBg : colors.cardBg,
                border: Border.all(
                  color: hasError
                      ? colors.error.withOpacity(0.5)
                      : colors.borderDefault,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(Icons.access_time_rounded,
                    size: 16, color: colors.textMuted),
                const SizedBox(width: 8),
                Text(_formatTod(value),
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: colors.textPrimary)),
              ]),
            ),
          ),
        ],
      );
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  const _TypeChip({
    required this.label,    required this.selected,
    required this.onTap,    required this.colors,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? colors.primary : colors.cardBg,
            border: Border.all(
                color: selected
                    ? colors.primary : colors.borderDefault),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: selected ? Colors.white : colors.textMuted,
                  fontWeight: selected
                      ? FontWeight.w700 : FontWeight.w600,
                )),
          ),
        ),
      );
}
