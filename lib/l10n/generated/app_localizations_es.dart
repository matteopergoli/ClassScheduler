// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'ClassScheduler';

  @override
  String get goodMorning => 'Buenos días 👋';

  @override
  String get yourSchools => 'Tus centros';

  @override
  String yourSchoolsCount(int count) {
    return 'Tus centros ($count)';
  }

  @override
  String get addSchool => 'Añadir centro';

  @override
  String get newSchool => 'Nuevo centro';

  @override
  String get schoolName => 'Nombre del centro';

  @override
  String get schoolDescription => 'Descripción (opcional)';

  @override
  String get schoolCreated => 'Centro creado';

  @override
  String get schoolUpdated => 'Centro actualizado';

  @override
  String get schoolDeleted => 'Centro eliminado';

  @override
  String get renameSchool => 'Renombrar';

  @override
  String get duplicateSchool => 'Duplicar';

  @override
  String get deleteSchool => 'Eliminar';

  @override
  String deleteSchoolConfirm(String name) {
    return '¿Eliminar \"$name\"? Se eliminarán permanentemente todas las aulas, materias, restricciones y horarios.';
  }

  @override
  String classCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count clases',
      one: '1 clase',
    );
    return '$_temp0';
  }

  @override
  String teacherCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count profesores',
      one: '1 profesor',
    );
    return '$_temp0';
  }

  @override
  String get lastGenerated => 'Última generación';

  @override
  String lastGeneratedDate(String date) {
    return 'Última ejecución: $date';
  }

  @override
  String get neverGenerated => 'Nunca';

  @override
  String get generate => 'Generar';

  @override
  String get reGenerate => 'Regenerar';

  @override
  String get generating => 'Generando…';

  @override
  String get cancelGeneration => 'Cancelar';

  @override
  String get generationComplete => 'Generación completada';

  @override
  String get generationCancelled =>
      'Generación cancelada — se muestra el mejor resultado';

  @override
  String get qualityScore => 'Puntuación de calidad';

  @override
  String get qualityExcellent => 'Excelente';

  @override
  String get qualityGood => 'Bueno';

  @override
  String get qualityFair => 'Regular';

  @override
  String get qualityPoor => 'Deficiente';

  @override
  String get qualityTooltip =>
      'Una puntuación más alta indica menos horas libres para profesores y menos cambios de materia al día.';

  @override
  String get resultPerfect =>
      'Horario generado. Todas las restricciones satisfechas.';

  @override
  String resultSoftViolations(int count) {
    return 'Horario generado. $count restricción/es preferente/s no se han podido satisfacer completamente.';
  }

  @override
  String resultHardViolations(int count) {
    return 'Se muestra el mejor horario parcial. $count restricción/es obligatoria/s no satisfecha/s — celdas afectadas resaltadas en rojo.';
  }

  @override
  String get teacherFreeHours => 'Horas libres del profesorado';

  @override
  String get subjectChanges => 'Cambios de materia';

  @override
  String get computationTime => 'Tiempo de cálculo';

  @override
  String get iterationsCompleted => 'Iteraciones completadas';

  @override
  String get navSchools => 'Centros';

  @override
  String get navSetup => 'Configuración';

  @override
  String get navConstraints => 'Restricciones';

  @override
  String get navSchedule => 'Horario';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get setupTitle => 'Configuración';

  @override
  String get step1Title => 'Días y períodos';

  @override
  String get step2Title => 'Aulas';

  @override
  String get step3Title => 'Capacidad diaria';

  @override
  String get step4Title => 'Materias';

  @override
  String get step1Description =>
      'Selecciona los días lectivos activos y define los períodos de clase y descanso.';

  @override
  String get step2Description => 'Añade y nombra las aulas (máximo 10).';

  @override
  String get step3Description =>
      'Establece el número máximo de clases por aula y día.';

  @override
  String get step4Description =>
      'Define las materias, asígnalas a las aulas y establece los objetivos semanales.';

  @override
  String get activeDays => 'Días lectivos activos';

  @override
  String get periods => 'Períodos';

  @override
  String get addPeriod => 'Añadir período';

  @override
  String get lessonSlot => 'Hora de clase';

  @override
  String get breakSlot => 'Descanso';

  @override
  String get step3ApplyToAllDays => 'Aplicar a todos los días';

  @override
  String get breakName => 'Nombre del descanso';

  @override
  String get startTime => 'Inicio';

  @override
  String get endTime => 'Fin';

  @override
  String get useTemplate => 'Usar plantilla';

  @override
  String get periodSaved => 'Período guardado';

  @override
  String get periodDeleted => 'Período eliminado';

  @override
  String get classrooms => 'Aulas';

  @override
  String get addClassroom => 'Añadir aula';

  @override
  String get classroomName => 'Nombre del aula (ej. 1A, Año 5 Azul)';

  @override
  String get classroomRenamed => 'Aula renombrada';

  @override
  String get classroomDeleted => 'Aula eliminada';

  @override
  String classroomDeleteConstraintWarning(int count) {
    return 'Esta aula está referenciada en $count restricción/es que también se eliminarán.';
  }

  @override
  String get maxClassroomsReached => 'Se ha alcanzado el máximo de 10 aulas.';

  @override
  String get dailyCapacity => 'Capacidad diaria';

  @override
  String get maxLessonsPerDay => 'Máx. clases por día';

  @override
  String get subjects => 'Materias';

  @override
  String get addSubject => 'Añadir materia';

  @override
  String get subjectName => 'Nombre de la materia';

  @override
  String get teacherName => 'Nombre del profesor';

  @override
  String get teacherNameOptional => 'Teacher name (optional)';

  @override
  String get colour => 'Color';

  @override
  String get weeklyTarget => 'Objetivo semanal (slots)';

  @override
  String get minDailyHours => 'Mín. slots diarios (0 = desactivado)';

  @override
  String get maxDailyHours => 'Máx. slots diarios';

  @override
  String get assignToClassroom => 'Asignar al aula';

  @override
  String get unassignSubject => 'Desasignar';

  @override
  String get subjectSaved => 'Materia guardada';

  @override
  String get subjectDeleted => 'Materia eliminada';

  @override
  String subjectDeleteConstraintWarning(int count) {
    return 'Esta materia se usa en $count restricción/es que también se eliminarán.';
  }

  @override
  String get validationMinGtMax =>
      'Los slots diarios mínimos no pueden ser mayores que los máximos.';

  @override
  String validationMaxDaysInsufficient(int product, int target) {
    return 'Máx. diario × días activos ($product) es menor que el objetivo semanal ($target).';
  }

  @override
  String validationWeeklyExceedsSlots(int target, int available) {
    return 'El objetivo semanal ($target) supera los slots de clase disponibles ($available).';
  }

  @override
  String get validationWeeklyMustBePositive =>
      'El objetivo semanal debe ser mayor que 0.';

  @override
  String validationMinDailyInfeasible(int target, int minDaily) {
    return 'El objetivo semanal ($target) no se puede alcanzar con MínDiario $minDaily — no existe distribución diaria válida.';
  }

  @override
  String get feasibilityTitle => 'Análisis de viabilidad';

  @override
  String get feasibilitySlack => 'Margen';

  @override
  String get feasibilityInsufficient =>
      'Lecciones disponibles insuficientes — es probable que la generación produzca un horario parcial.';

  @override
  String get feasibilityOk =>
      'Suficientes lecciones disponibles para todas las clases.';

  @override
  String get constraints => 'Restricciones';

  @override
  String get hardConstraints => 'Obligatorias';

  @override
  String get softConstraints => 'Preferentes';

  @override
  String get addConstraint => 'Añadir restricción';

  @override
  String get noConstraints => 'No hay restricciones definidas.';

  @override
  String get constraintDeleted => 'Restricción eliminada';

  @override
  String get undoDelete => 'Deshacer';

  @override
  String get mustAssign => 'DEBE ASIGNARSE';

  @override
  String get mustNotAssign => 'NO DEBE ASIGNARSE';

  @override
  String get avoidTimeslot => 'EVITAR FRANJA HORARIA';

  @override
  String get preferBlock => 'PREFERIR BLOQUE';

  @override
  String mustAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject debe asignarse a $classroom el $day a las $time.';
  }

  @override
  String mustNotAssignDescription(
      String subject, String classroom, String day, String time) {
    return '$subject NO debe asignarse a $classroom el $day a las $time.';
  }

  @override
  String avoidTimeslotDescription(
      String subject, String day, String start, String end) {
    return '$subject debería evitarse el $day entre las $start y las $end.';
  }

  @override
  String preferBlockDescription(String subject) {
    return '$subject debería programarse en slots consecutivos cuando sea posible.';
  }

  @override
  String get weightLow => 'Baja';

  @override
  String get weightMedium => 'Media';

  @override
  String get weightHigh => 'Alta';

  @override
  String get conflictDetected => 'Conflicto de restricciones detectado';

  @override
  String get conflictMustAssignMustNot =>
      'DEBE ASIGNARSE y NO DEBE ASIGNARSE en la misma celda.';

  @override
  String get conflictMustAssignBreakSlot =>
      'No se puede asignar obligatoriamente a un período de descanso.';

  @override
  String get conflictMustAssignTeacher =>
      'Dos aulas obligadas con el mismo profesor al mismo tiempo.';

  @override
  String get conflictMustAssignMinDaily =>
      'El vincolo DEBE ASIGNARSE entra en conflicto con MínDiario.';

  @override
  String conflictSuggestion(String suggestion) {
    return 'Solución sugerida: $suggestion';
  }

  @override
  String get schedule => 'Horario';

  @override
  String get scheduleVersions => 'Versiones del horario';

  @override
  String get newVersion => 'Nueva versión';

  @override
  String get versionName => 'Nombre de versión';

  @override
  String get versionNameHint => 'ej. Definitivo Sept 2026';

  @override
  String get manuallyEdited => 'Editado manualmente';

  @override
  String get allClassrooms => 'Todas las aulas';

  @override
  String get singleClassroom => 'Aula individual';

  @override
  String get perTeacher => 'Por profesor';

  @override
  String get exportPdf => 'Exportar PDF';

  @override
  String get exportExcel => 'Exportar Excel';

  @override
  String get export => 'Exportar';

  @override
  String get share => 'Compartir';

  @override
  String get exportSuccess => 'Exportación lista';

  @override
  String get trialBannerRemaining =>
      'Versión de prueba: 1 generación gratuita disponible. Suscríbete para acceso ilimitado.';

  @override
  String get trialBannerUsed =>
      'Prueba utilizada. Suscríbete para generar nuevos horarios.';

  @override
  String get subscribe => 'Suscribirse';

  @override
  String get subscribeTitle => 'Desbloquear ClassScheduler';

  @override
  String get subscribeDescription =>
      'Genera horarios ilimitados para todos tus centros.';

  @override
  String get subscribePrice => '€14,99 / año';

  @override
  String get subscribeButton => 'Suscribirse ahora';

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get purchaseRestored => 'Compra restaurada con éxito.';

  @override
  String get purchaseFailed => 'Error en la compra. Inténtalo de nuevo.';

  @override
  String get alreadySubscribed => 'Ya tienes una suscripción activa.';

  @override
  String get settings => 'Ajustes';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Apariencia';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Predeterminado del sistema';

  @override
  String get account => 'Cuenta';

  @override
  String get premiumComingSoon => 'Premium';

  @override
  String get premiumComingSoonTitle => 'Coming soon';

  @override
  String get premiumComingSoonMessage =>
      'ClassScheduler is free for now. Were gauging interest in a paid plan — thanks for letting us know youre interested!';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get deleteAccount => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirm =>
      '¿Estás seguro? Esta acción eliminará permanentemente tu cuenta y todos los datos. No se puede deshacer.';

  @override
  String get deleteAccountSuccess => 'Cuenta eliminada.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String appVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get loginTitle => 'Bienvenido de nuevo';

  @override
  String get loginSubtitle => 'Inicia sesión en ClassScheduler';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get signIn => 'Iniciar sesión';

  @override
  String get signInWithGoogle => 'Continuar con Google';

  @override
  String get signInWithApple => 'Continuar con Apple';

  @override
  String get noAccount => '¿No tienes cuenta?';

  @override
  String get createAccount => 'Crear cuenta';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get forgotPasswordTitle => 'Restablecer contraseña';

  @override
  String get forgotPasswordSubtitle =>
      'Introduce tu correo y te enviaremos un enlace de restablecimiento.';

  @override
  String get sendResetLink => 'Enviar enlace';

  @override
  String get resetLinkSent => 'Enlace enviado. Revisa tu correo.';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerSubtitle => 'Empieza a crear horarios en minutos.';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get done => 'Hecho';

  @override
  String get next => 'Siguiente';

  @override
  String get back => 'Atrás';

  @override
  String get close => 'Cerrar';

  @override
  String get retry => 'Reintentar';

  @override
  String get ok => 'Aceptar';

  @override
  String get errorGeneric => 'Algo ha ido mal. Inténtalo de nuevo.';

  @override
  String get errorNetwork => 'Sin conexión a Internet.';

  @override
  String get errorOfflineGeneration =>
      'Horario guardado localmente — se sincronizará cuando haya conexión.';

  @override
  String get errorRequiresReauth => 'Inicia sesión de nuevo para continuar.';

  @override
  String get monday => 'Lunes';

  @override
  String get tuesday => 'Martes';

  @override
  String get wednesday => 'Miércoles';

  @override
  String get thursday => 'Jueves';

  @override
  String get friday => 'Viernes';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get monShort => 'Lun';

  @override
  String get tueShort => 'Mar';

  @override
  String get wedShort => 'Mié';

  @override
  String get thuShort => 'Jue';

  @override
  String get friShort => 'Vie';

  @override
  String get satShort => 'Sáb';

  @override
  String get sunShort => 'Dom';

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
  String get sendFeedback => 'Send feedback';

  @override
  String feedbackEmailSubject(String version) {
    return 'ClassScheduler feedback (v$version)';
  }

  @override
  String feedbackEmailBody(String version, String platform) {
    return 'Describe the problem or suggestion here:\n\n\n---\nApp version: $version\nPlatform: $platform';
  }

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
