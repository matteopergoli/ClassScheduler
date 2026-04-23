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
  String get themeSystem => 'System default';

  @override
  String get account => 'Account';

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
}
