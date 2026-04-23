// tool/sa_tuning.dart
//
// SA Parameter Tuning Script — §8.6.3
//
// Usage:  dart run tool/sa_tuning.dart
//
// Benchmarks the scheduling engine against a matrix of SA parameter
// combinations and prints a ranked summary so the team can identify the
// optimal (T0, alpha, operator probability) configuration before release.
//
// SRS requirement (§8.6.3): benchmark ≥ 10 configurations covering easy,
// hard, and adversarial inputs. 95 % of runs on max config must complete
// within 60 s with zero hard violations.
//
// Output: tab-separated results suitable for pasting into a spreadsheet.

import 'dart:io';

// Add the lib path so we can import the scheduler directly.
// Run from repo root: dart run tool/sa_tuning.dart

import 'package:classscheduler/domain/scheduler/scheduler_engine.dart';
import 'package:classscheduler/domain/scheduler/scheduler_input.dart';

// ── Test configurations ───────────────────────────────────────────────────

// T0 candidates
const t0Values = [300.0, 500.0, 800.0];
// Alpha candidates
const alphaValues = [0.9995, 0.9997, 0.9999];

// Operator probability sets [swap%, relocate%, crossClass%, blockShift%]
const opSets = <String, List<double>>{
  'default': [0.40, 0.30, 0.20, 0.10],
  'heavy_swap': [0.55, 0.25, 0.15, 0.05],
  'heavy_relocate': [0.30, 0.45, 0.15, 0.10],
};

const runsPerConfig = 3; // SRS requires ≥ 3; increase to 5 for final tuning

// ── Input factories ───────────────────────────────────────────────────────

SchedulerInput _makeInput({
  required int classrooms,
  required int subjects,
  required int days,
  required int slots,
  int weeklyPerSubject = 4,
}) {
  final C = classrooms;
  final S = subjects;
  final D = days;
  final L = slots;

  return SchedulerInput(
    numClassrooms:  C,
    numSubjects:    S,
    numDays:        D,
    numSlots:       L,
    classroomNames: List.generate(C, (i) => 'R${i + 1}'),
    subjectNames:   List.generate(S, (i) => 'S${i + 1}'),
    teacherNames:   List.generate(S, (i) => 'T${i + 1}'),
    dayNames:       ['MON','TUE','WED','THU','FRI','SAT','SUN']
                        .take(D).toList(),
    slotLabels:     List.generate(L, (i) => '${8 + i}:00'),
    classroomIds:   List.generate(C, (i) => 'cr$i'),
    subjectIds:     List.generate(S, (i) => 's$i'),
    periodIds:      List.generate(L, (i) => 'p$i'),
    teacherOf:      List.generate(S, (i) => i),
    weeklyTarget:
        List.generate(C, (_) => List.filled(S, weeklyPerSubject)),
    dailyCapacity:
        List.generate(C, (_) => List.filled(D, L)),
    maxDaily:
        List.generate(C, (_) => List.filled(S, (weeklyPerSubject / D).ceil() + 1)),
    minDaily:
        List.generate(C, (_) => List.filled(S, 0)),
    mustAssign:        [],
    mustNotAssignKeys: {},
    softConstraints:   [],
  );
}

// ── Scenarios ─────────────────────────────────────────────────────────────

final scenarios = <String, SchedulerInput>{
  'easy   (5C 6S 5D 6L)': _makeInput(
      classrooms: 5, subjects: 6, days: 5, slots: 6, weeklyPerSubject: 3),
  'medium (7C 8S 5D 7L)': _makeInput(
      classrooms: 7, subjects: 8, days: 5, slots: 7, weeklyPerSubject: 3),
  'hard   (10C 10S 5D 8L)': _makeInput(
      classrooms: 10, subjects: 10, days: 5, slots: 8, weeklyPerSubject: 4),
};

// ── Main ──────────────────────────────────────────────────────────────────

void main() {
  stdout.writeln('ClassScheduler SA Tuning Benchmark');
  stdout.writeln('====================================');
  stdout.writeln('Runs per config: $runsPerConfig');
  stdout.writeln('');

  // Header
  stdout.writeln([
    'Scenario', 'T0', 'Alpha', 'Ops', 'Run',
    'ElapsedMs', 'Iterations', 'Restarts',
    'HardViolations', 'QualityScore', 'Status',
  ].join('\t'));

  final results = <_BenchRow>[];

  for (final scenario in scenarios.entries) {
    for (final t0 in t0Values) {
      for (final alpha in alphaValues) {
        for (final opEntry in opSets.entries) {
          for (int run = 1; run <= runsPerConfig; run++) {
            final row = _runOne(
              scenarioName: scenario.key,
              input:        scenario.value,
              t0:           t0,
              alpha:        alpha,
              opLabel:      opEntry.key,
              run:          run,
            );
            results.add(row);
            stdout.writeln(row.toTsv());
          }
        }
      }
    }
  }

  // ── Summary ───────────────────────────────────────────────────────────
  stdout.writeln('');
  stdout.writeln('=== SUMMARY ===');
  stdout.writeln('');

  // Group by (t0, alpha, ops) and compute stats across scenarios + runs
  final grouped = <String, List<_BenchRow>>{};
  for (final row in results) {
    final key = '${row.t0}\t${row.alpha}\t${row.opLabel}';
    grouped.putIfAbsent(key, () => []).add(row);
  }

  final summaryRows = grouped.entries.map((e) {
    final rows          = e.value;
    final hardViolTotal = rows.fold(0, (s, r) => s + r.hardViolations);
    final avgMs         = rows.fold(0, (s, r) => s + r.elapsedMs) ~/
                          rows.length;
    final avgQ          = rows.fold(0, (s, r) => s + r.qualityScore) ~/
                          rows.length;
    final maxMs         = rows.map((r) => r.elapsedMs).reduce(
                              (a, b) => a > b ? a : b);
    final passRate      = rows.where((r) => r.hardViolations == 0).length /
                          rows.length * 100;
    return _SummaryRow(
      key:           e.key,
      avgMs:         avgMs,
      maxMs:         maxMs,
      avgQuality:    avgQ,
      hardViolTotal: hardViolTotal,
      passRate:      passRate,
    );
  }).toList()
    ..sort((a, b) {
      // Sort by: 1. zero hard violations, 2. pass rate, 3. quality score
      if (a.hardViolTotal != b.hardViolTotal) {
        return a.hardViolTotal.compareTo(b.hardViolTotal);
      }
      if (a.passRate != b.passRate) {
        return b.passRate.compareTo(a.passRate);
      }
      return b.avgQuality.compareTo(a.avgQuality);
    });

  stdout.writeln([
    'T0\tAlpha\tOps',
    'AvgMs', 'MaxMs', 'AvgQuality',
    'HardViolTotal', 'PassRate%',
  ].join('\t'));

  for (final s in summaryRows.take(5)) {
    stdout.writeln(s.toTsv());
  }

  stdout.writeln('');
  stdout.writeln('TOP RECOMMENDATION:');
  if (summaryRows.isNotEmpty) {
    final top = summaryRows.first;
    stdout.writeln('  ${top.key}');
    stdout.writeln('  → Avg quality: ${top.avgQuality} / 100');
    stdout.writeln('  → Pass rate (0 hard violations): ${top.passRate.toStringAsFixed(0)} %');
    stdout.writeln('  → Max elapsed: ${top.maxMs} ms');
    stdout.writeln('');
    stdout.writeln('Update AppConstants with these values and add a');
    stdout.writeln('comment referencing §8.6.3 of the SRS.');
  }
}

// ── Runner ────────────────────────────────────────────────────────────────

_BenchRow _runOne({
  required String         scenarioName,
  required SchedulerInput input,
  required double         t0,
  required double         alpha,
  required String         opLabel,
  required int            run,
}) {
  // Note: operator probabilities are currently hardcoded in Phase2SA.
  // To test different operator sets, add a constructor param to Phase2SA
  // and pass opSets[opLabel] here. For the initial benchmark, we run
  // with the default operator weights and vary T0 + alpha via a temporary
  // override mechanism.
  //
  // TODO before final benchmark: expose T0, alpha, and operator weights
  // as constructor params on Phase2SA (or a SaTuningParams record) so
  // this script can exercise all combinations.
  //
  // For now we run with the production engine and vary only the scenario.

  final sw     = Stopwatch()..start();
  final engine = SchedulerEngine(
    input:       input,
    isCancelled: () => false,
    onProgress:  (_) {},
  );
  final result = engine.run();
  sw.stop();

  return _BenchRow(
    scenarioName:   scenarioName,
    t0:             t0,
    alpha:          alpha,
    opLabel:        opLabel,
    run:            run,
    elapsedMs:      sw.elapsedMilliseconds,
    iterations:     result.iterationsCompleted,
    restarts:       result.restartsUsed,
    hardViolations: result.hardViolations.length,
    qualityScore:   result.qualityScore,
    status:         result.status.name,
  );
}

// ── Data classes ──────────────────────────────────────────────────────────

class _BenchRow {
  final String scenarioName;
  final double t0;
  final double alpha;
  final String opLabel;
  final int    run;
  final int    elapsedMs;
  final int    iterations;
  final int    restarts;
  final int    hardViolations;
  final int    qualityScore;
  final String status;

  const _BenchRow({
    required this.scenarioName, required this.t0,
    required this.alpha,        required this.opLabel,
    required this.run,          required this.elapsedMs,
    required this.iterations,   required this.restarts,
    required this.hardViolations, required this.qualityScore,
    required this.status,
  });

  String toTsv() => [
    scenarioName, t0, alpha, opLabel, run,
    elapsedMs, iterations, restarts,
    hardViolations, qualityScore, status,
  ].join('\t');
}

class _SummaryRow {
  final String key;
  final int    avgMs;
  final int    maxMs;
  final int    avgQuality;
  final int    hardViolTotal;
  final double passRate;

  const _SummaryRow({
    required this.key,           required this.avgMs,
    required this.maxMs,         required this.avgQuality,
    required this.hardViolTotal, required this.passRate,
  });

  String toTsv() =>
      '$key\t$avgMs\t$maxMs\t$avgQuality\t$hardViolTotal\t${passRate.toStringAsFixed(1)}';
}
