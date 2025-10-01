/// Feature-specific translations (habits, tasks, lists, statistics)
///
/// SOLID COMPLIANCE:
/// - SRP: Only responsible for business feature translations
/// - OCP: Extensible for new features
/// - LSP: Any feature translation implementation is substitutable
/// - ISP: Interface segregated for feature-specific concerns
/// - DIP: Abstract interface, concrete implementations
///
/// CONSTRAINTS: <350 lines (currently ~280 lines)
abstract class AppLocalizationsFeatures {
  // === HABITS FEATURE ===
  String get habitTitle;
  String get habitDescription;
  String get createHabit;
  String get editHabit;
  String get deleteHabit;
  String get habitStreak;
  String get habitFrequency;
  String get daily;
  String get weekly;
  String get monthly;
  String get habitCompleted;
  String get habitMissed;
  String get habitProgress;
  String get trackHabit;
  String get habitGoal;
  String get habitReminder;

  // === TASKS FEATURE ===
  String get taskTitle;
  String get taskDescription;
  String get createTask;
  String get editTask;
  String get deleteTask;
  String get taskCompleted;
  String get taskPending;
  String get taskOverdue;
  String get dueDate;
  String get assignTask;
  String get taskPriority;
  String get subtasks;
  String get taskNotes;

  // === LISTS FEATURE ===
  String get listTitle;
  String get listDescription;
  String get createList;
  String get editList;
  String get deleteList;
  String get addItem;
  String get listItems;
  String get listType;
  String get sharedList;
  String get privateList;
  String get listProgress;
  String get itemsCompleted;
  String get totalItems;

  // === STATISTICS FEATURE ===
  String get statistics;
  String get analytics;
  String get progress;
  String get trends;
  String get achievements;
  String get streaks;
  String get completionRate;
  String get productivity;
  String get insights;
  String get reports;
  String get charts;
  String get metrics;

  // === PRIORITIZATION FEATURE ===
  String get prioritize;
  String get ranking;
  String get comparison;
  String get vote;
  String get duel;
  String get winner;
  String get battle;
  String get versus;
  String get score;

  // === COLLABORATION FEATURE ===
  String get share;
  String get invite;
  String get collaborate;
  String get team;
  String get members;
  String get permissions;
  String get owner;
  String get viewer;
  String get editor;
}

/// Factory for creating feature translations
class AppLocalizationsFeaturesFactory {
  static AppLocalizationsFeatures create(String locale) {
    switch (locale) {
      case 'de':
        return AppLocalizationsFeaturesGerman();
      case 'es':
        return AppLocalizationsFeaturesSpanish();
      case 'fr':
        return AppLocalizationsFeaturesFrench();
      case 'en':
      default:
        return AppLocalizationsFeaturesEnglish();
    }
  }
}

/// English feature translations
class AppLocalizationsFeaturesEnglish implements AppLocalizationsFeatures {
  @override String get habitTitle => 'Habit';
  @override String get habitDescription => 'Habit Description';
  @override String get createHabit => 'Create Habit';
  @override String get editHabit => 'Edit Habit';
  @override String get deleteHabit => 'Delete Habit';
  @override String get habitStreak => 'Streak';
  @override String get habitFrequency => 'Frequency';
  @override String get daily => 'Daily';
  @override String get weekly => 'Weekly';
  @override String get monthly => 'Monthly';
  @override String get habitCompleted => 'Habit Completed';
  @override String get habitMissed => 'Habit Missed';
  @override String get habitProgress => 'Habit Progress';
  @override String get trackHabit => 'Track Habit';
  @override String get habitGoal => 'Goal';
  @override String get habitReminder => 'Reminder';

  @override String get taskTitle => 'Task';
  @override String get taskDescription => 'Task Description';
  @override String get createTask => 'Create Task';
  @override String get editTask => 'Edit Task';
  @override String get deleteTask => 'Delete Task';
  @override String get taskCompleted => 'Task Completed';
  @override String get taskPending => 'Task Pending';
  @override String get taskOverdue => 'Overdue';
  @override String get dueDate => 'Due Date';
  @override String get assignTask => 'Assign Task';
  @override String get taskPriority => 'Task Priority';
  @override String get subtasks => 'Subtasks';
  @override String get taskNotes => 'Notes';

  @override String get listTitle => 'List';
  @override String get listDescription => 'List Description';
  @override String get createList => 'Create List';
  @override String get editList => 'Edit List';
  @override String get deleteList => 'Delete List';
  @override String get addItem => 'Add Item';
  @override String get listItems => 'List Items';
  @override String get listType => 'List Type';
  @override String get sharedList => 'Shared List';
  @override String get privateList => 'Private List';
  @override String get listProgress => 'List Progress';
  @override String get itemsCompleted => 'Items Completed';
  @override String get totalItems => 'Total Items';

  @override String get statistics => 'Statistics';
  @override String get analytics => 'Analytics';
  @override String get progress => 'Progress';
  @override String get trends => 'Trends';
  @override String get achievements => 'Achievements';
  @override String get streaks => 'Streaks';
  @override String get completionRate => 'Completion Rate';
  @override String get productivity => 'Productivity';
  @override String get insights => 'Insights';
  @override String get reports => 'Reports';
  @override String get charts => 'Charts';
  @override String get metrics => 'Metrics';

  @override String get prioritize => 'Prioritize';
  @override String get ranking => 'Ranking';
  @override String get comparison => 'Comparison';
  @override String get vote => 'Vote';
  @override String get duel => 'Duel';
  @override String get winner => 'Winner';
  @override String get battle => 'Battle';
  @override String get versus => 'VS';
  @override String get score => 'Score';

  @override String get share => 'Share';
  @override String get invite => 'Invite';
  @override String get collaborate => 'Collaborate';
  @override String get team => 'Team';
  @override String get members => 'Members';
  @override String get permissions => 'Permissions';
  @override String get owner => 'Owner';
  @override String get viewer => 'Viewer';
  @override String get editor => 'Editor';
}

/// German feature translations
class AppLocalizationsFeaturesGerman implements AppLocalizationsFeatures {
  @override String get habitTitle => 'Gewohnheit';
  @override String get habitDescription => 'Gewohnheitsbeschreibung';
  @override String get createHabit => 'Gewohnheit erstellen';
  @override String get editHabit => 'Gewohnheit bearbeiten';
  @override String get deleteHabit => 'Gewohnheit löschen';
  @override String get habitStreak => 'Serie';
  @override String get habitFrequency => 'Häufigkeit';
  @override String get daily => 'Täglich';
  @override String get weekly => 'Wöchentlich';
  @override String get monthly => 'Monatlich';
  @override String get habitCompleted => 'Gewohnheit abgeschlossen';
  @override String get habitMissed => 'Gewohnheit verpasst';
  @override String get habitProgress => 'Gewohnheitsfortschritt';
  @override String get trackHabit => 'Gewohnheit verfolgen';
  @override String get habitGoal => 'Ziel';
  @override String get habitReminder => 'Erinnerung';

  @override String get taskTitle => 'Aufgabe';
  @override String get taskDescription => 'Aufgabenbeschreibung';
  @override String get createTask => 'Aufgabe erstellen';
  @override String get editTask => 'Aufgabe bearbeiten';
  @override String get deleteTask => 'Aufgabe löschen';
  @override String get taskCompleted => 'Aufgabe abgeschlossen';
  @override String get taskPending => 'Aufgabe ausstehend';
  @override String get taskOverdue => 'Überfällig';
  @override String get dueDate => 'Fälligkeitsdatum';
  @override String get assignTask => 'Aufgabe zuweisen';
  @override String get taskPriority => 'Aufgabenpriorität';
  @override String get subtasks => 'Unteraufgaben';
  @override String get taskNotes => 'Notizen';

  @override String get listTitle => 'Liste';
  @override String get listDescription => 'Listenbeschreibung';
  @override String get createList => 'Liste erstellen';
  @override String get editList => 'Liste bearbeiten';
  @override String get deleteList => 'Liste löschen';
  @override String get addItem => 'Element hinzufügen';
  @override String get listItems => 'Listenelemente';
  @override String get listType => 'Listentyp';
  @override String get sharedList => 'Geteilte Liste';
  @override String get privateList => 'Private Liste';
  @override String get listProgress => 'Listenfortschritt';
  @override String get itemsCompleted => 'Elemente abgeschlossen';
  @override String get totalItems => 'Gesamtelemente';

  @override String get statistics => 'Statistiken';
  @override String get analytics => 'Analytik';
  @override String get progress => 'Fortschritt';
  @override String get trends => 'Trends';
  @override String get achievements => 'Errungenschaften';
  @override String get streaks => 'Serien';
  @override String get completionRate => 'Abschlussrate';
  @override String get productivity => 'Produktivität';
  @override String get insights => 'Erkenntnisse';
  @override String get reports => 'Berichte';
  @override String get charts => 'Diagramme';
  @override String get metrics => 'Metriken';

  @override String get prioritize => 'Priorisieren';
  @override String get ranking => 'Rangfolge';
  @override String get comparison => 'Vergleich';
  @override String get vote => 'Stimme';
  @override String get duel => 'Duell';
  @override String get winner => 'Gewinner';
  @override String get battle => 'Schlacht';
  @override String get versus => 'gegen';
  @override String get score => 'Punkte';

  @override String get share => 'Teilen';
  @override String get invite => 'Einladen';
  @override String get collaborate => 'Zusammenarbeiten';
  @override String get team => 'Team';
  @override String get members => 'Mitglieder';
  @override String get permissions => 'Berechtigungen';
  @override String get owner => 'Besitzer';
  @override String get viewer => 'Betrachter';
  @override String get editor => 'Bearbeiter';
}

/// Spanish feature translations
class AppLocalizationsFeaturesSpanish implements AppLocalizationsFeatures {
  @override String get habitTitle => 'Hábito';
  @override String get habitDescription => 'Descripción del Hábito';
  @override String get createHabit => 'Crear Hábito';
  @override String get editHabit => 'Editar Hábito';
  @override String get deleteHabit => 'Eliminar Hábito';
  @override String get habitStreak => 'Racha';
  @override String get habitFrequency => 'Frecuencia';
  @override String get daily => 'Diario';
  @override String get weekly => 'Semanal';
  @override String get monthly => 'Mensual';
  @override String get habitCompleted => 'Hábito Completado';
  @override String get habitMissed => 'Hábito Perdido';
  @override String get habitProgress => 'Progreso del Hábito';
  @override String get trackHabit => 'Seguir Hábito';
  @override String get habitGoal => 'Meta';
  @override String get habitReminder => 'Recordatorio';

  @override String get taskTitle => 'Tarea';
  @override String get taskDescription => 'Descripción de la Tarea';
  @override String get createTask => 'Crear Tarea';
  @override String get editTask => 'Editar Tarea';
  @override String get deleteTask => 'Eliminar Tarea';
  @override String get taskCompleted => 'Tarea Completada';
  @override String get taskPending => 'Tarea Pendiente';
  @override String get taskOverdue => 'Vencido';
  @override String get dueDate => 'Fecha de Vencimiento';
  @override String get assignTask => 'Asignar Tarea';
  @override String get taskPriority => 'Prioridad de Tarea';
  @override String get subtasks => 'Subtareas';
  @override String get taskNotes => 'Notas';

  @override String get listTitle => 'Lista';
  @override String get listDescription => 'Descripción de Lista';
  @override String get createList => 'Crear Lista';
  @override String get editList => 'Editar Lista';
  @override String get deleteList => 'Eliminar Lista';
  @override String get addItem => 'Agregar Elemento';
  @override String get listItems => 'Elementos de Lista';
  @override String get listType => 'Tipo de Lista';
  @override String get sharedList => 'Lista Compartida';
  @override String get privateList => 'Lista Privada';
  @override String get listProgress => 'Progreso de Lista';
  @override String get itemsCompleted => 'Elementos Completados';
  @override String get totalItems => 'Total de Elementos';

  @override String get statistics => 'Estadísticas';
  @override String get analytics => 'Analítica';
  @override String get progress => 'Progreso';
  @override String get trends => 'Tendencias';
  @override String get achievements => 'Logros';
  @override String get streaks => 'Rachas';
  @override String get completionRate => 'Tasa de Finalización';
  @override String get productivity => 'Productividad';
  @override String get insights => 'Perspectivas';
  @override String get reports => 'Reportes';
  @override String get charts => 'Gráficos';
  @override String get metrics => 'Métricas';

  @override String get prioritize => 'Priorizar';
  @override String get ranking => 'Clasificación';
  @override String get comparison => 'Comparación';
  @override String get vote => 'Votar';
  @override String get duel => 'Duelo';
  @override String get winner => 'Ganador';
  @override String get battle => 'Batalla';
  @override String get versus => 'contra';
  @override String get score => 'Puntuación';

  @override String get share => 'Compartir';
  @override String get invite => 'Invitar';
  @override String get collaborate => 'Colaborar';
  @override String get team => 'Equipo';
  @override String get members => 'Miembros';
  @override String get permissions => 'Permisos';
  @override String get owner => 'Propietario';
  @override String get viewer => 'Visualizador';
  @override String get editor => 'Editor';
}

/// French feature translations
class AppLocalizationsFeaturesFrench implements AppLocalizationsFeatures {
  @override String get habitTitle => 'Habitude';
  @override String get habitDescription => 'Description de l\'Habitude';
  @override String get createHabit => 'Créer une Habitude';
  @override String get editHabit => 'Modifier l\'Habitude';
  @override String get deleteHabit => 'Supprimer l\'Habitude';
  @override String get habitStreak => 'Série';
  @override String get habitFrequency => 'Fréquence';
  @override String get daily => 'Quotidien';
  @override String get weekly => 'Hebdomadaire';
  @override String get monthly => 'Mensuel';
  @override String get habitCompleted => 'Habitude Terminée';
  @override String get habitMissed => 'Habitude Manquée';
  @override String get habitProgress => 'Progrès de l\'Habitude';
  @override String get trackHabit => 'Suivre l\'Habitude';
  @override String get habitGoal => 'Objectif';
  @override String get habitReminder => 'Rappel';

  @override String get taskTitle => 'Tâche';
  @override String get taskDescription => 'Description de la Tâche';
  @override String get createTask => 'Créer une Tâche';
  @override String get editTask => 'Modifier la Tâche';
  @override String get deleteTask => 'Supprimer la Tâche';
  @override String get taskCompleted => 'Tâche Terminée';
  @override String get taskPending => 'Tâche en Attente';
  @override String get taskOverdue => 'En Retard';
  @override String get dueDate => 'Date d\'Échéance';
  @override String get assignTask => 'Assigner la Tâche';
  @override String get taskPriority => 'Priorité de la Tâche';
  @override String get subtasks => 'Sous-tâches';
  @override String get taskNotes => 'Notes';

  @override String get listTitle => 'Liste';
  @override String get listDescription => 'Description de la Liste';
  @override String get createList => 'Créer une Liste';
  @override String get editList => 'Modifier la Liste';
  @override String get deleteList => 'Supprimer la Liste';
  @override String get addItem => 'Ajouter un Élément';
  @override String get listItems => 'Éléments de la Liste';
  @override String get listType => 'Type de Liste';
  @override String get sharedList => 'Liste Partagée';
  @override String get privateList => 'Liste Privée';
  @override String get listProgress => 'Progrès de la Liste';
  @override String get itemsCompleted => 'Éléments Terminés';
  @override String get totalItems => 'Total des Éléments';

  @override String get statistics => 'Statistiques';
  @override String get analytics => 'Analyses';
  @override String get progress => 'Progrès';
  @override String get trends => 'Tendances';
  @override String get achievements => 'Réalisations';
  @override String get streaks => 'Séries';
  @override String get completionRate => 'Taux de Réalisation';
  @override String get productivity => 'Productivité';
  @override String get insights => 'Aperçus';
  @override String get reports => 'Rapports';
  @override String get charts => 'Graphiques';
  @override String get metrics => 'Métriques';

  @override String get prioritize => 'Prioriser';
  @override String get ranking => 'Classement';
  @override String get comparison => 'Comparaison';
  @override String get vote => 'Voter';
  @override String get duel => 'Duel';
  @override String get winner => 'Gagnant';
  @override String get battle => 'Bataille';
  @override String get versus => 'contre';
  @override String get score => 'Score';

  @override String get share => 'Partager';
  @override String get invite => 'Inviter';
  @override String get collaborate => 'Collaborer';
  @override String get team => 'Équipe';
  @override String get members => 'Membres';
  @override String get permissions => 'Permissions';
  @override String get owner => 'Propriétaire';
  @override String get viewer => 'Visualiseur';
  @override String get editor => 'Éditeur';
}