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
  static const int    saMaxRestarts   = 3;

  /// Phase 1 backtracking window (number of recent assignments to undo).
  static const int    phase1BacktrackN = 15;

  /// Progress update interval (every N SA iterations → send to UI).
  static const int    saProgressInterval = 5000;

  /// Cancellation flag check interval (every N SA iterations).
  static const int    saCancelCheckInterval = 1000;

  // ── Objective function weights (§8.1.3) ───────────────────────────────────
  static const int    wMissingLesson     = 10000000; // dominates all other terms
  static const int    wTeacherFreeHours  = 1000; // w1
  static const int    wSubjectChanges    = 100;  // w2
  // w3 (soft constraint weight) is 1–10 per constraint weight level

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
