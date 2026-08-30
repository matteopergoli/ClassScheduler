// lib/core/constants/app_constants.dart
// All non-UI constants.
// SA algorithm parameters are defined here with a comment referencing §8.2.2.

abstract class AppConstants {
  // ── App identity ──────────────────────────────────────────────────────────
  static const String appName       = 'ClassScheduler';
  static const String packageName   = 'com.classscheduler.app';
  static const String appVersion    = '1.0.0';

  // ── Firebase paths ────────────────────────────────────────────────────────
  static const String fsUsers       = 'users';
  static const String fsAccount     = 'account';
  static const String fsSchools     = 'schools';
  static const String fsPeriods     = 'periods';
  static const String fsClassrooms  = 'classrooms';
  static const String fsDayCapacities = 'dayCapacities';
  static const String fsSubjects    = 'subjects';
  static const String fsClassroomSubjects = 'classroomSubjects';
  static const String fsConstraints = 'constraints';
  static const String fsConstraintSets = 'constraintSets';
  static const String fsSchedules   = 'schedules';
  static const String fsScheduleCells = 'scheduleCells';

  // ── RevenueCat ────────────────────────────────────────────────────────────
  // TODO: replace with real keys from RevenueCat dashboard
  static const String rcApiKeyAndroid = 'REVENUECAT_API_KEY_ANDROID';
  static const String rcApiKeyIos     = 'REVENUECAT_API_KEY_IOS';
  static const String rcEntitlementId = 'classscheduler_annual';
  static const String rcProductId     = 'classscheduler_annual_1490';

  // ── Business rules ────────────────────────────────────────────────────────
  static const int maxClassroomsPerSchool = 10;
  static const int maxSubjectsPerSchool   = 20;  // practical UI limit
  static const int maxPeriodsPerDay       = 12;
  static const int subscriptionOfflineDays = 30; // §4.2 FR-SUB-IAP-03

  // ── Scheduling algorithm parameters (§8.2.2) ─────────────────────────────
  // These are the starting/default values per the SRS.
  // After benchmarking (§8.6.3), final values must be documented here
  // with a comment: "Tuned YYYY-MM-DD: <rationale>"

  /// Initial SA temperature. Accepts ~80% of worsening moves at start.
  static const double saInitialTemp   = 500.0;

  /// Geometric cooling rate. T ← T × alpha per iteration.
  static const double saCoolingRate   = 0.9997;

  /// SA stops when temperature drops below this value.
  static const double saMinTemp       = 0.1;

  /// Hard cap on SA iterations to guarantee termination.
  static const int    saMaxIterations = 500000;

  /// Wall-clock time budget for Phase 2 SA (seconds).
  /// 5 s reserved for Phase 1, ALGO-R03, and reporting.
  static const int    saMaxWallSecs   = 55;

  /// No-improvement window before a restart is triggered.
  static const int    saNoImprovementLimit = 50000;

  /// Maximum SA restarts per run (full reheat to T0 each time).
  /// Raised from 3: at T0=500 / alpha=0.9997 / Tmin=0.1, a single cooling
  /// cycle completes in only ~28,000 iterations — far short of
  /// saMaxIterations or saMaxWallSecs. With only 3 restarts allowed, SA was
  /// exhausting its restart budget after ~4 short cycles (a few seconds)
  /// and returning early, well before the real time/iteration budget was
  /// used. Raised so the outer cooling-cycle loop (phase2_sa.dart) can keep
  /// reheating and re-annealing until it genuinely exhausts wall-clock time
  /// or the iteration cap — giving tight / zero-slack problems many more
  /// real attempts to find rare move combinations (e.g. BLOCK SHIFT + FILL)
  /// needed to escape a MinDaily deadlock.
  static const int    saMaxRestarts   = 200;

  /// Phase 1 backtracking window (number of recent assignments to undo).
  /// Increased from 15: zero-slack / exact-cover problems (shared teachers
  /// across classrooms with no free capacity) need much deeper undo windows
  /// to escape deadlocks that a shallow backtrack can't resolve.
  static const int    phase1BacktrackN = 60;

  /// Progress update interval (every N SA iterations → send to UI).
  static const int    saProgressInterval = 5000;

  /// Cancellation flag check interval (every N SA iterations).
  static const int    saCancelCheckInterval = 1000;

  // ── Objective function weights (§8.1.3) ───────────────────────────────────
  static const int    wMissingLesson     = 10000000; // dominates all other terms
  static const int    wTeacherFreeHours  = 1000; // w1
  static const int    wSubjectChanges    = 100;  // w2
  // w3 (soft constraint weight) is 1–10 per constraint weight level

  /// Per-excess-hour multiplier for soft DAILY_LIMIT violations.
  /// The soft daily-limit penalty is
  ///   excessHours × constraintWeight × wDailyLimitUnit
  /// where excessHours is how far a day sits above softMax (or below softMin,
  /// counting only days where the subject is present).
  ///
  /// Rationale: the old penalty was a flat 1-per-violated-day × weight, so a
  /// whole lopsidedly-packed week scored ≤ 10 total — trivially outweighed by
  /// F2 (wSubjectChanges = 100), whose block-compaction reward is *minimised*
  /// by piling a subject's entire weekly quota onto one day. It was also
  /// gradient-free (8h and 3h over a max of 2 both scored 1), so SA could not
  /// improve a day incrementally. Scaling per excess hour restores the
  /// gradient; 50 makes one medium-weight (5) constraint exceeded by a single
  /// hour (5 × 50 = 250) cost more than one avoided subject change (100),
  /// while staying far below wMissingLesson so it never blocks a required
  /// lesson.
  static const int    wDailyLimitUnit    = 50;

  // ── Soft constraint penalty values ────────────────────────────────────────
  static const int    softWeightLow    = 1;
  static const int    softWeightMedium = 5;
  static const int    softWeightHigh   = 10;

  // ── Generation timeout (total, §8.2) ─────────────────────────────────────
  static const int    generationTimeoutSecs = 60;

  // ── GDPR ─────────────────────────────────────────────────────────────────
  static const String privacyPolicyUrl = 'https://classscheduler.app/privacy';
  static const String termsUrl         = 'https://classscheduler.app/terms';

  static const List<String> defaultActiveDays = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
}
