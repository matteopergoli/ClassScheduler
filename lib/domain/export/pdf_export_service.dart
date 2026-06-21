// lib/domain/export/pdf_export_service.dart
//
// FR-EXP-01: A4 PDF export.
//   - One timetable grid per classroom
//   - Optional combined overview page
//   - School name, schedule version name, generation date, teacher names
//   - Break rows shaded grey
//   - Violation cells marked red
//   - Exported via dart-pdf; shared via printing package

import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/models/app_models.dart';

class PdfExportService {
  static Future<Uint8List> generate({
    required String               schoolName,
    required String               scheduleName,
    required String               generatedAt,
    required List<String>         activeDayCodes,
    required List<PeriodModel>    periods,
    required List<ClassroomModel> classrooms,
    required List<SubjectModel>   subjects,
    required List<ScheduleCellModel> cells,
    ScheduleModel?                scheduleStats, // optional: quality/F1/F2
    bool includeOverview = true,
  }) async {
    final subjectById   = {for (final s in subjects)   s.id: s};
    final classroomById = {for (final c in classrooms) c.id: c};

    // Index cells: classroomId|dayCode|periodId → cell
    final cellIndex = <String, ScheduleCellModel>{};
    for (final cell in cells) {
      final dayCode = _dayFromCellId(cell.id, activeDayCodes);
      if (dayCode != null) {
        cellIndex['${cell.classroomId}|$dayCode|${cell.periodId}'] = cell;
      }
    }

    final lessonPeriods = periods
        .where((p) => p.type == 'LESSON')
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final allPeriods = List<PeriodModel>.from(periods)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final ttf     = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();

    final doc = pw.Document(
      title:   '$scheduleName — $schoolName',
      author:  'ClassScheduler',
      creator: 'ClassScheduler',
    );

    final headerStyle = pw.TextStyle(font: ttfBold, fontSize: 8,
        color: PdfColors.white);
    final cellStyle   = pw.TextStyle(font: ttf,     fontSize: 7);
    final boldCell    = pw.TextStyle(font: ttfBold, fontSize: 7);

    final dayLabels = {
      'MON': 'Mon', 'TUE': 'Tue', 'WED': 'Wed',
      'THU': 'Thu', 'FRI': 'Fri', 'SAT': 'Sat', 'SUN': 'Sun',
    };

    // ── Helper: build one grid for a classroom ──────────────────────────
    pw.Widget buildGrid(ClassroomModel classroom) {
      final colCount  = activeDayCodes.length + 1;
      final colWidths = <int, pw.TableColumnWidth>{
        0: const pw.FixedColumnWidth(52),
        for (var i = 1; i < colCount; i++)
          i: const pw.FlexColumnWidth(),
      };

      final rows = <pw.TableRow>[];

      // Header row
      rows.add(pw.TableRow(
        decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFF1E2030)),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Text('', style: headerStyle)),
          ...activeDayCodes.map((d) => pw.Padding(
            padding: const pw.EdgeInsets.all(3),
            child: pw.Center(
              child: pw.Text(
                dayLabels[d] ?? d,
                style: headerStyle,
              ),
            ),
          )),
        ],
      ));

      // Period rows
      for (final period in allPeriods) {
        final isBreak = period.type == 'BREAK';
        final rowBg   = isBreak
            ? const PdfColor.fromInt(0xFFEEEEEE)
            : PdfColors.white;

        rows.add(pw.TableRow(
          decoration: pw.BoxDecoration(color: rowBg),
          children: [
            // Time label
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 3, vertical: 2),
              child: pw.Text(
                isBreak && period.name != null
                    ? '${period.name}\n${period.startTime}'
                    : period.startTime,
                style: pw.TextStyle(
                    font: ttf, fontSize: 6,
                    color: const PdfColor.fromInt(0xFF555555)),
              ),
            ),

            // Day cells
            ...activeDayCodes.map((dayCode) {
              if (isBreak) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Container(
                    height: 28,
                    decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFFDDDDDD)),
                    child: pw.Center(
                      child: pw.Text(
                        period.name ?? 'Break',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 6,
                            color: const PdfColor.fromInt(0xFF777777)),
                      ),
                    ),
                  ),
                );
              }

              final key     = '${classroom.id}|$dayCode|${period.id}';
              final cell    = cellIndex[key];
              final subjectId = cell?.subjectId;
              final subject   = subjectId != null
                  ? subjectById[subjectId]
                  : null;
              final isViolation = cell?.isViolation ?? false;

              if (subject == null) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Container(height: 28),
                );
              }

              final bgHex    = subject.colourHex.replaceAll('#', '').padLeft(6, '0');
              final bgColor  = _pdfColorFromHex(bgHex, opacity: 0.22);
              final bdColor  = _pdfColorFromHex(bgHex, opacity: 0.6);
              // Always use dark text for readability on the light background
              const textColor = PdfColor.fromInt(0xFF1A1A2E);

              return pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Container(
                  height: 28,
                  decoration: pw.BoxDecoration(
                    color: bgColor,
                    border: pw.Border.all(
                      color: isViolation ? PdfColors.red : bdColor,
                      width: isViolation ? 1.5 : 0.5,
                    ),
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(3)),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 2, vertical: 1),
                    child: pw.Stack(
                      children: [
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          mainAxisAlignment: pw.MainAxisAlignment.center,
                          mainAxisSize: pw.MainAxisSize.max,
                          children: [
                            pw.Text(
                              subject.name,
                              style: boldCell.copyWith(color: textColor),
                              maxLines: 1,
                              overflow: pw.TextOverflow.clip,
                            ),
                            pw.SizedBox(height: 1),
                            pw.Text(
                              subject.teacherName,
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 5.5,
                                  color: const PdfColor.fromInt(0xFF444444)),
                              maxLines: 1,
                              overflow: pw.TextOverflow.clip,
                            ),
                          ],
                        ),
                        if (isViolation)
                          pw.Positioned(
                            top: 0,
                            right: 0,
                            child: pw.Text('⚠',
                                style: pw.TextStyle(
                                    font: ttf,
                                    fontSize: 7,
                                    color: PdfColors.red)),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ));
      }

      return pw.Table(
        columnWidths:  colWidths,
        border: pw.TableBorder.all(
            color: const PdfColor.fromInt(0xFFCCCCCC), width: 0.5),
        children: rows,
      );
    }

    // ── Page header ─────────────────────────────────────────────────────
    pw.Widget buildPageHeader(String subtitle) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
          pw.Text(schoolName,
              style: pw.TextStyle(
                  font: ttfBold, fontSize: 14,
                  color: const PdfColor.fromInt(0xFF6C63FF))),
          pw.Text('ClassScheduler',
              style: pw.TextStyle(
                  font: ttf, fontSize: 8,
                  color: const PdfColor.fromInt(0xFF888888))),
        ]),
        pw.SizedBox(height: 2),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
          pw.Text(subtitle,
              style: pw.TextStyle(
                  font: ttfBold, fontSize: 10,
                  color: const PdfColor.fromInt(0xFF1A1A2E))),
          pw.Text('Generated: $generatedAt  ·  $scheduleName',
              style: pw.TextStyle(
                  font: ttf, fontSize: 7,
                  color: const PdfColor.fromInt(0xFF888888))),
        ]),
        pw.Divider(
            color: const PdfColor.fromInt(0xFFCCCCCC), height: 8),
        pw.SizedBox(height: 4),
      ],
    );

    // ── Optional overview page ───────────────────────────────────────────
    if (includeOverview) {
      // Per-teacher weekly hour totals, derived from assigned cells.
      final teacherHours = <String, int>{};
      for (final cell in cells) {
        if (cell.subjectId == null) continue;
        final subject = subjectById[cell.subjectId];
        if (subject == null) continue;
        teacherHours[subject.teacherName] =
            (teacherHours[subject.teacherName] ?? 0) + 1;
      }
      final sortedTeachers = teacherHours.keys.toList()
        ..sort((a, b) => teacherHours[b]!.compareTo(teacherHours[a]!));

      final totalViolations =
          cells.where((c) => c.isViolation).length;

      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        header: (_) => buildPageHeader('Combined Overview'),
        build: (_) => [
          pw.Text(
            'All classrooms — ${activeDayCodes.map((d) => dayLabels[d] ?? d).join(' · ')}',
            style: pw.TextStyle(
                font: ttf, fontSize: 8,
                color: const PdfColor.fromInt(0xFF888888)),
          ),
          pw.SizedBox(height: 12),

          // ── Quality stats row ───────────────────────────────────────
          if (scheduleStats != null)
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              margin: const pw.EdgeInsets.only(bottom: 14),
              decoration: pw.BoxDecoration(
                color: _statusBg(scheduleStats.resultStatus),
                border: pw.Border.all(
                    color: _statusColor(scheduleStats.resultStatus),
                    width: 0.75),
                borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(5)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _StatBlock(
                    label: 'QUALITY SCORE',
                    value: '${scheduleStats.qualityScore}/100',
                    ttf: ttf, ttfBold: ttfBold,
                    color: _statusColor(scheduleStats.resultStatus),
                  ),
                  _StatBlock(
                    label: 'STATUS',
                    value: _statusLabel(scheduleStats.resultStatus),
                    ttf: ttf, ttfBold: ttfBold,
                    color: _statusColor(scheduleStats.resultStatus),
                  ),
                  _StatBlock(
                    label: 'TEACHER FREE HOURS',
                    value: '${scheduleStats.teacherFreeHours}',
                    ttf: ttf, ttfBold: ttfBold,
                    color: const PdfColor.fromInt(0xFF1A1A2E),
                  ),
                  _StatBlock(
                    label: 'SUBJECT CHANGES',
                    value: '${scheduleStats.subjectChanges}',
                    ttf: ttf, ttfBold: ttfBold,
                    color: const PdfColor.fromInt(0xFF1A1A2E),
                  ),
                  _StatBlock(
                    label: 'VIOLATIONS',
                    value: '$totalViolations',
                    ttf: ttf, ttfBold: ttfBold,
                    color: totalViolations > 0
                        ? PdfColors.red
                        : const PdfColor.fromInt(0xFF1A1A2E),
                  ),
                ],
              ),
            ),

          // ── Classroom cards ──────────────────────────────────────────
          pw.Text('Classrooms',
              style: pw.TextStyle(
                  font: ttfBold, fontSize: 10,
                  color: const PdfColor.fromInt(0xFF1A1A2E))),
          pw.SizedBox(height: 6),
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: classrooms.map((classroom) {
              final assignedCount = cells
                  .where((c) =>
                      c.classroomId == classroom.id &&
                      c.subjectId   != null)
                  .length;
              final violations = cells
                  .where((c) =>
                      c.classroomId == classroom.id &&
                      c.isViolation)
                  .length;
              return pw.Container(
                width: 100,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFFCCCCCC)),
                  borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4)),
                ),
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                  pw.Text(classroom.name,
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 9,
                          color: const PdfColor.fromInt(0xFF1A1A2E))),
                  pw.SizedBox(height: 2),
                  pw.Text('$assignedCount slots assigned',
                      style: pw.TextStyle(
                          font: ttf, fontSize: 7,
                          color: const PdfColor.fromInt(0xFF888888))),
                  if (violations > 0)
                    pw.Text('$violations violation(s)',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 7,
                            color: PdfColors.red)),
                ]),
              );
            }).toList(),
          ),

          // ── Per-teacher weekly hours ─────────────────────────────────
          if (sortedTeachers.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            pw.Text('Teacher weekly hours',
                style: pw.TextStyle(
                    font: ttfBold, fontSize: 10,
                    color: const PdfColor.fromInt(0xFF1A1A2E))),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(
                  color: const PdfColor.fromInt(0xFFCCCCCC), width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(3),
                1: pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColor.fromInt(0xFF1E2030)),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: pw.Text('Teacher',
                          style: pw.TextStyle(
                              font: ttfBold, fontSize: 8,
                              color: PdfColors.white)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: pw.Text('Hours/week',
                          style: pw.TextStyle(
                              font: ttfBold, fontSize: 8,
                              color: PdfColors.white)),
                    ),
                  ],
                ),
                ...sortedTeachers.map((t) => pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: pw.Text(t,
                          style: pw.TextStyle(
                              font: ttf, fontSize: 8,
                              color: const PdfColor.fromInt(0xFF1A1A2E))),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      child: pw.Text('${teacherHours[t]}',
                          style: pw.TextStyle(
                              font: ttfBold, fontSize: 8,
                              color: const PdfColor.fromInt(0xFF1A1A2E))),
                    ),
                  ],
                )),
              ],
            ),
          ],
        ],
      ));
    }

    // ── One page per classroom ───────────────────────────────────────────
    for (final classroom in classrooms) {
      doc.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        theme: pw.ThemeData.withFont(base: ttf, bold: ttfBold),
        header: (_) => buildPageHeader('Classroom: ${classroom.name}'),
        build: (_) => [buildGrid(classroom)],
      ));
    }

    return doc.save();
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String? _dayFromCellId(String cellId, List<String> activeDayCodes) {
    for (final d in activeDayCodes) {
      if (cellId.contains('_${d}_')) return d;
    }
    return null;
  }

  /// Build a PdfColor from a 6-char hex string with an opacity multiplier.
  /// opacity is applied by blending toward white (for backgrounds).
  static PdfColor _pdfColorFromHex(String hex, {double opacity = 1.0}) {
    final r = int.parse(hex.substring(0, 2), radix: 16);
    final g = int.parse(hex.substring(2, 4), radix: 16);
    final b = int.parse(hex.substring(4, 6), radix: 16);
    if (opacity >= 1.0) {
      return PdfColor(r / 255, g / 255, b / 255);
    }
    // Blend with white for background tints
    final rb = (r + (255 - r) * (1 - opacity)).round();
    final gb = (g + (255 - g) * (1 - opacity)).round();
    final bb = (b + (255 - b) * (1 - opacity)).round();
    return PdfColor(rb / 255, gb / 255, bb / 255);
  }

  static PdfColor _statusColor(String resultStatus) {
    switch (resultStatus) {
      case 'PERFECT':         return const PdfColor.fromInt(0xFF10B981);
      case 'SOFT_VIOLATIONS': return const PdfColor.fromInt(0xFFD97706);
      default:                return PdfColors.red;
    }
  }

  static PdfColor _statusBg(String resultStatus) {
    switch (resultStatus) {
      case 'PERFECT':         return const PdfColor.fromInt(0xFFE6F9F1);
      case 'SOFT_VIOLATIONS': return const PdfColor.fromInt(0xFFFEF3E2);
      default:                return const PdfColor.fromInt(0xFFFDE8E8);
    }
  }

  static String _statusLabel(String resultStatus) {
    switch (resultStatus) {
      case 'PERFECT':         return 'Perfect';
      case 'SOFT_VIOLATIONS': return 'Soft violations';
      default:                return 'Hard violations';
    }
  }
}

// ── Small stat block used on the overview page ──────────────────────────────

class _StatBlock extends pw.StatelessWidget {
  final String label;
  final String value;
  final pw.Font ttf;
  final pw.Font ttfBold;
  final PdfColor color;

  _StatBlock({
    required this.label,
    required this.value,
    required this.ttf,
    required this.ttfBold,
    required this.color,
  });

  @override
  pw.Widget build(pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(
                  font: ttf, fontSize: 6.5,
                  color: const PdfColor.fromInt(0xFF888888))),
          pw.SizedBox(height: 2),
          pw.Text(value,
              style: pw.TextStyle(
                  font: ttfBold, fontSize: 13, color: color)),
        ],
      );
}
