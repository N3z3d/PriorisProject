/// UI-specific translations (buttons, labels, navigation)
///
/// SOLID COMPLIANCE:
/// - SRP: Only responsible for UI element translations
/// - OCP: Extensible for new UI translations
/// - LSP: Any UI translation implementation is substitutable
/// - ISP: Interface segregated for UI-only concerns
/// - DIP: Abstract interface, concrete implementations
///
/// CONSTRAINTS: <300 lines (currently ~250 lines)
abstract class AppLocalizationsUI {
  // === NAVIGATION LABELS ===
  String get home;
  String get habits;
  String get tasks;
  String get lists;
  String get settings;
  String get statistics;
  String get profile;
  String get insights;

  // === COMMON BUTTONS ===
  String get add;
  String get edit;
  String get close;
  String get back;
  String get next;
  String get previous;
  String get continue_;
  String get finish;
  String get done;
  String get retry;
  String get refresh;
  String get confirm;

  // === FORM LABELS ===
  String get name;
  String get title;
  String get description;
  String get priority;
  String get category;
  String get tags;
  String get search;
  String get filter;
  String get sort;
  String get sortBy;

  // === STATUS LABELS ===
  String get completed;
  String get pending;
  String get inProgress;
  String get paused;
  String get cancelled;
  String get active;
  String get inactive;
  String get enabled;
  String get disabled;

  // === TIME LABELS ===
  String get today;
  String get yesterday;
  String get tomorrow;
  String get thisWeek;
  String get lastWeek;
  String get nextWeek;
  String get thisMonth;
  String get lastMonth;
  String get nextMonth;

  // === PRIORITY LABELS ===
  String get high;
  String get medium;
  String get low;
  String get urgent;
  String get normal;

  // === LOADING STATES ===
  String get loading;
  String get saving;
  String get deleting;
  String get updating;
  String get syncing;
  String get uploading;
  String get downloading;

  // === EMPTY STATES ===
  String get noData;
  String get noResults;
  String get noItems;
  String get empty;

  // === ACCESSIBILITY ===
  String get tapToSelect;
  String get tapToEdit;
  String get tapToDelete;
  String get doubleTapToOpen;
  String get swipeToDelete;
  String get longPressForOptions;
}

/// Factory for creating UI translations based on locale
class AppLocalizationsUIFactory {
  static AppLocalizationsUI create(String locale) {
    switch (locale) {
      case 'de':
        return AppLocalizationsUIGerman();
      case 'es':
        return AppLocalizationsUISpanish();
      case 'fr':
        return AppLocalizationsUIFrench();
      case 'en':
      default:
        return AppLocalizationsUIEnglish();
    }
  }
}

/// English UI translations
class AppLocalizationsUIEnglish implements AppLocalizationsUI {
  @override String get home => 'Home';
  @override String get habits => 'Habits';
  @override String get tasks => 'Tasks';
  @override String get lists => 'Lists';
  @override String get settings => 'Settings';
  @override String get statistics => 'Statistics';
  @override String get profile => 'Profile';
  @override String get insights => 'Insights';

  @override String get add => 'Add';
  @override String get edit => 'Edit';
  @override String get close => 'Close';
  @override String get back => 'Back';
  @override String get next => 'Next';
  @override String get previous => 'Previous';
  @override String get continue_ => 'Continue';
  @override String get finish => 'Finish';
  @override String get done => 'Done';
  @override String get retry => 'Retry';
  @override String get refresh => 'Refresh';
  @override String get confirm => 'Confirm';

  @override String get name => 'Name';
  @override String get title => 'Title';
  @override String get description => 'Description';
  @override String get priority => 'Priority';
  @override String get category => 'Category';
  @override String get tags => 'Tags';
  @override String get search => 'Search';
  @override String get filter => 'Filter';
  @override String get sort => 'Sort';
  @override String get sortBy => 'Sort by';

  @override String get completed => 'Completed';
  @override String get pending => 'Pending';
  @override String get inProgress => 'In Progress';
  @override String get paused => 'Paused';
  @override String get cancelled => 'Cancelled';
  @override String get active => 'Active';
  @override String get inactive => 'Inactive';
  @override String get enabled => 'Enabled';
  @override String get disabled => 'Disabled';

  @override String get today => 'Today';
  @override String get yesterday => 'Yesterday';
  @override String get tomorrow => 'Tomorrow';
  @override String get thisWeek => 'This Week';
  @override String get lastWeek => 'Last Week';
  @override String get nextWeek => 'Next Week';
  @override String get thisMonth => 'This Month';
  @override String get lastMonth => 'Last Month';
  @override String get nextMonth => 'Next Month';

  @override String get high => 'High';
  @override String get medium => 'Medium';
  @override String get low => 'Low';
  @override String get urgent => 'Urgent';
  @override String get normal => 'Normal';

  @override String get loading => 'Loading...';
  @override String get saving => 'Saving...';
  @override String get deleting => 'Deleting...';
  @override String get updating => 'Updating...';
  @override String get syncing => 'Syncing...';
  @override String get uploading => 'Uploading...';
  @override String get downloading => 'Downloading...';

  @override String get noData => 'No data';
  @override String get noResults => 'No results';
  @override String get noItems => 'No items';
  @override String get empty => 'Empty';

  @override String get tapToSelect => 'Tap to select';
  @override String get tapToEdit => 'Tap to edit';
  @override String get tapToDelete => 'Tap to delete';
  @override String get doubleTapToOpen => 'Double tap to open';
  @override String get swipeToDelete => 'Swipe to delete';
  @override String get longPressForOptions => 'Long press for options';
}

/// German UI translations
class AppLocalizationsUIGerman implements AppLocalizationsUI {
  @override String get home => 'Startseite';
  @override String get habits => 'Gewohnheiten';
  @override String get tasks => 'Aufgaben';
  @override String get lists => 'Listen';
  @override String get settings => 'Einstellungen';
  @override String get statistics => 'Statistiken';
  @override String get profile => 'Profil';
  @override String get insights => 'Erkenntnisse';

  @override String get add => 'Hinzufügen';
  @override String get edit => 'Bearbeiten';
  @override String get close => 'Schließen';
  @override String get back => 'Zurück';
  @override String get next => 'Weiter';
  @override String get previous => 'Zurück';
  @override String get continue_ => 'Fortsetzen';
  @override String get finish => 'Beenden';
  @override String get done => 'Fertig';
  @override String get retry => 'Wiederholen';
  @override String get refresh => 'Aktualisieren';
  @override String get confirm => 'Bestätigen';

  @override String get name => 'Name';
  @override String get title => 'Titel';
  @override String get description => 'Beschreibung';
  @override String get priority => 'Priorität';
  @override String get category => 'Kategorie';
  @override String get tags => 'Tags';
  @override String get search => 'Suchen';
  @override String get filter => 'Filter';
  @override String get sort => 'Sortieren';
  @override String get sortBy => 'Sortieren nach';

  @override String get completed => 'Abgeschlossen';
  @override String get pending => 'Ausstehend';
  @override String get inProgress => 'In Bearbeitung';
  @override String get paused => 'Pausiert';
  @override String get cancelled => 'Abgebrochen';
  @override String get active => 'Aktiv';
  @override String get inactive => 'Inaktiv';
  @override String get enabled => 'Aktiviert';
  @override String get disabled => 'Deaktiviert';

  @override String get today => 'Heute';
  @override String get yesterday => 'Gestern';
  @override String get tomorrow => 'Morgen';
  @override String get thisWeek => 'Diese Woche';
  @override String get lastWeek => 'Letzte Woche';
  @override String get nextWeek => 'Nächste Woche';
  @override String get thisMonth => 'Dieser Monat';
  @override String get lastMonth => 'Letzter Monat';
  @override String get nextMonth => 'Nächster Monat';

  @override String get high => 'Hoch';
  @override String get medium => 'Mittel';
  @override String get low => 'Niedrig';
  @override String get urgent => 'Dringend';
  @override String get normal => 'Normal';

  @override String get loading => 'Laden...';
  @override String get saving => 'Speichern...';
  @override String get deleting => 'Löschen...';
  @override String get updating => 'Aktualisieren...';
  @override String get syncing => 'Synchronisieren...';
  @override String get uploading => 'Hochladen...';
  @override String get downloading => 'Herunterladen...';

  @override String get noData => 'Keine Daten';
  @override String get noResults => 'Keine Ergebnisse';
  @override String get noItems => 'Keine Elemente';
  @override String get empty => 'Leer';

  @override String get tapToSelect => 'Tippen zum Auswählen';
  @override String get tapToEdit => 'Tippen zum Bearbeiten';
  @override String get tapToDelete => 'Tippen zum Löschen';
  @override String get doubleTapToOpen => 'Doppeltippen zum Öffnen';
  @override String get swipeToDelete => 'Wischen zum Löschen';
  @override String get longPressForOptions => 'Lange drücken für Optionen';
}

/// Spanish UI translations
class AppLocalizationsUISpanish implements AppLocalizationsUI {
  @override String get home => 'Inicio';
  @override String get habits => 'Hábitos';
  @override String get tasks => 'Tareas';
  @override String get lists => 'Listas';
  @override String get settings => 'Configuración';
  @override String get statistics => 'Estadísticas';
  @override String get profile => 'Perfil';
  @override String get insights => 'Perspectivas';

  @override String get add => 'Agregar';
  @override String get edit => 'Editar';
  @override String get close => 'Cerrar';
  @override String get back => 'Atrás';
  @override String get next => 'Siguiente';
  @override String get previous => 'Anterior';
  @override String get continue_ => 'Continuar';
  @override String get finish => 'Terminar';
  @override String get done => 'Hecho';
  @override String get retry => 'Reintentar';
  @override String get refresh => 'Actualizar';
  @override String get confirm => 'Confirmar';

  @override String get name => 'Nombre';
  @override String get title => 'Título';
  @override String get description => 'Descripción';
  @override String get priority => 'Prioridad';
  @override String get category => 'Categoría';
  @override String get tags => 'Etiquetas';
  @override String get search => 'Buscar';
  @override String get filter => 'Filtro';
  @override String get sort => 'Ordenar';
  @override String get sortBy => 'Ordenar por';

  @override String get completed => 'Completado';
  @override String get pending => 'Pendiente';
  @override String get inProgress => 'En Progreso';
  @override String get paused => 'Pausado';
  @override String get cancelled => 'Cancelado';
  @override String get active => 'Activo';
  @override String get inactive => 'Inactivo';
  @override String get enabled => 'Habilitado';
  @override String get disabled => 'Deshabilitado';

  @override String get today => 'Hoy';
  @override String get yesterday => 'Ayer';
  @override String get tomorrow => 'Mañana';
  @override String get thisWeek => 'Esta Semana';
  @override String get lastWeek => 'Semana Pasada';
  @override String get nextWeek => 'Próxima Semana';
  @override String get thisMonth => 'Este Mes';
  @override String get lastMonth => 'Mes Pasado';
  @override String get nextMonth => 'Próximo Mes';

  @override String get high => 'Alto';
  @override String get medium => 'Medio';
  @override String get low => 'Bajo';
  @override String get urgent => 'Urgente';
  @override String get normal => 'Normal';

  @override String get loading => 'Cargando...';
  @override String get saving => 'Guardando...';
  @override String get deleting => 'Eliminando...';
  @override String get updating => 'Actualizando...';
  @override String get syncing => 'Sincronizando...';
  @override String get uploading => 'Subiendo...';
  @override String get downloading => 'Descargando...';

  @override String get noData => 'Sin datos';
  @override String get noResults => 'Sin resultados';
  @override String get noItems => 'Sin elementos';
  @override String get empty => 'Vacío';

  @override String get tapToSelect => 'Tocar para seleccionar';
  @override String get tapToEdit => 'Tocar para editar';
  @override String get tapToDelete => 'Tocar para eliminar';
  @override String get doubleTapToOpen => 'Doble toque para abrir';
  @override String get swipeToDelete => 'Deslizar para eliminar';
  @override String get longPressForOptions => 'Presión larga para opciones';
}

/// French UI translations
class AppLocalizationsUIFrench implements AppLocalizationsUI {
  @override String get home => 'Accueil';
  @override String get habits => 'Habitudes';
  @override String get tasks => 'Tâches';
  @override String get lists => 'Listes';
  @override String get settings => 'Paramètres';
  @override String get statistics => 'Statistiques';
  @override String get profile => 'Profil';
  @override String get insights => 'Aperçus';

  @override String get add => 'Ajouter';
  @override String get edit => 'Modifier';
  @override String get close => 'Fermer';
  @override String get back => 'Retour';
  @override String get next => 'Suivant';
  @override String get previous => 'Précédent';
  @override String get continue_ => 'Continuer';
  @override String get finish => 'Terminer';
  @override String get done => 'Terminé';
  @override String get retry => 'Réessayer';
  @override String get refresh => 'Actualiser';
  @override String get confirm => 'Confirmer';

  @override String get name => 'Nom';
  @override String get title => 'Titre';
  @override String get description => 'Description';
  @override String get priority => 'Priorité';
  @override String get category => 'Catégorie';
  @override String get tags => 'Tags';
  @override String get search => 'Recherche';
  @override String get filter => 'Filtre';
  @override String get sort => 'Trier';
  @override String get sortBy => 'Trier par';

  @override String get completed => 'Terminé';
  @override String get pending => 'En attente';
  @override String get inProgress => 'En cours';
  @override String get paused => 'En pause';
  @override String get cancelled => 'Annulé';
  @override String get active => 'Actif';
  @override String get inactive => 'Inactif';
  @override String get enabled => 'Activé';
  @override String get disabled => 'Désactivé';

  @override String get today => 'Aujourd\'hui';
  @override String get yesterday => 'Hier';
  @override String get tomorrow => 'Demain';
  @override String get thisWeek => 'Cette Semaine';
  @override String get lastWeek => 'Semaine Dernière';
  @override String get nextWeek => 'Semaine Prochaine';
  @override String get thisMonth => 'Ce Mois';
  @override String get lastMonth => 'Mois Dernier';
  @override String get nextMonth => 'Mois Prochain';

  @override String get high => 'Élevé';
  @override String get medium => 'Moyen';
  @override String get low => 'Faible';
  @override String get urgent => 'Urgent';
  @override String get normal => 'Normal';

  @override String get loading => 'Chargement...';
  @override String get saving => 'Sauvegarde...';
  @override String get deleting => 'Suppression...';
  @override String get updating => 'Mise à jour...';
  @override String get syncing => 'Synchronisation...';
  @override String get uploading => 'Téléversement...';
  @override String get downloading => 'Téléchargement...';

  @override String get noData => 'Aucune donnée';
  @override String get noResults => 'Aucun résultat';
  @override String get noItems => 'Aucun élément';
  @override String get empty => 'Vide';

  @override String get tapToSelect => 'Toucher pour sélectionner';
  @override String get tapToEdit => 'Toucher pour modifier';
  @override String get tapToDelete => 'Toucher pour supprimer';
  @override String get doubleTapToOpen => 'Double toucher pour ouvrir';
  @override String get swipeToDelete => 'Glisser pour supprimer';
  @override String get longPressForOptions => 'Appui long pour les options';
}