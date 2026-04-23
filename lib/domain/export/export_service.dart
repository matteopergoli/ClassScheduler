// lib/domain/export/export_service.dart
//
// FR-EXP-01 / FR-EXP-02 / FR-EXP-03 — Export orchestration service.

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/app_models.dart';
import '../../data/repositories/period_classroom_capacity_repositories.dart';
import '../../data/repositories/schedule_repository.dart';
import '../../data/repositories/subject_repositories.dart';
import 'pdf_export_service.dart';
import 'excel_export_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum ExportFormat { pdf, excel }
enum ExportPhase  { idle, loading, exporting, sharing, done, error }

class ExportState {
  final ExportPhase phase;
  final String?     errorMessage;
  const ExportState({this.phase = ExportPhase.idle, this.errorMessage});
  ExportState copyWith({ExportPhase? phase, String? errorMessage}) =>
      ExportState(phase: phase ?? this.phase, errorMessage: errorMessage ?? this.errorMessage);
}

// ── Provider ──────────────────────────────────────────────────────────────────

final exportServiceProvider = StateNotifierProvider.family<
    ExportService, ExportState, String>(
  (ref, schoolId) => ExportService(ref, schoolId),
);

// ── Service ───────────────────────────────────────────────────────────────────

class ExportService extends StateNotifier<ExportState> {
  final Ref    _ref;
  final String _schoolId;

  ExportService(this._ref, this._schoolId) : super(const ExportState());

  Future<void> export({
    required String       scheduleId,
    required String       scheduleName,
    required String       schoolName,
    required ExportFormat format,
    bool                  includeOverview = true,
  }) async {
    state = const ExportState(phase: ExportPhase.loading);
    try {
      final periods    = await _ref.read(periodRepositoryProvider(_schoolId)).fetchAll();
      final classrooms = await _ref.read(classroomRepositoryProvider(_schoolId)).fetchAll();
      final subjects   = await _ref.read(subjectRepositoryProvider(_schoolId)).fetchAll();
      final cells      = await _ref.read(scheduleRepositoryProvider(_schoolId)).fetchCells(scheduleId);

      final activeDayCodes = _deriveActiveDayCodes(cells);
      if (activeDayCodes.isEmpty) throw Exception('No scheduled lessons found.');

      final generatedAt = DateFormat('d MMM yyyy, HH:mm').format(DateTime.now());
      final fileName    = _sanitise(
          '${schoolName}_${scheduleName}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}');

      state = const ExportState(phase: ExportPhase.exporting);

      final File file;
      if (format == ExportFormat.pdf) {
        final bytes = await PdfExportService.generate(
          schoolName: schoolName, scheduleName: scheduleName,
          generatedAt: generatedAt, activeDayCodes: activeDayCodes,
          periods: periods, classrooms: classrooms,
          subjects: subjects, cells: cells, includeOverview: includeOverview,
        );
        file = await _write('$fileName.pdf', bytes);
      } else {
        final bytes = ExcelExportService.generate(
          schoolName: schoolName, scheduleName: scheduleName,
          generatedAt: generatedAt, activeDayCodes: activeDayCodes,
          periods: periods, classrooms: classrooms,
          subjects: subjects, cells: cells,
        );
        file = await _write('$fileName.xlsx', bytes);
      }

      state = const ExportState(phase: ExportPhase.sharing);
      await Share.shareXFiles([XFile(file.path,
          mimeType: format == ExportFormat.pdf
              ? 'application/pdf'
              : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')],
          subject: '$schoolName — $scheduleName');

      state = const ExportState(phase: ExportPhase.done);
    } catch (e) {
      state = ExportState(phase: ExportPhase.error, errorMessage: e.toString());
    }
  }

  static List<String> _deriveActiveDayCodes(List<ScheduleCellModel> cells) {
    const ordered = ['MON','TUE','WED','THU','FRI','SAT','SUN'];
    final found = <String>{};
    for (final cell in cells) {
      for (final d in ordered) {
        if (cell.id.contains('_${d}_')) { found.add(d); break; }
      }
    }
    return ordered.where(found.contains).toList();
  }

  static Future<File> _write(String name, List<int> bytes) async {
    final dir  = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String _sanitise(String raw) => raw.replaceAll(RegExp(r'[^\w\-.]'), '_');
}
