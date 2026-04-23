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
  /// Builds a PDF document and returns its bytes.
  ///
  /// [schoolName]     — displayed in the header of every page
  /// [scheduleName]   — displayed as the schedule version name
  /// [generatedAt]    — datetime string shown on each page
  /// [activeDayCodes] — ordered list of active day codes e.g. ['MON'…'FRI']
  /// [periods]        — ALL periods for the school (LESSON + BREAK), sorted
  /// [classrooms]     — all classrooms
  /// [subjects]       — all subjects (for colour + teacher lookup)
  /// [cells]          — all ScheduleCellModels for the chosen schedule
  /// [includeOverview]— whether to prepend a combined overview page
  static Future<Uint8List> generate({
    required String               schoolName,
    required String               scheduleName,
    required String               generatedAt,
    required List<String>         activeDayCodes,
    required List<PeriodModel>    periods,
    required List<ClassroomModel> classrooms,
    required List<SubjectModel>   subjects,
    required List<ScheduleCellModel> cells,
    bool includeOverview = true,
  }) async {
    // ── Pre-build lookup maps ────────────────────────────────────────────
    final subjectById   = {for (final s in subjects)   s.id: s};
    final classroomById = {for (final c in classrooms) c.id: c};

    // cells indexed by (classroomId, dayCode, periodId)
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

    // ── Load font ────────────────────────────────────────────────────────
    final ttf = await PdfGoogleFonts.nunitoRegular();
    final ttfBold = await PdfGoogleFonts.nunitoBold();

    final doc = pw.Document(
      title:    '$scheduleName — $schoolName',
      author:   'ClassScheduler',
      creator:  'ClassScheduler',
    );

    final headerStyle = pw.TextStyle(font: ttfBold, fontSize: 8);
    final cellStyle   = pw.TextStyle(font: ttf,     fontSize: 7);
    final boldCell    = pw.TextStyle(font: ttfBold, fontSize: 7);

    final dayLabels = {
      'MON': 'Mon', 'TUE': 'Tue', 'WED': 'Wed',
      'THU': 'Thu', 'FRI': 'Fri', 'SAT': 'Sat', 'SUN': 'Sun',
    };

    // ── Helper: build one grid for a classroom ───────────────────────────
    pw.Widget buildGrid(ClassroomModel classroom) {
      // Column widths: time label + one col per day
      final colCount  = activeDayCodes.length + 1;
      final colWidths = <int, pw.TableColumnWidth>{
        0: const pw.FixedColumnWidth(52),
        for (var i = 1; i < colCount; i++)
          i: const pw.FlexColumnWidth(),
      };

      final rows = <pw.TableRow>[];

      // Header row (day names)
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
                style: pw.TextStyle(
                    font: ttfBold, fontSize: 8,
                    color: PdfColors.white),
              ),
            ),
          )),
        ],
      ));

      // Period rows
      for (final period in allPeriods) {
        final isBreak = period.type == 'BREAK';
        final rowBg   = isBreak
            ? const PdfColor.fromInt(0xFF2A2D3E)
            : PdfColors.white;

        rows.add(pw.TableRow(
          decoration: pw.BoxDecoration(color: rowBg),
          children: [
            // Time label cell
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(
                  horizontal: 3, vertical: 2),
              child: pw.Text(
                isBreak && period.name != null
                    ? '${period.name}\n${period.startTime}'
                    : period.startTime,
                style: pw.TextStyle(
                    font: ttf, fontSize: 6,
                    color: const PdfColor.fromInt(0xFF94A3B8)),
              ),
            ),

            // Day cells
            ...activeDayCodes.map((dayCode) {
              if (isBreak) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Container(
                    height: 20,
                    decoration: const pw.BoxDecoration(
                        color: PdfColor.fromInt(0xFF252836)),
                    child: pw.Center(
                      child: pw.Text(
                        period.name ?? 'Break',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 6,
                            color: const PdfColor.fromInt(0xFF64748B)),
                      ),
                    ),
                  ),
                );
              }

              final key  = '${classroom.id}|$dayCode|${period.id}';
              final cell = cellIndex[key];
              final subjectId = cell?.subjectId;
              final subject   = subjectId != null
                  ? subjectById[subjectId]
                  : null;
              final isViolation = cell?.isViolation ?? false;

              if (subject == null) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(2),
                  child: pw.Container(height: 20),
                );
              }

              final hexColor = _pdfColor(subject.colourHex);
              final bgColor  = PdfColor(
                hexColor.red,
                hexColor.green,
                hexColor.blue,
                0.18,
              );

              return pw.Padding(
                padding: const pw.EdgeInsets.all(2),
                child: pw.Container(
                  height: 20,
                  decoration: pw.BoxDecoration(
                    color: bgColor,
                    border: pw.Border.all(
                      color: isViolation
                          ? PdfColors.red
                          : PdfColor(hexColor.red, hexColor.green, hexColor.blue, 0.5),
                      width: isViolation ? 1.5 : 0.5,
                    ),
                    borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(3)),
                  ),
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.all(2),
                    child: pw.Column(
                      crossAxisAlignment:
                          pw.CrossAxisAlignment.start,
                      mainAxisAlignment:
                          pw.MainAxisAlignment.center,
                      children: [
                        pw.Text(subject.name,
                            style: boldCell.copyWith(
                                color: hexColor),
                            maxLines: 1),
                        pw.Text(subject.teacherName,
                            style: cellStyle.copyWith(
                                fontSize: 5.5,
                                color: const PdfColor.fromInt(
                                    0xFF94A3B8)),
                            maxLines: 1),
                        if (isViolation)
                          pw.Text('⚠',
                              style: pw.TextStyle(
                                  font: ttf,
                                  fontSize: 7,
                                  color: PdfColors.red)),
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
            color: const PdfColor.fromInt(0xFF2A2D3E), width: 0.5),
        children: rows,
      );
    }

    // ── Helper: page header ──────────────────────────────────────────────
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
                  color: const PdfColor.fromInt(0xFF64748B))),
        ]),
        pw.SizedBox(height: 2),
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
          pw.Text(subtitle,
              style: pw.TextStyle(
                  font: ttfBold, fontSize: 10,
                  color: const PdfColor.fromInt(0xFFF1F5F9))),
          pw.Text('Generated: $generatedAt  ·  $scheduleName',
              style: pw.TextStyle(
                  font: ttf, fontSize: 7,
                  color: const PdfColor.fromInt(0xFF94A3B8))),
        ]),
        pw.Divider(
            color: const PdfColor.fromInt(0xFF2A2D3E), height: 8),
        pw.SizedBox(height: 4),
      ],
    );

    // ── Optional: combined overview page ─────────────────────────────────
    if (includeOverview) {
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
                color: const PdfColor.fromInt(0xFF64748B)),
          ),
          pw.SizedBox(height: 6),
          // Compact side-by-side: just show classroom names + slot count
          pw.Wrap(
            spacing: 8,
            runSpacing: 8,
            children: classrooms.map((classroom) {
              final assignedCount = cells
                  .where((c) =>
                      c.classroomId == classroom.id &&
                      c.subjectId   != null)
                  .length;
              return pw.Container(
                width: 100,
                padding: const pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                      color: const PdfColor.fromInt(0xFF2A2D3E)),
                  borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(4)),
                ),
                child: pw.Column(
                    crossAxisAlignment:
                        pw.CrossAxisAlignment.start,
                    children: [
                  pw.Text(classroom.name,
                      style: pw.TextStyle(
                          font: ttfBold, fontSize: 9,
                          color: const PdfColor.fromInt(0xFFF1F5F9))),
                  pw.SizedBox(height: 2),
                  pw.Text('$assignedCount slots assigned',
                      style: pw.TextStyle(
                          font: ttf, fontSize: 7,
                          color: const PdfColor.fromInt(0xFF94A3B8))),
                ]),
              );
            }).toList(),
          ),
        ],
      ));
    }

    // ── One page per classroom ────────────────────────────────────────────
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

  static String? _dayFromCellId(
      String cellId, List<String> activeDayCodes) {
    for (final d in activeDayCodes) {
      if (cellId.contains('_${d}_')) return d;
    }
    return null;
  }

  static PdfColor _pdfColor(String hex) {
    final h = int.tryParse(
            hex.replaceAll('#', '').padLeft(6, '0'),
            radix: 16) ??
        0x6C63FF;
    return PdfColor.fromInt(h | 0xFF000000);
  }
}
