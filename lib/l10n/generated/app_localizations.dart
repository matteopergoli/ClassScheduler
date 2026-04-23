import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it')
  ];

  /// App display name
  ///
  /// In en, this message translates to:
  /// **'ClassScheduler'**
  String get appName;

  /// Home screen greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning 👋'**
  String get goodMorning;

  /// Section header on schools screen
  ///
  /// In en, this message translates to:
  /// **'Your Schools'**
  String get yourSchools;

  /// Section header with count
  ///
  /// In en, this message translates to:
  /// **'Your Schools ({count})'**
  String yourSchoolsCount(int count);

  /// FAB label / dashed add card
  ///
  /// In en, this message translates to:
  /// **'Add a school'**
  String get addSchool;

  /// Screen title
  ///
  /// In en, this message translates to:
  /// **'New School'**
  String get newSchool;

  /// No description provided for @schoolName.
  ///
  /// In en, this message translates to:
  /// **'School name'**
  String get schoolName;

  /// No description provided for @schoolDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get schoolDescription;

  /// No description provided for @schoolCreated.
  ///
  /// In en, this message translates to:
  /// **'School created'**
  String get schoolCreated;

  /// No description provided for @schoolUpdated.
  ///
  /// In en, this message translates to:
  /// **'School updated'**
  String get schoolUpdated;

  /// No description provided for @schoolDeleted.
  ///
  /// In en, this message translates to:
  /// **'School deleted'**
  String get schoolDeleted;

  /// No description provided for @renameSchool.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get renameSchool;

  /// No description provided for @duplicateSchool.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicateSchool;

  /// No description provided for @deleteSchool.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteSchool;

  /// No description provided for @deleteSchoolConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This will permanently remove all classrooms, subjects, constraints and schedules.'**
  String deleteSchoolConfirm(String name);

  /// No description provided for @classCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 class} other{{count} classes}}'**
  String classCount(int count);

  /// No description provided for @teacherCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 teacher} other{{count} teachers}}'**
  String teacherCount(int count);

  /// No description provided for @lastGenerated.
  ///
  /// In en, this message translates to:
  /// **'Last generated'**
  String get lastGenerated;

  /// No description provided for @lastGeneratedDate.
  ///
  /// In en, this message translates to:
  /// **'Last run: {date}'**
  String lastGeneratedDate(String date);

  /// No description provided for @neverGenerated.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get neverGenerated;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @reGenerate.
  ///
  /// In en, this message translates to:
  /// **'Re-generate'**
  String get reGenerate;

  /// No description provided for @generating.
  ///
  /// In en, this message translates to:
  /// **'Generating…'**
  String get generating;

  /// No description provided for @cancelGeneration.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelGeneration;

  /// No description provided for @generationComplete.
  ///
  /// In en, this message translates to:
  /// **'Generation complete'**
  String get generationComplete;

  /// No description provided for @generationCancelled.
  ///
  /// In en, this message translates to:
  /// **'Generation cancelled — best result shown'**
  String get generationCancelled;

  /// No description provided for @qualityScore.
  ///
  /// In en, this message translates to:
  /// **'Quality Score'**
  String get qualityScore;

  /// No description provided for @qualityExcellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get qualityExcellent;

  /// No description provided for @qualityGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get qualityGood;

  /// No description provided for @qualityFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get qualityFair;

  /// No description provided for @qualityPoor.
  ///
  /// In en, this message translates to:
  /// **'Poor'**
  String get qualityPoor;

  /// No description provided for @qualityTooltip.
  ///
  /// In en, this message translates to:
  /// **'Higher scores mean fewer teacher gaps and fewer subject changes per day.'**
  String get qualityTooltip;

  /// No description provided for @resultPerfect.
  ///
  /// In en, this message translates to:
  /// **'Schedule generated. All constraints satisfied.'**
  String get resultPerfect;

  /// No description provided for @resultSoftViolations.
  ///
  /// In en, this message translates to:
  /// **'Schedule generated. {count} soft constraint(s) could not be fully satisfied.'**
  String resultSoftViolations(int count);

  /// No description provided for @resultHardViolations.
  ///
  /// In en, this message translates to:
  /// **'Best partial schedule shown. {count} hard constraint(s) could not be satisfied — affected cells highlighted in red.'**
  String resultHardViolations(int count);

  /// No description provided for @teacherFreeHours.
  ///
  /// In en, this message translates to:
  /// **'Teacher free hours'**
  String get teacherFreeHours;

  /// No description provided for @subjectChanges.
  ///
  /// In en, this message translates to:
  /// **'Subject changes'**
  String get subjectChanges;

  /// No description provided for @computationTime.
  ///
  /// In en, this message translates to:
  /// **'Computation time'**
  String get computationTime;

  /// No description provided for @iterationsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Iterations completed'**
  String get iterationsCompleted;

  /// No description provided for @navSchools.
  ///
  /// In en, this message translates to:
  /// **'Schools'**
  String get navSchools;

  /// No description provided for @navSetup.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get navSetup;

  /// No description provided for @navConstraints.
  ///
  /// In en, this message translates to:
  /// **'Constraints'**
  String get navConstraints;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup'**
  String get setupTitle;

  /// No description provided for @step1Title.
  ///
  /// In en, this message translates to:
  /// **'School Days & Periods'**
  String get step1Title;

  /// No description provided for @step2Title.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get step2Title;

  /// No description provided for @step3Title.
  ///
  /// In en, this message translates to:
  /// **'Daily Capacity'**
  String get step3Title;

  /// No description provided for @step4Title.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get step4Title;

  /// No description provided for @step1Description.
  ///
  /// In en, this message translates to:
  /// **'Select active school days and define lesson and break slots.'**
  String get step1Description;

  /// No description provided for @step2Description.
  ///
  /// In en, this message translates to:
  /// **'Add and name your classrooms (up to 10).'**
  String get step2Description;

  /// No description provided for @step3Description.
  ///
  /// In en, this message translates to:
  /// **'Set the maximum number of lessons per classroom per day.'**
  String get step3Description;

  /// No description provided for @step4Description.
  ///
  /// In en, this message translates to:
  /// **'Define subjects, assign them to classrooms, and set weekly targets.'**
  String get step4Description;

  /// No description provided for @activeDays.
  ///
  /// In en, this message translates to:
  /// **'Active school days'**
  String get activeDays;

  /// No description provided for @periods.
  ///
  /// In en, this message translates to:
  /// **'Periods'**
  String get periods;

  /// No description provided for @addPeriod.
  ///
  /// In en, this message translates to:
  /// **'Add period'**
  String get addPeriod;

  /// No description provided for @lessonSlot.
  ///
  /// In en, this message translates to:
  /// **'Lesson slot'**
  String get lessonSlot;

  /// No description provided for @breakSlot.
  ///
  /// In en, this message translates to:
  /// **'Break'**
  String get breakSlot;

  /// No description provided for @step3ApplyToAllDays.
  ///
  /// In en, this message translates to:
  /// **'Apply to all days'**
  String get step3ApplyToAllDays;

  /// No description provided for @breakName.
  ///
  /// In en, this message translates to:
  /// **'Break name'**
  String get breakName;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End time'**
  String get endTime;

  /// No description provided for @useTemplate.
  ///
  /// In en, this message translates to:
  /// **'Use a template'**
  String get useTemplate;

  /// No description provided for @periodSaved.
  ///
  /// In en, this message translates to:
  /// **'Period saved'**
  String get periodSaved;

  /// No description provided for @periodDeleted.
  ///
  /// In en, this message translates to:
  /// **'Period deleted'**
  String get periodDeleted;

  /// No description provided for @classrooms.
  ///
  /// In en, this message translates to:
  /// **'Classrooms'**
  String get classrooms;

  /// No description provided for @addClassroom.
  ///
  /// In en, this message translates to:
  /// **'Add classroom'**
  String get addClassroom;

  /// No description provided for @classroomName.
  ///
  /// In en, this message translates to:
  /// **'Classroom name (e.g. 1A, Year 5 Blue)'**
  String get classroomName;

  /// No description provided for @classroomRenamed.
  ///
  /// In en, this message translates to:
  /// **'Classroom renamed'**
  String get classroomRenamed;

  /// No description provided for @classroomDeleted.
  ///
  /// In en, this message translates to:
  /// **'Classroom deleted'**
  String get classroomDeleted;

  /// No description provided for @classroomDeleteConstraintWarning.
  ///
  /// In en, this message translates to:
  /// **'This classroom is referenced in {count} constraint(s). They will also be deleted.'**
  String classroomDeleteConstraintWarning(int count);

  /// No description provided for @maxClassroomsReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum of 10 classrooms reached.'**
  String get maxClassroomsReached;

  /// No description provided for @dailyCapacity.
  ///
  /// In en, this message translates to:
  /// **'Daily capacity'**
  String get dailyCapacity;

  /// No description provided for @maxLessonsPerDay.
  ///
  /// In en, this message translates to:
  /// **'Max lessons per day'**
  String get maxLessonsPerDay;

  /// No description provided for @subjects.
  ///
  /// In en, this message translates to:
  /// **'Subjects'**
  String get subjects;

  /// No description provided for @addSubject.
  ///
  /// In en, this message translates to:
  /// **'Add subject'**
  String get addSubject;

  /// No description provided for @subjectName.
  ///
  /// In en, this message translates to:
  /// **'Subject name'**
  String get subjectName;

  /// No description provided for @teacherName.
  ///
  /// In en, this message translates to:
  /// **'Teacher name'**
  String get teacherName;

  /// No description provided for @colour.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get colour;

  /// No description provided for @weeklyTarget.
  ///
  /// In en, this message translates to:
  /// **'Weekly target (slots)'**
  String get weeklyTarget;

  /// No description provided for @minDailyHours.
  ///
  /// In en, this message translates to:
  /// **'Min daily slots (0 = disabled)'**
  String get minDailyHours;

  /// No description provided for @maxDailyHours.
  ///
  /// In en, this message translates to:
  /// **'Max daily slots'**
  String get maxDailyHours;

  /// No description provided for @assignToClassroom.
  ///
  /// In en, this message translates to:
  /// **'Assign to classroom'**
  String get assignToClassroom;

  /// No description provided for @unassignSubject.
  ///
  /// In en, this message translates to:
  /// **'Unassign'**
  String get unassignSubject;

  /// No description provided for @subjectSaved.
  ///
  /// In en, this message translates to:
  /// **'Subject saved'**
  String get subjectSaved;

  /// No description provided for @subjectDeleted.
  ///
  /// In en, this message translates to:
  /// **'Subject deleted'**
  String get subjectDeleted;

  /// No description provided for @subjectDeleteConstraintWarning.
  ///
  /// In en, this message translates to:
  /// **'This subject is used in {count} constraint(s). They will also be deleted.'**
  String subjectDeleteConstraintWarning(int count);

  /// No description provided for @validationMinGtMax.
  ///
  /// In en, this message translates to:
  /// **'Minimum daily slots cannot be greater than maximum daily slots.'**
  String get validationMinGtMax;

  /// No description provided for @validationMaxDaysInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Max daily × active days ({product}) is less than weekly target ({target}).'**
  String validationMaxDaysInsufficient(int product, int target);

  /// No description provided for @validationWeeklyExceedsSlots.
  ///
  /// In en, this message translates to:
  /// **'Weekly target ({target}) exceeds total available lesson slots ({available}).'**
  String validationWeeklyExceedsSlots(int target, int available);

  /// No description provided for @validationWeeklyMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Weekly target must be greater than 0.'**
  String get validationWeeklyMustBePositive;

  /// No description provided for @feasibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Feasibility Check'**
  String get feasibilityTitle;

  /// No description provided for @feasibilitySlack.
  ///
  /// In en, this message translates to:
  /// **'Slack'**
  String get feasibilitySlack;

  /// No description provided for @feasibilityInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Insufficient lessons available — generation is likely to produce a partial schedule.'**
  String get feasibilityInsufficient;

  /// No description provided for @feasibilityOk.
  ///
  /// In en, this message translates to:
  /// **'Enough lessons available for all classrooms.'**
  String get feasibilityOk;

  /// No description provided for @constraints.
  ///
  /// In en, this message translates to:
  /// **'Constraints'**
  String get constraints;

  /// No description provided for @hardConstraints.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hardConstraints;

  /// No description provided for @softConstraints.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get softConstraints;

  /// No description provided for @addConstraint.
  ///
  /// In en, this message translates to:
  /// **'Add constraint'**
  String get addConstraint;

  /// No description provided for @noConstraints.
  ///
  /// In en, this message translates to:
  /// **'No constraints defined yet.'**
  String get noConstraints;

  /// No description provided for @constraintDeleted.
  ///
  /// In en, this message translates to:
  /// **'Constraint deleted'**
  String get constraintDeleted;

  /// No description provided for @undoDelete.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undoDelete;

  /// No description provided for @mustAssign.
  ///
  /// In en, this message translates to:
  /// **'MUST-ASSIGN'**
  String get mustAssign;

  /// No description provided for @mustNotAssign.
  ///
  /// In en, this message translates to:
  /// **'MUST-NOT-ASSIGN'**
  String get mustNotAssign;

  /// No description provided for @avoidTimeslot.
  ///
  /// In en, this message translates to:
  /// **'AVOID-TIMESLOT'**
  String get avoidTimeslot;

  /// No description provided for @preferBlock.
  ///
  /// In en, this message translates to:
  /// **'PREFER-BLOCK'**
  String get preferBlock;

  /// No description provided for @mustAssignDescription.
  ///
  /// In en, this message translates to:
  /// **'{subject} must be assigned to {classroom} on {day} at {time}.'**
  String mustAssignDescription(
      String subject, String classroom, String day, String time);

  /// No description provided for @mustNotAssignDescription.
  ///
  /// In en, this message translates to:
  /// **'{subject} must NOT be assigned to {classroom} on {day} at {time}.'**
  String mustNotAssignDescription(
      String subject, String classroom, String day, String time);

  /// No description provided for @avoidTimeslotDescription.
  ///
  /// In en, this message translates to:
  /// **'{subject} should be avoided on {day} between {start} and {end}.'**
  String avoidTimeslotDescription(
      String subject, String day, String start, String end);

  /// No description provided for @preferBlockDescription.
  ///
  /// In en, this message translates to:
  /// **'{subject} should be scheduled in consecutive slots when possible.'**
  String preferBlockDescription(String subject);

  /// No description provided for @weightLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get weightLow;

  /// No description provided for @weightMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get weightMedium;

  /// No description provided for @weightHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get weightHigh;

  /// No description provided for @conflictDetected.
  ///
  /// In en, this message translates to:
  /// **'Constraint conflict detected'**
  String get conflictDetected;

  /// No description provided for @conflictMustAssignMustNot.
  ///
  /// In en, this message translates to:
  /// **'MUST-ASSIGN and MUST-NOT-ASSIGN on the same cell.'**
  String get conflictMustAssignMustNot;

  /// No description provided for @conflictMustAssignBreakSlot.
  ///
  /// In en, this message translates to:
  /// **'Cannot MUST-ASSIGN to a break slot.'**
  String get conflictMustAssignBreakSlot;

  /// No description provided for @conflictMustAssignTeacher.
  ///
  /// In en, this message translates to:
  /// **'Two classrooms forced to the same teacher at the same time.'**
  String get conflictMustAssignTeacher;

  /// No description provided for @conflictMustAssignMinDaily.
  ///
  /// In en, this message translates to:
  /// **'MUST-ASSIGN conflicts with MinDaily: only one slot available but MinDaily > 1.'**
  String get conflictMustAssignMinDaily;

  /// No description provided for @conflictSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Suggested fix: {suggestion}'**
  String conflictSuggestion(String suggestion);

  /// No description provided for @schedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get schedule;

  /// Title of the version picker bottom sheet
  ///
  /// In en, this message translates to:
  /// **'Schedule Versions'**
  String get scheduleVersions;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New version'**
  String get newVersion;

  /// No description provided for @versionName.
  ///
  /// In en, this message translates to:
  /// **'Version name'**
  String get versionName;

  /// No description provided for @versionNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Final Sept 2026'**
  String get versionNameHint;

  /// No description provided for @manuallyEdited.
  ///
  /// In en, this message translates to:
  /// **'Manually edited'**
  String get manuallyEdited;

  /// No description provided for @allClassrooms.
  ///
  /// In en, this message translates to:
  /// **'All Classrooms'**
  String get allClassrooms;

  /// No description provided for @singleClassroom.
  ///
  /// In en, this message translates to:
  /// **'Single Classroom'**
  String get singleClassroom;

  /// No description provided for @perTeacher.
  ///
  /// In en, this message translates to:
  /// **'Per Teacher'**
  String get perTeacher;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @exportExcel.
  ///
  /// In en, this message translates to:
  /// **'Export Excel'**
  String get exportExcel;

  /// Export button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Success message after export
  ///
  /// In en, this message translates to:
  /// **'File shared successfully.'**
  String get exportSuccess;

  /// No description provided for @trialBannerRemaining.
  ///
  /// In en, this message translates to:
  /// **'Free trial: 1 schedule generation available. Subscribe for unlimited access.'**
  String get trialBannerRemaining;

  /// No description provided for @trialBannerUsed.
  ///
  /// In en, this message translates to:
  /// **'Trial used. Subscribe to generate new schedules.'**
  String get trialBannerUsed;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @subscribeTitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock ClassScheduler'**
  String get subscribeTitle;

  /// No description provided for @subscribeDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate unlimited timetables for all your schools.'**
  String get subscribeDescription;

  /// No description provided for @subscribePrice.
  ///
  /// In en, this message translates to:
  /// **'€14.99 / year'**
  String get subscribePrice;

  /// No description provided for @subscribeButton.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeButton;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @purchaseRestored.
  ///
  /// In en, this message translates to:
  /// **'Purchase restored successfully.'**
  String get purchaseRestored;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailed;

  /// No description provided for @alreadySubscribed.
  ///
  /// In en, this message translates to:
  /// **'You already have an active subscription.'**
  String get alreadySubscribed;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure? This will permanently delete your account and all data. This cannot be undone.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to ClassScheduler'**
  String get loginSubtitle;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get signInWithApple;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'\'t have an account?'**
  String get noAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email and we\'\'ll send a reset link.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent. Check your email.'**
  String get resetLinkSent;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start scheduling in minutes.'**
  String get registerSubtitle;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordMismatch;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No internet connection.'**
  String get errorNetwork;

  /// No description provided for @errorOfflineGeneration.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved locally — will sync when online.'**
  String get errorOfflineGeneration;

  /// No description provided for @errorRequiresReauth.
  ///
  /// In en, this message translates to:
  /// **'Please sign in again to continue.'**
  String get errorRequiresReauth;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @monShort.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get monShort;

  /// No description provided for @tueShort.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get tueShort;

  /// No description provided for @wedShort.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get wedShort;

  /// No description provided for @thuShort.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get thuShort;

  /// No description provided for @friShort.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get friShort;

  /// No description provided for @satShort.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get satShort;

  /// No description provided for @sunShort.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get sunShort;

  /// Label for a cancelled schedule
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Title for delete schedule dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Schedule'**
  String get deleteSchedule;

  /// Confirmation message for schedule deletion
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This cannot be undone.'**
  String deleteScheduleConfirm(String name);

  /// Empty schedule state message
  ///
  /// In en, this message translates to:
  /// **'Press Generate to create your first timetable.'**
  String get generateToSeeSchedule;

  /// Heading for hard violations section in result panel
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 hard constraint could not be satisfied} other{{count} hard constraints could not be satisfied}}'**
  String hardViolationsHeading(int count);

  /// Placeholder when no schedule version is selected
  ///
  /// In en, this message translates to:
  /// **'No schedule yet'**
  String get noScheduleYet;

  /// Rename action label
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// Label for SA restart count in result panel
  ///
  /// In en, this message translates to:
  /// **'Restarts'**
  String get restartsUsed;

  /// Snackbar message after schedule deletion
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted.'**
  String scheduleDeleted(String name);

  /// Label for schedule name input dialog
  ///
  /// In en, this message translates to:
  /// **'Schedule name'**
  String get scheduleVersionName;

  /// Collapse violations list
  ///
  /// In en, this message translates to:
  /// **'Show less'**
  String get showLess;

  /// Expand violations list
  ///
  /// In en, this message translates to:
  /// **'Show {count} more'**
  String showMore(int count);

  /// Heading for soft violations section in result panel
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 soft constraint could not be fully satisfied} other{{count} soft constraints could not be fully satisfied}}'**
  String softViolationsHeading(int count);

  /// Undo snackbar action
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// View mode: all classrooms side by side
  ///
  /// In en, this message translates to:
  /// **'All Classrooms'**
  String get viewAllClassrooms;

  /// View mode: filter by teacher
  ///
  /// In en, this message translates to:
  /// **'Per Teacher'**
  String get viewPerTeacher;

  /// View mode: one classroom at a time
  ///
  /// In en, this message translates to:
  /// **'Single Classroom'**
  String get viewSingleClassroom;

  /// Export sheet title
  ///
  /// In en, this message translates to:
  /// **'Export Schedule'**
  String get exportSchedule;

  /// Export format selector label
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get exportFormat;

  /// Export button label for PDF
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get exportAsPdf;

  /// Export button label for Excel
  ///
  /// In en, this message translates to:
  /// **'Export as Excel'**
  String get exportAsExcel;

  /// PDF format description
  ///
  /// In en, this message translates to:
  /// **'A4 pages, one per classroom'**
  String get exportPdfSubtitle;

  /// Excel format description
  ///
  /// In en, this message translates to:
  /// **'.xlsx with colour coding'**
  String get exportExcelSubtitle;

  /// Toggle label for overview page in PDF export
  ///
  /// In en, this message translates to:
  /// **'Include combined overview page'**
  String get exportIncludeOverview;

  /// Export button state: loading data
  ///
  /// In en, this message translates to:
  /// **'Loading data…'**
  String get exportLoading;

  /// Export button state: generating
  ///
  /// In en, this message translates to:
  /// **'Generating file…'**
  String get exportGenerating;

  /// Export button state: sharing
  ///
  /// In en, this message translates to:
  /// **'Opening share sheet…'**
  String get exportSharing;

  /// Subscription section heading
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// Subscription paywall headline
  ///
  /// In en, this message translates to:
  /// **'Unlock Unlimited Schedules'**
  String get subscriptionHeadline;

  /// Subscription paywall subtitle
  ///
  /// In en, this message translates to:
  /// **'Generate as many timetables as you need, all year long.'**
  String get subscriptionSubtitle;

  /// Label when subscription is active
  ///
  /// In en, this message translates to:
  /// **'Subscription Active'**
  String get subscriptionActive;

  /// Subtitle when subscription is active
  ///
  /// In en, this message translates to:
  /// **'Your subscription is active. Enjoy unlimited generation.'**
  String get subscriptionActiveSubtitle;

  /// Price card label
  ///
  /// In en, this message translates to:
  /// **'ANNUAL PLAN'**
  String get subscriptionPriceLabel;

  /// Subscription price displayed on paywall
  ///
  /// In en, this message translates to:
  /// **'€14.99'**
  String get subscriptionPrice;

  /// Price suffix on paywall
  ///
  /// In en, this message translates to:
  /// **'per year · billed annually'**
  String get subscriptionPriceSuffix;

  /// Offline grace period notice
  ///
  /// In en, this message translates to:
  /// **'You\'\'re offline. Your subscription is honoured for up to 30 days without a connection.'**
  String get subscriptionOfflineGrace;

  /// Legal note on subscription screen
  ///
  /// In en, this message translates to:
  /// **'Payment will be charged to your App Store / Play Store account at confirmation of purchase. Subscription renews automatically unless cancelled at least 24 hours before the end of the current period.'**
  String get subscriptionLegalNote;

  /// Primary CTA button on subscription screen
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// Underlined link in trial banner
  ///
  /// In en, this message translates to:
  /// **'Subscribe for unlimited access'**
  String get subscribeForUnlimited;

  /// Snackbar when restore finds nothing
  ///
  /// In en, this message translates to:
  /// **'No purchases found to restore.'**
  String get noPurchasesToRestore;

  /// Feature list item
  ///
  /// In en, this message translates to:
  /// **'Unlimited schedule generation'**
  String get featureUnlimitedGeneration;

  /// Feature list item
  ///
  /// In en, this message translates to:
  /// **'PDF & Excel export'**
  String get featurePdfExcel;

  /// Feature list item
  ///
  /// In en, this message translates to:
  /// **'Manual drag-and-drop editing'**
  String get featureManualEditing;

  /// Feature list item
  ///
  /// In en, this message translates to:
  /// **'Cloud sync across all devices'**
  String get featureCloudSync;

  /// Feature list item
  ///
  /// In en, this message translates to:
  /// **'Multiple schools per account'**
  String get featureMultipleSchools;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
