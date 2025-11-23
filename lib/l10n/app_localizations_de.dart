// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Prioris';

  @override
  String get home => 'Startseite';

  @override
  String get habits => 'Gewohnheiten';

  @override
  String get tasks => 'Aufgaben';

  @override
  String get lists => 'Listen';

  @override
  String get habitFormTitleNew => 'Neue Gewohnheit';

  @override
  String get habitFormTitleEdit => 'Gewohnheit bearbeiten';

  @override
  String get habitFormIntro =>
      'Gib der Gewohnheit einen klaren Namen, ordne eine Kategorie zu und lege fest, wie du deinen Fortschritt verfolgst.';

  @override
  String get habitFormNameLabel => 'Name der Gewohnheit';

  @override
  String get habitFormNameHint => 'Z. B. 8 Gläser Wasser trinken';

  @override
  String get habitFormCategoryLabel => 'Kategorie (optional)';

  @override
  String get habitFormCategoryHint => 'Kategorie auswählen';

  @override
  String get habitFormCategoryNone => 'Keine Kategorie';

  @override
  String get habitFormCategoryCreate => '+ Neue Kategorie erstellen…';

  @override
  String get habitFormQuantTargetLabel => 'Ziel';

  @override
  String get habitFormQuantTargetHint => '8';

  @override
  String get habitFormQuantUnitLabel => 'Einheit';

  @override
  String get habitFormQuantUnitHint => 'Gläser';

  @override
  String get habitTrackingTitle =>
      'Wie möchtest du diese Gewohnheit verfolgen?';

  @override
  String get habitTrackingTip =>
      'Tipp: Gib 1 ein, wenn einmal pro Zeitraum reicht (entspricht \"erledigt / nicht erledigt\").';

  @override
  String get habitTrackingPrefix => 'Ich möchte diese Gewohnheit';

  @override
  String get habitTrackingTimesWord => 'Mal';

  @override
  String get habitTrackingEveryWord => 'alle';

  @override
  String get habitTrackingBackToPeriod => 'Zurück zum Modus \"pro Zeitraum\"';

  @override
  String get habitTrackingPeriodDay => 'pro Tag';

  @override
  String get habitTrackingPeriodWeek => 'pro Woche';

  @override
  String get habitTrackingPeriodMonth => 'pro Monat';

  @override
  String get habitTrackingPeriodYear => 'pro Jahr';

  @override
  String get habitTrackingCustomInterval => 'alle...';

  @override
  String get habitTrackingUnitHours => 'Stunden';

  @override
  String get habitTrackingUnitDays => 'Tage';

  @override
  String get habitTrackingUnitWeeks => 'Wochen';

  @override
  String get habitTrackingUnitMonths => 'Monate';

  @override
  String get habitSummaryTitle => 'Zusammenfassung';

  @override
  String get habitSummaryPlaceholder =>
      'Name und Häufigkeit ausfüllen, um die Zusammenfassung zu sehen.';

  @override
  String habitSummaryAction(Object name) {
    return 'Du willst $name';
  }

  @override
  String habitSummaryTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal',
      one: '$count Mal',
    );
    return '$_temp0';
  }

  @override
  String listItemDateLabel(String date) {
    return 'Hinzugefügt am $date';
  }

  @override
  String get listItemDateUnknown => 'Kein Datum';

  @override
  String get listItemActionComplete => 'Abschließen';

  @override
  String get listItemActionReopen => 'Wieder öffnen';

  @override
  String get listEditTooltip => 'Liste bearbeiten';

  @override
  String get listDeleteTooltip => 'Liste löschen';

  @override
  String get listEditDialogTitle => 'Liste bearbeiten';

  @override
  String get listEditNameLabel => 'Name der Liste';

  @override
  String get listEditSaved => 'Liste aktualisiert.';

  @override
  String get habitFormTypePrompt =>
      'Ich möchte diese Gewohnheit verfolgen, indem ich';

  @override
  String get habitFormTypeBinaryOption => 'abhake, wenn sie erledigt ist';

  @override
  String get habitFormTypeQuantOption => 'die erreichte Menge erfasse';

  @override
  String get habitFormTypeBinaryDescription =>
      'Ideal für Ja/Nein-Gewohnheiten: Hake sie jedes Mal ab, wenn du sie erledigst.';

  @override
  String get habitFormTypeQuantDescription =>
      'Verfolge eine messbare Menge mit einem numerischen Ziel und einer eigenen Einheit.';

  @override
  String get habitRecurrenceDaily => 'Täglich';

  @override
  String get habitRecurrenceWeekly => 'Wöchentlich';

  @override
  String get habitRecurrenceMonthly => 'Monatlich';

  @override
  String get habitRecurrenceTimesPerWeek => 'Mehrmals pro Woche';

  @override
  String get habitRecurrenceTimesPerDay => 'Mehrmals täglich';

  @override
  String get habitRecurrenceMonthlyDay => 'Bestimmter Tag im Monat';

  @override
  String get habitRecurrenceQuarterly => 'Vierteljährlich';

  @override
  String get habitRecurrenceYearly => 'Jährlich';

  @override
  String get habitRecurrenceHourlyInterval => 'Alle X Stunden';

  @override
  String get habitRecurrenceTimesPerHour => 'Mehrmals pro Stunde';

  @override
  String get habitRecurrenceWeekends => 'Wochenenden';

  @override
  String get habitRecurrenceWeekdays => 'Werktage';

  @override
  String get habitRecurrenceEveryXDays => 'Alle X Tage';

  @override
  String get habitRecurrenceSpecificWeekdays => 'Bestimmte Wochentage';

  @override
  String get habitFormSubmitCreate => 'Gewohnheit erstellen';

  @override
  String get habitFormValidationNameRequired =>
      'Bitte gib einen Namen für die Gewohnheit ein';

  @override
  String get statistics => 'Statistiken';

  @override
  String get prioritize => 'Priorisieren';

  @override
  String get addHabit => 'Gewohnheit hinzufügen';

  @override
  String get addTask => 'Aufgabe hinzufügen';

  @override
  String get addList => 'Liste hinzufügen';

  @override
  String get name => 'Name';

  @override
  String get description => 'Beschreibung';

  @override
  String get category => 'Kategorie';

  @override
  String get priority => 'Priorität';

  @override
  String get frequency => 'Häufigkeit';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get create => 'Erstellen';

  @override
  String get completed => 'Abgeschlossen';

  @override
  String get incomplete => 'Unvollständig';

  @override
  String get hideCompleted => 'Abgeschlossene ausblenden';

  @override
  String get showCompleted => 'Abgeschlossene anzeigen';

  @override
  String get hideEloScores => 'ELO-Punkte ausblenden';

  @override
  String get showEloScores => 'ELO-Punkte anzeigen';

  @override
  String get overview => 'Übersicht';

  @override
  String get habitsTab => 'Gewohnheiten';

  @override
  String get tasksTab => 'Aufgaben';

  @override
  String get totalPoints => 'Gesamtpunkte';

  @override
  String get successRate => 'Erfolgsrate';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get longestStreak => 'Längste Serie';

  @override
  String get language => 'Sprache';

  @override
  String get settings => 'Einstellungen';

  @override
  String get noData => 'Keine Daten verfügbar';

  @override
  String get loading => 'Lädt...';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get back => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get previous => 'Zurück';

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filtern';

  @override
  String get sort => 'Sortieren';

  @override
  String get clear => 'Löschen';

  @override
  String get apply => 'Anwenden';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get close => 'Schließen';

  @override
  String get open => 'Öffnen';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get export => 'Exportieren';

  @override
  String get import => 'Importieren';

  @override
  String get share => 'Teilen';

  @override
  String get copy => 'Kopieren';

  @override
  String get paste => 'Einfügen';

  @override
  String get cut => 'Ausschneiden';

  @override
  String get undo => 'Rückgängig';

  @override
  String get redo => 'Wiederholen';

  @override
  String get selectAll => 'Alles auswählen';

  @override
  String get deselectAll => 'Alles abwählen';

  @override
  String get select => 'Auswählen';

  @override
  String get deselect => 'Abwählen';

  @override
  String get all => 'Alle';

  @override
  String get none => 'Keine';

  @override
  String get today => 'Heute';

  @override
  String get yesterday => 'Gestern';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get lastWeek => 'Letzte Woche';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get lastMonth => 'Letzter Monat';

  @override
  String get thisYear => 'Dieses Jahr';

  @override
  String get lastYear => 'Letztes Jahr';

  @override
  String get days => 'Tage';

  @override
  String get hours => 'Stunden';

  @override
  String get minutes => 'Minuten';

  @override
  String get seconds => 'Sekunden';

  @override
  String get points => 'Punkte';

  @override
  String get items => 'Elemente';

  @override
  String get tasksCompleted => 'Aufgaben abgeschlossen';

  @override
  String get habitsCompleted => 'Gewohnheiten abgeschlossen';

  @override
  String get listsCompleted => 'Listen abgeschlossen';

  @override
  String listCompletionLabel(int completed, int total) {
    return '$completed von $total Elementen abgeschlossen';
  }

  @override
  String listCompletionProgress(String percent) {
    return '$percent% abgeschlossen';
  }

  @override
  String get progress => 'Fortschritt';

  @override
  String get performance => 'Leistung';

  @override
  String get analytics => 'Analysen';

  @override
  String get insights => 'Einblicke';

  @override
  String get recommendations => 'Empfehlungen';

  @override
  String get suggestions => 'Vorschläge';

  @override
  String get tips => 'Tipps';

  @override
  String get help => 'Hilfe';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Entwickler';

  @override
  String get contact => 'Kontakt';

  @override
  String get feedback => 'Feedback';

  @override
  String get reportBug => 'Fehler melden';

  @override
  String get requestFeature => 'Funktion anfordern';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get license => 'Lizenz';

  @override
  String get credits => 'Credits';

  @override
  String get changelog => 'Änderungsprotokoll';

  @override
  String get updateAvailable => 'Update verfügbar';

  @override
  String get updateNow => 'Jetzt aktualisieren';

  @override
  String get later => 'Später';

  @override
  String get never => 'Nie';

  @override
  String get always => 'Immer';

  @override
  String get sometimes => 'Manchmal';

  @override
  String get rarely => 'Selten';

  @override
  String get often => 'Oft';

  @override
  String get daily => 'Täglich';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get monthly => 'Monatlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get custom => 'Benutzerdefiniert';

  @override
  String get automatic => 'Automatisch';

  @override
  String get manual => 'Manuell';

  @override
  String get enabled => 'Aktiviert';

  @override
  String get disabled => 'Deaktiviert';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get connected => 'Verbunden';

  @override
  String get disconnected => 'Getrennt';

  @override
  String get synchronized => 'Synchronisiert';

  @override
  String get notSynchronized => 'Nicht synchronisiert';

  @override
  String get synchronizing => 'Synchronisiere...';

  @override
  String get syncFailed => 'Synchronisation fehlgeschlagen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get skip => 'Überspringen';

  @override
  String get finish => 'Beenden';

  @override
  String get complete => 'Vollständig';

  @override
  String get pending => 'Ausstehend';

  @override
  String get processing => 'Verarbeite...';

  @override
  String get waiting => 'Warte...';

  @override
  String get ready => 'Bereit';

  @override
  String get notReady => 'Nicht bereit';

  @override
  String get available => 'Verfügbar';

  @override
  String get unavailable => 'Nicht verfügbar';

  @override
  String get busy => 'Beschäftigt';

  @override
  String get free => 'Frei';

  @override
  String get occupied => 'Besetzt';

  @override
  String get empty => 'Leer';

  @override
  String get full => 'Voll';

  @override
  String get partial => 'Teilweise';

  @override
  String get exact => 'Exakt';

  @override
  String get approximate => 'Ungefähr';

  @override
  String get estimated => 'Geschätzt';

  @override
  String get actual => 'Tatsächlich';

  @override
  String get planned => 'Geplant';

  @override
  String get unplanned => 'Ungeplant';

  @override
  String get scheduled => 'Geplant';

  @override
  String get unscheduled => 'Nicht geplant';

  @override
  String get overdue => 'Überfällig';

  @override
  String get onTime => 'Pünktlich';

  @override
  String get early => 'Früh';

  @override
  String get late => 'Spät';

  @override
  String get urgent => 'Dringend';

  @override
  String get high => 'Hoch';

  @override
  String get medium => 'Mittel';

  @override
  String get low => 'Niedrig';

  @override
  String get critical => 'Kritisch';

  @override
  String get important => 'Wichtig';

  @override
  String get normal => 'Normal';

  @override
  String get minor => 'Gering';

  @override
  String get trivial => 'Trivial';

  @override
  String get personal => 'Persönlich';

  @override
  String get work => 'Arbeit';

  @override
  String get health => 'Gesundheit';

  @override
  String get fitness => 'Fitness';

  @override
  String get education => 'Bildung';

  @override
  String get finance => 'Finanzen';

  @override
  String get social => 'Sozial';

  @override
  String get family => 'Familie';

  @override
  String get hobby => 'Hobby';

  @override
  String get travel => 'Reisen';

  @override
  String get shopping => 'Einkaufen';

  @override
  String get entertainment => 'Unterhaltung';

  @override
  String get other => 'Andere';

  @override
  String get defaultValue => 'Standard';

  @override
  String get continueLabel => 'Fortfahren';

  @override
  String get duelPriorityTitle => 'Prioritätsmodus';

  @override
  String get duelPrioritySubtitle => 'Welche Aufgabe bevorzugst du?';

  @override
  String get duelPriorityHint =>
      'Tippe auf die Karte, die du priorisieren möchtest.';

  @override
  String get duelSkipAction => 'Duell überspringen';

  @override
  String get duelRandomAction => 'Zufälliges Ergebnis';

  @override
  String get duelShowElo => 'Elo anzeigen';

  @override
  String get duelHideElo => 'Elo verbergen';

  @override
  String get duelModeLabel => 'Duellmodus';

  @override
  String get duelModeWinner => 'Gewinner';

  @override
  String get duelModeRanking => 'Rangliste';

  @override
  String get duelCardsPerRoundLabel => 'Karten pro Runde';

  @override
  String duelCardsPerRoundOption(int count) {
    return '$count Karten';
  }

  @override
  String duelModeSummary(String mode, int count) {
    return 'Duellmodus: $mode - $count Karten';
  }

  @override
  String get duelSubmitRanking => 'Rangliste speichern';

  @override
  String get duelPreferenceSaved => 'Präferenz gespeichert ✅';

  @override
  String duelRemainingDuels(int count) {
    return '$count Duelle heute übrig';
  }

  @override
  String get duelConfigureLists => 'Listen für Duelle auswählen';

  @override
  String get duelNoAvailableLists => 'Keine Liste verfügbar';

  @override
  String get duelNoAvailableListsForPrioritization =>
      'Keine Liste für die Priorisierung verfügbar';

  @override
  String get duelListsUpdated => 'Priorisierungslisten aktualisiert';

  @override
  String get duelNewDuel => 'Neues Duell';

  @override
  String get duelNotEnoughTasksTitle => 'Nicht genügend Aufgaben';

  @override
  String get duelNotEnoughTasksMessage =>
      'Füge mindestens zwei Aufgaben hinzu, um zu priorisieren.';

  @override
  String get duelErrorMessage =>
      'Duell konnte nicht geladen werden. Bitte erneut versuchen.';

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
  String get habitCategoryDialogTitle => 'Neue Kategorie';

  @override
  String get habitCategoryDialogFieldHint => 'Kategorienamen eingeben';

  @override
  String get habitsEmptyTitle => 'Noch keine Gewohnheiten';

  @override
  String get habitsEmptySubtitle =>
      'Erstelle deine erste Gewohnheit, um zu starten.';

  @override
  String get habitsErrorTitle => 'Fehler';

  @override
  String habitsErrorLoadFailure(Object error) {
    return 'Gewohnheiten konnten nicht geladen werden.';
  }

  @override
  String get habitsMenuTooltip => 'Aktionen';

  @override
  String get habitsMenuRecord => 'Eintragen';

  @override
  String get habitsMenuEdit => 'Bearbeiten';

  @override
  String get habitsMenuDelete => 'Löschen';

  @override
  String get habitsCategoryDefault => 'Allgemein';

  @override
  String get habitProgressThisWeek => 'Diese Woche';

  @override
  String habitProgressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage Serie',
      one: '$count Tag Serie',
    );
    return '$_temp0';
  }

  @override
  String habitProgressSuccessfulDays(Object successful, Object total) {
    return 'Erfolgreiche Tage';
  }

  @override
  String get habitProgressCompletedToday => 'Heute erledigt';

  @override
  String get habitsErrorNetwork => 'Netzwerkproblem';

  @override
  String get habitsErrorTimeout => 'Zeitüberschreitung';

  @override
  String get habitsErrorPermission => 'Berechtigung verweigert';

  @override
  String get habitsErrorUnexpected => 'Unerwarteter Fehler';

  @override
  String get habitFrequencySelectorTitle => 'Frequenz';

  @override
  String get habitFrequencyModelATitle => 'X-mal pro Zeitraum';

  @override
  String get habitFrequencyModelADescription =>
      'Leg fest, wie oft du die Gewohnheit pro Zeitraum erledigen willst.';

  @override
  String get habitFrequencyModelBTitle => 'Alle X Einheiten';

  @override
  String get habitFrequencyModelBDescription =>
      'Lege ein fixes Intervall zwischen zwei Wiederholungen fest.';

  @override
  String get habitFrequencyModelAFieldsLabel => 'Ziel pro Zeitraum';

  @override
  String get habitFrequencyModelBFieldsLabel => 'Intervall';

  @override
  String get habitFrequencyTimesLabel => 'Anzahl';

  @override
  String get habitFrequencyIntervalLabel => 'Intervall';

  @override
  String get habitFrequencyPeriodLabel => 'Zeitraum';

  @override
  String get habitFrequencyUnitLabel => 'Einheit';

  @override
  String get habitFrequencyPeriodHour => 'pro Stunde';

  @override
  String get habitFrequencyPeriodDay => 'pro Tag';

  @override
  String get habitFrequencyPeriodWeek => 'pro Woche';

  @override
  String get habitFrequencyPeriodMonth => 'pro Monat';

  @override
  String get habitFrequencyPeriodYear => 'pro Jahr';

  @override
  String get habitFrequencyUnitHours => 'Stunden';

  @override
  String get habitFrequencyUnitDays => 'Tage';

  @override
  String get habitFrequencyUnitWeeks => 'Wochen';

  @override
  String get habitFrequencyUnitMonths => 'Monate';

  @override
  String get habitFrequencyUnitQuarters => 'Quartale';

  @override
  String get habitFrequencyUnitYears => 'Jahre';

  @override
  String get habitFrequencyDayFilterLabel => 'Tage';

  @override
  String get habitFrequencyDayFilterAllDays => 'Alle Tage';

  @override
  String get habitFrequencyDayFilterWeekdays => 'Werktage';

  @override
  String get habitFrequencyDayFilterWeekends => 'Wochenende';

  @override
  String habitFrequencyTimesPerHour(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Stunde',
      one: '$count Mal pro Stunde',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerDay(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Tag',
      one: '$count Mal pro Tag',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerWeek(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Woche',
      one: '$count Mal pro Woche',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerMonth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Monat',
      one: '$count Mal pro Monat',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Jahr',
      one: '$count Mal pro Jahr',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryHours(num interval, Object count) {
    return 'Alle $count Stunden';
  }

  @override
  String habitFrequencyEveryDays(num interval, Object count) {
    return 'Alle $count Tage';
  }

  @override
  String habitFrequencyEveryWeeks(num interval, Object count) {
    return 'Alle $count Wochen';
  }

  @override
  String habitFrequencyEveryMonths(num interval, Object count) {
    return 'Alle $count Monate';
  }

  @override
  String habitFrequencyEveryQuarters(num interval, Object count) {
    return 'Alle $count Quartale';
  }

  @override
  String habitFrequencyEveryYears(num interval, Object count) {
    return 'Alle $count Jahre';
  }

  @override
  String get habitFrequencyWeekdaysOnly => 'Nur werktags';

  @override
  String get habitFrequencyWeekendsOnly => 'Nur am Wochenende';

  @override
  String habitFrequencySpecificDays(Object days) {
    return 'Bestimmte Tage: $days';
  }

  @override
  String habitFrequencyMonthlyOnDay(Object day) {
    return 'Jeden Monat am $day';
  }

  @override
  String habitFrequencyYearlyOnDate(Object day, Object month) {
    return 'Jedes Jahr am $day $month';
  }

  @override
  String get habitWeekdayMonday => 'Montag';

  @override
  String get habitWeekdayTuesday => 'Dienstag';

  @override
  String get habitWeekdayWednesday => 'Mittwoch';

  @override
  String get habitWeekdayThursday => 'Donnerstag';

  @override
  String get habitWeekdayFriday => 'Freitag';

  @override
  String get habitWeekdaySaturday => 'Samstag';

  @override
  String get habitWeekdaySunday => 'Sonntag';

  @override
  String get habitMonthJanuary => 'Januar';

  @override
  String get habitMonthFebruary => 'Februar';

  @override
  String get habitMonthMarch => 'März';

  @override
  String get habitMonthApril => 'April';

  @override
  String get habitMonthMay => 'Mai';

  @override
  String get habitMonthJune => 'Juni';

  @override
  String get habitMonthJuly => 'Juli';

  @override
  String get habitMonthAugust => 'August';

  @override
  String get habitMonthSeptember => 'September';

  @override
  String get habitMonthOctober => 'Oktober';

  @override
  String get habitMonthNovember => 'November';

  @override
  String get habitMonthDecember => 'Dezember';

  @override
  String get sortBy => 'Sortieren nach';

  @override
  String get scoreElo => 'ELO-Wert';

  @override
  String get random => 'Zufällig';

  @override
  String get orderAscending => 'Aufsteigend';

  @override
  String get orderDescending => 'Absteigend';

  @override
  String itemsCount(int count) {
    return '$count Elemente';
  }

  @override
  String get add => 'Hinzufügen';

  @override
  String get keepOpenAfterAdd => 'Nach dem Hinzufügen geöffnet lassen';

  @override
  String get bulkAddSingleHint => 'Gib ein Element pro Zeile ein.';

  @override
  String get bulkAddMultipleHint => 'Füge mehrere Zeilen auf einmal ein.';

  @override
  String get bulkAddHelpText =>
      'Füge mehrere Elemente in einem Durchgang hinzu.';

  @override
  String get closeDialog => 'Schließen';

  @override
  String get bulkAddDefaultTitle => 'Mehrere Elemente hinzufügen';

  @override
  String get bulkAddSubmitting => 'Wird hinzugefügt...';

  @override
  String get bulkAddModeSingle => 'Einzeln hinzufügen';

  @override
  String get bulkAddModeMultiple => 'Mehrere hinzufügen';

  @override
  String get listDeleteDialogTitle => 'Liste löschen';

  @override
  String listDeleteDialogMessage(String listName) {
    return 'Möchten Sie \"$listName\" wirklich löschen?';
  }

  @override
  String get listDeleteConfirm => 'Löschen';

  @override
  String get listRenameDialogTitle => 'Element umbenennen';

  @override
  String get listRenameDialogLabel => 'Name des Elements';

  @override
  String get listRenameSaved => 'Element umbenannt.';

  @override
  String get listMoveDialogTitle => 'Element verschieben';

  @override
  String get listMoveDialogLabel => 'Zielliste';

  @override
  String get listMoveNoOtherList => 'Keine andere Liste verfügbar';

  @override
  String get listMoveSaved => 'Element verschoben.';

  @override
  String get listDuplicateSaved => 'Element dupliziert.';

  @override
  String get listConfirmDeleteItemTitle => 'Element löschen';

  @override
  String listConfirmDeleteItemMessage(String itemTitle) {
    return 'Möchten Sie \"$itemTitle\" wirklich löschen?';
  }

  @override
  String get more => 'Weitere Aktionen';

  @override
  String get rename => 'Umbenennen';

  @override
  String get move => 'Verschieben...';

  @override
  String get duplicate => 'Duplizieren';
}
