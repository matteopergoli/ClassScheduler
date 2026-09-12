// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'ClassScheduler';

  @override
  String get goodMorning => 'Good morning 👋';

  @override
  String get yourSchools => 'Your Schools';

  @override
  String yourSchoolsCount(int count) {
    return 'Your Schools ($count)';
  }

  @override
  String get addSchool => 'Add a school';

  @override
  String get newSchool => 'New School';

  @override
  String get schoolName => 'School name';

  @override
  String get schoolDescription => 'Description (optional)';

  @override
  String get schoolCreated => 'School created';

  @override
  String get schoolUpdated => 'School updated';

  @override
  String get schoolDeleted => 'School deleted';

  @override
  String get renameSchool => 'Rename';

  @override
  String get duplicateSchool => 'Duplicate';

  @override
  String get deleteSchool => 'Delete';

  @override
  String deleteSchoolConfirm(String name) {
    return 'Delete \"$name\"? This will permanently remove all classrooms, subjects, constraints and schedules.';
  }

  @override
  String classCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '1 class',
    );
    return '$_temp0';
  }

  @override
  String teacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count teachers',
      one: '1 teacher',
    );
    return '$_temp0';
  }

  @override
  String get lastGenerated => 'Last generated';

  @override
  String lastGeneratedDate(String date) {
    return 'Last run: $date';
  }

  @override
  String get neverGenerated => 'Never';

  @override
  String get generate => 'Generate';

  @override
  String get reGenerate => 'Re-generate';

  @override
  String get generating => 'Generating…';

  @override
  String get cancelGeneration => 'Cancel';

  @override
  String get generationComplete => 'Generation complete';

  @override
  String get generationCancelled => 'Generation cancelled — best result shown';

  @override
  String get qualityScore => 'Quality Score';

  @override
  String get qualityExcellent => 'Excellent';

  @override
  String get qualityGood => 'Good';

  @override
  String get qualityFair => 'Fair';

  @override
  String get qualityPoor => 'Poor';

  @override
  String get qualityTooltip =>
      'Higher scores mean fewer teacher gaps and fewer subject changes per day.';

  @override
  String get resultPerfect => 'Schedule generated. All constraints satisfied.';

  @override
  String resultSoftViolations(int count) {
    return 'Schedule generated. $count soft constraint(s) could not be fully satisfied.';
  }

  @override
  String resultHardViolations(int count) {
    return 'Best partial schedule shown. $count hard constraint(s) could not be satisfied — affected cells highlighted in red.';
  }

  @override
  String get teacherFreeHours => 'Teacher free hours';

  @override
  String get subjectChanges => 'Subject changes';

  @override
  String get computationTime => 'Computation time';

  @override
  String get iterationsCompleted => 'Iterations completed';

  @override
  String get navSchools => 'Schools';

  @override
  String get navSetup => 'Setup';

  @override
  String get navConstraints => 'Constraints';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get navSettings => 'Settings';

  @override
  String get setupTitle => 'Setup';

  @override
  String get step1Title => 'School Days & Periods';

  @override
  String get step2Title => 'Classrooms';

  @override
  String get step3Title => 'Daily Capacity';

  @override
  String get step4Title => 'Subjects';

  @override
  String get step1Description =>
      'Select active school days and define lesson and break slots.';

  @override
  String get step2Description => 'Add and name your classrooms (up to 10).';

  @override
  String get step3Description =>
      'Set the maximum number of lessons per classroom per day.';

  @override
  String get step4Description =>
      'Define subjects, assign them to classrooms, and set weekly targets.';

  @override
  String get activeDays => 'Active school days';

  @override
  String get periods => 'Periods';

  @override
  String get addPeriod => 'Add period';

  @override
  String get lessonSlot => 'Lesson slot';

  @override
  String get breakSlot => 'Break';

  @override
  String get step3ApplyToAllDays => 'Apply to all days';

  @override
  String get breakName => 'Break name';

  @override
  String get startTime => 'Start time';

  @override
  String get endTime => 'End time';

  @override
  String get useTemplate => 'Use a template';

  @override
  String get periodSaved => 'Period saved';

  @override
  String get periodDeleted => 'Period deleted';

  @override
  String get classrooms => 'Classrooms';

  @override
  String get addClassroom => 'Add classroom';

  @override
  String get classroomName => 'Classroom name (e.g. 1A, Year 5 Blue)';

  @override
  String get classroomRenamed => 'Classroom renamed';

  @override
  String get classroomDeleted => 'Classroom deleted';

  @override
  String classroomDeleteConstraintWarning(int count) {
    return 'This classroom is referenced in $count constraint(s). They will also be deleted.';
  }

  @override
  String get maxClassroomsReached => 'Maximum of 10 classrooms reached.';

  @override
  String get dailyCapacity => 'Daily capacity';

  @override
  String get maxLessonsPerDay => 'Max lessons per day';

  @override
  String get subjects => 'Subjects';

  @override
  String get addSubject => 'Add subject';

  @override
  String get subjectName => 'Subject name';

  @override
  String get teacherName => 'Teacher name';

  @override
  String get teacherNameOptional => 'Teacher name (optional)';

  @override
  String get colour => 'Colour';

  @override
  String get weeklyTarget => 'Weekly target (slots)';

  @override
  String get minDailyHours => 'Min daily slots (0 = disabled)';

  @override
  String get maxDailyHours => 'Max daily slots';

  @override
  String get assignToClassroom => 'Assign to classroom';

  @override
  String get unassignSubject => 'Unassign';

  @override
  String get subjectSaved => 'Subject saved';

  @override
  String get subjectDeleted => 'Subject deleted';

  @override
  String subjectDeleteConstraintWarning(int count) {
    return 'This subject is used in $count constraint(s). They will also be deleted.';
  }

  @override
  String get validationMinGtMax =>
      'Minimum daily slots cannot be greater than maximum daily slots.';

  @override
  String validationMaxDaysInsufficient(int product, int target) {
    return 'Max daily × active days ($product) is less than weekly target ($target).';
  }

  @override
  String validationWeeklyExceedsSlots(int target, int available) {
    return 'Weekly target ($target) exceeds total available lesson slots ($available).';
  }

  @override
  String get validationWeeklyMustBePositive =>
      'Weekly target must be greater than 0.';

  @override
  String validationMinDailyInfeasible(int target, int minDaily) {
    return 'Weekly target ($target) cannot be achieved with MinDaily $minDaily — no valid day distribution exists.';
  }

  @override
  String get feasibilityTitle => 'Feasibility Check';

  @override
  String get feasibilitySlack => 'Slack';

  @override
  String get feasibilityInsufficient =>
      'Insufficient lessons available — generation is likely to produce a partial schedule.';

  @override
  String get feasibilityOk => 'Enough lessons available for all classrooms.';

  @override
  String get constraints => 'Constraints';

  @override
  String get hardConstraints => 'Hard';

  @override
  String get softConstraints => 'Soft';

  @override
  String get addConstraint => 'Add constraint';

  @override
  String get noConstraints => 'No constraints defined yet.';

  @override
  String get constraintDeleted => 'Constraint deleted';

  @override
  String get undoDelete => 'Undo';

  @override
  String get mustAssign => 'MUST-ASSIGN';

  @override
  String get mustNotAssign => 'MUST-NOT-ASSIGN';

  @override
  String get avoidTimeslot => 'AVOID-TIMESLOT';

  @override
  String get preferBlock => 'PREFER-BLOCK';

  @override
  String mustAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject must be assigned to $classroom on $day at $time.';
  }

  @override
  String mustNotAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject must NOT be assigned to $classroom on $day at $time.';
  }

  @override
  String avoidTimeslotDescription(
      String subject, String day, String start, String end) {
    return '$subject should be avoided on $day between $start and $end.';
  }

  @override
  String preferBlockDescription(String subject) {
    return '$subject should be scheduled in consecutive slots when possible.';
  }

  @override
  String get weightLow => 'Low';

  @override
  String get weightMedium => 'Medium';

  @override
  String get weightHigh => 'High';

  @override
  String get conflictDetected => 'Constraint conflict detected';

  @override
  String get conflictMustAssignMustNot =>
      'MUST-ASSIGN and MUST-NOT-ASSIGN on the same cell.';

  @override
  String get conflictMustAssignBreakSlot =>
      'Cannot MUST-ASSIGN to a break slot.';

  @override
  String get conflictMustAssignTeacher =>
      'Two classrooms forced to the same teacher at the same time.';

  @override
  String get conflictMustAssignMinDaily =>
      'MUST-ASSIGN conflicts with MinDaily: only one slot available but MinDaily > 1.';

  @override
  String conflictSuggestion(String suggestion) {
    return 'Suggested fix: $suggestion';
  }

  @override
  String get schedule => 'Schedule';

  @override
  String get scheduleVersions => 'Schedule Versions';

  @override
  String get newVersion => 'New version';

  @override
  String get versionName => 'Version name';

  @override
  String get versionNameHint => 'e.g. Final Sept 2026';

  @override
  String get manuallyEdited => 'Manually edited';

  @override
  String get allClassrooms => 'All Classrooms';

  @override
  String get singleClassroom => 'Single Classroom';

  @override
  String get perTeacher => 'Per Teacher';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get exportExcel => 'Export Excel';

  @override
  String get export => 'Export';

  @override
  String get share => 'Share';

  @override
  String get exportSuccess => 'File shared successfully.';

  @override
  String get trialBannerRemaining =>
      'Free trial: 1 schedule generation available. Subscribe for unlimited access.';

  @override
  String get trialBannerUsed =>
      'Trial used. Subscribe to generate new schedules.';

  @override
  String get subscribe => 'Subscribe';

  @override
  String get subscribeTitle => 'Unlock ClassScheduler';

  @override
  String get subscribeDescription =>
      'Generate unlimited timetables for all your schools.';

  @override
  String get subscribePrice => '€14.99 / year';

  @override
  String get subscribeButton => 'Subscribe Now';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get purchaseRestored => 'Purchase restored successfully.';

  @override
  String get purchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get alreadySubscribed => 'You already have an active subscription.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Appearance';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get account => 'Account';

  @override
  String get premiumComingSoon => 'Premium';

  @override
  String get premiumComingSoonTitle => 'Coming soon';

  @override
  String get premiumComingSoonMessage =>
      'ClassScheduler is free for now. Were gauging interest in a paid plan — thanks for letting us know youre interested!';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure? This will permanently delete your account and all data. This cannot be undone.';

  @override
  String get deleteAccountSuccess => 'Account deleted.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to ClassScheduler';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInWithApple => 'Continue with Apple';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get createAccount => 'Create account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get forgotPasswordTitle => 'Reset password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we\'ll send a reset link.';

  @override
  String get sendResetLink => 'Send reset link';

  @override
  String get resetLinkSent => 'Reset link sent. Check your email.';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Start scheduling in minutes.';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get passwordMismatch => 'Passwords do not match.';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get next => 'Next';

  @override
  String get back => 'Back';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'No internet connection.';

  @override
  String get errorOfflineGeneration =>
      'Schedule saved locally — will sync when online.';

  @override
  String get errorRequiresReauth => 'Please sign in again to continue.';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get monShort => 'Mon';

  @override
  String get tueShort => 'Tue';

  @override
  String get wedShort => 'Wed';

  @override
  String get thuShort => 'Thu';

  @override
  String get friShort => 'Fri';

  @override
  String get satShort => 'Sat';

  @override
  String get sunShort => 'Sun';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String deleteScheduleConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get generateToSeeSchedule =>
      'Press Generate to create your first timetable.';

  @override
  String hardViolationsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hard constraints could not be satisfied',
      one: '1 hard constraint could not be satisfied',
    );
    return '$_temp0';
  }

  @override
  String get noScheduleYet => 'No schedule yet';

  @override
  String get rename => 'Rename';

  @override
  String get restartsUsed => 'Restarts';

  @override
  String scheduleDeleted(String name) {
    return '\"$name\" deleted.';
  }

  @override
  String get scheduleVersionName => 'Schedule name';

  @override
  String get showLess => 'Show less';

  @override
  String showMore(int count) {
    return 'Show $count more';
  }

  @override
  String softViolationsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count soft constraints could not be fully satisfied',
      one: '1 soft constraint could not be fully satisfied',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Undo';

  @override
  String get viewAllClassrooms => 'All Classrooms';

  @override
  String get viewPerTeacher => 'Per Teacher';

  @override
  String get viewSingleClassroom => 'Single Classroom';

  @override
  String get exportSchedule => 'Export Schedule';

  @override
  String get exportFormat => 'Format';

  @override
  String get exportAsPdf => 'Export as PDF';

  @override
  String get exportAsExcel => 'Export as Excel';

  @override
  String get exportPdfSubtitle => 'A4 pages, one per classroom';

  @override
  String get exportExcelSubtitle => '.xlsx with colour coding';

  @override
  String get exportIncludeOverview => 'Include combined overview page';

  @override
  String get exportLoading => 'Loading data…';

  @override
  String get exportGenerating => 'Generating file…';

  @override
  String get exportSharing => 'Opening share sheet…';

  @override
  String get subscription => 'Subscription';

  @override
  String get subscriptionHeadline => 'Unlock Unlimited Schedules';

  @override
  String get subscriptionSubtitle =>
      'Generate as many timetables as you need, all year long.';

  @override
  String get subscriptionActive => 'Subscription Active';

  @override
  String get subscriptionActiveSubtitle =>
      'Your subscription is active. Enjoy unlimited generation.';

  @override
  String get subscriptionPriceLabel => 'ANNUAL PLAN';

  @override
  String get subscriptionPrice => '€14.99';

  @override
  String get subscriptionPriceSuffix => 'per year · billed annually';

  @override
  String get subscriptionOfflineGrace =>
      'You\'re offline. Your subscription is honoured for up to 30 days without a connection.';

  @override
  String get subscriptionLegalNote =>
      'Payment will be charged to your App Store / Play Store account at confirmation of purchase. Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get subscribeForUnlimited => 'Subscribe for unlimited access';

  @override
  String get noPurchasesToRestore => 'No purchases found to restore.';

  @override
  String get featureUnlimitedGeneration => 'Unlimited schedule generation';

  @override
  String get featurePdfExcel => 'PDF & Excel export';

  @override
  String get featureManualEditing => 'Manual drag-and-drop editing';

  @override
  String get featureCloudSync => 'Cloud sync across all devices';

  @override
  String get featureMultipleSchools => 'Multiple schools per account';

  @override
  String get manage => 'Manage';

  @override
  String get collapse => 'Collapse';

  @override
  String switchedToSet(String name) {
    return 'Switched to \"$name\".';
  }

  @override
  String get apply => 'Apply';

  @override
  String get logOut => 'Log out';

  @override
  String get changeAction => 'Change';

  @override
  String get orSeparator => 'or';

  @override
  String get templatesTitle => 'Templates';

  @override
  String get builtInTemplates => 'Built-in';

  @override
  String get myTemplates => 'My templates';

  @override
  String get saveAsTemplate => 'Save as template';

  @override
  String get savePeriodsAsTemplate => 'Save periods as template';

  @override
  String get templateNameLabel => 'Template name';

  @override
  String get templateNameHint => 'e.g. My School Schedule';

  @override
  String get renameTemplate => 'Rename template';

  @override
  String get deleteTemplate => 'Delete template';

  @override
  String get templateSaved => 'Template saved.';

  @override
  String get tapTimeFieldsHint => 'Tap the time fields to use the time picker.';

  @override
  String get breakNameHint => 'e.g. Morning Break';

  @override
  String get priorityLabel => 'Priority';

  @override
  String get ruleLabel => 'Rule';

  @override
  String get slotLabel => 'Slot';

  @override
  String get dayFieldLabel => 'Day';

  @override
  String get dailyLimitLabel => 'Daily limit';

  @override
  String get constraintTypeLabel => 'Constraint type';

  @override
  String get allDaysOption => 'All days';

  @override
  String get anyDayOption => 'Any day';

  @override
  String get anyClassroomOption => 'Any classroom';

  @override
  String get noMaximumFullDay => 'No maximum (up to a full day)';

  @override
  String get hardDailyLimitTag => 'HARD · DAILY LIMIT';

  @override
  String get constraintSetsTitle => 'Constraint sets';

  @override
  String get saveCurrentEllipsis => 'Save current…';

  @override
  String get saveCurrentConstraints => 'Save current constraints';

  @override
  String get updateWithCurrentConstraints => 'Update with current constraints';

  @override
  String get setNameHint => 'Set name';

  @override
  String get switchAction => 'Switch';

  @override
  String get deleteConstraintSet => 'Delete constraint set';

  @override
  String get noSavedSetsYet => 'No saved sets yet.';

  @override
  String switchToSetConfirm(String name) {
    return 'Switch to \"$name\"?';
  }

  @override
  String deleteSetConfirm(String name) {
    return 'Delete \"$name\"? This can\'t be undone.';
  }

  @override
  String get noSchoolsYet => 'No schools yet.';

  @override
  String get goToSchoolsTab =>
      'Go to the Schools tab to create your first school.';

  @override
  String get addFirstSchoolToStart => 'Add your first school to get started.';

  @override
  String get selectSchoolForConstraints => 'Select a school for constraints';

  @override
  String get selectSchoolForSchedule => 'Select a school for the schedule';

  @override
  String get selectSchoolToSetUp => 'Select a school to set up';

  @override
  String get lastRunLabel => 'Last run';

  @override
  String get editSetup => 'Edit setup';

  @override
  String get statusReady => 'Ready';

  @override
  String get statusFixNeeded => 'Fix needed';

  @override
  String get teacherLabel => 'Teacher';

  @override
  String get classColumnLabel => 'Class';

  @override
  String get timeColumnLabel => 'Time';

  @override
  String get neededColumnLabel => 'Needed';

  @override
  String get availableColumnLabel => 'Available';

  @override
  String notTaughtInClose(String classroom) {
    return 'Not taught in $classroom — close';
  }

  @override
  String scheduleNameExists(String name) {
    return 'A schedule named \"$name\" already exists. Please choose a unique name.';
  }

  @override
  String deleteClassroomConfirm(String name) {
    return 'Delete \"$name\"?';
  }

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get supportSection => 'Support';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get actionCannotBeUndone => 'This action cannot be undone.';

  @override
  String scheduleCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'schedules',
      one: 'schedule',
    );
    return '$_temp0';
  }

  @override
  String get viewPerClassroom => 'Per Classroom';

  @override
  String get lessonLabel => 'Lesson';

  @override
  String get breakLabel => 'Break';

  @override
  String overlapsWith(String name) {
    return 'Overlaps with $name';
  }

  @override
  String get weeklyTargetHelp =>
      'Number of lesson slots per week. Must be at least 1.';

  @override
  String get dayShortMon => 'Mon';

  @override
  String get dayShortTue => 'Tue';

  @override
  String get dayShortWed => 'Wed';

  @override
  String get dayShortThu => 'Thu';

  @override
  String get dayShortFri => 'Fri';

  @override
  String get dayShortSat => 'Sat';

  @override
  String get dayShortSun => 'Sun';

  @override
  String get dayLongMon => 'Monday';

  @override
  String get dayLongTue => 'Tuesday';

  @override
  String get dayLongWed => 'Wednesday';

  @override
  String get dayLongThu => 'Thursday';

  @override
  String get dayLongFri => 'Friday';

  @override
  String get dayLongSat => 'Saturday';

  @override
  String get dayLongSun => 'Sunday';

  @override
  String get exportSummary => 'Summary';

  @override
  String get exportCombinedOverview => 'Combined Overview';

  @override
  String get exportGeneratedLabel => 'Generated';

  @override
  String get exportTimeHeader => 'Time';

  @override
  String get exportStatusHeader => 'Status';

  @override
  String get exportViolationsHeader => 'Violations';

  @override
  String get exportTeacherWeeklyHours => 'Teacher weekly hours';

  @override
  String exportSlotsAssigned(int count) {
    return '$count slots assigned';
  }

  @override
  String exportViolationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count violations',
      one: '1 violation',
    );
    return '$_temp0';
  }

  @override
  String get exportStatusPerfect => 'Perfect';

  @override
  String get exportStatusSoft => 'Soft violations';

  @override
  String get exportStatusHard => 'Hard violations';

  @override
  String get clAnyDay => 'any day';

  @override
  String clInClassroom(String classroom) {
    return ' in $classroom';
  }

  @override
  String clMustAssign(
      Object subject, Object classroom, Object day, Object time) {
    return '$subject must be scheduled in $classroom — $day, $time.';
  }

  @override
  String clMustNotAssign(
      Object subject, Object classroom, Object day, Object time) {
    return '$subject must NOT be scheduled in $classroom — $day, $time.';
  }

  @override
  String clAvoidTimeslotDay(
      Object subject, Object scope, Object day, Object start, Object end) {
    return '$subject$scope should be avoided on $day between $start and $end.';
  }

  @override
  String clAvoidTimeslotNoDay(
      Object subject, Object scope, Object start, Object end) {
    return '$subject$scope should be avoided between $start and $end.';
  }

  @override
  String clPreferBlock(Object subject, Object scope, Object detail) {
    return '$subject$scope should be scheduled in consecutive slots when possible$detail.';
  }

  @override
  String clDailyLimitRange(
      Object subject, Object classroom, Object min, Object max) {
    return '$subject in $classroom should stay within $min–$max hours/day.';
  }

  @override
  String clDailyLimitMax(Object subject, Object classroom, Object max) {
    return '$subject in $classroom should stay under $max hours/day.';
  }

  @override
  String clDailyLimitMin(Object subject, Object classroom, Object min) {
    return '$subject in $classroom should reach at least $min hours on days it is scheduled.';
  }

  @override
  String clDailyLimitGeneric(Object subject, Object classroom) {
    return '$subject in $classroom has a daily-hours preference.';
  }

  @override
  String clSubtitleSoft(String weight) {
    return 'Soft · Priority: $weight';
  }

  @override
  String get clSubtitleHard => 'Hard constraint';

  @override
  String clUnknownType(String type) {
    return 'Unknown constraint type: $type';
  }

  @override
  String get unknownSubject => 'Unknown subject';

  @override
  String get unknownClass => 'Unknown class';

  @override
  String get assignSubjectEditHint =>
      'Set the weekly lesson count for this classroom. To remove the subject from this classroom, tap \"Unassign\" below.';

  @override
  String assignSubjectNewHint(String classroom) {
    return 'Only assign if this subject is actually taught in $classroom. If it is not taught here, just close this sheet — leaving it unassigned is correct.';
  }

  @override
  String get builtInTemplate5NoBreak => '5 × 1h (no breaks)';

  @override
  String get builtInTemplate5MorningBreak => '5 × 1h + morning break';

  @override
  String get builtInTemplate8 => '8 × 1h + morning break + lunch break';

  @override
  String get breakMorning => 'Morning break';

  @override
  String get breakLunch => 'Lunch break';

  @override
  String get noHardConstraintsYet => 'No hard constraints yet.';

  @override
  String get noPreferencesYet => 'No preferences set yet.';

  @override
  String get hardConstraintsEmptyHint =>
      'Hard constraints force or block\nspecific slot assignments.';

  @override
  String get preferencesEmptyHint =>
      'Preferences guide the scheduler\nbut never block a solution.';

  @override
  String get selectSubjectHint => 'Select subject';

  @override
  String get selectClassroomHint => 'Select classroom';

  @override
  String get selectSubjectFirst => 'Select a subject first';

  @override
  String get notAssignedToClassroomYet => 'Not assigned to any classroom yet';

  @override
  String get notAvailable => 'Not available';

  @override
  String get clearAction => 'Clear';

  @override
  String get moveNotAllowed => 'Move not allowed';

  @override
  String get noOptionsAvailable => 'No options available';

  @override
  String get errSelectSubject => 'Please select a subject.';

  @override
  String get errSelectClassroom => 'Please select a classroom.';

  @override
  String get errSelectDay => 'Please select a day.';

  @override
  String get errSelectSlot => 'Please select a slot.';

  @override
  String get errSelectStartSlot => 'Please select a start slot.';

  @override
  String get errSelectEndSlot => 'Please select an end slot.';

  @override
  String get errMinGtMaxDaily =>
      'Minimum daily hours cannot be greater than maximum.';

  @override
  String get slotUnavailableForClassroomDay =>
      'Not available for this classroom on this day.';

  @override
  String get slotTeacherBusy =>
      'Teacher already assigned elsewhere at this time.';

  @override
  String get slotPickerHint =>
      'Tap a slot to select it, tap another to select a range.';

  @override
  String get subjectNotAssignedYet =>
      'This subject isn\'t assigned to any classroom yet.';

  @override
  String get subjectNotAssignedYetLong =>
      'This subject isn\'t assigned to any classroom yet. Assign it first in Setup → Subjects.';

  @override
  String get minDailyHoursHint =>
      'Applies only on days this subject is actually scheduled — a day with no lesson at all is still allowed. 0 disables the minimum.';

  @override
  String get ruleMust => 'Must';

  @override
  String get rulePrefer => 'Prefer';

  @override
  String get ruleMustNot => 'Must not';

  @override
  String get ruleAvoid => 'Avoid';

  @override
  String get ruleMustDescHard =>
      'Force a subject into a specific classroom slot.';

  @override
  String get ruleMustDescSoft =>
      'Encourage consecutive lessons for a subject, optionally limited to a day/time range.';

  @override
  String get ruleMustNotDescHard =>
      'Block a subject from a specific classroom slot.';

  @override
  String get ruleMustNotDescSoft => 'Discourage a subject during a time range.';

  @override
  String get dailyLimitDescHard =>
      'Require a minimum and/or maximum number of daily hours for a subject — blocks generation if unmet.';

  @override
  String get dailyLimitDescSoft =>
      'Prefer a minimum and/or maximum number of daily hours for a subject — a guideline, never blocks generation.';

  @override
  String switchSetWarning(String name, int hard, int soft) {
    return 'This replaces every current constraint and HARD daily limit with what was saved in \"$name\" ($hard hard · $soft soft). Anything not saved elsewhere will be lost.';
  }
}
