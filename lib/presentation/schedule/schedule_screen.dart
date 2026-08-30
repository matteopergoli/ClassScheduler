// lib/presentation/schedule/schedule_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/app_models.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/school_repository.dart';
import '../../domain/constraints/constraint_conflict_detector.dart';
import '../../domain/scheduler/generation_service.dart';
import '../../l10n/generated/app_localizations.dart';
import '../widgets/trial_banner.dart';
import 'export_sheet.dart';
import 'result_panel.dart';
import 'schedule_grid.dart';
import 'version_sheet.dart';

// ── View mode enum ───────────────────────────────────────────────────────

// UPDATED: Removed singleClassroom, renamed allClassrooms to perClassroom
enum ScheduleViewMode { perClassroom, perTeacher }

// ── Schedules stream provider ────────────────────────────────────────────

final _schedulesProvider =
    StreamProvider.autoDispose.family<List<ScheduleModel>, String>(
  (ref, schoolId) =>
      ref.watch(scheduleRepositoryProvider(schoolId)).watchAll(),
);

final _schoolsProvider = StreamProvider.autoDispose<List<SchoolModel>>(
  (ref) => ref.watch(schoolRepositoryProvider).watchAll(),
);

// ── Resolves the human-readable school name from its Firestore ID ────────

final _schoolNameProvider =
    FutureProvider.autoDispose.family<String, String>((ref, schoolId) async {
  final school =
      await ref.watch(schoolRepositoryProvider).fetch(schoolId);
  return school?.name ?? schoolId;
});

// The selected school for the current Schedule tab session. Mirrors
// ConstraintsScreen/SetupScreen: uses its own selection state rather than
// the app-wide selectedSchoolIdProvider — that one gets auto-set to the
// first school as soon as the Schools tab loads, which would otherwise skip
// the picker below on every first visit to this tab.
final scheduleActiveSchoolProvider = StateProvider<String?>((ref) => null);

// ── Screen ────────────────────────────────────────────────────────────────

class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolId = ref.watch(scheduleActiveSchoolProvider);

    if (schoolId == null || schoolId.isEmpty) {
      final colors = AppColors.of(context);
      final schools = ref.watch(_schoolsProvider);
      return Scaffold(
        body: SafeArea(
          child: schools.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
            data: (list) => list.isEmpty
                ? _NoSchoolPrompt(colors: colors)
                : _SchoolPicker(
                    schools: list,
                    colors: colors,
                    onSelect: (s) => ref
                        .read(scheduleActiveSchoolProvider.notifier)
                        .state = s.id,
                  ),
          ),
        ),
      );
    }

    return _ScheduleScreenBody(schoolId: schoolId);
  }
}

class _ScheduleScreenBody extends ConsumerStatefulWidget {
  final String schoolId;
  const _ScheduleScreenBody({required this.schoolId});

  @override
  ConsumerState<_ScheduleScreenBody> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<_ScheduleScreenBody> {
  String? _selectedScheduleId;
  String? _currentScheduleName;
  ScheduleViewMode _viewMode = ScheduleViewMode.perClassroom; // Updated default
  bool _isEditing = false;
  // The last generation result stays around (in generationServiceProvider)
  // regardless of which schedule version is currently selected, so rather
  // than tying its visibility to schedule selection, it's tracked as its
  // own collapsed/expanded/dismissed UI state — switching versions just
  // collapses it to a summary bar instead of hiding it outright, so it's
  // still one tap away instead of gone.
  bool _resultPanelExpanded = true;
  bool _resultPanelDismissed = false;

  @override
  void didUpdateWidget(covariant _ScheduleScreenBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.schoolId != widget.schoolId) {
      _selectedScheduleId = null;
      _currentScheduleName = null;
      _isEditing = false;
      _resultPanelExpanded = true;
      _resultPanelDismissed = false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _onScheduleSelected(String scheduleId, String scheduleName) {
    setState(() {
      _selectedScheduleId = scheduleId;
      _currentScheduleName = scheduleName;
      _isEditing = false;
      _resultPanelExpanded = false;
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
    final fallbackName = 'Schedule ${existingSchedules.length + 1}';
    final suggestedName = (_currentScheduleName?.trim().isNotEmpty ?? false)
        ? _currentScheduleName!.trim()
        : fallbackName;

    final nameCtrl = TextEditingController(
      text: suggestedName,
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
      ? suggestedName
      : nameCtrl.text.trim();

    // Check for Duplicate Name
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

    setState(() => _resultPanelDismissed = true);

    await ref
        .read(generationServiceProvider(widget.schoolId).notifier)
        .generate(scheduleName: name);
  }

  void _showExport() {
    if (_selectedScheduleId == null) return;
    final schoolNameAsync = ref.read(_schoolNameProvider(widget.schoolId));
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(
        schoolId: widget.schoolId,
        scheduleId: _selectedScheduleId!,
        scheduleName: _currentScheduleName ?? 'Schedule',
        schoolName: schoolNameAsync.valueOrNull ?? widget.schoolId,
      ),
    );
  }

  Future<void> _showSchoolSheet(List<SchoolModel> schools) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final colors = AppColors.of(sheetContext);
        final l10n = AppLocalizations.of(sheetContext);
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceBg,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDimensions.radiusXl),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.borderDefault,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.yourSchools,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ),
                ...schools.map(
                  (school) => ListTile(
                    leading: Icon(
                      school.id == widget.schoolId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: school.id == widget.schoolId
                          ? colors.primary
                          : colors.textMuted,
                    ),
                    title: Text(school.name),
                    selected: school.id == widget.schoolId,
                    onTap: () {
                      ref.read(scheduleActiveSchoolProvider.notifier).state =
                          school.id;
                      Navigator.pop(sheetContext);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    final genState = ref.watch(generationServiceProvider(widget.schoolId));
    final schedulesAsync = ref.watch(_schedulesProvider(widget.schoolId));
    final schoolsAsync = ref.watch(_schoolsProvider);

    // Ensure the school name is loaded/cached before Export is tapped.
    ref.watch(_schoolNameProvider(widget.schoolId));

    ref.listen(generationServiceProvider(widget.schoolId), (prev, next) {
      if (next.phase == GenerationPhase.done) {
        setState(() {
          _resultPanelDismissed = false;
          _resultPanelExpanded = true;
        });

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
              schools: schoolsAsync.valueOrNull ?? const [],
              schoolId: widget.schoolId,
              selectedScheduleId: _selectedScheduleId,
              viewMode: _viewMode,
              genPhase: genState.phase,
              colors: colors,
              l10n: l10n,
              onVersionsTap: (schedules) => _showVersionSheet(schedules),
              onSchoolTap: (schools) => _showSchoolSheet(schools),
              onGenerate: (schedules) => _startGeneration(schedules),
              onViewModeChanged: (mode) =>
                  setState(() {
                    _viewMode = mode;
                    if (mode == ScheduleViewMode.perTeacher) {
                      _isEditing = false;
                    }
                  }),
              isEditing: _isEditing,
              onEditingChanged: (value) =>
                  setState(() => _isEditing = value),
              onExport: _selectedScheduleId != null ? _showExport : null,
            ),
            const TrialBanner(),
            if (!_resultPanelDismissed && genState.result != null)
              _resultPanelExpanded
                  ? ResultPanel(
                      result: genState.result!,
                      colors: colors,
                      l10n: l10n,
                      onCollapse: () =>
                          setState(() => _resultPanelExpanded = false),
                    )
                  : ResultSummaryBar(
                      result: genState.result!,
                      colors: colors,
                      l10n: l10n,
                      onExpand: () =>
                          setState(() => _resultPanelExpanded = true),
                      onDismiss: () =>
                          setState(() => _resultPanelDismissed = true),
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
                _isEditing = false;
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
          isEditing: _isEditing,
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────

class _ScheduleHeader extends StatelessWidget {
  final AsyncValue<List<ScheduleModel>> schedulesAsync;
  final List<SchoolModel> schools;
  final String schoolId;
  final String? selectedScheduleId;
  final ScheduleViewMode viewMode;
  final GenerationPhase genPhase;
  final AppColors colors;
  final AppLocalizations l10n;
  final void Function(List<ScheduleModel>) onVersionsTap;
  final void Function(List<SchoolModel>) onSchoolTap;
  final void Function(List<ScheduleModel>) onGenerate;
  final void Function(ScheduleViewMode) onViewModeChanged;
  final bool isEditing;
  final ValueChanged<bool> onEditingChanged;
  final VoidCallback? onExport;

  const _ScheduleHeader({
    required this.schedulesAsync,
    required this.schools,
    required this.schoolId,
    required this.selectedScheduleId,
    required this.viewMode,
    required this.genPhase,
    required this.colors,
    required this.l10n,
    required this.onVersionsTap,
    required this.onSchoolTap,
    required this.onGenerate,
    required this.onViewModeChanged,
    required this.isEditing,
    required this.onEditingChanged,
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
    final selectedSchool = schools
      .where((school) => school.id == schoolId)
      .firstOrNull;

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
                  GestureDetector(
                    onTap: schools.length > 1
                        ? () => onSchoolTap(schools)
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            selectedSchool?.name ?? schoolId,
                            style: AppTextStyles.titleSmall.copyWith(
                              color: colors.textSecondary,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (schools.length > 1) ...[
                          const SizedBox(width: 2),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: colors.textMuted,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
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
          ]),
          const SizedBox(height: 10),
          Row(
            children: [
            if (selectedScheduleId != null && !_isBusy)
              _ViewModeToggle(
                viewMode: viewMode,
                colors: colors,
                l10n: l10n,
                onChanged: onViewModeChanged,
              ),
            const Spacer(),
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
            const SizedBox(width: 8),
            Visibility(
              visible: selectedScheduleId != null &&
                  !_isBusy &&
                  viewMode == ScheduleViewMode.perClassroom,
              maintainSize: true,
              maintainAnimation: true,
              maintainState: true,
              child: OutlinedButton.icon(
                onPressed: () => onEditingChanged(!isEditing),
                icon: Icon(
                  isEditing ? Icons.check_rounded : Icons.edit_outlined,
                  size: 17,
                ),
                label: Text(isEditing ? l10n.done : l10n.edit),
              ),
            ),
            ],
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
    // UPDATED: Only two options now
    final modes = [
      (ScheduleViewMode.perClassroom, 'Per Classroom',
          Icons.grid_view_rounded),
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

// ── Error Banner ─────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final List<dynamic> conflicts;
  final AppColors colors;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.message,
    required this.conflicts,
    required this.colors,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.error.withOpacity(0.1),
        border: Border.all(color: colors.error),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                if (conflicts.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${conflicts.length} conflict${conflicts.length != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colors.textMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: colors.textMuted),
            onPressed: onDismiss,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}

// ── Generating View ───────────────────────────────────────────────────────

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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.primary),
          const SizedBox(height: 24),
          Text(
            l10n.generating,
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              genState.progress <= 0
                  ? 'Starting...'
                  : '${(genState.progress * 100).clamp(0.0, 100.0).toStringAsFixed(
                      genState.progress < 0.99 ? 1 : 0)}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: colors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: onCancel,
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(l10n.cancelGeneration),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────

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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: colors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noScheduleYet,
            style: AppTextStyles.titleMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.generateToSeeSchedule,
            style: AppTextStyles.bodySmall.copyWith(
              color: colors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.bolt_rounded),
            label: Text(l10n.generate),
          ),
        ],
      ),
    );
  }
}

// ── School picker (mirrors ConstraintsScreen's/SetupScreen's) ──────────────

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
            child: Text('Select a school for schedule',
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
