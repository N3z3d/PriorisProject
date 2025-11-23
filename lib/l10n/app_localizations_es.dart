// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Prioris';

  @override
  String get home => 'Inicio';

  @override
  String get habits => 'Hábitos';

  @override
  String get tasks => 'Tareas';

  @override
  String get lists => 'Listas';

  @override
  String get habitFormTitleNew => 'Nuevo hábito';

  @override
  String get habitFormTitleEdit => 'Editar hábito';

  @override
  String get habitFormIntro =>
      'Ponle a este hábito un nombre claro, asigna una categoría y elige cómo seguirás tu progreso.';

  @override
  String get habitFormNameLabel => 'Nombre del hábito';

  @override
  String get habitFormNameHint => 'Ej.: Beber 8 vasos de agua';

  @override
  String get habitFormCategoryLabel => 'Categoría (opcional)';

  @override
  String get habitFormCategoryHint => 'Seleccionar una categoría';

  @override
  String get habitFormCategoryNone => 'Sin categoría';

  @override
  String get habitFormCategoryCreate => '+ Crear una nueva categoría…';

  @override
  String get habitFormQuantTargetLabel => 'Objetivo';

  @override
  String get habitFormQuantTargetHint => '8';

  @override
  String get habitFormQuantUnitLabel => 'Unidad';

  @override
  String get habitFormQuantUnitHint => 'vasos';

  @override
  String get habitTrackingTitle => '¿Cómo quieres seguir este hábito?';

  @override
  String get habitTrackingTip =>
      'Consejo: pon 1 si una vez por período es suficiente (equivale a \"hecho / no hecho\").';

  @override
  String get habitTrackingPrefix => 'Quiero hacer este hábito';

  @override
  String get habitTrackingTimesWord => 'veces';

  @override
  String get habitTrackingEveryWord => 'cada';

  @override
  String get habitTrackingBackToPeriod => 'Volver al modo \"por período\"';

  @override
  String get habitTrackingPeriodDay => 'al día';

  @override
  String get habitTrackingPeriodWeek => 'a la semana';

  @override
  String get habitTrackingPeriodMonth => 'al mes';

  @override
  String get habitTrackingPeriodYear => 'al año';

  @override
  String get habitTrackingCustomInterval => 'cada...';

  @override
  String get habitTrackingUnitHours => 'horas';

  @override
  String get habitTrackingUnitDays => 'días';

  @override
  String get habitTrackingUnitWeeks => 'semanas';

  @override
  String get habitTrackingUnitMonths => 'meses';

  @override
  String get habitSummaryTitle => 'Resumen';

  @override
  String get habitSummaryPlaceholder =>
      'Completa el nombre y la frecuencia para ver el resumen.';

  @override
  String habitSummaryAction(Object name) {
    return 'Quieres $name';
  }

  @override
  String habitSummaryTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '$count vez',
    );
    return '$_temp0';
  }

  @override
  String listItemDateLabel(String date) {
    return 'Añadido el $date';
  }

  @override
  String get listItemDateUnknown => 'Sin fecha';

  @override
  String get listItemActionComplete => 'Completar';

  @override
  String get listItemActionReopen => 'Reabrir';

  @override
  String get listEditTooltip => 'Editar lista';

  @override
  String get listDeleteTooltip => 'Eliminar lista';

  @override
  String get listEditDialogTitle => 'Editar lista';

  @override
  String get listEditNameLabel => 'Nombre de la lista';

  @override
  String get listEditSaved => 'Lista actualizada.';

  @override
  String get habitFormTypePrompt => 'Quiero seguir este hábito';

  @override
  String get habitFormTypeBinaryOption => 'marcándolo cuando esté hecho';

  @override
  String get habitFormTypeQuantOption => 'registrando la cantidad realizada';

  @override
  String get habitFormTypeBinaryDescription =>
      'Perfecto para hábitos de sí/no: márcalo cada vez que lo completes.';

  @override
  String get habitFormTypeQuantDescription =>
      'Controla una cantidad medible con una meta numérica y una unidad personalizada.';

  @override
  String get habitRecurrenceDaily => 'Diaria';

  @override
  String get habitRecurrenceWeekly => 'Semanal';

  @override
  String get habitRecurrenceMonthly => 'Mensual';

  @override
  String get habitRecurrenceTimesPerWeek => 'Varias veces por semana';

  @override
  String get habitRecurrenceTimesPerDay => 'Varias veces al día';

  @override
  String get habitRecurrenceMonthlyDay => 'Día específico del mes';

  @override
  String get habitRecurrenceQuarterly => 'Trimestral';

  @override
  String get habitRecurrenceYearly => 'Anual';

  @override
  String get habitRecurrenceHourlyInterval => 'Cada X horas';

  @override
  String get habitRecurrenceTimesPerHour => 'Varias veces por hora';

  @override
  String get habitRecurrenceWeekends => 'Fines de semana';

  @override
  String get habitRecurrenceWeekdays => 'Días laborables';

  @override
  String get habitRecurrenceEveryXDays => 'Cada X días';

  @override
  String get habitRecurrenceSpecificWeekdays => 'Días específicos de la semana';

  @override
  String get habitFormSubmitCreate => 'Crear hábito';

  @override
  String get habitFormValidationNameRequired =>
      'Introduce un nombre para el hábito';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get prioritize => 'Priorizar';

  @override
  String get addHabit => 'Agregar hábito';

  @override
  String get addTask => 'Agregar tarea';

  @override
  String get addList => 'Agregar lista';

  @override
  String get name => 'Nombre';

  @override
  String get description => 'Descripción';

  @override
  String get category => 'Categoría';

  @override
  String get priority => 'Prioridad';

  @override
  String get frequency => 'Frecuencia';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get create => 'Crear';

  @override
  String get completed => 'Completado';

  @override
  String get incomplete => 'Incompleto';

  @override
  String get hideCompleted => 'Ocultar completados';

  @override
  String get showCompleted => 'Mostrar completados';

  @override
  String get hideEloScores => 'Ocultar puntuaciones ELO';

  @override
  String get showEloScores => 'Mostrar puntuaciones ELO';

  @override
  String get overview => 'Resumen';

  @override
  String get habitsTab => 'Hábitos';

  @override
  String get tasksTab => 'Tareas';

  @override
  String get totalPoints => 'Puntos totales';

  @override
  String get successRate => 'Tasa de éxito';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String get longestStreak => 'Racha más larga';

  @override
  String get language => 'Idioma';

  @override
  String get settings => 'Configuración';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get confirm => 'Confirmar';

  @override
  String get back => 'Atrás';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get clear => 'Limpiar';

  @override
  String get apply => 'Aplicar';

  @override
  String get reset => 'Restablecer';

  @override
  String get close => 'Cerrar';

  @override
  String get open => 'Abrir';

  @override
  String get refresh => 'Actualizar';

  @override
  String get export => 'Exportar';

  @override
  String get import => 'Importar';

  @override
  String get share => 'Compartir';

  @override
  String get copy => 'Copiar';

  @override
  String get paste => 'Pegar';

  @override
  String get cut => 'Cortar';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Rehacer';

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get deselectAll => 'Deseleccionar todo';

  @override
  String get select => 'Seleccionar';

  @override
  String get deselect => 'Deseleccionar';

  @override
  String get all => 'Todo';

  @override
  String get none => 'Ninguno';

  @override
  String get today => 'Hoy';

  @override
  String get yesterday => 'Ayer';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get thisWeek => 'Esta semana';

  @override
  String get lastWeek => 'Semana pasada';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get lastMonth => 'Mes pasado';

  @override
  String get thisYear => 'Este año';

  @override
  String get lastYear => 'Año pasado';

  @override
  String get days => 'días';

  @override
  String get hours => 'horas';

  @override
  String get minutes => 'minutos';

  @override
  String get seconds => 'segundos';

  @override
  String get points => 'puntos';

  @override
  String get items => 'elementos';

  @override
  String get tasksCompleted => 'tareas completadas';

  @override
  String get habitsCompleted => 'hábitos completados';

  @override
  String get listsCompleted => 'listas completadas';

  @override
  String listCompletionLabel(int completed, int total) {
    return '$completed de $total elementos completados';
  }

  @override
  String listCompletionProgress(String percent) {
    return '$percent% completado';
  }

  @override
  String get progress => 'Progreso';

  @override
  String get performance => 'Rendimiento';

  @override
  String get analytics => 'Análisis';

  @override
  String get insights => 'Perspectivas';

  @override
  String get recommendations => 'Recomendaciones';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get tips => 'Consejos';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get developer => 'Desarrollador';

  @override
  String get contact => 'Contacto';

  @override
  String get feedback => 'Comentarios';

  @override
  String get reportBug => 'Reportar error';

  @override
  String get requestFeature => 'Solicitar función';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get license => 'Licencia';

  @override
  String get credits => 'Créditos';

  @override
  String get changelog => 'Registro de cambios';

  @override
  String get updateAvailable => 'Actualización disponible';

  @override
  String get updateNow => 'Actualizar ahora';

  @override
  String get later => 'Más tarde';

  @override
  String get never => 'Nunca';

  @override
  String get always => 'Siempre';

  @override
  String get sometimes => 'A veces';

  @override
  String get rarely => 'Raramente';

  @override
  String get often => 'A menudo';

  @override
  String get daily => 'Diario';

  @override
  String get weekly => 'Semanal';

  @override
  String get monthly => 'Mensual';

  @override
  String get yearly => 'Anual';

  @override
  String get custom => 'Personalizado';

  @override
  String get automatic => 'Automático';

  @override
  String get manual => 'Manual';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Deshabilitado';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get online => 'En línea';

  @override
  String get offline => 'Sin conexión';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get synchronized => 'Sincronizado';

  @override
  String get notSynchronized => 'No sincronizado';

  @override
  String get synchronizing => 'Sincronizando...';

  @override
  String get syncFailed => 'Error de sincronización';

  @override
  String get retry => 'Reintentar';

  @override
  String get skip => 'Omitir';

  @override
  String get finish => 'Finalizar';

  @override
  String get complete => 'Completar';

  @override
  String get pending => 'Pendiente';

  @override
  String get processing => 'Procesando...';

  @override
  String get waiting => 'Esperando...';

  @override
  String get ready => 'Listo';

  @override
  String get notReady => 'No listo';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'No disponible';

  @override
  String get busy => 'Ocupado';

  @override
  String get free => 'Libre';

  @override
  String get occupied => 'Ocupado';

  @override
  String get empty => 'Vacío';

  @override
  String get full => 'Lleno';

  @override
  String get partial => 'Parcial';

  @override
  String get exact => 'Exacto';

  @override
  String get approximate => 'Aproximado';

  @override
  String get estimated => 'Estimado';

  @override
  String get actual => 'Real';

  @override
  String get planned => 'Planificado';

  @override
  String get unplanned => 'No planificado';

  @override
  String get scheduled => 'Programado';

  @override
  String get unscheduled => 'No programado';

  @override
  String get overdue => 'Atrasado';

  @override
  String get onTime => 'A tiempo';

  @override
  String get early => 'Temprano';

  @override
  String get late => 'Tardío';

  @override
  String get urgent => 'Urgente';

  @override
  String get high => 'Alta';

  @override
  String get medium => 'Media';

  @override
  String get low => 'Baja';

  @override
  String get critical => 'Crítica';

  @override
  String get important => 'Importante';

  @override
  String get normal => 'Normal';

  @override
  String get minor => 'Menor';

  @override
  String get trivial => 'Trivial';

  @override
  String get personal => 'Personal';

  @override
  String get work => 'Trabajo';

  @override
  String get health => 'Salud';

  @override
  String get fitness => 'Fitness';

  @override
  String get education => 'Educación';

  @override
  String get finance => 'Finanzas';

  @override
  String get social => 'Social';

  @override
  String get family => 'Familia';

  @override
  String get hobby => 'Pasatiempo';

  @override
  String get travel => 'Viaje';

  @override
  String get shopping => 'Compras';

  @override
  String get entertainment => 'Entretenimiento';

  @override
  String get other => 'Otro';

  @override
  String get defaultValue => 'Predeterminado';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get duelPriorityTitle => 'Modo Prioridad';

  @override
  String get duelPrioritySubtitle => '¿Qué tarea prefieres?';

  @override
  String get duelPriorityHint => 'Toca la tarjeta que deseas priorizar.';

  @override
  String get duelSkipAction => 'Saltar duelo';

  @override
  String get duelRandomAction => 'Resultado aleatorio';

  @override
  String get duelShowElo => 'Mostrar Elo';

  @override
  String get duelHideElo => 'Ocultar Elo';

  @override
  String get duelModeLabel => 'Modo del duelo';

  @override
  String get duelModeWinner => 'Ganador';

  @override
  String get duelModeRanking => 'Clasificación';

  @override
  String get duelCardsPerRoundLabel => 'Cartas por ronda';

  @override
  String duelCardsPerRoundOption(int count) {
    return '$count cartas';
  }

  @override
  String duelModeSummary(String mode, int count) {
    return 'Modo de duelo: $mode - $count cartas';
  }

  @override
  String get duelSubmitRanking => 'Guardar clasificación';

  @override
  String get duelPreferenceSaved => 'Preferencia guardada ✅';

  @override
  String duelRemainingDuels(int count) {
    return '$count duelos restantes hoy';
  }

  @override
  String get duelConfigureLists => 'Elegir listas para los duelos';

  @override
  String get duelNoAvailableLists => 'Ninguna lista disponible';

  @override
  String get duelNoAvailableListsForPrioritization =>
      'Ninguna lista disponible para la priorización';

  @override
  String get duelListsUpdated => 'Listas de priorización actualizadas';

  @override
  String get duelNewDuel => 'Nuevo duelo';

  @override
  String get duelNotEnoughTasksTitle => 'No hay suficientes tareas';

  @override
  String get duelNotEnoughTasksMessage =>
      'Añade al menos dos tareas para empezar a priorizar.';

  @override
  String get duelErrorMessage =>
      'No se pudo cargar el duelo. Inténtalo de nuevo.';

  @override
  String get habitsActionCreateSuccess => 'Habit created ✅';

  @override
  String habitsActionCreateError(String error) {
    return 'Error while creating: $error';
  }

  @override
  String habitsActionUpdateSuccess(String habitName) {
    return 'Habit \"$habitName\" updated';
  }

  @override
  String habitsActionUpdateError(String error) {
    return 'Error while updating: $error';
  }

  @override
  String habitsActionDeleteSuccess(String habitName) {
    return 'Habit \"$habitName\" deleted';
  }

  @override
  String habitsActionDeleteError(String error) {
    return 'Unable to delete habit: $error';
  }

  @override
  String habitsActionRecordSuccess(String habitName) {
    return 'Habit \"$habitName\" recorded';
  }

  @override
  String habitsActionRecordError(String error) {
    return 'Error while recording: $error';
  }

  @override
  String get habitsLoadingRecord => 'Recording...';

  @override
  String get habitsLoadingDelete => 'Deleting...';

  @override
  String habitsActionUnsupported(String action) {
    return 'Unsupported action: $action';
  }

  @override
  String get habitsDialogDeleteTitle => 'Delete habit';

  @override
  String habitsDialogDeleteMessage(String habitName) {
    return 'Are you sure you want to delete \"$habitName\"?\nThis action is irreversible and removes historical data.';
  }

  @override
  String get habitsButtonCreate => 'Create a habit';

  @override
  String get habitsHeaderTitle => 'My habits';

  @override
  String get habitsHeaderSubtitle => 'Track your progress every day';

  @override
  String get habitsHeroTitle => 'My Habits';

  @override
  String get habitsHeroSubtitle => 'Create and track your daily habits';

  @override
  String get habitsTabHabits => 'Habits';

  @override
  String get habitsTabAdd => 'Add';

  @override
  String get habitCategoryDialogTitle => 'Nueva categoría';

  @override
  String get habitCategoryDialogFieldHint => 'Introduce un nombre de categoría';

  @override
  String get habitsEmptyTitle => 'Aún no tienes hábitos';

  @override
  String get habitsEmptySubtitle =>
      'Crea tu primer hábito para empezar a hacer seguimiento.';

  @override
  String get habitsErrorTitle => 'Error';

  @override
  String habitsErrorLoadFailure(Object error) {
    return 'No se pudieron cargar los hábitos.';
  }

  @override
  String get habitsMenuTooltip => 'Acciones';

  @override
  String get habitsMenuRecord => 'Registrar';

  @override
  String get habitsMenuEdit => 'Editar';

  @override
  String get habitsMenuDelete => 'Eliminar';

  @override
  String get habitsCategoryDefault => 'General';

  @override
  String get habitProgressThisWeek => 'Esta semana';

  @override
  String habitProgressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count días de racha',
      one: '$count día de racha',
    );
    return '$_temp0';
  }

  @override
  String habitProgressSuccessfulDays(Object successful, Object total) {
    return 'Días con éxito';
  }

  @override
  String get habitProgressCompletedToday => 'Completado hoy';

  @override
  String get habitsErrorNetwork => 'Problema de red';

  @override
  String get habitsErrorTimeout => 'Tiempo de espera agotado';

  @override
  String get habitsErrorPermission => 'Permiso denegado';

  @override
  String get habitsErrorUnexpected => 'Error inesperado';

  @override
  String get habitFrequencySelectorTitle => 'Frecuencia';

  @override
  String get habitFrequencyModelATitle => 'Veces por período';

  @override
  String get habitFrequencyModelADescription =>
      'Define cuántas veces quieres cumplir el hábito en cada período.';

  @override
  String get habitFrequencyModelBTitle => 'Cada X unidades';

  @override
  String get habitFrequencyModelBDescription =>
      'Define un intervalo fijo entre cada repetición.';

  @override
  String get habitFrequencyModelAFieldsLabel => 'Objetivo por período';

  @override
  String get habitFrequencyModelBFieldsLabel => 'Intervalo';

  @override
  String get habitFrequencyTimesLabel => 'Veces';

  @override
  String get habitFrequencyIntervalLabel => 'Intervalo';

  @override
  String get habitFrequencyPeriodLabel => 'Período';

  @override
  String get habitFrequencyUnitLabel => 'Unidad';

  @override
  String get habitFrequencyPeriodHour => 'por hora';

  @override
  String get habitFrequencyPeriodDay => 'por día';

  @override
  String get habitFrequencyPeriodWeek => 'por semana';

  @override
  String get habitFrequencyPeriodMonth => 'por mes';

  @override
  String get habitFrequencyPeriodYear => 'por año';

  @override
  String get habitFrequencyUnitHours => 'horas';

  @override
  String get habitFrequencyUnitDays => 'días';

  @override
  String get habitFrequencyUnitWeeks => 'semanas';

  @override
  String get habitFrequencyUnitMonths => 'meses';

  @override
  String get habitFrequencyUnitQuarters => 'trimestres';

  @override
  String get habitFrequencyUnitYears => 'años';

  @override
  String get habitFrequencyDayFilterLabel => 'Días';

  @override
  String get habitFrequencyDayFilterAllDays => 'Todos los días';

  @override
  String get habitFrequencyDayFilterWeekdays => 'Entre semana';

  @override
  String get habitFrequencyDayFilterWeekends => 'Fin de semana';

  @override
  String habitFrequencyTimesPerHour(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por hora',
      one: '$count vez por hora',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerDay(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por día',
      one: '$count vez por día',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerWeek(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por semana',
      one: '$count vez por semana',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerMonth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por mes',
      one: '$count vez por mes',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por año',
      one: '$count vez por año',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryHours(num interval, Object count) {
    return 'Cada $count horas';
  }

  @override
  String habitFrequencyEveryDays(num interval, Object count) {
    return 'Cada $count días';
  }

  @override
  String habitFrequencyEveryWeeks(num interval, Object count) {
    return 'Cada $count semanas';
  }

  @override
  String habitFrequencyEveryMonths(num interval, Object count) {
    return 'Cada $count meses';
  }

  @override
  String habitFrequencyEveryQuarters(num interval, Object count) {
    return 'Cada $count trimestres';
  }

  @override
  String habitFrequencyEveryYears(num interval, Object count) {
    return 'Cada $count años';
  }

  @override
  String get habitFrequencyWeekdaysOnly => 'Solo entre semana';

  @override
  String get habitFrequencyWeekendsOnly => 'Solo fines de semana';

  @override
  String habitFrequencySpecificDays(Object days) {
    return 'Días específicos: $days';
  }

  @override
  String habitFrequencyMonthlyOnDay(Object day) {
    return 'Cada mes el día $day';
  }

  @override
  String habitFrequencyYearlyOnDate(Object day, Object month) {
    return 'Cada año el $day de $month';
  }

  @override
  String get habitWeekdayMonday => 'Lunes';

  @override
  String get habitWeekdayTuesday => 'Martes';

  @override
  String get habitWeekdayWednesday => 'Miércoles';

  @override
  String get habitWeekdayThursday => 'Jueves';

  @override
  String get habitWeekdayFriday => 'Viernes';

  @override
  String get habitWeekdaySaturday => 'Sábado';

  @override
  String get habitWeekdaySunday => 'Domingo';

  @override
  String get habitMonthJanuary => 'enero';

  @override
  String get habitMonthFebruary => 'febrero';

  @override
  String get habitMonthMarch => 'marzo';

  @override
  String get habitMonthApril => 'abril';

  @override
  String get habitMonthMay => 'mayo';

  @override
  String get habitMonthJune => 'junio';

  @override
  String get habitMonthJuly => 'julio';

  @override
  String get habitMonthAugust => 'agosto';

  @override
  String get habitMonthSeptember => 'septiembre';

  @override
  String get habitMonthOctober => 'octubre';

  @override
  String get habitMonthNovember => 'noviembre';

  @override
  String get habitMonthDecember => 'diciembre';

  @override
  String get sortBy => 'Ordenar por';

  @override
  String get scoreElo => 'Puntuación ELO';

  @override
  String get random => 'Aleatorio';

  @override
  String get orderAscending => 'Ascendente';

  @override
  String get orderDescending => 'Descendente';

  @override
  String itemsCount(int count) {
    return '$count elementos';
  }

  @override
  String get add => 'Añadir';

  @override
  String get keepOpenAfterAdd => 'Mantener abierto tras añadir';

  @override
  String get bulkAddSingleHint => 'Escribe un elemento por línea.';

  @override
  String get bulkAddMultipleHint => 'Pega varios elementos, uno por línea.';

  @override
  String get bulkAddHelpText => 'Agrega varios elementos de una sola vez.';

  @override
  String get closeDialog => 'Cerrar';

  @override
  String get bulkAddDefaultTitle => 'Añadir varios elementos';

  @override
  String get bulkAddSubmitting => 'Añadiendo...';

  @override
  String get bulkAddModeSingle => 'Añadir uno';

  @override
  String get bulkAddModeMultiple => 'Añadir varios';

  @override
  String get listDeleteDialogTitle => 'Eliminar lista';

  @override
  String listDeleteDialogMessage(String listName) {
    return '¿Seguro que quieres eliminar \"$listName\"?';
  }

  @override
  String get listDeleteConfirm => 'Eliminar';

  @override
  String get listRenameDialogTitle => 'Renombrar elemento';

  @override
  String get listRenameDialogLabel => 'Nombre del elemento';

  @override
  String get listRenameSaved => 'Elemento renombrado.';

  @override
  String get listMoveDialogTitle => 'Mover elemento';

  @override
  String get listMoveDialogLabel => 'Lista de destino';

  @override
  String get listMoveNoOtherList => 'No hay otra lista disponible';

  @override
  String get listMoveSaved => 'Elemento movido.';

  @override
  String get listDuplicateSaved => 'Elemento duplicado.';

  @override
  String get listConfirmDeleteItemTitle => 'Eliminar elemento';

  @override
  String listConfirmDeleteItemMessage(String itemTitle) {
    return '¿Seguro que quieres eliminar \"$itemTitle\"?';
  }

  @override
  String get more => 'Más acciones';

  @override
  String get rename => 'Renombrar';

  @override
  String get move => 'Mover...';

  @override
  String get duplicate => 'Duplicar';
}
