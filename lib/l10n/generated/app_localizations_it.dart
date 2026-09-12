// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'ClassScheduler';

  @override
  String get goodMorning => 'Buongiorno 👋';

  @override
  String get yourSchools => 'Le tue scuole';

  @override
  String yourSchoolsCount(int count) {
    return 'Le tue scuole ($count)';
  }

  @override
  String get addSchool => 'Aggiungi una scuola';

  @override
  String get newSchool => 'Nuova scuola';

  @override
  String get schoolName => 'Nome della scuola';

  @override
  String get schoolDescription => 'Descrizione (opzionale)';

  @override
  String get schoolCreated => 'Scuola creata';

  @override
  String get schoolUpdated => 'Scuola aggiornata';

  @override
  String get schoolDeleted => 'Scuola eliminata';

  @override
  String get renameSchool => 'Rinomina';

  @override
  String get duplicateSchool => 'Duplica';

  @override
  String get deleteSchool => 'Elimina';

  @override
  String deleteSchoolConfirm(String name) {
    return 'Eliminare \"$name\"? Verranno rimossi definitivamente tutte le classi, le materie, i vincoli e gli orari.';
  }

  @override
  String classCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count classi',
      one: '1 classe',
    );
    return '$_temp0';
  }

  @override
  String teacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count docenti',
      one: '1 docente',
    );
    return '$_temp0';
  }

  @override
  String get lastGenerated => 'Ultima generazione';

  @override
  String lastGeneratedDate(String date) {
    return 'Ultima esecuzione: $date';
  }

  @override
  String get neverGenerated => 'Mai';

  @override
  String get generate => 'Genera';

  @override
  String get reGenerate => 'Rigenera';

  @override
  String get generating => 'Generazione in corso…';

  @override
  String get cancelGeneration => 'Annulla';

  @override
  String get generationComplete => 'Generazione completata';

  @override
  String get generationCancelled =>
      'Generazione annullata — mostrato il miglior risultato';

  @override
  String get qualityScore => 'Punteggio qualità';

  @override
  String get qualityExcellent => 'Eccellente';

  @override
  String get qualityGood => 'Buono';

  @override
  String get qualityFair => 'Discreto';

  @override
  String get qualityPoor => 'Scarso';

  @override
  String get qualityTooltip =>
      'Un punteggio più alto indica meno ore libere per i docenti e meno cambi di materia durante la giornata.';

  @override
  String get resultPerfect =>
      'Orario generato. Tutti i vincoli sono soddisfatti.';

  @override
  String resultSoftViolations(int count) {
    return 'Orario generato. $count vincolo/i preferenziale/i non è stato possibile soddisfare completamente.';
  }

  @override
  String resultHardViolations(int count) {
    return 'Mostrato il miglior orario parziale. $count vincolo/i obbligatorio/i non soddisfatto/i — le celle interessate sono evidenziate in rosso.';
  }

  @override
  String get teacherFreeHours => 'Ore libere docenti';

  @override
  String get subjectChanges => 'Cambi di materia';

  @override
  String get computationTime => 'Tempo di calcolo';

  @override
  String get iterationsCompleted => 'Iterazioni completate';

  @override
  String get navSchools => 'Scuole';

  @override
  String get navSetup => 'Configurazione';

  @override
  String get navConstraints => 'Vincoli';

  @override
  String get navSchedule => 'Orario';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get setupTitle => 'Configurazione';

  @override
  String get step1Title => 'Giorni e periodi';

  @override
  String get step2Title => 'Classi';

  @override
  String get step3Title => 'Capacità giornaliera';

  @override
  String get step4Title => 'Materie';

  @override
  String get step1Description =>
      'Seleziona i giorni scolastici attivi e definisci le ore di lezione e le pause.';

  @override
  String get step2Description =>
      'Aggiungi e assegna un nome alle classi (massimo 10).';

  @override
  String get step3Description =>
      'Imposta il numero massimo di lezioni per classe al giorno.';

  @override
  String get step4Description =>
      'Definisci le materie, assegnale alle classi e imposta gli obiettivi settimanali.';

  @override
  String get activeDays => 'Giorni scolastici attivi';

  @override
  String get periods => 'Periodi';

  @override
  String get addPeriod => 'Aggiungi periodo';

  @override
  String get lessonSlot => 'Ora di lezione';

  @override
  String get breakSlot => 'Pausa';

  @override
  String get step3ApplyToAllDays => 'Applica a tutti i giorni';

  @override
  String get breakName => 'Nome della pausa';

  @override
  String get startTime => 'Inizio';

  @override
  String get endTime => 'Fine';

  @override
  String get useTemplate => 'Usa un modello';

  @override
  String get periodSaved => 'Periodo salvato';

  @override
  String get periodDeleted => 'Periodo eliminato';

  @override
  String get classrooms => 'Classi';

  @override
  String get addClassroom => 'Aggiungi classe';

  @override
  String get classroomName => 'Nome della classe (es. 1A, Anno 5 Blu)';

  @override
  String get classroomRenamed => 'Classe rinominata';

  @override
  String get classroomDeleted => 'Classe eliminata';

  @override
  String classroomDeleteConstraintWarning(int count) {
    return 'Questa classe è usata in $count vincolo/i che verranno anch\'essi eliminati.';
  }

  @override
  String get maxClassroomsReached =>
      'Raggiunto il limite massimo di 10 classi.';

  @override
  String get dailyCapacity => 'Capacità giornaliera';

  @override
  String get maxLessonsPerDay => 'Max lezioni al giorno';

  @override
  String get subjects => 'Materie';

  @override
  String get addSubject => 'Aggiungi materia';

  @override
  String get subjectName => 'Nome della materia';

  @override
  String get teacherName => 'Nome del docente';

  @override
  String get teacherNameOptional => 'Nome del docente (opzionale)';

  @override
  String get colour => 'Colore';

  @override
  String get weeklyTarget => 'Obiettivo settimanale (slot)';

  @override
  String get minDailyHours => 'Min slot giornalieri (0 = disabilitato)';

  @override
  String get maxDailyHours => 'Max slot giornalieri';

  @override
  String get assignToClassroom => 'Assegna alla classe';

  @override
  String get unassignSubject => 'Rimuovi assegnazione';

  @override
  String get subjectSaved => 'Materia salvata';

  @override
  String get subjectDeleted => 'Materia eliminata';

  @override
  String subjectDeleteConstraintWarning(int count) {
    return 'Questa materia è usata in $count vincolo/i che verranno anch\'essi eliminati.';
  }

  @override
  String get validationMinGtMax =>
      'Gli slot giornalieri minimi non possono essere maggiori di quelli massimi.';

  @override
  String validationMaxDaysInsufficient(int product, int target) {
    return 'Max giornaliero × giorni attivi ($product) è inferiore all\'obiettivo settimanale ($target).';
  }

  @override
  String validationWeeklyExceedsSlots(int target, int available) {
    return 'L\'obiettivo settimanale ($target) supera il totale degli slot di lezione disponibili ($available).';
  }

  @override
  String get validationWeeklyMustBePositive =>
      'L\'obiettivo settimanale deve essere maggiore di 0.';

  @override
  String validationMinDailyInfeasible(int target, int minDaily) {
    return 'L\'obiettivo settimanale ($target) non è raggiungibile con MinGiornaliero $minDaily — nessuna distribuzione giornaliera valida.';
  }

  @override
  String get feasibilityTitle => 'Analisi di fattibilità';

  @override
  String get feasibilitySlack => 'Margine';

  @override
  String get feasibilityInsufficient =>
      'Lezioni disponibili insufficienti — la generazione produrrà probabilmente un orario parziale.';

  @override
  String get feasibilityOk =>
      'Lezioni disponibili sufficienti per tutte le classi.';

  @override
  String get constraints => 'Vincoli';

  @override
  String get hardConstraints => 'Obbligatori';

  @override
  String get softConstraints => 'Preferenziali';

  @override
  String get addConstraint => 'Aggiungi vincolo';

  @override
  String get noConstraints => 'Nessun vincolo definito.';

  @override
  String get constraintDeleted => 'Vincolo eliminato';

  @override
  String get undoDelete => 'Annulla';

  @override
  String get mustAssign => 'DEVE ESSERE ASSEGNATO';

  @override
  String get mustNotAssign => 'NON DEVE ESSERE ASSEGNATO';

  @override
  String get avoidTimeslot => 'EVITA FASCIA ORARIA';

  @override
  String get preferBlock => 'PREFERISCI BLOCCO';

  @override
  String mustAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject deve essere assegnato a $classroom il $day alle $time.';
  }

  @override
  String mustNotAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject NON deve essere assegnato a $classroom il $day alle $time.';
  }

  @override
  String avoidTimeslotDescription(
      String subject, String day, String start, String end) {
    return '$subject dovrebbe essere evitato il $day tra le $start e le $end.';
  }

  @override
  String preferBlockDescription(String subject) {
    return '$subject dovrebbe essere programmato in slot consecutivi quando possibile.';
  }

  @override
  String get weightLow => 'Bassa';

  @override
  String get weightMedium => 'Media';

  @override
  String get weightHigh => 'Alta';

  @override
  String get conflictDetected => 'Conflitto tra vincoli rilevato';

  @override
  String get conflictMustAssignMustNot =>
      'DEVE ESSERE ASSEGNATO e NON DEVE ESSERE ASSEGNATO sulla stessa cella.';

  @override
  String get conflictMustAssignBreakSlot =>
      'Impossibile assegnare obbligatoriamente a una pausa.';

  @override
  String get conflictMustAssignTeacher =>
      'Due classi obbligate con lo stesso docente nello stesso momento.';

  @override
  String get conflictMustAssignMinDaily =>
      'Il vincolo DEVE ESSERE ASSEGNATO è in conflitto con il MinGiornaliero: un solo slot disponibile ma MinGiornaliero > 1.';

  @override
  String conflictSuggestion(String suggestion) {
    return 'Soluzione suggerita: $suggestion';
  }

  @override
  String get schedule => 'Orario';

  @override
  String get scheduleVersions => 'Versioni orario';

  @override
  String get newVersion => 'Nuova versione';

  @override
  String get versionName => 'Nome versione';

  @override
  String get versionNameHint => 'es. Definitivo Settembre 2026';

  @override
  String get manuallyEdited => 'Modificato manualmente';

  @override
  String get allClassrooms => 'Tutte le classi';

  @override
  String get singleClassroom => 'Singola classe';

  @override
  String get perTeacher => 'Per docente';

  @override
  String get exportPdf => 'Esporta PDF';

  @override
  String get exportExcel => 'Esporta Excel';

  @override
  String get export => 'Esporta';

  @override
  String get share => 'Condividi';

  @override
  String get exportSuccess => 'File condiviso con successo.';

  @override
  String get trialBannerRemaining =>
      'Versione di prova: 1 generazione gratuita disponibile. Abbonati per accesso illimitato.';

  @override
  String get trialBannerUsed =>
      'Prova utilizzata. Abbonati per generare nuovi orari.';

  @override
  String get subscribe => 'Abbonati';

  @override
  String get subscribeTitle => 'Sblocca ClassScheduler';

  @override
  String get subscribeDescription =>
      'Genera orari illimitati per tutte le tue scuole.';

  @override
  String get subscribePrice => '€14,99 / anno';

  @override
  String get subscribeButton => 'Abbonati ora';

  @override
  String get restorePurchases => 'Ripristina acquisti';

  @override
  String get purchaseRestored => 'Acquisto ripristinato con successo.';

  @override
  String get purchaseFailed => 'Acquisto non riuscito. Riprova.';

  @override
  String get alreadySubscribed => 'Hai già un abbonamento attivo.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get language => 'Lingua';

  @override
  String get theme => 'Aspetto';

  @override
  String get themeDark => 'Scuro';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get account => 'Account';

  @override
  String get premiumComingSoon => 'Premium';

  @override
  String get premiumComingSoonTitle => 'Prossimamente';

  @override
  String get premiumComingSoonMessage =>
      'ClassScheduler è gratis per ora. Stiamo valutando l\'interesse per un piano a pagamento — grazie per averci fatto sapere che ti interessa!';

  @override
  String get signOut => 'Esci';

  @override
  String get deleteAccount => 'Elimina account';

  @override
  String get deleteAccountConfirm =>
      'Sei sicuro? Questa azione eliminerà definitivamente il tuo account e tutti i dati. Non è reversibile.';

  @override
  String get deleteAccountSuccess => 'Account eliminato.';

  @override
  String get privacyPolicy => 'Informativa sulla privacy';

  @override
  String get termsOfService => 'Termini di servizio';

  @override
  String appVersion(String version) {
    return 'Versione $version';
  }

  @override
  String get loginTitle => 'Bentornato';

  @override
  String get loginSubtitle => 'Accedi a ClassScheduler';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Accedi';

  @override
  String get signInWithGoogle => 'Continua con Google';

  @override
  String get signInWithApple => 'Continua con Apple';

  @override
  String get noAccount => 'Non hai un account?';

  @override
  String get createAccount => 'Crea account';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get forgotPasswordTitle => 'Reimposta password';

  @override
  String get forgotPasswordSubtitle =>
      'Inserisci la tua email e ti invieremo un link di reimpostazione.';

  @override
  String get sendResetLink => 'Invia link di reimpostazione';

  @override
  String get resetLinkSent => 'Link inviato. Controlla la tua email.';

  @override
  String get registerTitle => 'Crea account';

  @override
  String get registerSubtitle => 'Inizia a creare orari in pochi minuti.';

  @override
  String get confirmPassword => 'Conferma password';

  @override
  String get passwordMismatch => 'Le password non corrispondono.';

  @override
  String get alreadyHaveAccount => 'Hai già un account?';

  @override
  String get save => 'Salva';

  @override
  String get cancel => 'Annulla';

  @override
  String get confirm => 'Conferma';

  @override
  String get delete => 'Elimina';

  @override
  String get edit => 'Modifica';

  @override
  String get done => 'Fatto';

  @override
  String get next => 'Avanti';

  @override
  String get back => 'Indietro';

  @override
  String get close => 'Chiudi';

  @override
  String get retry => 'Riprova';

  @override
  String get ok => 'OK';

  @override
  String get errorGeneric => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorNetwork => 'Nessuna connessione a Internet.';

  @override
  String get errorOfflineGeneration =>
      'Orario salvato localmente — sincronizzazione in attesa di connessione.';

  @override
  String get errorRequiresReauth => 'Accedi nuovamente per continuare.';

  @override
  String get monday => 'Lunedì';

  @override
  String get tuesday => 'Martedì';

  @override
  String get wednesday => 'Mercoledì';

  @override
  String get thursday => 'Giovedì';

  @override
  String get friday => 'Venerdì';

  @override
  String get saturday => 'Sabato';

  @override
  String get sunday => 'Domenica';

  @override
  String get monShort => 'Lun';

  @override
  String get tueShort => 'Mar';

  @override
  String get wedShort => 'Mer';

  @override
  String get thuShort => 'Gio';

  @override
  String get friShort => 'Ven';

  @override
  String get satShort => 'Sab';

  @override
  String get sunShort => 'Dom';

  @override
  String get cancelled => 'Annullato';

  @override
  String get deleteSchedule => 'Elimina orario';

  @override
  String deleteScheduleConfirm(String name) {
    return 'Eliminare \"$name\"? Questa operazione non può essere annullata.';
  }

  @override
  String get generateToSeeSchedule =>
      'Premi Genera per creare il tuo primo orario.';

  @override
  String hardViolationsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vincoli rigidi non soddisfatti',
      one: '1 vincolo rigido non soddisfatto',
    );
    return '$_temp0';
  }

  @override
  String get noScheduleYet => 'Nessun orario';

  @override
  String get rename => 'Rinomina';

  @override
  String get restartsUsed => 'Riavvii';

  @override
  String scheduleDeleted(String name) {
    return '\"$name\" eliminato.';
  }

  @override
  String get scheduleVersionName => 'Nome orario';

  @override
  String get showLess => 'Mostra meno';

  @override
  String showMore(int count) {
    return 'Mostra altri $count';
  }

  @override
  String softViolationsHeading(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count vincoli morbidi non completamente soddisfatti',
      one: '1 vincolo morbido non completamente soddisfatto',
    );
    return '$_temp0';
  }

  @override
  String get undo => 'Annulla';

  @override
  String get viewAllClassrooms => 'Tutte le classi';

  @override
  String get viewPerTeacher => 'Per insegnante';

  @override
  String get viewSingleClassroom => 'Singola classe';

  @override
  String get exportSchedule => 'Esporta orario';

  @override
  String get exportFormat => 'Formato';

  @override
  String get exportAsPdf => 'Esporta come PDF';

  @override
  String get exportAsExcel => 'Esporta come Excel';

  @override
  String get exportPdfSubtitle => 'Pagine A4, una per classe';

  @override
  String get exportExcelSubtitle => '.xlsx con codifica colori';

  @override
  String get exportIncludeOverview => 'Includi pagina di riepilogo';

  @override
  String get exportLoading => 'Caricamento dati…';

  @override
  String get exportGenerating => 'Generazione file…';

  @override
  String get exportSharing => 'Apertura condivisione…';

  @override
  String get subscription => 'Abbonamento';

  @override
  String get subscriptionHeadline => 'Sblocca orari illimitati';

  @override
  String get subscriptionSubtitle =>
      'Genera tutti gli orari di cui hai bisogno, tutto l\'anno.';

  @override
  String get subscriptionActive => 'Abbonamento attivo';

  @override
  String get subscriptionActiveSubtitle =>
      'Il tuo abbonamento è attivo. Generazione illimitata.';

  @override
  String get subscriptionPriceLabel => 'PIANO ANNUALE';

  @override
  String get subscriptionPrice => '€14,99';

  @override
  String get subscriptionPriceSuffix => 'all\'anno · fatturazione annuale';

  @override
  String get subscriptionOfflineGrace =>
      'Sei offline. Il tuo abbonamento è valido per 30 giorni senza connessione.';

  @override
  String get subscriptionLegalNote =>
      'Il pagamento verrà addebitato al tuo account App Store / Play Store alla conferma dell\'acquisto. L\'abbonamento si rinnova automaticamente salvo cancellazione almeno 24 ore prima della fine del periodo corrente.';

  @override
  String get subscribeNow => 'Abbonati ora';

  @override
  String get subscribeForUnlimited => 'Abbonati per accesso illimitato';

  @override
  String get noPurchasesToRestore => 'Nessun acquisto da ripristinare.';

  @override
  String get featureUnlimitedGeneration => 'Generazione orari illimitata';

  @override
  String get featurePdfExcel => 'Esportazione PDF ed Excel';

  @override
  String get featureManualEditing => 'Modifica manuale con trascinamento';

  @override
  String get featureCloudSync =>
      'Sincronizzazione cloud su tutti i dispositivi';

  @override
  String get featureMultipleSchools => 'Più scuole per account';

  @override
  String get manage => 'Gestisci';

  @override
  String get collapse => 'Comprimi';

  @override
  String switchedToSet(String name) {
    return 'Passato a \"$name\".';
  }

  @override
  String get apply => 'Applica';

  @override
  String get logOut => 'Esci';

  @override
  String get changeAction => 'Cambia';

  @override
  String get orSeparator => 'oppure';

  @override
  String get templatesTitle => 'Modelli';

  @override
  String get builtInTemplates => 'Predefiniti';

  @override
  String get myTemplates => 'I miei modelli';

  @override
  String get saveAsTemplate => 'Salva come modello';

  @override
  String get savePeriodsAsTemplate => 'Salva le ore come modello';

  @override
  String get templateNameLabel => 'Nome del modello';

  @override
  String get templateNameHint => 'es. Il mio orario scolastico';

  @override
  String get renameTemplate => 'Rinomina modello';

  @override
  String get deleteTemplate => 'Elimina modello';

  @override
  String get templateSaved => 'Modello salvato.';

  @override
  String get tapTimeFieldsHint =>
      'Tocca i campi dell\'orario per usare il selettore.';

  @override
  String get breakNameHint => 'es. Ricreazione';

  @override
  String get priorityLabel => 'Priorità';

  @override
  String get ruleLabel => 'Regola';

  @override
  String get slotLabel => 'Fascia oraria';

  @override
  String get dayFieldLabel => 'Giorno';

  @override
  String get dailyLimitLabel => 'Limite giornaliero';

  @override
  String get constraintTypeLabel => 'Tipo di vincolo';

  @override
  String get allDaysOption => 'Tutti i giorni';

  @override
  String get anyDayOption => 'Qualsiasi giorno';

  @override
  String get anyClassroomOption => 'Qualsiasi aula';

  @override
  String get noMaximumFullDay => 'Nessun massimo (fino a un giorno intero)';

  @override
  String get hardDailyLimitTag => 'HARD · LIMITE GIORNALIERO';

  @override
  String get constraintSetsTitle => 'Set di vincoli';

  @override
  String get saveCurrentEllipsis => 'Salva quelli attuali…';

  @override
  String get saveCurrentConstraints => 'Salva i vincoli attuali';

  @override
  String get updateWithCurrentConstraints => 'Aggiorna con i vincoli attuali';

  @override
  String get setNameHint => 'Nome del set';

  @override
  String get switchAction => 'Passa';

  @override
  String get deleteConstraintSet => 'Elimina set di vincoli';

  @override
  String get noSavedSetsYet => 'Nessun set salvato.';

  @override
  String switchToSetConfirm(String name) {
    return 'Passare a \"$name\"?';
  }

  @override
  String deleteSetConfirm(String name) {
    return 'Eliminare \"$name\"? L\'azione è irreversibile.';
  }

  @override
  String get noSchoolsYet => 'Nessuna scuola.';

  @override
  String get goToSchoolsTab =>
      'Vai alla scheda Scuole per creare la tua prima scuola.';

  @override
  String get addFirstSchoolToStart =>
      'Aggiungi la tua prima scuola per iniziare.';

  @override
  String get selectSchoolForConstraints => 'Seleziona una scuola per i vincoli';

  @override
  String get selectSchoolForSchedule => 'Seleziona una scuola per l\'orario';

  @override
  String get selectSchoolToSetUp => 'Seleziona una scuola da configurare';

  @override
  String get lastRunLabel => 'Ultima generazione';

  @override
  String get editSetup => 'Modifica configurazione';

  @override
  String get statusReady => 'Pronta';

  @override
  String get statusFixNeeded => 'Da sistemare';

  @override
  String get teacherLabel => 'Insegnante';

  @override
  String get classColumnLabel => 'Classe';

  @override
  String get timeColumnLabel => 'Orario';

  @override
  String get neededColumnLabel => 'Necessarie';

  @override
  String get availableColumnLabel => 'Disponibili';

  @override
  String notTaughtInClose(String classroom) {
    return 'Non insegnata in $classroom — chiudi';
  }

  @override
  String scheduleNameExists(String name) {
    return 'Esiste già un orario con il nome \"$name\". Scegli un nome diverso.';
  }

  @override
  String deleteClassroomConfirm(String name) {
    return 'Eliminare \"$name\"?';
  }

  @override
  String errorWithMessage(String message) {
    return 'Errore: $message';
  }

  @override
  String get appearanceSection => 'Aspetto';

  @override
  String get supportSection => 'Assistenza';

  @override
  String get contactSupport => 'Contatta l\'assistenza';

  @override
  String get sendFeedback => 'Invia feedback';

  @override
  String feedbackEmailSubject(String version) {
    return 'Feedback ClassScheduler (v$version)';
  }

  @override
  String feedbackEmailBody(String version, String platform) {
    return 'Descrivi qui il problema o il suggerimento:\n\n\n---\nVersione app: $version\nPiattaforma: $platform';
  }

  @override
  String get selectLanguage => 'Seleziona la lingua';

  @override
  String get actionCannotBeUndone => 'Questa azione non può essere annullata.';

  @override
  String scheduleCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'orari',
      one: 'orario',
    );
    return '$_temp0';
  }

  @override
  String get viewPerClassroom => 'Per classe';

  @override
  String get lessonLabel => 'Lezione';

  @override
  String get breakLabel => 'Pausa';

  @override
  String overlapsWith(String name) {
    return 'Si sovrappone a $name';
  }

  @override
  String get weeklyTargetHelp =>
      'Numero di ore di lezione a settimana. Deve essere almeno 1.';

  @override
  String get dayShortMon => 'Lun';

  @override
  String get dayShortTue => 'Mar';

  @override
  String get dayShortWed => 'Mer';

  @override
  String get dayShortThu => 'Gio';

  @override
  String get dayShortFri => 'Ven';

  @override
  String get dayShortSat => 'Sab';

  @override
  String get dayShortSun => 'Dom';

  @override
  String get dayLongMon => 'Lunedì';

  @override
  String get dayLongTue => 'Martedì';

  @override
  String get dayLongWed => 'Mercoledì';

  @override
  String get dayLongThu => 'Giovedì';

  @override
  String get dayLongFri => 'Venerdì';

  @override
  String get dayLongSat => 'Sabato';

  @override
  String get dayLongSun => 'Domenica';

  @override
  String get exportSummary => 'Riepilogo';

  @override
  String get exportCombinedOverview => 'Prospetto riepilogativo';

  @override
  String get exportGeneratedLabel => 'Generato';

  @override
  String get exportTimeHeader => 'Orario';

  @override
  String get exportStatusHeader => 'Stato';

  @override
  String get exportViolationsHeader => 'Violazioni';

  @override
  String get exportTeacherWeeklyHours => 'Ore settimanali docenti';

  @override
  String exportSlotsAssigned(int count) {
    return '$count slot assegnati';
  }

  @override
  String exportViolationsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count violazioni',
      one: '1 violazione',
    );
    return '$_temp0';
  }

  @override
  String get exportStatusPerfect => 'Perfetto';

  @override
  String get exportStatusSoft => 'Violazioni preferenziali';

  @override
  String get exportStatusHard => 'Violazioni obbligatorie';

  @override
  String get clAnyDay => 'qualsiasi giorno';

  @override
  String clInClassroom(String classroom) {
    return ' in $classroom';
  }

  @override
  String clMustAssign(
      Object subject, Object classroom, Object day, Object time) {
    return '$subject deve essere programmata in $classroom — $day, $time.';
  }

  @override
  String clMustNotAssign(
      Object subject, Object classroom, Object day, Object time) {
    return '$subject NON deve essere programmata in $classroom — $day, $time.';
  }

  @override
  String clAvoidTimeslotDay(
      Object subject, Object scope, Object day, Object start, Object end) {
    return '$subject$scope andrebbe evitata il $day tra le $start e le $end.';
  }

  @override
  String clAvoidTimeslotNoDay(
      Object subject, Object scope, Object start, Object end) {
    return '$subject$scope andrebbe evitata tra le $start e le $end.';
  }

  @override
  String clPreferBlock(Object subject, Object scope, Object detail) {
    return '$subject$scope andrebbe programmata in slot consecutivi quando possibile$detail.';
  }

  @override
  String clDailyLimitRange(
      Object subject, Object classroom, Object min, Object max) {
    return '$subject in $classroom dovrebbe restare tra $min e $max ore al giorno.';
  }

  @override
  String clDailyLimitMax(Object subject, Object classroom, Object max) {
    return '$subject in $classroom dovrebbe restare sotto le $max ore al giorno.';
  }

  @override
  String clDailyLimitMin(Object subject, Object classroom, Object min) {
    return '$subject in $classroom dovrebbe raggiungere almeno $min ore nei giorni in cui è programmata.';
  }

  @override
  String clDailyLimitGeneric(Object subject, Object classroom) {
    return '$subject in $classroom ha una preferenza sulle ore giornaliere.';
  }

  @override
  String clSubtitleSoft(String weight) {
    return 'Preferenziale · Priorità: $weight';
  }

  @override
  String get clSubtitleHard => 'Vincolo obbligatorio';

  @override
  String clUnknownType(String type) {
    return 'Tipo di vincolo sconosciuto: $type';
  }

  @override
  String get unknownSubject => 'Materia sconosciuta';

  @override
  String get unknownClass => 'Classe sconosciuta';

  @override
  String get assignSubjectEditHint =>
      'Imposta il numero di ore settimanali per questa classe. Per rimuovere la materia da questa classe, tocca \"Rimuovi assegnazione\" qui sotto.';

  @override
  String assignSubjectNewHint(String classroom) {
    return 'Assegna solo se questa materia viene effettivamente insegnata in $classroom. Se non viene insegnata qui, chiudi semplicemente questo pannello — lasciarla non assegnata è corretto.';
  }

  @override
  String get builtInTemplate5NoBreak => '5 × 1h (senza pause)';

  @override
  String get builtInTemplate5MorningBreak => '5 × 1h + ricreazione';

  @override
  String get builtInTemplate8 => '8 × 1h + ricreazione + pausa pranzo';

  @override
  String get breakMorning => 'Ricreazione';

  @override
  String get breakLunch => 'Pausa pranzo';

  @override
  String get noHardConstraintsYet => 'Nessun vincolo obbligatorio.';

  @override
  String get noPreferencesYet => 'Nessuna preferenza impostata.';

  @override
  String get hardConstraintsEmptyHint =>
      'I vincoli obbligatori impongono o vietano\nassegnazioni in slot specifici.';

  @override
  String get preferencesEmptyHint =>
      'Le preferenze guidano il generatore\nma non bloccano mai una soluzione.';

  @override
  String get selectSubjectHint => 'Seleziona la materia';

  @override
  String get selectClassroomHint => 'Seleziona la classe';

  @override
  String get selectSubjectFirst => 'Seleziona prima una materia';

  @override
  String get notAssignedToClassroomYet =>
      'Non ancora assegnata a nessuna classe';

  @override
  String get notAvailable => 'Non disponibile';

  @override
  String get clearAction => 'Cancella';

  @override
  String get moveNotAllowed => 'Spostamento non consentito';

  @override
  String get noOptionsAvailable => 'Nessuna opzione disponibile';

  @override
  String get errSelectSubject => 'Seleziona una materia.';

  @override
  String get errSelectClassroom => 'Seleziona una classe.';

  @override
  String get errSelectDay => 'Seleziona un giorno.';

  @override
  String get errSelectSlot => 'Seleziona una fascia oraria.';

  @override
  String get errSelectStartSlot => 'Seleziona la fascia oraria iniziale.';

  @override
  String get errSelectEndSlot => 'Seleziona la fascia oraria finale.';

  @override
  String get errMinGtMaxDaily =>
      'Le ore giornaliere minime non possono superare le massime.';

  @override
  String get slotUnavailableForClassroomDay =>
      'Non disponibile per questa classe in questo giorno.';

  @override
  String get slotTeacherBusy =>
      'Insegnante già assegnato altrove in questo orario.';

  @override
  String get slotPickerHint =>
      'Tocca una fascia per selezionarla, toccane un\'altra per selezionare un intervallo.';

  @override
  String get subjectNotAssignedYet =>
      'Questa materia non è ancora assegnata a nessuna classe.';

  @override
  String get subjectNotAssignedYetLong =>
      'Questa materia non è ancora assegnata a nessuna classe. Assegnala prima in Configurazione → Materie.';

  @override
  String get minDailyHoursHint =>
      'Vale solo nei giorni in cui la materia è effettivamente programmata — un giorno senza lezioni è comunque ammesso. 0 disattiva il minimo.';

  @override
  String get ruleMust => 'Deve';

  @override
  String get rulePrefer => 'Preferisci';

  @override
  String get ruleMustNot => 'Non deve';

  @override
  String get ruleAvoid => 'Evita';

  @override
  String get ruleMustDescHard =>
      'Forza una materia in uno slot specifico di una classe.';

  @override
  String get ruleMustDescSoft =>
      'Favorisce lezioni consecutive per una materia, eventualmente limitate a un intervallo di giorni/orari.';

  @override
  String get ruleMustNotDescHard =>
      'Impedisce a una materia di stare in uno slot specifico di una classe.';

  @override
  String get ruleMustNotDescSoft =>
      'Sconsiglia una materia in un dato intervallo orario.';

  @override
  String get dailyLimitDescHard =>
      'Richiede un numero minimo e/o massimo di ore giornaliere per una materia — blocca la generazione se non rispettato.';

  @override
  String get dailyLimitDescSoft =>
      'Preferisce un numero minimo e/o massimo di ore giornaliere per una materia — un\'indicazione, non blocca mai la generazione.';

  @override
  String switchSetWarning(String name, int hard, int soft) {
    return 'Sostituisce ogni vincolo attuale e i limiti giornalieri HARD con quanto salvato in \"$name\" ($hard hard · $soft soft). Ciò che non è salvato altrove andrà perso.';
  }
}
