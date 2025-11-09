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
  String get habitCategoryDialogTitle => 'New category';

  @override
  String get habitCategoryDialogFieldHint => 'Category name';

  @override
  String get habitsEmptyTitle => 'No habits yet';

  @override
  String get habitsEmptySubtitle =>
      'Create your first habit to start tracking progress.';

  @override
  String get habitsErrorTitle => 'Unable to load habits';

  @override
  String habitsErrorLoadFailure(Object error) {
    return 'Unable to load habits: $error';
  }

  @override
  String get habitsMenuTooltip => 'Open habit menu';

  @override
  String get habitsMenuRecord => 'Mark as done';

  @override
  String get habitsMenuEdit => 'Edit';

  @override
  String get habitsMenuDelete => 'Delete';

  @override
  String get habitsCategoryDefault => 'General';

  @override
  String get habitProgressThisWeek => 'this week';

  @override
  String habitProgressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String habitProgressSuccessfulDays(Object successful, Object total) {
    return '$successful/$total days completed';
  }

  @override
  String get habitProgressCompletedToday => 'Done today';

  @override
  String get habitsErrorNetwork => 'Network issue.\\nCheck your connection.';

  @override
  String get habitsErrorTimeout =>
      'The request took too long.\\nPlease try again.';

  @override
  String get habitsErrorPermission =>
      'Insufficient permissions.\\nCheck your access rights.';

  @override
  String get habitsErrorUnexpected =>
      'Unexpected error.\\nPlease try again later.';

  @override
  String get habitFrequencySelectorTitle => 'Frequency';

  @override
  String get habitFrequencyModelATitle => 'Set times per period';

  @override
  String get habitFrequencyModelADescription =>
      'Example: 3 times per day, 5 times per week';

  @override
  String get habitFrequencyModelBTitle => 'Set interval';

  @override
  String get habitFrequencyModelBDescription =>
      'Example: every 2 days, every month';

  @override
  String get habitFrequencyModelAFieldsLabel => 'How many times?';

  @override
  String get habitFrequencyModelBFieldsLabel => 'How often?';

  @override
  String get habitFrequencyTimesLabel => 'Times';

  @override
  String get habitFrequencyIntervalLabel => 'Every';

  @override
  String get habitFrequencyPeriodLabel => 'Period';

  @override
  String get habitFrequencyUnitLabel => 'Unit';

  @override
  String get habitFrequencyPeriodHour => 'hour';

  @override
  String get habitFrequencyPeriodDay => 'day';

  @override
  String get habitFrequencyPeriodWeek => 'week';

  @override
  String get habitFrequencyPeriodMonth => 'month';

  @override
  String get habitFrequencyPeriodYear => 'year';

  @override
  String get habitFrequencyUnitHours => 'hours';

  @override
  String get habitFrequencyUnitDays => 'days';

  @override
  String get habitFrequencyUnitWeeks => 'weeks';

  @override
  String get habitFrequencyUnitMonths => 'months';

  @override
  String get habitFrequencyUnitQuarters => 'quarters';

  @override
  String get habitFrequencyUnitYears => 'years';

  @override
  String get habitFrequencyDayFilterLabel => 'Day filter (optional)';

  @override
  String get habitFrequencyDayFilterAllDays => 'All days';

  @override
  String get habitFrequencyDayFilterWeekdays => 'Weekdays only';

  @override
  String get habitFrequencyDayFilterWeekends => 'Weekends only';

  @override
  String habitFrequencyTimesPerHour(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per hour',
      one: '$count time per hour',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerDay(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per day',
      one: '$count time per day',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerWeek(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per week',
      one: '$count time per week',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerMonth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per month',
      one: '$count time per month',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per year',
      one: '$count time per year',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryHours(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval hours',
      one: 'every hour',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryDays(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval days',
      one: 'daily',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryWeeks(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval weeks',
      one: 'weekly',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryMonths(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval months',
      one: 'monthly',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryQuarters(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval quarters',
      one: 'quarterly',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryYears(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval years',
      one: 'yearly',
    );
    return '$_temp0';
  }

  @override
  String get habitFrequencyWeekdaysOnly => 'Weekdays only (Mon-Fri)';

  @override
  String get habitFrequencyWeekendsOnly => 'Weekends only (Sat-Sun)';

  @override
  String habitFrequencySpecificDays(Object days) {
    return 'On: $days';
  }

  @override
  String habitFrequencyMonthlyOnDay(Object day) {
    return 'Monthly on day $day';
  }

  @override
  String habitFrequencyYearlyOnDate(Object day, Object month) {
    return 'Yearly on $month $day';
  }

  @override
  String get habitWeekdayMonday => 'Mon';

  @override
  String get habitWeekdayTuesday => 'Tue';

  @override
  String get habitWeekdayWednesday => 'Wed';

  @override
  String get habitWeekdayThursday => 'Thu';

  @override
  String get habitWeekdayFriday => 'Fri';

  @override
  String get habitWeekdaySaturday => 'Sat';

  @override
  String get habitWeekdaySunday => 'Sun';

  @override
  String get habitMonthJanuary => 'January';

  @override
  String get habitMonthFebruary => 'February';

  @override
  String get habitMonthMarch => 'March';

  @override
  String get habitMonthApril => 'April';

  @override
  String get habitMonthMay => 'May';

  @override
  String get habitMonthJune => 'June';

  @override
  String get habitMonthJuly => 'July';

  @override
  String get habitMonthAugust => 'August';

  @override
  String get habitMonthSeptember => 'September';

  @override
  String get habitMonthOctober => 'October';

  @override
  String get habitMonthNovember => 'November';

  @override
  String get habitMonthDecember => 'December';
}
