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
}
