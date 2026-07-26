// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'ClassScheduler';

  @override
  String get goodMorning => 'Bonjour 👋';

  @override
  String get yourSchools => 'Vos établissements';

  @override
  String yourSchoolsCount(int count) {
    return 'Vos établissements ($count)';
  }

  @override
  String get addSchool => 'Ajouter un établissement';

  @override
  String get newSchool => 'Nouvel établissement';

  @override
  String get schoolName => 'Nom de l\'établissement';

  @override
  String get schoolDescription => 'Description (facultatif)';

  @override
  String get schoolCreated => 'Établissement créé';

  @override
  String get schoolUpdated => 'Établissement mis à jour';

  @override
  String get schoolDeleted => 'Établissement supprimé';

  @override
  String get renameSchool => 'Renommer';

  @override
  String get duplicateSchool => 'Dupliquer';

  @override
  String get deleteSchool => 'Supprimer';

  @override
  String deleteSchoolConfirm(String name) {
    return 'Supprimer \"$name\" ? Toutes les classes, matières, contraintes et emplois du temps seront supprimés définitivement.';
  }

  @override
  String classCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classes',
      one: '1 classe',
    );
    return '$_temp0';
  }

  @override
  String teacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count enseignants',
      one: '1 enseignant',
    );
    return '$_temp0';
  }

  @override
  String get lastGenerated => 'Dernière génération';

  @override
  String lastGeneratedDate(String date) {
    return 'Dernière exécution : $date';
  }

  @override
  String get neverGenerated => 'Jamais';

  @override
  String get generate => 'Générer';

  @override
  String get reGenerate => 'Regénérer';

  @override
  String get generating => 'Génération en cours…';

  @override
  String get cancelGeneration => 'Annuler';

  @override
  String get generationComplete => 'Génération terminée';

  @override
  String get generationCancelled =>
      'Génération annulée — meilleur résultat affiché';

  @override
  String get qualityScore => 'Score de qualité';

  @override
  String get qualityExcellent => 'Excellent';

  @override
  String get qualityGood => 'Bon';

  @override
  String get qualityFair => 'Passable';

  @override
  String get qualityPoor => 'Mauvais';

  @override
  String get qualityTooltip =>
      'Un score plus élevé signifie moins d\'heures creuses pour les enseignants et moins de changements de matière par jour.';

  @override
  String get resultPerfect =>
      'Emploi du temps généré. Toutes les contraintes sont satisfaites.';

  @override
  String resultSoftViolations(int count) {
    return 'Emploi du temps généré. $count contrainte(s) souple(s) n\'ont pas pu être entièrement satisfaites.';
  }

  @override
  String resultHardViolations(int count) {
    return 'Meilleur emploi du temps partiel affiché. $count contrainte(s) obligatoire(s) non satisfaite(s) — cellules concernées surlignées en rouge.';
  }

  @override
  String get teacherFreeHours => 'Heures creuses enseignants';

  @override
  String get subjectChanges => 'Changements de matière';

  @override
  String get computationTime => 'Temps de calcul';

  @override
  String get iterationsCompleted => 'Itérations effectuées';

  @override
  String get navSchools => 'Établissements';

  @override
  String get navSetup => 'Configuration';

  @override
  String get navConstraints => 'Contraintes';

  @override
  String get navSchedule => 'Emploi du temps';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get setupTitle => 'Configuration';

  @override
  String get step1Title => 'Jours et périodes';

  @override
  String get step2Title => 'Classes';

  @override
  String get step3Title => 'Capacité journalière';

  @override
  String get step4Title => 'Matières';

  @override
  String get step1Description =>
      'Sélectionnez les jours scolaires actifs et définissez les créneaux de cours et de pause.';

  @override
  String get step2Description => 'Ajoutez et nommez les classes (10 maximum).';

  @override
  String get step3Description =>
      'Définissez le nombre maximum de cours par classe et par jour.';

  @override
  String get step4Description =>
      'Définissez les matières, affectez-les aux classes et fixez les objectifs hebdomadaires.';

  @override
  String get activeDays => 'Jours scolaires actifs';

  @override
  String get periods => 'Périodes';

  @override
  String get addPeriod => 'Ajouter une période';

  @override
  String get lessonSlot => 'Créneau de cours';

  @override
  String get breakSlot => 'Pause';

  @override
  String get step3ApplyToAllDays => 'Appliquer à tous les jours';

  @override
  String get breakName => 'Nom de la pause';

  @override
  String get startTime => 'Début';

  @override
  String get endTime => 'Fin';

  @override
  String get useTemplate => 'Utiliser un modèle';

  @override
  String get periodSaved => 'Période enregistrée';

  @override
  String get periodDeleted => 'Période supprimée';

  @override
  String get classrooms => 'Classes';

  @override
  String get addClassroom => 'Ajouter une classe';

  @override
  String get classroomName => 'Nom de la classe (ex. 1A, CM2 Bleu)';

  @override
  String get classroomRenamed => 'Classe renommée';

  @override
  String get classroomDeleted => 'Classe supprimée';

  @override
  String classroomDeleteConstraintWarning(int count) {
    return 'Cette classe est référencée dans $count contrainte(s) qui seront également supprimées.';
  }

  @override
  String get maxClassroomsReached => 'Le maximum de 10 classes est atteint.';

  @override
  String get dailyCapacity => 'Capacité journalière';

  @override
  String get maxLessonsPerDay => 'Cours max par jour';

  @override
  String get subjects => 'Matières';

  @override
  String get addSubject => 'Ajouter une matière';

  @override
  String get subjectName => 'Nom de la matière';

  @override
  String get teacherName => 'Nom de l\'enseignant';

  @override
  String get colour => 'Couleur';

  @override
  String get weeklyTarget => 'Objectif hebdomadaire (créneaux)';

  @override
  String get minDailyHours => 'Créneaux min par jour (0 = désactivé)';

  @override
  String get maxDailyHours => 'Créneaux max par jour';

  @override
  String get assignToClassroom => 'Affecter à la classe';

  @override
  String get unassignSubject => 'Désaffecter';

  @override
  String get subjectSaved => 'Matière enregistrée';

  @override
  String get subjectDeleted => 'Matière supprimée';

  @override
  String subjectDeleteConstraintWarning(int count) {
    return 'Cette matière est utilisée dans $count contrainte(s) qui seront également supprimées.';
  }

  @override
  String get validationMinGtMax =>
      'Les créneaux journaliers minimum ne peuvent pas être supérieurs aux maximum.';

  @override
  String validationMaxDaysInsufficient(int product, int target) {
    return 'Max journalier × jours actifs ($product) est inférieur à l\'objectif hebdomadaire ($target).';
  }

  @override
  String validationWeeklyExceedsSlots(int target, int available) {
    return 'L\'objectif hebdomadaire ($target) dépasse les créneaux de cours disponibles ($available).';
  }

  @override
  String get validationWeeklyMustBePositive =>
      'L\'objectif hebdomadaire doit être supérieur à 0.';

  @override
  String validationMinDailyInfeasible(int target, int minDaily) {
    return 'L\'objectif hebdomadaire ($target) ne peut pas être atteint avec MinJour $minDaily — aucune distribution journalière valide n\'existe.';
  }

  @override
  String get feasibilityTitle => 'Analyse de faisabilité';

  @override
  String get feasibilitySlack => 'Marge';

  @override
  String get feasibilityInsufficient =>
      'Cours disponibles insuffisants — la génération produira probablement un emploi du temps partiel.';

  @override
  String get feasibilityOk =>
      'Assez de cours disponibles pour toutes les classes.';

  @override
  String get constraints => 'Contraintes';

  @override
  String get hardConstraints => 'Obligatoires';

  @override
  String get softConstraints => 'Préférentielles';

  @override
  String get addConstraint => 'Ajouter une contrainte';

  @override
  String get noConstraints => 'Aucune contrainte définie.';

  @override
  String get constraintDeleted => 'Contrainte supprimée';

  @override
  String get undoDelete => 'Annuler';

  @override
  String get mustAssign => 'DOIT ÊTRE AFFECTÉ';

  @override
  String get mustNotAssign => 'NE DOIT PAS ÊTRE AFFECTÉ';

  @override
  String get avoidTimeslot => 'ÉVITER LE CRÉNEAU';

  @override
  String get preferBlock => 'PRÉFÉRER UN BLOC';

  @override
  String mustAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject doit être affecté à $classroom le $day à $time.';
  }

  @override
  String mustNotAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject NE doit PAS être affecté à $classroom le $day à $time.';
  }

  @override
  String avoidTimeslotDescription(
      String subject, String day, String start, String end) {
    return '$subject devrait être évité le $day entre $start et $end.';
  }

  @override
  String preferBlockDescription(String subject) {
    return '$subject devrait être planifié en créneaux consécutifs si possible.';
  }

  @override
  String get weightLow => 'Faible';

  @override
  String get weightMedium => 'Moyenne';

  @override
  String get weightHigh => 'Élevée';

  @override
  String get conflictDetected => 'Conflit de contraintes détecté';

  @override
  String get conflictMustAssignMustNot =>
      'DOIT ÊTRE AFFECTÉ et NE DOIT PAS ÊTRE AFFECTÉ sur la même cellule.';

  @override
  String get conflictMustAssignBreakSlot =>
      'Impossible d\'affecter obligatoirement à une période de pause.';

  @override
  String get conflictMustAssignTeacher =>
      'Deux classes obligées avec le même enseignant au même moment.';

  @override
  String get conflictMustAssignMinDaily =>
      'La contrainte DOIT ÊTRE AFFECTÉ est en conflit avec MinJournalier.';

  @override
  String conflictSuggestion(String suggestion) {
    return 'Solution suggérée : $suggestion';
  }

  @override
  String get schedule => 'Emploi du temps';

  @override
  String get scheduleVersions => 'Versions de l\'emploi du temps';

  @override
  String get newVersion => 'Nouvelle version';

  @override
  String get versionName => 'Nom de la version';

  @override
  String get versionNameHint => 'ex. Définitif Sept 2026';

  @override
  String get manuallyEdited => 'Modifié manuellement';

  @override
  String get allClassrooms => 'Toutes les classes';

  @override
  String get singleClassroom => 'Classe individuelle';

  @override
  String get perTeacher => 'Par enseignant';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get exportExcel => 'Exporter en Excel';

  @override
  String get export => 'Exporter';

  @override
  String get share => 'Partager';

  @override
  String get exportSuccess => 'Export prêt';

  @override
  String get trialBannerRemaining =>
      'Version d\'essai : 1 génération gratuite disponible. Abonnez-vous pour un accès illimité.';

  @override
  String get trialBannerUsed =>
      'Essai utilisé. Abonnez-vous pour générer de nouveaux emplois du temps.';

  @override
  String get subscribe => 'S\'abonner';

  @override
  String get subscribeTitle => 'Débloquer ClassScheduler';

  @override
  String get subscribeDescription =>
      'Générez des emplois du temps illimités pour tous vos établissements.';

  @override
  String get subscribePrice => '14,99 € / an';

  @override
  String get subscribeButton => 'S\'abonner maintenant';

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get purchaseRestored => 'Achat restauré avec succès.';

  @override
  String get purchaseFailed => 'Échec de l\'achat. Veuillez réessayer.';

  @override
  String get alreadySubscribed => 'Vous avez déjà un abonnement actif.';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Apparence';

  @override
  String get themeDark => 'Sombre';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeSystem => 'Par défaut du système';

  @override
  String get account => 'Compte';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirm =>
      'Êtes-vous sûr ? Cette action supprimera définitivement votre compte et toutes vos données. Elle est irréversible.';

  @override
  String get deleteAccountSuccess => 'Compte supprimé.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get loginTitle => 'Bon retour';

  @override
  String get loginSubtitle => 'Connectez-vous à ClassScheduler';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get signInWithApple => 'Continuer avec Apple';

  @override
  String get noAccount => 'Pas encore de compte ?';

  @override
  String get createAccount => 'Créer un compte';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle =>
      'Saisissez votre e-mail et nous vous enverrons un lien de réinitialisation.';

  @override
  String get sendResetLink => 'Envoyer le lien';

  @override
  String get resetLinkSent => 'Lien envoyé. Vérifiez votre e-mail.';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle =>
      'Commencez à créer des emplois du temps en quelques minutes.';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get passwordMismatch => 'Les mots de passe ne correspondent pas.';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get done => 'Terminé';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get ok => 'OK';

  @override
  String get errorGeneric => 'Une erreur s\'est produite. Veuillez réessayer.';

  @override
  String get errorNetwork => 'Pas de connexion Internet.';

  @override
  String get errorOfflineGeneration =>
      'Emploi du temps sauvegardé localement — synchronisation en attente de connexion.';

  @override
  String get errorRequiresReauth => 'Veuillez vous reconnecter pour continuer.';

  @override
  String get monday => 'Lundi';

  @override
  String get tuesday => 'Mardi';

  @override
  String get wednesday => 'Mercredi';

  @override
  String get thursday => 'Jeudi';

  @override
  String get friday => 'Vendredi';

  @override
  String get saturday => 'Samedi';

  @override
  String get sunday => 'Dimanche';

  @override
  String get monShort => 'Lun';

  @override
  String get tueShort => 'Mar';

  @override
  String get wedShort => 'Mer';

  @override
  String get thuShort => 'Jeu';

  @override
  String get friShort => 'Ven';

  @override
  String get satShort => 'Sam';

  @override
  String get sunShort => 'Dim';

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
