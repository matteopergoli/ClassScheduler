import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';
import 'export_sheet.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  final String schoolId;
  const ScheduleScreen({super.key, required this.schoolId});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  String? _selectedScheduleId;
  String? _currentScheduleName;

  void _showExport(BuildContext context) {
    if (_selectedScheduleId == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExportSheet(
        schoolId:     widget.schoolId,
        scheduleId:   _selectedScheduleId!,
        scheduleName: _currentScheduleName ?? 'Schedule',
        schoolName:   widget.schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: const Center(child: Text('Schedule Content')),
      floatingActionButton: _selectedScheduleId == null ? null : FloatingActionButton(
        onPressed: () => _showExport(context),
        child: const Icon(Icons.share),
      ),
    );
  }
}