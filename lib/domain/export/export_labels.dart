// lib/domain/export/export_labels.dart
//
// Localised strings passed into the context-free PDF/Excel export generators.

import '../../l10n/generated/app_localizations.dart';


class ExportLabels {
  final String localeName;
  final Map<String, String> dayLong; // 'MON' -> 'Lunedì'
  final Map<String, String> dayShort; // 'MON' -> 'Lun'
  final String breakLabel;
  final String summary;
  final String combinedOverview;
  final String generatedLabel;
  final String timeHeader;
  final String statusHeader;
  final String violationsHeader;
  final String teacher;
  final String teacherWeeklyHours;
  final String classrooms;
  final String qualityScore;
  final String teacherFreeHours;
  final String subjectChanges;
  final String Function(int) slotsAssigned;
  final String Function(int) violationsCount;
  final String statusPerfect;
  final String statusSoft;
  final String statusHard;

  const ExportLabels({
    required this.localeName,
    required this.dayLong,
    required this.dayShort,
    required this.breakLabel,
    required this.summary,
    required this.combinedOverview,
    required this.generatedLabel,
    required this.timeHeader,
    required this.statusHeader,
    required this.violationsHeader,
    required this.teacher,
    required this.teacherWeeklyHours,
    required this.classrooms,
    required this.qualityScore,
    required this.teacherFreeHours,
    required this.subjectChanges,
    required this.slotsAssigned,
    required this.violationsCount,
    required this.statusPerfect,
    required this.statusSoft,
    required this.statusHard,
  });

  factory ExportLabels.from(AppLocalizations l10n, String localeName) => ExportLabels(
        localeName: localeName,
        dayLong: {
          'MON': l10n.dayLongMon,
          'TUE': l10n.dayLongTue,
          'WED': l10n.dayLongWed,
          'THU': l10n.dayLongThu,
          'FRI': l10n.dayLongFri,
          'SAT': l10n.dayLongSat,
          'SUN': l10n.dayLongSun,
        },
        dayShort: {
          'MON': l10n.dayShortMon,
          'TUE': l10n.dayShortTue,
          'WED': l10n.dayShortWed,
          'THU': l10n.dayShortThu,
          'FRI': l10n.dayShortFri,
          'SAT': l10n.dayShortSat,
          'SUN': l10n.dayShortSun,
        },
        breakLabel: l10n.breakLabel,
        summary: l10n.exportSummary,
        combinedOverview: l10n.exportCombinedOverview,
        generatedLabel: l10n.exportGeneratedLabel,
        timeHeader: l10n.exportTimeHeader,
        statusHeader: l10n.exportStatusHeader,
        violationsHeader: l10n.exportViolationsHeader,
        teacher: l10n.teacherLabel,
        teacherWeeklyHours: l10n.exportTeacherWeeklyHours,
        classrooms: l10n.classrooms,
        qualityScore: l10n.qualityScore,
        teacherFreeHours: l10n.teacherFreeHours,
        subjectChanges: l10n.subjectChanges,
        slotsAssigned: l10n.exportSlotsAssigned,
        violationsCount: l10n.exportViolationsCount,
        statusPerfect: l10n.exportStatusPerfect,
        statusSoft: l10n.exportStatusSoft,
        statusHard: l10n.exportStatusHard,
      );
}
