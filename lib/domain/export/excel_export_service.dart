// lib/domain/export/excel_export_service.dart
//
// FR-EXP-02: Excel (.xlsx) export.
//   - One worksheet per classroom
//   - Summary worksheet with all classrooms
//   - Subject cells colour-coded (fill + font)
//   - Teacher name, subject name, time slot in each cell
//   - Break rows shaded grey
//   - Exported via excel package; shared via share_plus / path_provider

import 'dart:typed_data';
import 'package:excel/excel.dart';

import '../../data/models/app_models.dart';

class ExcelExportService {
  /// Builds an Excel workbook and returns its bytes.
  static Uint8List generate({
    required String               schoolName,
    required String               scheduleName,
    required String               generatedAt,
    required List<String>         activeDayCodes,
    required List<PeriodModel>    periods,
    required List<ClassroomModel> classrooms,
    required List<SubjectModel>   subjects,
    required List<ScheduleCellModel> cells,
  }) {
    final excel = Excel.createExcel();

    // ── Pre-build lookup maps ────────────────────────────────────────────
    final subjectById = {for (final s in subjects) s.id: s};

    // cells indexed: classroomId → dayCode → periodId → cell
    final cellIndex = <String, Map<String, Map<String, ScheduleCellModel>>>{};
    for (final cell in cells) {
      final dayCode = _dayFromCellId(cell.id, activeDayCodes);
      if (dayCode == null) continue;
      cellIndex
          .putIfAbsent(cell.classroomId, () => {})
          .putIfAbsent(dayCode, () => {})[cell.periodId] = cell;
    }

    final allPeriods = List<PeriodModel>.from(periods)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final dayLabels = {
      'MON': 'Monday', 'TUE': 'Tuesday', 'WED': 'Wednesday',
      'THU': 'Thursday', 'FRI': 'Friday',
      'SAT': 'Saturday', 'SUN': 'Sunday',
    };

    // Shared cell styles
    final headerFill = ExcelColor.fromHexString('FF1E2030');
    final breakFill  = ExcelColor.fromHexString('FF252836');
    final freeFill   = ExcelColor.fromHexString('FF0F1118');
    final white      = ExcelColor.fromHexString('FFF1F5F9');
    final grey       = ExcelColor.fromHexString('FF64748B');

    CellStyle headerStyle() => CellStyle(
      backgroundColorHex: headerFill,
      fontColorHex: white,
      bold: true,
      fontSize: 10,
      horizontalAlign: HorizontalAlign.Center,
    );

    CellStyle breakStyle() => CellStyle(
      backgroundColorHex: breakFill,
      fontColorHex: grey,
      italic: true,
      fontSize: 9,
      horizontalAlign: HorizontalAlign.Center,
    );

    CellStyle timeLabelStyle() => CellStyle(
      fontColorHex: grey,
      fontSize: 8,
      horizontalAlign: HorizontalAlign.Right,
    );

    // ── Summary sheet ────────────────────────────────────────────────────
    final summarySheet = excel['Summary'];
    summarySheet.setColumnWidth(0, 22);
    // Title row
    final titleCell = summarySheet.cell(
        CellIndex.indexByString('A1'));
    titleCell.value = TextCellValue(
        '$schoolName — $scheduleName — $generatedAt');
    titleCell.cellStyle = CellStyle(
        bold: true, fontSize: 12,
        fontColorHex: ExcelColor.fromHexString('FF6C63FF'));
    summarySheet.merge(
        CellIndex.indexByString('A1'),
        CellIndex.indexByString(
            '${_colLetter(activeDayCodes.length)}1'));

    // Classroom + assigned count
    var summaryRow = 3;
    for (final classroom in classrooms) {
      final assigned = cells
          .where((c) =>
              c.classroomId == classroom.id &&
              c.subjectId   != null)
          .length;
      final violations = cells
          .where((c) =>
              c.classroomId == classroom.id &&
              c.isViolation)
          .length;
      final c = summarySheet.cell(
          CellIndex.indexByColumnRow(
              columnIndex: 0, rowIndex: summaryRow));
      c.value = TextCellValue(classroom.name);
      c.cellStyle = CellStyle(bold: true);
      summarySheet
          .cell(CellIndex.indexByColumnRow(
              columnIndex: 1, rowIndex: summaryRow))
          .value = TextCellValue('$assigned slots assigned');
      if (violations > 0) {
        final vc = summarySheet.cell(
            CellIndex.indexByColumnRow(
                columnIndex: 2, rowIndex: summaryRow));
        vc.value =
            TextCellValue('$violations violation(s)');
        vc.cellStyle = CellStyle(
            fontColorHex: ExcelColor.fromHexString('FFEF4444'));
      }
      summaryRow++;
    }

    // ── One sheet per classroom ──────────────────────────────────────────
    for (final classroom in classrooms) {
      // Sheet name max 31 chars, sanitise
      final sheetName = classroom.name.length > 31
          ? classroom.name.substring(0, 31)
          : classroom.name;
      final sheet = excel[sheetName];

      // Set column widths
      sheet.setColumnWidth(0, 12); // time label
      for (var d = 0; d < activeDayCodes.length; d++) {
        sheet.setColumnWidth(d + 1, 22);
      }

      // ── Row 0: school/schedule info ─────────────────────────────
      final infoCell = sheet.cell(CellIndex.indexByString('A1'));
      infoCell.value = TextCellValue(
          '$schoolName  ·  $scheduleName  ·  ${classroom.name}');
      infoCell.cellStyle = CellStyle(bold: true, fontSize: 11);
      sheet.merge(
          CellIndex.indexByString('A1'),
          CellIndex.indexByString(
              '${_colLetter(activeDayCodes.length)}1'));

      // ── Row 1: day headers ───────────────────────────────────────
      final timeHeader = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
      timeHeader.value = TextCellValue('Time');
      timeHeader.cellStyle = headerStyle();

      for (var d = 0; d < activeDayCodes.length; d++) {
        final hCell = sheet.cell(CellIndex.indexByColumnRow(
            columnIndex: d + 1, rowIndex: 1));
        hCell.value =
            TextCellValue(dayLabels[activeDayCodes[d]] ??
                activeDayCodes[d]);
        hCell.cellStyle = headerStyle();
      }

      // ── Period rows (starting row 2) ─────────────────────────────
      var rowIdx = 2;
      for (final period in allPeriods) {
        final isBreak = period.type == 'BREAK';

        // Time label
        final timeCell = sheet.cell(
            CellIndex.indexByColumnRow(
                columnIndex: 0, rowIndex: rowIdx));
        timeCell.value = TextCellValue(
            '${period.startTime}–${period.endTime}');
        timeCell.cellStyle = isBreak ? breakStyle() : timeLabelStyle();

        // Day cells
        for (var d = 0; d < activeDayCodes.length; d++) {
          final dayCode = activeDayCodes[d];
          final dataCell = sheet.cell(CellIndex.indexByColumnRow(
              columnIndex: d + 1, rowIndex: rowIdx));

          if (isBreak) {
            dataCell.value = TextCellValue(
                period.name ?? 'Break');
            dataCell.cellStyle = breakStyle();
            continue;
          }

          final cell = cellIndex[classroom.id]
              ?[dayCode]?[period.id];
          final subjectId = cell?.subjectId;
          final subject   = subjectId != null
              ? subjectById[subjectId]
              : null;

          if (subject == null) {
            dataCell.value = TextCellValue('');
            dataCell.cellStyle = CellStyle(
                backgroundColorHex: freeFill);
            continue;
          }

          // Subject cell: name + teacher
          dataCell.value =
              TextCellValue('${subject.name}\n${subject.teacherName}');

          final bgHex = subject.colourHex
              .replaceAll('#', '').padLeft(6, '0');
          final fgHex = _contrastColor(bgHex);
          final isViolation = cell?.isViolation ?? false;

          dataCell.cellStyle = CellStyle(
            backgroundColorHex:
                ExcelColor.fromHexString('FF$bgHex'),
            fontColorHex:
                ExcelColor.fromHexString('FF$fgHex'),
            bold: true,
            fontSize: 9,
            textWrapping: TextWrapping.WrapText,
            horizontalAlign: HorizontalAlign.Center,
            verticalAlign: VerticalAlign.Center,
            leftBorder: isViolation
                ? Border(
                    borderStyle: BorderStyle.Thick,
                    borderColorHex: ExcelColor.fromHexString(
                        'FFEF4444'))
                : null,
          );

          // Row height for wrapped text
          sheet.setRowHeight(rowIdx, 36);
        }

        rowIdx++;
      }
    }

    // Remove the default "Sheet1" created by excel package
    if (excel.sheets.containsKey('Sheet1') &&
        excel.sheets.length > 1) {
      excel.delete('Sheet1');
    }

    final bytes = excel.save();
    if (bytes == null) {
      throw Exception('Excel generation failed: save() returned null');
    }
    return Uint8List.fromList(bytes);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String? _dayFromCellId(
      String cellId, List<String> activeDayCodes) {
    for (final d in activeDayCodes) {
      if (cellId.contains('_${d}_')) return d;
    }
    return null;
  }

  /// Returns A, B, C... AA, AB... for column index 0-based.
  static String _colLetter(int colCount) {
    // colCount is the last data column index (0 = time label)
    final idx = colCount; // 0-based column index of last day col
    if (idx < 26) return String.fromCharCode(65 + idx);
    return String.fromCharCode(64 + (idx ~/ 26)) +
        String.fromCharCode(65 + (idx % 26));
  }

  /// Returns black or white hex string for best contrast on [bgHex].
  static String _contrastColor(String bgHex) {
    final r = int.parse(bgHex.substring(0, 2), radix: 16);
    final g = int.parse(bgHex.substring(2, 4), radix: 16);
    final b = int.parse(bgHex.substring(4, 6), radix: 16);
    // Perceived luminance
    final luminance = (0.299 * r + 0.587 * g + 0.114 * b) / 255;
    return luminance > 0.55 ? '1E2030' : 'F1F5F9';
  }
}
