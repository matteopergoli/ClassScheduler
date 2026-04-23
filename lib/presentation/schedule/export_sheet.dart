// lib/presentation/schedule/export_sheet.dart
//
// FR-EXP-01 / FR-EXP-02 / FR-EXP-03
//
// Bottom sheet shown when the user taps Export.
// Allows selecting PDF or Excel format, optional combined overview,
// then triggers ExportService and shows progress / error feedback.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_dimensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/export/export_service.dart';
import '../../l10n/generated/app_localizations.dart';

class ExportSheet extends ConsumerStatefulWidget {
  final String schoolId;
  final String scheduleId;
  final String scheduleName;
  final String schoolName;

  const ExportSheet({
    super.key,
    required this.schoolId,
    required this.scheduleId,
    required this.scheduleName,
    required this.schoolName,
  });

  @override
  ConsumerState<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends ConsumerState<ExportSheet> {
  ExportFormat _format          = ExportFormat.pdf;
  bool         _includeOverview = true;

  @override
  Widget build(BuildContext context) {
    final l10n     = AppLocalizations.of(context);
    final colors   = AppColors.of(context);
    final expState = ref.watch(exportServiceProvider(widget.schoolId));

    final phase = expState.phase;
    final busy  = phase == ExportPhase.loading   ||
                  phase == ExportPhase.exporting  ||
                  phase == ExportPhase.sharing;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceBg,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXl)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: colors.borderDefault,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(l10n.exportSchedule,
                style: AppTextStyles.titleMedium
                    .copyWith(color: colors.textPrimary)),
            const SizedBox(height: 4),
            Text(
              widget.scheduleName,
              style: AppTextStyles.bodySmall
                  .copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: 20),

            // Format selector
            Text(l10n.exportFormat,
                style: AppTextStyles.labelMedium
                    .copyWith(color: colors.textSecondary)),
            const SizedBox(height: 10),
            Row(children: [
              _FormatButton(
                label:    'PDF',
                subtitle: l10n.exportPdfSubtitle,
                icon:     Icons.picture_as_pdf_outlined,
                selected: _format == ExportFormat.pdf,
                colors:   colors,
                onTap:    busy
                    ? null
                    : () => setState(
                        () => _format = ExportFormat.pdf),
              ),
              const SizedBox(width: 12),
              _FormatButton(
                label:    'Excel',
                subtitle: l10n.exportExcelSubtitle,
                icon:     Icons.table_chart_outlined,
                selected: _format == ExportFormat.excel,
                colors:   colors,
                onTap:    busy
                    ? null
                    : () => setState(
                        () => _format = ExportFormat.excel),
              ),
            ]),
            const SizedBox(height: 16),

            // Overview toggle (PDF only)
            if (_format == ExportFormat.pdf)
              _ToggleRow(
                label:   l10n.exportIncludeOverview,
                value:   _includeOverview,
                colors:  colors,
                enabled: !busy,
                onChanged: (v) =>
                    setState(() => _includeOverview = v),
              ),

            const SizedBox(height: 20),

            // Error message
            if (phase == ExportPhase.error &&
                expState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.errorBg,
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd),
                    border: Border.all(
                        color: colors.error.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    Icon(Icons.error_outline_rounded,
                        color: colors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        expState.errorMessage!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: colors.error),
                      ),
                    ),
                  ]),
                ),
              ),

            // Export button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: busy ? null : _export,
                icon: busy
                    ? SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.textMuted),
                      )
                    : Icon(
                        _format == ExportFormat.pdf
                            ? Icons.picture_as_pdf_outlined
                            : Icons.table_chart_outlined,
                        size: 18,
                      ),
                label: Text(_buttonLabel(phase, l10n)),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 14),
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      colors.primary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd),
                  ),
                ),
              ),
            ),

            // Success message
            if (phase == ExportPhase.done) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  l10n.exportSuccess,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: colors.success),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _buttonLabel(ExportPhase phase, AppLocalizations l10n) {
    switch (phase) {
      case ExportPhase.loading:
        return l10n.exportLoading;
      case ExportPhase.exporting:
        return l10n.exportGenerating;
      case ExportPhase.sharing:
        return l10n.exportSharing;
      default:
        return _format == ExportFormat.pdf
            ? l10n.exportAsPdf
            : l10n.exportAsExcel;
    }
  }

  Future<void> _export() async {
    await ref
        .read(exportServiceProvider(widget.schoolId).notifier)
        .export(
          scheduleId:      widget.scheduleId,
          scheduleName:    widget.scheduleName,
          schoolName:      widget.schoolName,
          format:          _format,
          includeOverview: _includeOverview,
        );
  }
}

// ── Format button ─────────────────────────────────────────────────────────

class _FormatButton extends StatelessWidget {
  final String       label;
  final String       subtitle;
  final IconData     icon;
  final bool         selected;
  final AppColors    colors;
  final VoidCallback? onTap;

  const _FormatButton({
    required this.label,    required this.subtitle,
    required this.icon,     required this.selected,
    required this.colors,   required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary.withOpacity(0.12)
              : colors.surfaceVariant,
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.borderDefault,
            width: selected ? 2 : 1,
          ),
          borderRadius:
              BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: selected
                    ? colors.primary
                    : colors.textMuted,
                size: 22),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.labelMedium.copyWith(
                    color: selected
                        ? colors.primary
                        : colors.textPrimary,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: AppTextStyles.labelSmall
                    .copyWith(color: colors.textMuted)),
          ],
        ),
      ),
    ),
  );
}

// ── Toggle row ────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final String       label;
  final bool         value;
  final AppColors    colors;
  final bool         enabled;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,   required this.value,
    required this.colors,  required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(
      child: Text(label,
          style: AppTextStyles.bodyMedium
              .copyWith(color: colors.textPrimary)),
    ),
    Switch.adaptive(
      value:    value,
      onChanged: enabled ? onChanged : null,
      activeColor: colors.primary,
    ),
  ]);
}
