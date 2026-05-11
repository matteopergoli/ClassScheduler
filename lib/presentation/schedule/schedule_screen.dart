// lib/presentation/schedule/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../domain/constraints/constraint_conflict_detector.dart';
import '../../domain/scheduler/generation_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/trial_banner.dart';
import 'export_sheet.dart';
import 'result_panel.dart';
import 'schedule_grid.dart';
import 'version_sheet.dart';

// ── View mode enum ───────────────────────────────────────────────────────

enum ScheduleViewMode { allClassrooms, singleClassroom, perTeacher }

// ── Schedules stream provider ────────────────────────────────────────────

final _schedulesProvider =
    StreamProvider.autoDispose.family<List<ScheduleModel>, String>(
  (ref, schoolId) =>
      ref.watch(scheduleRepositoryProvider(schoolId)).watchAll(),
);

// ── Screen ────────────────────────────────────────────────────────────────

class ScheduleScreen extends ConsumerStatefulWidget {
  final String schoolId;
  const ScheduleScreen({super.key, required this.schoolId});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String? _selectedScheduleId;
  String? _currentScheduleName;
  ScheduleViewMode _viewMode = ScheduleViewMode.allClassrooms;
  bool _showResultPanel = false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _onScheduleSelected(String scheduleId) {
    setState(() {
      _selectedScheduleId = scheduleId;
      _showResultPanel = false;
    });
  }

  void _showScheduleDeletedSnackBar(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 3),
      content: Text(message),
    ));
  }

  Future<void> _showVersionSheet(List<ScheduleModel> schedules) async {
    final selected =
        schedules.where((s) => s.id == _selectedScheduleId).firstOrNull;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VersionSheet(
        schedules: schedules,
        schoolId: widget.schoolId,
        selected: selected,
        onSelect: _onScheduleSelected,
      ),
    );

    if (result == 'generate' && mounted) {
      _startGeneration(schedules);
      return;
    }

    if (result != null && mounted) {
      _showScheduleDeletedSnackBar(result);
    }
  }

  Future<void> _startGeneration(List<ScheduleModel> existingSchedules) async {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final nameCtrl = TextEditingController(
      text: 'Schedule ${existingSchedules.length + 1}',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.cardBg,
        title: Text(l10n.newVersion,
            style:
                AppTextStyles.titleSmall.copyWith(color: colors.textPrimary)),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.scheduleVersionName,
            hintText: l10n.versionNameHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.generate),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final name = nameCtrl.text.trim().isEmpty
        ? 'Schedule ${existingSchedules.length + 1}'
        : nameCtrl.text.trim();

    // ── Check for Duplicate Name ──────────────────────────────────────────
    final nameExists = existingSchedules.any(
      (s) => s.name.toLowerCase() == name.toLowerCase(),
    );

    if (nameExists) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.newVersion),
          content: Text('A schedule with the name "$name" already exists. Please choose a unique name.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      );
      return;
    }
    // ──────────────────────────────────────────────────────────────────────

    setState(() => _showResultPanel = false);

    await ref
        .read(generationServiceProvider(widget.schoolId).notifier)
        .generate(scheduleName: name);
  }

  void _showExport() {
    if (_selectedScheduleId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(
        schoolId: widget.schoolId,
        scheduleId: _selectedScheduleId!,
        scheduleName: _currentScheduleName ?? 'Schedule',
        schoolName: widget.schoolId,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final genState = ref.watch(generationServiceProvider(widget.schoolId));
    final schedulesAsync = ref.watch(_schedulesProvider(widget.schoolId));

    // Listen for completion and force selection of the newest item
    ref.listen(generationServiceProvider(widget.schoolId), (prev, next) {
      if (next.phase == GenerationPhase.done) {
        setState(() => _showResultPanel = true);

        // Auto-select the newly generated schedule
        schedulesAsync.whenData((schedules) {
          if (schedules.isNotEmpty) {
            setState(() {
              _selectedScheduleId = schedules.first.id;
              _currentScheduleName = schedules.first.name;
            });
          }
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ScheduleHeader(
              schedulesAsync: schedulesAsync,
              selectedScheduleId: _selectedScheduleId,
              viewMode: _viewMode,
              genPhase: genState.phase,
              colors: colors,
              l10n: l10n,
              onVersionsTap: (schedules) => _showVersionSheet(schedules),
              onGenerate: (schedules) => _startGeneration(schedules),
              onViewModeChanged: (mode) =>
                  setState(() => _viewMode = mode),
              onExport: _selectedScheduleId != null ? _showExport : null,
            ),
            const TrialBanner(),
            if (_showResultPanel && genState.result != null)
              ResultPanel(
                result: genState.result!,
                colors: colors,
                l10n: l10n,
                onDismiss: () =>
                    setState(() => _showResultPanel = false),
              ),
            if (genState.phase == GenerationPhase.error &&
                genState.errorMessage != null)
              _ErrorBanner(
                message: genState.errorMessage!,
                conflicts: genState.conflicts,
                colors: colors,
                onDismiss: () => ref
                    .read(generationServiceProvider(widget.schoolId)
                        .notifier)
                    .cancel(),
              ),
            Expanded(
              child: _buildBody(
                  context, l10n, colors, genState, schedulesAsync),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    AppColors colors,
    GenerationState genState,
    AsyncValue<List<ScheduleModel>> schedulesAsync,
  ) {
    final busy = genState.phase == GenerationPhase.loadingData ||
        genState.phase == GenerationPhase.validating ||
        genState.phase == GenerationPhase.generating ||
        genState.phase == GenerationPhase.saving;

    if (busy) {
      return _GeneratingView(
        genState: genState,
        colors: colors,
        l10n: l10n,
        onCancel: () => ref
            .read(generationServiceProvider(widget.schoolId).notifier)
            .cancel(),
      );
    }

    return schedulesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (schedules) {
        if (schedules.isNotEmpty &&
            ((_selectedScheduleId == null) ||
                !schedules.any((s) => s.id == _selectedScheduleId))) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedScheduleId = schedules.first.id;
                _currentScheduleName = schedules.first.name;
              });
            }
          });
        }

        if (schedules.isEmpty) {
          return _EmptyState(
            colors: colors,
            l10n: l10n,
            onGenerate: () => _startGeneration(schedules),
          );
        }

        if (_selectedScheduleId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ScheduleGrid(
          scheduleId: _selectedScheduleId!,
          schoolId: widget.schoolId,
          viewMode: _viewMode,
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget {
  final AsyncValue<List<ScheduleModel>> schedulesAsync;
  final String? selectedScheduleId;
  final ScheduleViewMode viewMode;
  final GenerationPhase genPhase;
  final AppColors colors;
  final AppLocalizations l10n;
  final void Function(List<ScheduleModel>) onVersionsTap;
  final void Function(List<ScheduleModel>) onGenerate;
  final void Function(ScheduleViewMode) onViewModeChanged;
  final VoidCallback? onExport;

  const _ScheduleHeader({
    required this.schedulesAsync,
    required this.selectedScheduleId,
    required this.viewMode,
    required this.genPhase,
    required this.colors,
    required this.l10n,
    required this.onVersionsTap,
    required this.onGenerate,
    required this.onViewModeChanged,
    required this.onExport,
  });

  bool get _isBusy =>
      genPhase == GenerationPhase.loadingData ||
      genPhase == GenerationPhase.validating ||
      genPhase == GenerationPhase.generating ||
      genPhase == GenerationPhase.saving;

  @override
  Widget build(BuildContext context) {
    return schedulesAsync.when(
      loading: () => _content(context, [], null),
      error: (_, __) => _content(context, [], null),
      data: (schedules) {
        final selected = schedules
            .where((s) => s.id == selectedScheduleId)
            .firstOrNull;
        return _content(context, schedules, selected);
      },
    );
  }

  Widget _content(BuildContext context, List<ScheduleModel> schedules,
      ScheduleModel? selected) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.navSchedule,
                      style: AppTextStyles.overline
                          .copyWith(color: colors.textMuted)),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: schedules.isNotEmpty && !_isBusy
                        ? () => onVersionsTap(schedules)
                        : null,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Flexible(
                        child: Text(
                          selected?.name ?? l10n.noScheduleYet,
                          style: AppTextStyles.titleMedium
                              .copyWith(color: colors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (schedules.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded,
                            size: 18, color: colors.textMuted),
                      ],
                    ]),
                  ),
                ],
              ),
            ),
            _GenerateButton(
              isBusy: _isBusy,
              hasSchedules: schedules.isNotEmpty,
              colors: colors,
              l10n: l10n,
              onTap: _isBusy ? null : () => onGenerate(schedules),
            ),
            if (onExport != null && !_isBusy) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.ios_share_rounded,
                    color: colors.textMuted, size: 20),
                onPressed: onExport,
                tooltip: l10n.export,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ]),
          if (selectedScheduleId != null && !_isBusy)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: _ViewModeToggle(
                viewMode: viewMode,
                colors: colors,
                l10n: l10n,
                onChanged: onViewModeChanged,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Generate button ───────────────────────────────────────────────────────

class _GenerateButton extends StatelessWidget {
  final bool isBusy;
  final bool hasSchedules;
  final AppColors colors;
  final AppLocalizations l10n;
  final VoidCallback? onTap;

  const _GenerateButton({
    required this.isBusy,
    required this.hasSchedules,
    required this.colors,
    required this.l10n,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        gradient: onTap != null
            ? LinearGradient(
                colors: [colors.primary, colors.primaryLight],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: onTap == null ? colors.borderDefault : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: onTap != null
            ? [
                BoxShadow(
                  color: colors.primary.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isBusy)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              else
                const Icon(Icons.bolt_rounded,
                    size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                isBusy
                    ? l10n.generating
                    : hasSchedules
                        ? l10n.reGenerate
                        : l10n.generate,
                style: AppTextStyles.button
                    .copyWith(color: Colors.white),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── View mode toggle ──────────────────────────────────────────────────────

class _ViewModeToggle extends StatelessWidget {
  final ScheduleViewMode viewMode;
  final AppColors colors;
  final AppLocalizations l10n;
  final void Function(ScheduleViewMode) onChanged;

  const _ViewModeToggle({
    required this.viewMode,
    required this.colors,
    required this.l10n,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final modes = [
      (ScheduleViewMode.allClassrooms, l10n.viewAllClassrooms,
          Icons.grid_view_rounded),
      (ScheduleViewMode.singleClassroom, l10n.viewSingleClassroom,
          Icons.crop_square_rounded),
      (ScheduleViewMode.perTeacher, l10n.viewPerTeacher,
          Icons.person_outline_rounded),
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: modes.map((m) {
          final active = viewMode == m.$1;
          return GestureDetector(
            onTap: () => onChanged(m.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                        colors: [colors.primary, colors.primaryLight])
                    : null,
                borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMd - 2),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(m.$3,
                    size: 13,
                    color: active ? Colors.white : colors.textMuted),
                const SizedBox(width: 4),
                Text(m.$2,
                    style: AppTextStyles.labelSmall.copyWith(
                        color:
                            active ? Colors.white : colors.textMuted)),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Generating progress view ──────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  final GenerationState genState;
  final AppColors colors;
  final AppLocalizations l10n;
  final VoidCallback onCancel;

  const _GeneratingView({
    required this.genState,
    required this.colors,
    required this.l10n,
    required this.onCancel,
  });

  String get _phaseLabel {
    switch (genState.phase) {
      case GenerationPhase.loadingData:
        return 'Loading school data…';
      case GenerationPhase.validating:
        return 'Checking for constraint conflicts…';
      case GenerationPhase.generating:
        return 'Running MCF Greedy + Simulated Annealing…';
      case GenerationPhase.saving:
        return 'Saving schedule to cloud…';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = genState.phase == GenerationPhase.generating
        ? genState.progress
        : genState.phase == GenerationPhase.saving
            ? 1.0
            : 0.05;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: progress,
                strokeWidth: 7,
                backgroundColor: colors.borderDefault,
                valueColor: AlwaysStoppedAnimation(colors.primary),
                strokeCap: StrokeCap.round,
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(
                  '${(progress * 100).round()}%',
                  style: AppTextStyles.titleSmall
                      .copyWith(color: colors.textPrimary),
                ),
              ]),
            ]),
          ),
          const SizedBox(height: 28),
          Text(l10n.generating,
              style: AppTextStyles.titleMedium
                  .copyWith(color: colors.textPrimary)),
          const SizedBox(height: 8),
          Text(
            _phaseLabel,
            style: AppTextStyles.bodySmall
                .copyWith(color: colors.textMuted),
            textAlign: TextAlign.center,
          ),
          if (genState.phase == GenerationPhase.generating &&
              genState.iterationsCompleted > 0) ...[
            const SizedBox(height: 6),
            Text(
              '${_formatIterations(genState.iterationsCompleted)} iterations',
              style: AppTextStyles.labelSmall
                  .copyWith(color: colors.textMuted),
            ),
          ],
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.cancel_outlined, size: 16),
            label: Text(l10n.cancelGeneration),
            style: OutlinedButton.styleFrom(
              foregroundColor: colors.error,
              side: BorderSide(color: colors.error.withOpacity(0.4)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatIterations(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}k';
    return '$n';
  }
}

// ── Error / conflict banner ───────────────────────────────────────────────

class _ErrorBanner extends StatefulWidget {
  final String message;
  final List<ConflictResult> conflicts;
  final AppColors colors;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.conflicts,
    required this.colors,
    required this.onDismiss,
  });

  @override
  State<_ErrorBanner> createState() => _ErrorBannerState();
}

class _ErrorBannerState extends State<_ErrorBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.errorBg,
          border: Border.all(color: colors.error.withOpacity(0.35)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: widget.conflicts.isNotEmpty
                ? () => setState(() => _expanded = !_expanded)
                : null,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(children: [
                Icon(Icons.error_outline_rounded,
                    color: colors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.message,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: colors.error)),
                ),
                if (widget.conflicts.isNotEmpty)
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: colors.error,
                    size: 18,
                  )
                else
                  GestureDetector(
                    onTap: widget.onDismiss,
                    child: Icon(Icons.close_rounded,
                        color: colors.textMuted, size: 16),
                  ),
              ]),
            ),
          ),
          if (_expanded)
            ...widget.conflicts.map((c) => Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.description,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: colors.textSecondary)),
                      const SizedBox(height: 3),
                      Text('💡 ${c.suggestion}',
                          style: AppTextStyles.labelSmall
                              .copyWith(color: colors.textMuted)),
                      Divider(
                          color: colors.borderSubtle, height: 14),
                    ],
                  ),
                )),
        ]),
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final AppColors colors;
  final AppLocalizations l10n;
  final VoidCallback onGenerate;

  const _EmptyState({
    required this.colors,
    required this.l10n,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_month_outlined,
                size: 64, color: colors.textMuted),
            const SizedBox(height: 20),
            Text(l10n.noScheduleYet,
                style: AppTextStyles.titleMedium
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 8),
            Text(
              l10n.generateToSeeSchedule,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 28),
            Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [colors.primary, colors.primaryLight],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight),
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusMd),
                boxShadow: [
                  BoxShadow(
                    color: colors.primary.withOpacity(0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onGenerate,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(l10n.generate,
                            style: AppTextStyles.button
                                .copyWith(color: Colors.white)),
                      ],
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

// ── Extension ─────────────────────────────────────────────────────────────

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}