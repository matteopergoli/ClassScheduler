// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'ClassScheduler';

  @override
  String get goodMorning => 'Guten Morgen 👋';

  @override
  String get yourSchools => 'Ihre Schulen';

  @override
  String yourSchoolsCount(int count) {
    return 'Ihre Schulen ($count)';
  }

  @override
  String get addSchool => 'Schule hinzufügen';

  @override
  String get newSchool => 'Neue Schule';

  @override
  String get schoolName => 'Name der Schule';

  @override
  String get schoolDescription => 'Beschreibung (optional)';

  @override
  String get schoolCreated => 'Schule erstellt';

  @override
  String get schoolUpdated => 'Schule aktualisiert';

  @override
  String get schoolDeleted => 'Schule gelöscht';

  @override
  String get renameSchool => 'Umbenennen';

  @override
  String get duplicateSchool => 'Duplizieren';

  @override
  String get deleteSchool => 'Löschen';

  @override
  String deleteSchoolConfirm(String name) {
    return '\"$name\" löschen? Alle Klassen, Fächer, Einschränkungen und Stundenpläne werden dauerhaft entfernt.';
  }

  @override
  String classCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Klassen',
      one: '1 Klasse',
    );
    return '$_temp0';
  }

  @override
  String teacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Lehrkräfte',
      one: '1 Lehrkraft',
    );
    return '$_temp0';
  }

  @override
  String get lastGenerated => 'Zuletzt generiert';

  @override
  String lastGeneratedDate(String date) {
    return 'Letzte Ausführung: $date';
  }

  @override
  String get neverGenerated => 'Nie';

  @override
  String get generate => 'Generieren';

  @override
  String get reGenerate => 'Neu generieren';

  @override
  String get generating => 'Wird generiert…';

  @override
  String get cancelGeneration => 'Abbrechen';

  @override
  String get generationComplete => 'Generierung abgeschlossen';

  @override
  String get generationCancelled =>
      'Generierung abgebrochen — bestes Ergebnis wird angezeigt';

  @override
  String get qualityScore => 'Qualitätsbewertung';

  @override
  String get qualityExcellent => 'Ausgezeichnet';

  @override
  String get qualityGood => 'Gut';

  @override
  String get qualityFair => 'Befriedigend';

  @override
  String get qualityPoor => 'Mangelhaft';

  @override
  String get qualityTooltip =>
      'Ein höherer Wert bedeutet weniger Freistunden für Lehrkräfte und weniger Fachwechsel pro Tag.';

  @override
  String get resultPerfect =>
      'Stundenplan generiert. Alle Einschränkungen erfüllt.';

  @override
  String resultSoftViolations(int count) {
    return 'Stundenplan generiert. $count weiche Einschränkung(en) konnten nicht vollständig erfüllt werden.';
  }

  @override
  String resultHardViolations(int count) {
    return 'Bester Teillösungs-Stundenplan angezeigt. $count harte Einschränkung(en) nicht erfüllt — betroffene Zellen rot markiert.';
  }

  @override
  String get teacherFreeHours => 'Freistunden der Lehrkräfte';

  @override
  String get subjectChanges => 'Fachwechsel';

  @override
  String get computationTime => 'Rechenzeit';

  @override
  String get iterationsCompleted => 'Abgeschlossene Iterationen';

  @override
  String get navSchools => 'Schulen';

  @override
  String get navSetup => 'Einrichtung';

  @override
  String get navConstraints => 'Einschränkungen';

  @override
  String get navSchedule => 'Stundenplan';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get setupTitle => 'Einrichtung';

  @override
  String get step1Title => 'Schultage & Zeiträume';

  @override
  String get step2Title => 'Klassen';

  @override
  String get step3Title => 'Tageskapazität';

  @override
  String get step4Title => 'Fächer';

  @override
  String get step1Description =>
      'Wählen Sie aktive Schultage und definieren Sie Unterrichts- und Pausenzeiten.';

  @override
  String get step2Description => 'Klassen hinzufügen und benennen (max. 10).';

  @override
  String get step3Description =>
      'Maximale Unterrichtsstunden pro Klasse und Tag festlegen.';

  @override
  String get step4Description =>
      'Fächer definieren, Klassen zuweisen und Wochenziele festlegen.';

  @override
  String get activeDays => 'Aktive Schultage';

  @override
  String get periods => 'Zeiträume';

  @override
  String get addPeriod => 'Zeitraum hinzufügen';

  @override
  String get lessonSlot => 'Unterrichtsstunde';

  @override
  String get breakSlot => 'Pause';

  @override
  String get step3ApplyToAllDays => 'Auf alle Tage anwenden';

  @override
  String get breakName => 'Name der Pause';

  @override
  String get startTime => 'Beginn';

  @override
  String get endTime => 'Ende';

  @override
  String get useTemplate => 'Vorlage verwenden';

  @override
  String get periodSaved => 'Zeitraum gespeichert';

  @override
  String get periodDeleted => 'Zeitraum gelöscht';

  @override
  String get classrooms => 'Klassen';

  @override
  String get addClassroom => 'Klasse hinzufügen';

  @override
  String get classroomName => 'Klassenname (z.B. 1A, Jahrgang 5 Blau)';

  @override
  String get classroomRenamed => 'Klasse umbenannt';

  @override
  String get classroomDeleted => 'Klasse gelöscht';

  @override
  String classroomDeleteConstraintWarning(int count) {
    return 'Diese Klasse wird in $count Einschränkung(en) verwendet, die ebenfalls gelöscht werden.';
  }

  @override
  String get maxClassroomsReached => 'Maximale Anzahl von 10 Klassen erreicht.';

  @override
  String get dailyCapacity => 'Tageskapazität';

  @override
  String get maxLessonsPerDay => 'Max. Stunden pro Tag';

  @override
  String get subjects => 'Fächer';

  @override
  String get addSubject => 'Fach hinzufügen';

  @override
  String get subjectName => 'Name des Fachs';

  @override
  String get teacherName => 'Name der Lehrkraft';

  @override
  String get teacherNameOptional => 'Teacher name (optional)';

  @override
  String get colour => 'Farbe';

  @override
  String get weeklyTarget => 'Wochenziel (Slots)';

  @override
  String get minDailyHours => 'Min. tägliche Slots (0 = deaktiviert)';

  @override
  String get maxDailyHours => 'Max. tägliche Slots';

  @override
  String get assignToClassroom => 'Klasse zuweisen';

  @override
  String get unassignSubject => 'Zuweisung aufheben';

  @override
  String get subjectSaved => 'Fach gespeichert';

  @override
  String get subjectDeleted => 'Fach gelöscht';

  @override
  String subjectDeleteConstraintWarning(int count) {
    return 'Dieses Fach wird in $count Einschränkung(en) verwendet, die ebenfalls gelöscht werden.';
  }

  @override
  String get validationMinGtMax =>
      'Die täglichen Mindest-Slots dürfen die Maximum-Slots nicht überschreiten.';

  @override
  String validationMaxDaysInsufficient(int product, int target) {
    return 'Max. täglich × aktive Tage ($product) ist kleiner als das Wochenziel ($target).';
  }

  @override
  String validationWeeklyExceedsSlots(int target, int available) {
    return 'Das Wochenziel ($target) überschreitet die verfügbaren Unterrichts-Slots ($available).';
  }

  @override
  String get validationWeeklyMustBePositive =>
      'Das Wochenziel muss größer als 0 sein.';

  @override
  String validationMinDailyInfeasible(int target, int minDaily) {
    return 'Wochenziel ($target) kann mit MinTäglich $minDaily nicht erreicht werden — keine gültige Tagesverteilung möglich.';
  }

  @override
  String get feasibilityTitle => 'Machbarkeitsanalyse';

  @override
  String get feasibilitySlack => 'Spielraum';

  @override
  String get feasibilityInsufficient =>
      'Nicht genug verfügbare Stunden — die Generierung wird wahrscheinlich einen unvollständigen Plan ergeben.';

  @override
  String get feasibilityOk => 'Genug Stunden für alle Klassen verfügbar.';

  @override
  String get constraints => 'Einschränkungen';

  @override
  String get hardConstraints => 'Pflicht';

  @override
  String get softConstraints => 'Wunsch';

  @override
  String get addConstraint => 'Einschränkung hinzufügen';

  @override
  String get noConstraints => 'Keine Einschränkungen definiert.';

  @override
  String get constraintDeleted => 'Einschränkung gelöscht';

  @override
  String get undoDelete => 'Rückgängig';

  @override
  String get mustAssign => 'MUSS ZUGEWIESEN WERDEN';

  @override
  String get mustNotAssign => 'DARF NICHT ZUGEWIESEN WERDEN';

  @override
  String get avoidTimeslot => 'ZEITFENSTER VERMEIDEN';

  @override
  String get preferBlock => 'BLOCK BEVORZUGEN';

  @override
  String mustAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject muss $classroom am $day um $time zugewiesen werden.';
  }

  @override
  String mustNotAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject darf $classroom am $day um $time NICHT zugewiesen werden.';
  }

  @override
  String avoidTimeslotDescription(
      String subject, String day, String start, String end) {
    return '$subject sollte am $day zwischen $start und $end vermieden werden.';
  }

  @override
  String preferBlockDescription(String subject) {
    return '$subject sollte nach Möglichkeit in aufeinanderfolgenden Slots eingeplant werden.';
  }

  @override
  String get weightLow => 'Niedrig';

  @override
  String get weightMedium => 'Mittel';

  @override
  String get weightHigh => 'Hoch';

  @override
  String get conflictDetected => 'Einschränkungskonflikt erkannt';

  @override
  String get conflictMustAssignMustNot =>
      'MUSS ZUGEWIESEN WERDEN und DARF NICHT ZUGEWIESEN WERDEN in derselben Zelle.';

  @override
  String get conflictMustAssignBreakSlot =>
      'Kann nicht zwingend einer Pause zugewiesen werden.';

  @override
  String get conflictMustAssignTeacher =>
      'Zwei Klassen zwingen dieselbe Lehrkraft zur gleichen Zeit.';

  @override
  String get conflictMustAssignMinDaily =>
      'MUSS ZUGEWIESEN WERDEN steht im Konflikt mit MinTäglich.';

  @override
  String conflictSuggestion(String suggestion) {
    return 'Vorgeschlagene Lösung: $suggestion';
  }

  @override
  String get schedule => 'Stundenplan';

  @override
  String get scheduleVersions => 'Stundenplanversionen';

  @override
  String get newVersion => 'Neue Version';

  @override
  String get versionName => 'Versionsname';

  @override
  String get versionNameHint => 'z.B. Endgültig Sept 2026';

  @override
  String get manuallyEdited => 'Manuell bearbeitet';

  @override
  String get allClassrooms => 'Alle Klassen';

  @override
  String get singleClassroom => 'Einzelne Klasse';

  @override
  String get perTeacher => 'Pro Lehrkraft';

  @override
  String get exportPdf => 'PDF exportieren';

  @override
  String get exportExcel => 'Excel exportieren';

  @override
  String get export => 'Exportieren';

  @override
  String get share => 'Teilen';

  @override
  String get exportSuccess => 'Export bereit';

  @override
  String get trialBannerRemaining =>
      'Testversion: 1 kostenlose Generierung verfügbar. Abonnieren Sie für unbegrenzten Zugang.';

  @override
  String get trialBannerUsed =>
      'Test verwendet. Abonnieren Sie, um neue Stundenpläne zu erstellen.';

  @override
  String get subscribe => 'Abonnieren';

  @override
  String get subscribeTitle => 'ClassScheduler freischalten';

  @override
  String get subscribeDescription =>
      'Erstellen Sie unbegrenzt Stundenpläne für alle Ihre Schulen.';

  @override
  String get subscribePrice => '14,99 € / Jahr';

  @override
  String get subscribeButton => 'Jetzt abonnieren';

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get purchaseRestored => 'Kauf erfolgreich wiederhergestellt.';

  @override
  String get purchaseFailed => 'Kauf fehlgeschlagen. Bitte erneut versuchen.';

  @override
  String get alreadySubscribed => 'Sie haben bereits ein aktives Abonnement.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Erscheinungsbild';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeSystem => 'Systemstandard';

  @override
  String get account => 'Konto';

  @override
  String get signOut => 'Abmelden';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String get deleteAccountConfirm =>
      'Sind Sie sicher? Diese Aktion löscht Ihr Konto und alle Daten dauerhaft. Dies kann nicht rückgängig gemacht werden.';

  @override
  String get deleteAccountSuccess => 'Konto gelöscht.';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get loginTitle => 'Willkommen zurück';

  @override
  String get loginSubtitle => 'Bei ClassScheduler anmelden';

  @override
  String get email => 'E-Mail';

  @override
  String get password => 'Passwort';

  @override
  String get signIn => 'Anmelden';

  @override
  String get signInWithGoogle => 'Mit Google fortfahren';

  @override
  String get signInWithApple => 'Mit Apple fortfahren';

  @override
  String get noAccount => 'Noch kein Konto?';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get forgotPasswordTitle => 'Passwort zurücksetzen';

  @override
  String get forgotPasswordSubtitle =>
      'Geben Sie Ihre E-Mail ein und wir senden Ihnen einen Reset-Link.';

  @override
  String get sendResetLink => 'Reset-Link senden';

  @override
  String get resetLinkSent => 'Link gesendet. Überprüfen Sie Ihre E-Mail.';

  @override
  String get registerTitle => 'Konto erstellen';

  @override
  String get registerSubtitle =>
      'Starten Sie in wenigen Minuten mit der Stundenplanung.';

  @override
  String get confirmPassword => 'Passwort bestätigen';

  @override
  String get passwordMismatch => 'Die Passwörter stimmen nicht überein.';

  @override
  String get alreadyHaveAccount => 'Haben Sie bereits ein Konto?';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get done => 'Fertig';

  @override
  String get next => 'Weiter';

  @override
  String get back => 'Zurück';

  @override
  String get close => 'Schließen';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get ok => 'OK';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte erneut versuchen.';

  @override
  String get errorNetwork => 'Keine Internetverbindung.';

  @override
  String get errorOfflineGeneration =>
      'Stundenplan lokal gespeichert — wird bei Verbindung synchronisiert.';

  @override
  String get errorRequiresReauth =>
      'Bitte melden Sie sich erneut an, um fortzufahren.';

  @override
  String get monday => 'Montag';

  @override
  String get tuesday => 'Dienstag';

  @override
  String get wednesday => 'Mittwoch';

  @override
  String get thursday => 'Donnerstag';

  @override
  String get friday => 'Freitag';

  @override
  String get saturday => 'Samstag';

  @override
  String get sunday => 'Sonntag';

  @override
  String get monShort => 'Mo';

  @override
  String get tueShort => 'Di';

  @override
  String get wedShort => 'Mi';

  @override
  String get thuShort => 'Do';

  @override
  String get friShort => 'Fr';

  @override
  String get satShort => 'Sa';

  @override
  String get sunShort => 'So';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get deleteSchedule => 'Delete Schedule';

  @override
  String deleteScheduleConfirm(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get generateToSeeSchedule => 'Generate a schedule to see it here';

  @override
  String hardViolationsHeading(int count) {
    return 'Hard Violations';
  }

  @override
  String get noScheduleYet => 'No schedule yet';

  @override
  String get rename => 'Rename';

  @override
  String get restartsUsed => 'Restarts';

  @override
  String scheduleDeleted(String name) {
    return 'Schedule deleted';
  }

  @override
  String get scheduleVersionName => 'Schedule name';

  @override
  String get showLess => 'Show less';

  @override
  String showMore(int count) {
    return 'Show more';
  }

  @override
  String softViolationsHeading(int count) {
    return 'Soft Violations';
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
  String get exportPdfSubtitle => 'PDF subtitle';

  @override
  String get exportExcelSubtitle => 'Excel subtitle';

  @override
  String get exportIncludeOverview => 'Include overview';

  @override
  String get exportLoading => 'Loading';

  @override
  String get exportGenerating => 'Generating';

  @override
  String get exportSharing => 'Sharing';

  @override
  String get subscription => 'Subscription';

  @override
  String get subscriptionHeadline => 'Headline';

  @override
  String get subscriptionSubtitle => 'Subtitle';

  @override
  String get subscriptionActive => 'Active';

  @override
  String get subscriptionActiveSubtitle => 'Active subtitle';

  @override
  String get subscriptionPriceLabel => 'Price label';

  @override
  String get subscriptionPrice => 'Price';

  @override
  String get subscriptionPriceSuffix => 'Suffix';

  @override
  String get subscriptionOfflineGrace => 'Offline grace';

  @override
  String get subscriptionLegalNote => 'Legal note';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get subscribeForUnlimited => 'Subscribe for unlimited';

  @override
  String get noPurchasesToRestore => 'No purchases';

  @override
  String get featureUnlimitedGeneration => 'Unlimited generation';

  @override
  String get featurePdfExcel => 'PDF Excel';

  @override
  String get featureManualEditing => 'Manual editing';

  @override
  String get featureCloudSync => 'Cloud sync';

  @override
  String get featureMultipleSchools => 'Multiple schools';

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
