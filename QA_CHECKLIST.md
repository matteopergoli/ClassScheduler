# ClassScheduler — Pre-Submission QA Checklist
<!-- QA_CHECKLIST.md -->
<!-- M7 — Version 1.0 · Covers SRS v2.1 §9 acceptance criteria -->

Complete every item before submitting to App Store and Google Play.
Sign off each item with your initials and date in the `[Sign-off]` column.

---

## 1 — Automated Test Suite

Run the full test suite and verify zero failures before any manual step.

```bash
# Unit + integration tests
flutter test --coverage

# Coverage gate (§5.5: ≥ 80 % branch coverage on scheduler)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html   # verify lib/domain/scheduler/ ≥ 80 %

# SA tuning benchmark (§8.6.3 — run once before release)
dart run tool/sa_tuning.dart > sa_tuning_results.tsv
# Review results; update AppConstants with optimal T0/alpha if needed
```

| Test Group | File | Expected | [Sign-off] |
|---|---|---|---|
| ALG-T01–15 | `test/unit/scheduler/scheduling_engine_test.dart` | All pass | |
| Constraint validator | `test/unit/validation/constraint_validator_test.dart` | All pass | |
| AC-01–15 | `test/integration/acceptance_test.dart` | All pass | |
| Branch coverage (scheduler domain) | `coverage/` | ≥ 80 % | |

---

## 2 — Acceptance Criteria (§9)

### AC-01 — Cloud sync
- [ ] Register with email on Device A; create a school with 3 classrooms, 2 subjects.
- [ ] Log out, reinstall the app on Device A, log back in.
- [ ] **Pass condition**: all schools, schedules, and constraints are restored.
- [ ] Repeat with a second device (Device B).
- [Sign-off]: ______

### AC-02 — Break slot rendering
- [ ] Create a school with 2 break slots ("Morning Break 10:00–10:15", "Lunch 13:00–14:00").
- [ ] Generate a schedule.
- [ ] **Pass condition**: break rows appear shaded grey in the grid and are non-interactive (tap does nothing, drag ignores them).
- [Sign-off]: ______

### AC-03 — MinDaily enforcement
- [ ] Set MinDaily = 2 for at least one subject.
- [ ] Generate a schedule.
- [ ] **Pass condition**: every day that subject appears has ≥ 2 lessons. ALGO-R03 passes (no red banner showing HC-5).
- [Sign-off]: ______

### AC-04 — MUST-ASSIGN honoured
- [ ] Add a MUST-ASSIGN hard constraint (e.g. "Class 1A must have Maths on Monday 08:00").
- [ ] Generate a schedule.
- [ ] **Pass condition**: the forced cell contains the specified subject. No HC violations.
- [Sign-off]: ______

### AC-05 — Contradictory constraints
- [ ] Add MUST-ASSIGN and MUST-NOT-ASSIGN for the same classroom, subject, day, and slot.
- [ ] Attempt generation.
- [ ] **Pass condition**: conflict reported in plain language before or during generation. App does not crash. No existing schedule is overwritten.
- [Sign-off]: ______

### AC-06 — Maximum configuration performance
- [ ] Create a school with 10 classrooms, 10 subjects, 5 days, 8 slots per day. Add at least 2 MUST-ASSIGN constraints.
- [ ] Generate.
- [ ] **Pass condition**: generation completes in ≤ 60 seconds on a 3-year-old mid-range device. ALGO-R03 passes. QualityScore displayed.
- [Sign-off]: ______

### AC-07 — PDF export
- [ ] Generate a schedule with at least one break slot and one hard violation.
- [ ] Export to PDF.
- [ ] **Pass condition**: valid A4 PDF produced. Break rows are shaded. Violation cells are marked in red. School name, version name, and generation date appear. File opens correctly in a PDF viewer.
- [Sign-off]: ______

### AC-08 — Excel export
- [ ] Export the same schedule to Excel (.xlsx).
- [ ] **Pass condition**: valid XLSX file. One worksheet per classroom + Summary sheet. Subject cells are colour-coded. Teacher names populated in each cell. Break rows shaded. File opens in Excel / Numbers.
- [Sign-off]: ______

### AC-09 — Trial mode
- [ ] Fresh install (no prior account).
- [ ] Verify "Free trial: 1 schedule generation available" banner appears on the Schedule tab **before** pressing Generate.
- [ ] Generate one schedule. Verify banner changes to "Trial used. Subscribe to generate new schedules."
- [ ] Attempt a second generation — **Pass condition**: Generate button disabled until subscription confirmed. Paywall shown.
- [ ] Reinstall the app, log back in. **Pass condition**: trial flag still consumed (not reset by reinstall).
- [Sign-off]: ______

### AC-10 — Restore purchases
- [ ] Subscribe on Device A.
- [ ] Reinstall the app (or use Device B).
- [ ] Tap "Restore Purchases" in Settings.
- [ ] **Pass condition**: subscription restored. Generate button re-enabled.
- [ ] Test in both App Store sandbox (iOS) and Play Store sandbox (Android).
- [Sign-off]: ______

### AC-11 — Italian localisation
- [ ] Switch device language to Italian (Settings → General → Language).
- [ ] Open the app.
- [ ] Navigate through all 5 tabs and all major screens.
- [ ] **Pass condition**: all visible strings display in Italian. No English fallback keys visible. No layout overflow caused by longer Italian strings.
- [Sign-off]: ______

### AC-12 — Drag-and-drop constraint enforcement
- [ ] Open a generated schedule.
- [ ] Drag a lesson cell to a slot that would cause a teacher conflict.
- [ ] **Pass condition**: move is blocked. A message appears naming the specific violated constraint (e.g. "Alice already has a lesson in Room B at this time slot"). The schedule is unchanged.
- [ ] Also test dragging to a slot that exceeds MaxDaily — verify that is also blocked with a clear message.
- [Sign-off]: ______

### AC-13 — GDPR account deletion
- [ ] Go to Settings → Account → Delete Account.
- [ ] Follow the confirmation flow.
- [ ] **Pass condition**: app returns to the registration screen. All Firestore data under `/users/{uid}/` is removed (verify in Firebase console within 30 days). User cannot log back in with the deleted credentials.
- [Sign-off]: ______

### AC-14 — Input validation
- [ ] Create a subject assignment; enter MinDaily = 3, MaxDaily = 2.
- [ ] Attempt to save.
- [ ] **Pass condition**: inline validation error shown in plain language. Save is blocked.
- [ ] Also test: weeklyTarget > total available slots — verify blocked with a clear message.
- [Sign-off]: ______

### AC-15 — Offline generation
- [ ] Enable airplane mode.
- [ ] Generate a schedule.
- [ ] **Pass condition**: generation completes normally. A non-blocking notification appears: "Schedule saved locally — will sync when online." After disabling airplane mode, the schedule syncs to Firestore automatically.
- [Sign-off]: ______

---

## 3 — Platform-Specific Checks

### iOS
| Item | Pass condition | [Sign-off] |
|---|---|---|
| Apple Sign-In present | Sign in with Apple button visible whenever Google Sign-In is offered | |
| StoreKit 2 IAP | Annual subscription available in App Store sandbox; purchase completes | |
| iPad layout | Grid scrolls correctly on 7"+ iPads; no truncated columns | |
| iOS 14 minimum | App launches on iOS 14 simulator without crash | |
| Dark/Light mode | UI renders correctly in both modes on iOS | |
| Dynamic Type | Increasing system font size does not break grid layout | |

### Android
| Item | Pass condition | [Sign-off] |
|---|---|---|
| Google Play Billing | Annual subscription purchasable in Play Store sandbox | |
| Android 8.0 (API 26) | App launches on API 26 emulator without crash | |
| Back gesture | System back navigates correctly; does not exit app from nested screens unexpectedly | |
| Dark/Light mode | UI renders correctly in both modes on Android | |
| Foldable device | Grid renders acceptably on foldable emulator (no critical overflow) | |

---

## 4 — Performance Profile

Run with `flutter run --profile` on a 3-year-old mid-range test device.

| Metric | Target (SRS §5.1) | Measured | [Sign-off] |
|---|---|---|---|
| Cold start | < 3 seconds | | |
| Typical generation (5C, 6S) | < 10 seconds | | |
| Max generation (10C, 10S) | < 60 seconds | | |
| UI frame rate during grid scroll | 60 fps | | |
| PDF export (10 classrooms) | < 5 seconds | | |
| Excel export (10 classrooms) | < 5 seconds | | |
| Scheduler memory (max config) | < 50 MB heap | | |

---

## 5 — Accessibility

| Item | Pass condition | [Sign-off] |
|---|---|---|
| VoiceOver / TalkBack | Every interactive element has a semantic label | |
| Colour not sole indicator | Subject names always visible in grid cells (not colour-only) | |
| Touch targets | All tappable elements ≥ 48 × 48 dp | |
| Dynamic font size | UI remains usable at 2× system font scale | |
| Contrast ratio | Primary text on background meets WCAG AA (≥ 4.5:1) | |

---

## 6 — Security & GDPR

| Item | Pass condition | [Sign-off] |
|---|---|---|
| Firestore Security Rules | Rules deployed; user A cannot read user B's data (test in Firebase emulator) | |
| HTTPS enforced | All Firebase communication uses TLS (default) | |
| Privacy policy linked | Privacy policy URL accessible from Settings and app store listing | |
| Account deletion | All Firestore data removed within 30 days (GDPR Article 17) | |
| Teacher names not shared | No teacher name sent to any third-party analytics (check network traffic) | |
| No hardcoded secrets | `grep -r "API_KEY\|apiKey" lib/` returns only placeholder constants | |

---

## 7 — App Store / Play Store Submission

### Pre-submission
- [ ] `flutter build appbundle --release` succeeds with no errors or warnings.
- [ ] `flutter build ipa --release` succeeds on macOS.
- [ ] Version number and build number incremented in `pubspec.yaml`.
- [ ] All TODO / placeholder comments resolved in production code (`grep -r "TODO\|FIXME\|placeholder" lib/`).
- [ ] RevenueCat API keys replaced with production keys in `AppConstants`.
- [ ] Firebase `google-services.json` and `GoogleService-Info.plist` are production files (not debug).
- [ ] Firestore Security Rules and Indexes deployed to production project.
- [ ] SA tuning benchmark run; `AppConstants` SA parameters confirmed and commented with §8.6.3 reference.

### App Store (iOS)
- [ ] App Store Connect record created with correct bundle ID.
- [ ] Privacy nutrition labels completed (data types: Name, Email Address; linked to identity).
- [ ] In-app purchase product `classscheduler_annual_1490` created and approved.
- [ ] Apple Sign-In capability enabled in Xcode project.
- [ ] App review notes prepared: "This app requires an account because schedules sync across devices. Test credentials: [provide]."
- [ ] Expected review time: **1–5 business days** (as noted in SRS §10 M7).

### Google Play (Android)
- [ ] Play Console app created with correct application ID.
- [ ] Data safety form completed.
- [ ] In-app subscription product `classscheduler_annual_1490` created and activated.
- [ ] Expected review time: **1–3 business days** (as noted in SRS §10 M7).

---

## 8 — Known Limitations (v1.0)

Document these in release notes and app store description:

| Limitation | SRS Reference |
|---|---|
| One teacher per subject | §1.5 — deferred to v2.0 |
| Exact weekly targets only (no tolerance) | §1.4, OQ-06 |
| No week-by-week schedule variation | §1.4 |
| No multi-user collaborative editing | §1.4 |
| Max 10 classrooms per school | §1.4 |

---

## 9 — Sign-off Summary

| Milestone | Owner | Signed off | Date |
|---|---|---|---|
| M1 Scaffold & Auth | | | |
| M2 Setup Flows | | | |
| M3 Constraint Engine | | | |
| M4 Scheduling Algorithm | | | |
| M5 Schedule Viewer & Editor | | | |
| M6 Export & Monetisation | | | |
| M7 QA, Hardening & Release | | | |
| **App Store submission** | | | |
| **Google Play submission** | | | |

---

*ClassScheduler SRS v2.1 — QA Checklist v1.0*
