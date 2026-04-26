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
  String get habitFormTitleEdit => 'Editar h?bito';

  @override
  String get habitFormIntro =>
      'Ponle a este h?bito un nombre claro, asigna una categor?a y elige c?mo seguir?s tu progreso.';

  @override
  String get habitFormNameLabel => 'Nombre del h?bito';

  @override
  String get habitFormNameHint => 'Ej.: Beber 8 vasos de agua';

  @override
  String get habitFormCategoryLabel => 'Categor?a';

  @override
  String get habitFormCategoryHint => 'Seleccionar una categor?a';

  @override
  String get habitFormCategoryNone => 'Sin categor?a';

  @override
  String get habitFormCategoryCreate => '+ Crear una nueva categor?a?';

  @override
  String get habitCategoryHelper =>
      'Recomendado: elige una categor?a para mejores estad?sticas.';

  @override
  String get habitCategoryWarningTitle => 'Categor?a no elegida';

  @override
  String get habitCategoryWarningMessage =>
      'No has elegido categor?a, ?continuar de todos modos?';

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
  String get habitTrackingModeCycle => 'M días de N';

  @override
  String get habitTrackingModeWeekdays => 'Días específicos';

  @override
  String get habitTrackingModeSpecificDate => 'En una fecha precisa';

  @override
  String get habitTrackingCycleLabel => 'Ciclo';

  @override
  String get habitTrackingCycleActiveDays => 'Días activos (M)';

  @override
  String get habitTrackingCycleLength => 'Longitud del ciclo (N)';

  @override
  String get habitTrackingCycleStartDate => 'Fecha de inicio del ciclo';

  @override
  String get habitTrackingWeekdaysLabel => 'Selecciona los días';

  @override
  String get habitTrackingSpecificDateLabel => 'Fecha';

  @override
  String get habitTrackingRepeatEveryYear => 'Repetir cada año';

  @override
  String get habitTrackingBackToPeriod => 'Volver al modo \"por período\"';

  @override
  String get habitTrackingPeriodDay => 'al día';

  @override
  String get habitTrackingPeriodWeek => 'a la semana';

  @override
  String get habitTrackingPeriodMonth => 'al mes';

  @override
  String get habitTrackingPeriodQuarter => 'al trimestre';

  @override
  String get habitTrackingPeriodSemester => 'al semestre';

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
  String get addList => 'Agregar una lista';

  @override
  String get listsEmptyTitle => 'Todavia no hay listas';

  @override
  String get listsEmptySubtitle => 'Agrega tu primera lista para empezar';

  @override
  String get listEmptyTitle => 'No se encontraron elementos';

  @override
  String get listEmptySearchBody => 'Prueba con otro termino de busqueda';

  @override
  String get listEmptyNoItemsBody => 'Agrega tu primer elemento para empezar';

  @override
  String get listsOverviewTitle => 'Consulta tus listas de un vistazo';

  @override
  String listsOverviewSubtitle(int totalLists, int totalItems) {
    return '$totalLists listas | $totalItems elementos activos';
  }

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
  String get insightsTabTrends => 'Tendencias';

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
  String get settingsGeneralSectionTitle => 'General';

  @override
  String get settingsPilotSectionTitle => 'Piloto';

  @override
  String get pilotIdentityBadge => 'Piloto externo';

  @override
  String get settingsHelpFeedbackSectionTitle => 'Ayuda y comentarios';

  @override
  String get settingsAboutSectionTitle => 'Acerca de';

  @override
  String get settingsPilotStatusTitle => 'Estado del piloto';

  @override
  String get settingsPilotStatusBody =>
      'Piloto externo limitado. Prioris cubre hoy el shell, las listas, la priorización y los hábitos básicos.';

  @override
  String get settingsPilotLimitsTitle => 'Límites actuales';

  @override
  String get settingsPilotLimitsBody =>
      'Sin facturación, sin soporte público, sin centro de ayuda alojado y sin promesas más allá del alcance actual.';

  @override
  String settingsVersionValue(String version) {
    return '$version';
  }

  @override
  String get settingsVersionFallbackLabel => 'Build del piloto externo';

  @override
  String settingsLanguageChanged(String language) {
    return 'Idioma cambiado a $language';
  }

  @override
  String get logout => 'Cerrar sesion';

  @override
  String get homeLogoutHint => 'Cierra la sesion del usuario actual';

  @override
  String get homeSettingsHint => 'Abre la configuracion de la aplicacion';

  @override
  String get homeMainContentLabel => 'Contenido principal';

  @override
  String get homePrimaryNavigationLabel => 'Navegacion principal';

  @override
  String get homePrimaryNavigationHint =>
      'Usa la navegacion para cambiar de seccion';

  @override
  String homeNavigationAnnouncement(String section) {
    return 'Navegar a $section';
  }

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
  String get todayPanelSubtitle =>
      'Los pocos elementos que merecen tu atencion ahora';

  @override
  String todayPanelCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos fiables',
      one: '$count elemento fiable',
    );
    return '$_temp0';
  }

  @override
  String get todayPanelLoading => 'Preparando tu vista de hoy...';

  @override
  String get todayPanelCalmTitle => 'Nada urgente por ahora';

  @override
  String get todayPanelCalmBody =>
      'Tu dia parece tranquilo. Sigue desde tus listas o habitos si quieres avanzar.';

  @override
  String get todayPanelFirstUseTitle => 'Tu espacio esta listo';

  @override
  String get todayPanelFirstUseBody =>
      'Empieza creando tu primera lista o habito. Tus proximas acciones apareceran aqui.';

  @override
  String get todayPanelPartial =>
      'Vista parcial: algunas senales siguen cargando.';

  @override
  String get todayPanelError => 'La vista de hoy esta temporalmente limitada.';

  @override
  String get todayPanelTaskKind => 'Tarea';

  @override
  String get todayPanelHabitKind => 'Habito';

  @override
  String get todayPanelStatusOverdue => 'Atrasada';

  @override
  String get todayPanelStatusDueToday => 'Hoy';

  @override
  String get todayPanelStatusPending => 'Por revisar';

  @override
  String get todayPanelReasonOverdueTask => 'Tarea ya atrasada';

  @override
  String get todayPanelReasonDueTodayTask => 'Vence hoy';

  @override
  String get todayPanelReasonPriorityTask => 'Tarea de alto impacto';

  @override
  String get todayPanelReasonDueTodayHabit => 'Habito esperado hoy';

  @override
  String todayPanelParentListLabel(Object title) {
    return 'Lista: $title';
  }

  @override
  String get todayPanelActionOpenList => 'Abrir lista';

  @override
  String get todayPanelActionOpenDuel => 'Priorizar';

  @override
  String get todayPanelActionRecordHabit => 'Marcar hecho';

  @override
  String get todayPanelActionRecordValue => 'Ingresar valor';

  @override
  String get todayPanelActionOpenHabits => 'Abrir habitos';

  @override
  String get todayPanelActionUnavailable =>
      'Esta accion ya no esta disponible en el estado actual.';

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
  String get insightsHeaderTitle => 'Sigue tu progreso';

  @override
  String get insightsHeaderSubtitleEmpty =>
      'Crea habitos para desbloquear tus primeras perspectivas.';

  @override
  String insightsHeaderSubtitleWithHabits(int count) {
    return 'Resumen y tendencias de tus $count habitos';
  }

  @override
  String get insightsEmptyTitle => 'Todavia no hay perspectivas';

  @override
  String get insightsEmptyBody =>
      'Crea tu primer habito para desbloquear tus primeras perspectivas aqui.';

  @override
  String get insightsOverviewPlaceholder => 'Tu resumen aparecera aqui pronto.';

  @override
  String get insightsTrendsPlaceholder =>
      'Tus tendencias apareceran aqui pronto.';

  @override
  String get recommendations => 'Recomendaciones';

  @override
  String get suggestions => 'Sugerencias';

  @override
  String get tips => 'Consejos';

  @override
  String get help => 'Ayuda';

  @override
  String get settingsHelpSubtitle =>
      'Comprender cómo obtener ayuda durante este piloto.';

  @override
  String get settingsHelpDialogBody =>
      'El soporte del piloto sigue siendo manual y limitado. Use el canal de feedback del piloto para hacer una pregunta, reportar un problema o compartir una necesidad. No se promete asistencia en tiempo real ni un SLA público.';

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
  String get settingsFeedbackSubtitle =>
      'Abrir el canal de feedback del piloto.';

  @override
  String get settingsFeedbackDialogBody =>
      'El canal de feedback del piloto abre un formulario simple en su navegador. Tambien se usa para ayuda, errores y solicitudes de funciones.';

  @override
  String get reportBug => 'Reportar error';

  @override
  String get settingsReportBugSubtitle =>
      'Usar el mismo canal del piloto para reportar un error.';

  @override
  String get settingsReportBugDialogBody =>
      'Los errores pasan por el mismo canal del piloto que el feedback general. Describa el contexto visible, el dispositivo y el resultado observado.';

  @override
  String get requestFeature => 'Solicitar función';

  @override
  String get settingsRequestFeatureSubtitle =>
      'Usar el mismo canal del piloto para compartir una necesidad.';

  @override
  String get settingsRequestFeatureDialogBody =>
      'Las solicitudes de funciones pasan por el mismo canal del piloto. Se revisan manualmente y no suponen un compromiso de entrega.';

  @override
  String get settingsSupportLaunchFailureBody =>
      'No se pudo abrir este canal automaticamente. Use este enlace en su navegador:';

  @override
  String get settingsSupportUnavailableBody =>
      'Esta build todavia no configura un canal de soporte del piloto. Agregue una URL de feedback o un correo de soporte antes de cualquier difusion externa.';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get settingsPrivacySubtitle =>
      'Leer cómo se gestionan los datos del piloto.';

  @override
  String get settingsPrivacyDialogBody =>
      'Prioris solo guarda los datos necesarios para este piloto: cuenta, listas, tareas, habitos y señales de sincronizacion asociadas. Estos datos se usan para hacer funcionar el producto, corregir problemas reportados y evaluar el piloto. Si tiene preguntas sobre sus datos, use el canal de feedback del piloto.';

  @override
  String get termsOfService => 'Términos de servicio';

  @override
  String get settingsTermsSubtitle =>
      'Leer el marco minimo de uso de este piloto.';

  @override
  String get settingsTermsDialogBody =>
      'Este piloto esta reservado a un pequeno grupo invitado. El acceso, las funciones y la disponibilidad pueden cambiar sin previo aviso. No use Prioris como sistema critico ni como unica fuente de verdad para decisiones sensibles. El feedback es bienvenido, pero no se garantiza una correccion inmediata ni una apertura publica.';

  @override
  String get license => 'Licencia';

  @override
  String get settingsLicenseSubtitle =>
      'Abrir las licencias incluidas en esta versión.';

  @override
  String get settingsAboutLegalese =>
      'Piloto externo limitado. Soporte manual a traves del canal del piloto, sin precios ni compromiso publico por ahora.';

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
  String get habitsButtonCreate => 'Crear un habito';

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
      other: '$count veces por ía',
      one: '$count vez por ía',
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
  String habitFrequencyTimesPerQuarter(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por trimestre',
      one: '$count vez por trimestre',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerSemester(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por semestre',
      one: '$count vez por semestre',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces por ño',
      one: '$count vez por ño',
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
  String habitFrequencyEveryQuarters(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'cada $interval trimestres',
      one: 'trimestral',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyDaysPerCycle(Object daysActive, Object daysCycle) {
    return '$daysActive días de $daysCycle';
  }

  @override
  String habitFrequencySpecificDateAnnual(String date) {
    return 'Cada año el $date';
  }

  @override
  String habitFrequencySpecificDateOnce(String date) {
    return 'El $date';
  }

  @override
  String habitFrequencyEveryYears(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'cada $interval años',
      one: 'anual',
    );
    return '$_temp0';
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
  String bulkAddImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos importados',
      one: '$count elemento importado',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddImportError => 'Error al importar';

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

  @override
  String get authOfflineSignInError =>
      'El inicio de sesiÃ³n no estÃ¡ disponible en modo sin conexiÃ³n. Configura credenciales reales de Supabase en .env para activar las funciones en lÃ­nea.';

  @override
  String get authOfflineSignUpError =>
      'El registro no estÃ¡ disponible en modo sin conexiÃ³n. Configura credenciales reales de Supabase en .env para activar las funciones en lÃ­nea.';

  @override
  String get authLoginTitle => 'Inicia sesion';

  @override
  String get authSignUpTitle => 'Crear una cuenta';

  @override
  String get authSignInAction => 'Iniciar sesion';

  @override
  String get authSignUpAction => 'Crear cuenta';

  @override
  String get authToggleToSignUp => 'No tienes cuenta? Crea una';

  @override
  String get authToggleToSignIn => 'Ya tienes cuenta? Inicia sesion';

  @override
  String get authForgotPasswordAction => 'Olvidaste tu contrasena?';

  @override
  String get authEmailLabel => 'Correo electronico';

  @override
  String get authEmailHint => 'tu@correo.com';

  @override
  String get authPasswordLabel => 'Contrasena';

  @override
  String get authPasswordHint => '********';

  @override
  String get authTechnicalFieldLabel => 'Campo tecnico (dejar vacio)';

  @override
  String get authPendingConfirmationTitle => 'Confirmacion requerida';

  @override
  String authPendingConfirmationMessage(String email) {
    return 'Se envio un correo de validacion a $email. Confirma tu correo electronico para terminar el registro y luego vuelve a iniciar sesion.';
  }

  @override
  String get authCallbackExpiredMessage =>
      'Tu enlace de inicio de sesion ha expirado o fue abierto en un navegador diferente. Por favor, inicia sesion de nuevo.';

  @override
  String get duplicateWarningTitle => 'Duplicate detected';

  @override
  String duplicateWarningSingle(String title) {
    return 'The item \"$title\" is already in your list.';
  }

  @override
  String duplicateWarningMultiple(int duplicateCount, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      duplicateCount,
      locale: localeName,
      other: '$duplicateCount items are already',
      one: '$duplicateCount item is already',
    );
    return '$_temp0 in your list (out of $total).';
  }

  @override
  String duplicateWarningSkipAction(int uniqueCount) {
    return 'Skip duplicates ($uniqueCount to add)';
  }

  @override
  String get duplicateWarningAddAllSingle => 'Add anyway';

  @override
  String duplicateWarningAddAllBulk(int count) {
    return 'Add all ($count)';
  }

  @override
  String bulkAddImportSuccessWithSkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items imported',
      one: '$count item imported',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped duplicates skipped',
      one: '$skipped duplicate skipped',
    );
    return '$_temp0, $_temp1';
  }
}
