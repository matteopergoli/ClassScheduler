# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

ClassScheduler is a Flutter (Android/iOS) app that auto-generates classroom timetables. Users define
schools, periods (lesson slots/breaks), classrooms, subjects and per-subject constraints (weekly
targets, min/max daily hours, must/must-not-assign, time-slot preferences); a two-phase scheduling
algorithm (greedy construction + simulated annealing) then produces a timetable and reports a quality
score and any hard/soft constraint violations.

Backend is Firebase (Auth + Firestore); subscriptions via RevenueCat (`purchases_flutter`). All
per-user data lives under `/users/{uid}/schools/{schoolId}/...` (see `lib/data/repositories/base_repository.dart`
and `firestore.rules`).

Implementation follows an internal SRS document — code comments reference sections like `§8.2.2`,
requirement IDs like `FR-SUB-IAP-03`, and hard-constraint IDs `HC-1`..`HC-7`. Treat these IDs as stable
identifiers when reading code/tests, even though the SRS itself isn't in this repo.

## Commands

```bash
# Install deps
flutter pub get

# Regenerate Freezed/JSON models after touching lib/data/models/app_models.dart
dart run build_runner build --delete-conflicting-outputs

# Regenerate localizations after editing lib/l10n/*.arb
flutter gen-l10n

# Run all tests
flutter test

# Run a single test file
flutter test test/unit/scheduler/scheduling_engine_test.dart

# Run a single test by name
flutter test test/unit/scheduler/scheduling_engine_test.dart --plain-name "ALG-T01"

# Lint / static analysis
flutter analyze

# SA parameter benchmark (run before tuning lib/core/constants/app_constants.dart)
dart run tool/sa_tuning.dart

# Run on a device/emulator
flutter devices
flutter run -d emulator-5554

# Firebase emulators (local dev, no real project needed)
firebase emulators:start --only auth,firestore
```

Full first-time setup (Firebase project, RevenueCat keys, fonts, platform `android/`/`ios/` dirs which
are not checked in) is in [README.md](README.md) — use `./setup.sh` for a one-shot bootstrap.

## Architecture

Layered structure under `lib/`: `core/` (constants, router, theme) → `data/` (Firestore models,
repositories, services) → `domain/` (scheduling engine, constraints, export, validation) →
`presentation/` (screens per feature) → `providers/` (cross-cutting Riverpod state). State management
is `flutter_riverpod` 2.x (pinned — 3.x removed `StateNotifier`/`StateProvider`, do not upgrade past
`<3.0.0`). Navigation is `go_router` with a 5-tab `StatefulShellRoute` (Schools / Setup / Constraints /
Schedule / Settings) defined in `lib/core/router/app_router.dart`; an auth redirect guards all
non-auth routes via `authStateProvider`.

### Data models & Firestore access

All Firestore entities are Freezed classes in `lib/data/models/app_models.dart` (single file — run
`build_runner` after any change, the generated `*.freezed.dart`/`*.g.dart` are checked in). One
repository per entity in `lib/data/repositories/`, all extending `BaseRepository` for path helpers
(`/users/{uid}/schools/{schoolId}/...`) and typed stream/future accessors. `firestoreProvider` is
overridable so tests can inject `fake_cloud_firestore`.

### Scheduling engine (`lib/domain/scheduler/`)

This is the core of the app and the most subtle part of the codebase.

1. **`SchedulerInputBuilder`** converts Firestore models into a `SchedulerInput` (`scheduler_input.dart`):
   a fully self-contained, serializable problem description where every Firestore string ID is mapped
   to a compact integer index (`teacherOf`, `weeklyTarget[c][s]`, `blockedSlots`, `maxDaily`/`minDaily`,
   `mustAssign`, `mustNotAssignKeys`, `softConstraints`). This is what actually crosses the Isolate
   boundary in `scheduler_isolate.dart` — engine internals work only on flat int arrays/sets for speed.
2. **`SchedulerEngine.run()`** (`scheduler_engine.dart`) orchestrates, wrapped in a top-level try/catch
   so generation can never crash and silently returns an error `ScheduleResult` instead (ALGO-R05):
   - **Phase 1 — `Phase1Greedy`**: greedy construction with backtracking, retried up to 40 times with
     different RNG seeds, keeping the lowest-cost attempt (zero-slack / exact-cover problems, e.g. a
     teacher shared across classrooms with no spare capacity, often need many restarts to find any
     feasible ordering at all).
   - **Phase 2 — `Phase2SA`**: simulated annealing that improves the Phase 1 state. Tuning constants
     (initial temp, cooling rate, iteration/wall-clock caps, restart budget, backtrack window) live in
     `AppConstants` (`lib/core/constants/app_constants.dart`) under "Scheduling algorithm parameters
     (§8.2.2)" — each has an inline rationale comment; read those before changing a value, and re-run
     `tool/sa_tuning.dart` after.
   - **`IntegrityChecker`** (ALGO-R03) does a post-generation sanity pass. Violations are split: HC-1
     (teacher double-booking) and HC-7 (must-not-assign) are treated as real implementation bugs and
     block saving with a "please report this" message; HC-2/3/4/5 (capacity, weekly target, max/min
     daily) can legitimately arise from an over-constrained or partial solution and are surfaced to the
     user as ordinary hard violations instead.
   - **`ResultReporter`** builds the final `ScheduleResult` (quality score 0–100, teacher free hours,
     subject changes, soft penalty, violations).
3. Generation runs in a Dart Isolate (`scheduler_isolate.dart` + `generation_service.dart`) so the UI
   stays responsive; progress/cancel messages cross the isolate boundary as plain data classes
   (`ProgressUpdate`, `CancelMessage`).
4. `drag_drop_validator.dart` re-validates hard constraints when the user manually edits a generated
   schedule in the grid.

Constraint-side logic (conflict detection between user-entered constraints, human-readable constraint
labels) lives in `lib/domain/constraints/`, separate from the engine's internal `SoftConstraintInput`
representation.

### Export

`lib/domain/export/` has one service per format (`pdf_export_service.dart` via the `pdf`/`printing`
packages, `excel_export_service.dart` via `excel`) behind a shared `export_service.dart`, plus a
combined overview export.

### Localization

ARB files in `lib/l10n/` (`app_en.arb`, `app_it.arb` fully translated; `app_es`/`app_fr`/`app_de` are
stubs). Generated Dart lives in `lib/l10n/generated/` (excluded from analysis, regenerate with
`flutter gen-l10n`). Language is auto-selected from device locale, not user-selectable in-app.

### Tests

- `test/unit/scheduler/scheduling_engine_test.dart` — ALG-T01…T15, run the engine synchronously
  (no Isolate) against fixtures in `test/helpers/scheduler_fixtures.dart` via `test/helpers/engine_test_runner.dart`.
- `test/unit/validation/constraint_validator_test.dart` — constraint validation rules.
- `test/integration/acceptance_test.dart` — AC-01…AC-15 acceptance scenarios.
- `test/helpers/fake_firebase.dart` — `fake_cloud_firestore`/mockito wiring for repository tests.

## Notes for future changes

- `BUGs.txt` is the developer's running Italian-language bug/backlog log (closed items marked `x`,
  open items marked `O`). Check it for known-open issues (currently: constraint handling edge cases,
  `MinDaily=2` convergence) before assuming something is unimplemented.
- `tools/reset_min_daily.js` (see `tools/RESET_MIN_DAILY_README.md`) is a one-off Firestore Admin SDK
  migration script for clearing stale `minDailyHours` values — needs a service account, not part of
  the app build.
- Firebase/Riverpod/go_router/IAP dependency versions in `pubspec.yaml` are intentionally pinned below
  known-breaking major versions (see inline comments) — don't casually bump majors.
- Keep this file updated when you make architecturally significant changes (new scheduler phases,
  changed data model shape, new top-level routes/tabs, changed SA tuning defaults, etc.).
