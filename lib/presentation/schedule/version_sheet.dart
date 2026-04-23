// lib/presentation/schedule/version_sheet.dart
//
// FR-GEN-06 — Multiple named schedule versions per school.
// Bottom sheet listing all saved schedule versions with:
//   - Status dot (Perfect / Soft violations / Hard violations)
//   - Quality score
//   - Generated-at date
//   - Rename and delete actions (swipe or long-press)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../l10n/generated/app_localizations.dart';

class VersionSheet extends ConsumerWidget {
  final List<ScheduleModel> schedules;
  final String              schoolId;
  final ScheduleModel?      selected;
  final ValueChanged<String> onSelect;

  const VersionSheet({
    super.key,
    required this.schedules,
    required this.schoolId,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n   = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize:     0.35,
      maxChildSize:     0.85,
      expand:           false,
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
              width: 40, height: 4,
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
                child: Text(l10n.scheduleVersions,
                    style: AppTextStyles.titleMedium
                        .copyWith(color: colors.textPrimary)),
              ),
              TextButton.icon(
                icon: const Icon(Icons.add_rounded, size: 16),
                label: Text(l10n.generate),
                onPressed: () => Navigator.pop(context, 'generate'),
              ),
            ]),
          ),
          const Divider(height: 1),
          // Version list
          Expanded(
            child: ListView.separated(
              controller:  scrollCtrl,
              itemCount:   schedules.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: colors.borderSubtle),
              itemBuilder: (_, i) {
                final s      = schedules[i];
                final active = s.id == selected?.id;
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
                      _confirmDelete(context, l10n, s.name),
                  onDismissed: (_) async {
                    await ref
                        .read(scheduleRepositoryProvider(schoolId))
                        .delete(s.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              l10n.scheduleDeleted(s.name)),
                          action: SnackBarAction(
                            label: l10n.undo,
                            onPressed: () {}, // no-op (Firestore delete)
                          ),
                        ),
                      );
                    }
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    selected:  active,
                    selectedColor: colors.primary,
                    selectedTileColor: colors.primary.withOpacity(0.07),
                    leading: _StatusIcon(
                        status: s.resultStatus, colors: colors),
                    title: Text(s.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: active
                                ? colors.primary
                                : colors.textPrimary,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500)),
                    subtitle: Text(
                      _subtitle(s, l10n),
                      style: AppTextStyles.labelSmall
                          .copyWith(color: colors.textMuted),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quality score badge
                        if (s.qualityScore > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _scoreColor(
                                  s.qualityScore, colors)
                                  .withOpacity(0.12),
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Text('${s.qualityScore}',
                                style: AppTextStyles.labelSmall
                                    .copyWith(
                                        color: _scoreColor(
                                            s.qualityScore, colors),
                                        fontWeight: FontWeight.w800)),
                          ),
                        const SizedBox(width: 8),
                        // Rename
                        IconButton(
                          icon: Icon(Icons.edit_outlined,
                              size: 18, color: colors.textMuted),
                          onPressed: () =>
                              _rename(context, ref, l10n, s),
                          tooltip: l10n.rename,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    onTap: () {
                      onSelect(s.id);
                      Navigator.pop(context);
                    },
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  String _subtitle(ScheduleModel s, AppLocalizations l10n) {
    final date = DateFormat('d MMM yyyy, HH:mm')
        .format(s.generatedAt.toLocal());
    final cancelled = s.isCancelled ? ' · ${l10n.cancelled}' : '';
    final edited    = s.isManuallyEdited ? ' · ${l10n.manuallyEdited}' : '';
    return '$date$cancelled$edited';
  }

  Color _scoreColor(int score, AppColors colors) {
    if (score >= 90) return colors.success;
    if (score >= 75) return colors.warning;
    return colors.error;
  }

  Future<bool?> _confirmDelete(
      BuildContext context, AppLocalizations l10n, String name) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.deleteSchedule),
          content: Text(l10n.deleteScheduleConfirm(name)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.cancel)),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.red),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ScheduleModel schedule,
  ) async {
    final ctrl = TextEditingController(text: schedule.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel)),
          FilledButton(
              onPressed: () =>
                  Navigator.pop(ctx, ctrl.text.trim()),
              child: Text(l10n.save)),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await ref
          .read(scheduleRepositoryProvider(schoolId))
          .rename(schedule.id, name);
    }
  }
}

// ── Status icon ───────────────────────────────────────────────────────────

class _StatusIcon extends StatelessWidget {
  final String    status;
  final AppColors colors;
  const _StatusIcon({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final color = status == 'PERFECT'
        ? colors.success
        : status == 'SOFT_VIOLATIONS'
            ? colors.warning
            : colors.error;
    final icon  = status == 'PERFECT'
        ? Icons.check_circle_outline_rounded
        : status == 'SOFT_VIOLATIONS'
            ? Icons.warning_amber_rounded
            : Icons.error_outline_rounded;
    return Icon(icon, color: color, size: 22);
  }
}
