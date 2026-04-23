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
