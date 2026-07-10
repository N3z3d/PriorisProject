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
  String get habitFormCategoryLabel => 'Kategorie';

  @override
  String get habitFormCategoryHint => 'Kategorie auswählen';

  @override
  String get habitFormCategoryNone => 'Keine Kategorie';

  @override
  String get habitFormCategoryCreate => '+ Neue Kategorie erstellen…';

  @override
  String get habitCategoryHelper =>
      'Empfohlen: Wähle eine Kategorie für bessere Statistiken.';

  @override
  String get habitCategoryWarningTitle => 'Keine Kategorie gewählt';

  @override
  String get habitCategoryWarningMessage =>
      'Du hast keine Kategorie gewählt. Trotzdem fortfahren?';

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
  String get habitTrackingModeCycle => 'M Tage von N';

  @override
  String get habitTrackingModeWeekdays => 'Bestimmte Wochentage';

  @override
  String get habitTrackingModeSpecificDate => 'An einem bestimmten Datum';

  @override
  String get habitTrackingCycleLabel => 'Zyklus';

  @override
  String get habitTrackingCycleActiveDays => 'Aktive Tage (M)';

  @override
  String get habitTrackingCycleLength => 'Zykluslänge (N)';

  @override
  String get habitTrackingCycleStartDate => 'Startdatum des Zyklus';

  @override
  String get habitTrackingWeekdaysLabel => 'Wochentage auswählen';

  @override
  String get habitTrackingSpecificDateLabel => 'Datum';

  @override
  String get habitTrackingRepeatEveryYear => 'Jedes Jahr wiederholen';

  @override
  String get habitTrackingBackToPeriod => 'Zurück zum Modus \"pro Zeitraum\"';

  @override
  String get habitTrackingPeriodDay => 'pro Tag';

  @override
  String get habitTrackingPeriodWeek => 'pro Woche';

  @override
  String get habitTrackingPeriodMonth => 'pro Monat';

  @override
  String get habitTrackingPeriodQuarter => 'pro Quartal';

  @override
  String get habitTrackingPeriodSemester => 'pro Semester';

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
  String get addList => 'Eine Liste hinzufugen';

  @override
  String get listsEmptyTitle => 'Noch keine Liste';

  @override
  String get listsEmptySubtitle =>
      'Fuge deine erste Liste hinzu, um loszulegen';

  @override
  String get listEmptyTitle => 'Keine Elemente gefunden';

  @override
  String get listEmptySearchBody => 'Versuche einen anderen Suchbegriff';

  @override
  String get listEmptyNoItemsBody =>
      'Fuge dein erstes Element hinzu, um loszulegen';

  @override
  String get listsOverviewTitle => 'Behalte deine Listen auf einen Blick';

  @override
  String listsOverviewSubtitle(int totalLists, int totalItems) {
    return '$totalLists Listen | $totalItems aktive Elemente';
  }

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
  String get insightsTabOverview => 'Übersicht';

  @override
  String get insightsTabTrends => 'Trends';

  @override
  String get insightsCtaCreateHabit => 'Eine Gewohnheit erstellen';

  @override
  String get insightsTrendsSuccessRate => 'Erfolgsrate';

  @override
  String get insightsTrendsStreak => 'Aktuelle Serie';

  @override
  String insightsTrendsStreakDays(int count) {
    return '$count T.';
  }

  @override
  String get insightsTrendsToday => 'Heute abgeschlossen';

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
  String get settingsGeneralSectionTitle => 'Allgemein';

  @override
  String get settingsPilotSectionTitle => 'Pilot';

  @override
  String get pilotIdentityBadge => 'Externer Pilot';

  @override
  String get settingsHelpFeedbackSectionTitle => 'Hilfe und Feedback';

  @override
  String get settingsAboutSectionTitle => 'Über';

  @override
  String get settingsPilotStatusTitle => 'Pilotstatus';

  @override
  String get settingsPilotStatusBody =>
      'Begrenzter externer Pilot. Prioris deckt derzeit die Shell, Listen, Priorisierung und grundlegende Gewohnheiten ab.';

  @override
  String get settingsPilotLimitsTitle => 'Aktuelle Grenzen';

  @override
  String get settingsPilotLimitsBody =>
      'Kein Billing, kein öffentlicher Support, kein gehostetes Hilfezentrum und kein Versprechen über den aktuellen Umfang hinaus.';

  @override
  String settingsVersionValue(String version) {
    return '$version';
  }

  @override
  String get settingsVersionFallbackLabel => 'Externer Pilot-Build';

  @override
  String settingsLanguageChanged(String language) {
    return 'Sprache geändert zu $language';
  }

  @override
  String get logout => 'Abmelden';

  @override
  String get homeLogoutHint => 'Meldet den aktuellen Nutzer ab';

  @override
  String get homeSettingsHint => 'Offnet die App-Einstellungen';

  @override
  String get homeMainContentLabel => 'Hauptinhalt';

  @override
  String get homePrimaryNavigationLabel => 'Hauptnavigation';

  @override
  String get homePrimaryNavigationHint =>
      'Nutze die Navigation, um zwischen den Bereichen zu wechseln';

  @override
  String homeNavigationAnnouncement(String section) {
    return 'Navigation zu $section';
  }

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
  String get todayPanelSubtitle =>
      'Die wenigen Elemente, die jetzt deine Aufmerksamkeit verdienen';

  @override
  String todayPanelCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count verlassliche Elemente',
      one: '$count verlassliches Element',
    );
    return '$_temp0';
  }

  @override
  String get todayPanelLoading => 'Deine Ansicht fur heute wird vorbereitet...';

  @override
  String get todayPanelCalmTitle => 'Im Moment nichts Dringendes';

  @override
  String get todayPanelCalmBody =>
      'Dein Tag wirkt ruhig. Mach in deinen Listen oder Gewohnheiten weiter, wenn du vorankommen willst.';

  @override
  String get todayPanelFirstUseTitle => 'Dein Bereich ist bereit';

  @override
  String get todayPanelFirstUseBody =>
      'Starte mit deiner ersten Liste oder Gewohnheit. Deine nachsten Aktionen erscheinen hier.';

  @override
  String get todayPanelPartial => 'Teilansicht: Einige Signale laden noch.';

  @override
  String get todayPanelError =>
      'Die Ansicht fur heute ist vorubergehend eingeschrankt.';

  @override
  String get todayPanelTaskKind => 'Aufgabe';

  @override
  String get todayPanelHabitKind => 'Gewohnheit';

  @override
  String get todayPanelStatusOverdue => 'Uberfallig';

  @override
  String get todayPanelStatusDueToday => 'Heute';

  @override
  String get todayPanelStatusPending => 'Zu prufen';

  @override
  String get todayPanelReasonOverdueTask => 'Aufgabe bereits uberfallig';

  @override
  String get todayPanelReasonDueTodayTask => 'Heute fallig';

  @override
  String get todayPanelReasonPriorityTask => 'Aufgabe mit hoher Wirkung';

  @override
  String get todayPanelReasonDueTodayHabit => 'Gewohnheit fur heute erwartet';

  @override
  String todayPanelParentListLabel(Object title) {
    return 'Liste: $title';
  }

  @override
  String get todayPanelActionOpenList => 'Liste offnen';

  @override
  String get todayPanelActionOpenDuel => 'Priorisieren';

  @override
  String get todayPanelActionRecordHabit => 'Als erledigt markieren';

  @override
  String get todayPanelActionRecordValue => 'Wert eintragen';

  @override
  String get todayPanelActionOpenHabits => 'Gewohnheiten offnen';

  @override
  String get todayPanelActionUnavailable =>
      'Diese Aktion ist im aktuellen Zustand nicht mehr verfugbar.';

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
  String get insightsHeaderTitle => 'Behalte deinen Fortschritt im Blick';

  @override
  String get insightsHeaderSubtitleEmpty =>
      'Erstelle Gewohnheiten, um deine ersten Einblicke freizuschalten.';

  @override
  String insightsHeaderSubtitleWithHabits(int count) {
    return 'Uberblick und Trends fur deine $count Gewohnheiten';
  }

  @override
  String get insightsEmptyTitle => 'Noch keine Einblicke';

  @override
  String get insightsEmptyBody =>
      'Erstelle deine erste Gewohnheit, um hier deine ersten Einblicke freizuschalten.';

  @override
  String get insightsOverviewPlaceholder =>
      'Dein Uberblick erscheint hier bald.';

  @override
  String get insightsTrendsPlaceholder => 'Deine Trends erscheinen hier bald.';

  @override
  String get recommendations => 'Empfehlungen';

  @override
  String get suggestions => 'Vorschläge';

  @override
  String get tips => 'Tipps';

  @override
  String get help => 'Hilfe';

  @override
  String get settingsHelpSubtitle =>
      'Verstehen, wie Sie in diesem Pilot Hilfe erhalten.';

  @override
  String get settingsHelpDialogBody =>
      'Der Support fuer diesen Pilot bleibt manuell und bewusst begrenzt. Nutzen Sie den Pilot-Feedback-Kanal, um eine Frage zu stellen, ein Problem zu melden oder einen Bedarf zu teilen. Es gibt weder Echtzeit-Support noch ein oeffentliches SLA.';

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
  String get settingsFeedbackSubtitle =>
      'Den Feedback-Kanal des Piloten oeffnen.';

  @override
  String get settingsFeedbackDialogBody =>
      'Der Feedback-Kanal des Piloten oeffnet ein einfaches Formular in Ihrem Browser. Er wird auch fuer Hilfe, Fehler und Funktionswuensche verwendet.';

  @override
  String get reportBug => 'Fehler melden';

  @override
  String get settingsReportBugSubtitle =>
      'Denselben Pilot-Kanal fuer eine Fehlermeldung nutzen.';

  @override
  String get settingsReportBugDialogBody =>
      'Fehler werden ueber denselben Pilot-Kanal wie allgemeines Feedback gemeldet. Beschreiben Sie den sichtbaren Kontext, das Geraet und das beobachtete Ergebnis.';

  @override
  String get requestFeature => 'Funktion anfordern';

  @override
  String get settingsRequestFeatureSubtitle =>
      'Denselben Pilot-Kanal nutzen, um einen Bedarf zu teilen.';

  @override
  String get settingsRequestFeatureDialogBody =>
      'Funktionswuensche laufen ueber denselben Pilot-Kanal. Sie werden manuell geprueft und sind keine Lieferzusage.';

  @override
  String get settingsSupportLaunchFailureBody =>
      'Dieser Kanal konnte nicht automatisch geoeffnet werden. Nutzen Sie diesen Link in Ihrem Browser:';

  @override
  String get settingsSupportUnavailableBody =>
      'Diese Build konfiguriert noch keinen Support-Kanal fuer den Pilot. Fuegen Sie vor einer externen Pilot-Freigabe eine Feedback-URL oder eine Support-E-Mail hinzu.';

  @override
  String get privacyPolicy => 'Datenschutzrichtlinie';

  @override
  String get settingsPrivacySubtitle =>
      'Lesen, wie Pilotdaten behandelt werden.';

  @override
  String get settingsPrivacyDialogBody =>
      'Prioris speichert nur die Daten, die fuer diesen Pilot noetig sind: Konto, Listen, Aufgaben, Gewohnheiten und zugehoerige Sync-Signale. Diese Daten werden genutzt, um das Produkt zu betreiben, gemeldete Probleme zu beheben und den Pilot zu bewerten. Wenn Sie Fragen zu Ihren Daten haben, nutzen Sie den Pilot-Feedback-Kanal.';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get settingsTermsSubtitle =>
      'Den minimalen Nutzungsrahmen dieses Piloten lesen.';

  @override
  String get settingsTermsDialogBody =>
      'Dieser Pilot ist fuer eine kleine eingeladene Gruppe bestimmt. Zugang, Funktionen und Verfuegbarkeit koennen sich ohne Vorankuendigung aendern. Nutzen Sie Prioris nicht als kritisches System oder als einzige Wahrheitsquelle fuer sensible Entscheidungen. Feedback ist willkommen, aber weder ein sofortiger Fix noch eine oeffentliche Freigabe sind garantiert.';

  @override
  String get license => 'Lizenz';

  @override
  String get settingsLicenseSubtitle =>
      'Die in dieser Version enthaltenen Lizenzen öffnen.';

  @override
  String get settingsAboutLegalese =>
      'Begrenzter externer Pilot. Manueller Support ueber den Pilot-Kanal, noch ohne Preise oder oeffentliche Zusage.';

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
  String get habitsActionCreateSuccess => 'Gewohnheit erstellt ✅';

  @override
  String habitsActionCreateError(String error) {
    return 'Fehler beim Erstellen: $error';
  }

  @override
  String habitsActionUpdateSuccess(String habitName) {
    return 'Gewohnheit \"$habitName\" aktualisiert';
  }

  @override
  String habitsActionUpdateError(String error) {
    return 'Fehler beim Aktualisieren: $error';
  }

  @override
  String habitsActionDeleteSuccess(String habitName) {
    return 'Gewohnheit \"$habitName\" gelöscht';
  }

  @override
  String habitsActionDeleteError(String error) {
    return 'Gewohnheit konnte nicht gelöscht werden: $error';
  }

  @override
  String habitsActionRecordSuccess(String habitName) {
    return 'Gewohnheit \"$habitName\" eingetragen';
  }

  @override
  String habitsActionRecordError(String error) {
    return 'Fehler beim Eintragen: $error';
  }

  @override
  String get habitsLoadingRecord => 'Wird eingetragen...';

  @override
  String get habitsLoadingDelete => 'Wird gelöscht...';

  @override
  String habitsActionUnsupported(String action) {
    return 'Nicht unterstützte Aktion: $action';
  }

  @override
  String get habitsDialogDeleteTitle => 'Gewohnheit löschen';

  @override
  String habitsDialogDeleteMessage(String habitName) {
    return 'Gewohnheit \"$habitName\" löschen?\nDiese Aktion ist unwiderruflich und löscht auch den Verlauf.';
  }

  @override
  String get habitsButtonCreate => 'Eine Gewohnheit erstellen';

  @override
  String get habitsHeaderTitle => 'Meine Gewohnheiten';

  @override
  String get habitsHeaderSubtitle => 'Verfolge deinen Fortschritt täglich';

  @override
  String get habitsHeroTitle => 'Meine Gewohnheiten';

  @override
  String get habitsHeroSubtitle =>
      'Erstelle und verfolge deine täglichen Gewohnheiten';

  @override
  String get habitsTabHabits => 'Gewohnheiten';

  @override
  String get habitsTabAdd => 'Hinzufügen';

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
    return '$successful/$total erfolgreiche Tage';
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
  String habitFrequencyTimesPerQuarter(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Quartal',
      one: '$count Mal pro Quartal',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerSemester(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Mal pro Semester',
      one: '$count Mal pro Semester',
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
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'alle $interval Stunden',
      one: 'stündlich',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryDays(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'alle $interval Tage',
      one: 'täglich',
    );
    return '$_temp0';
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
  String habitFrequencyEveryQuarters(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'alle $interval Quartale',
      one: 'vierteljährlich',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyDaysPerCycle(Object daysActive, Object daysCycle) {
    return '$daysActive Tage von $daysCycle';
  }

  @override
  String habitFrequencySpecificDateAnnual(String date) {
    return 'Jedes Jahr am $date';
  }

  @override
  String habitFrequencySpecificDateOnce(String date) {
    return 'Am $date';
  }

  @override
  String habitFrequencyEveryYears(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'alle $interval Jahre',
      one: 'jährlich',
    );
    return '$_temp0';
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
  String bulkAddImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente importiert',
      one: '$count Element importiert',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddImportError => 'Import fehlgeschlagen';

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

  @override
  String get authOfflineSignInError =>
      'Die Anmeldung ist im Offline-Modus nicht verfÃ¼gbar. Konfiguriere echte Supabase-Zugangsdaten in .env, um Online-Funktionen zu aktivieren.';

  @override
  String get authOfflineSignUpError =>
      'Die Registrierung ist im Offline-Modus nicht verfÃ¼gbar. Konfiguriere echte Supabase-Zugangsdaten in .env, um Online-Funktionen zu aktivieren.';

  @override
  String get authLoginTitle => 'Anmelden';

  @override
  String get authSignUpTitle => 'Konto erstellen';

  @override
  String get authSignInAction => 'Anmelden';

  @override
  String get authSignUpAction => 'Konto erstellen';

  @override
  String get authToggleToSignUp => 'Noch kein Konto? Jetzt erstellen';

  @override
  String get authToggleToSignIn => 'Schon ein Konto? Anmelden';

  @override
  String get authForgotPasswordAction => 'Passwort vergessen?';

  @override
  String get authEmailLabel => 'E-Mail';

  @override
  String get authEmailHint => 'du@beispiel.de';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authPasswordHint => '********';

  @override
  String get authTechnicalFieldLabel => 'Technisches Feld (leer lassen)';

  @override
  String get authPendingConfirmationTitle => 'Bestatigung erforderlich';

  @override
  String authPendingConfirmationMessage(String email) {
    return 'Eine Bestatigungs-E-Mail wurde an $email gesendet. Bestatige deine E-Mail-Adresse, um die Registrierung abzuschliessen, und melde dich dann erneut an.';
  }

  @override
  String get authCallbackExpiredMessage =>
      'Dein Anmelde-Link ist abgelaufen oder wurde in einem anderen Browser geöffnet. Bitte melde dich erneut an.';

  @override
  String get duplicateWarningTitle => 'Duplikat erkannt';

  @override
  String duplicateWarningSingle(String title) {
    return 'Das Element \"$title\" ist bereits in deiner Liste.';
  }

  @override
  String duplicateWarningMultiple(int duplicateCount, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      duplicateCount,
      locale: localeName,
      other: '$duplicateCount Elemente sind bereits',
      one: '$duplicateCount Element ist bereits',
    );
    return '$_temp0 in deiner Liste (von $total).';
  }

  @override
  String duplicateWarningSkipAction(int uniqueCount) {
    return 'Duplikate überspringen ($uniqueCount hinzufügen)';
  }

  @override
  String get duplicateWarningAddAllSingle => 'Trotzdem hinzufügen';

  @override
  String duplicateWarningAddAllBulk(int count) {
    return 'Alle hinzufügen ($count)';
  }

  @override
  String bulkAddImportSuccessWithSkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Elemente importiert',
      one: '$count Element importiert',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped Duplikate übersprungen',
      one: '$skipped Duplikat übersprungen',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get errorGenericTitle => 'Ein Fehler ist aufgetreten';

  @override
  String get errorNetworkTitle => 'Verbindungsproblem';

  @override
  String get errorNetworkMessage =>
      'Überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorGenericMessage =>
      'Ein unerwarteter Fehler ist aufgetreten. Bitte versuche es erneut.';

  @override
  String get loadingListDetail => 'Deine Liste wird geladen...';

  @override
  String get noListsTitle => 'Keine Listen verfügbar';

  @override
  String get noListsBody => 'Erstelle deine erste Liste, um loszulegen.';

  @override
  String get settingsFeatureInDevelopment => 'Funktion in Entwicklung';

  @override
  String get archiveAction => 'Archivieren';

  @override
  String get listCreateDialogTitle => 'Neue Liste';

  @override
  String get listCreateError =>
      'Liste konnte nicht erstellt werden. Versuche es erneut.';

  @override
  String listEditError(String error) {
    return 'Fehler beim Bearbeiten: $error';
  }

  @override
  String listDeleteError(String error) {
    return 'Fehler beim Löschen: $error';
  }

  @override
  String get logoutKeepDataAction => 'Daten behalten';

  @override
  String get logoutClearDataAction => 'Daten löschen';

  @override
  String listCreatedSuccess(String title) {
    return 'Liste \"$title\" erfolgreich erstellt';
  }

  @override
  String listUpdatedSuccess(String name) {
    return 'Liste \"$name\" erfolgreich aktualisiert';
  }

  @override
  String listDeletedSuccess(String name) {
    return 'Liste \"$name\" erfolgreich gelöscht';
  }

  @override
  String get logoutDataQuestion =>
      'Was möchtest du mit deinen lokalen Daten tun?';

  @override
  String get logoutLocalDataInfo =>
      'Deine Listen sind lokal auf diesem Gerät gespeichert';

  @override
  String get privacyConsentTitle => 'Datenschutz';

  @override
  String get privacyConsentBody =>
      'Ohne deine Einwilligung können wir deine personenbezogenen Daten (Aufgaben, Gewohnheiten, Profil) nicht verarbeiten. Sie werden sicher gespeichert und niemals zu Werbezwecken an Dritte weitergegeben.';

  @override
  String get privacyConsentAcceptButton => 'Ich stimme zu und fahre fort';

  @override
  String get privacyConsentReadPolicyLink => 'Datenschutzrichtlinie lesen';

  @override
  String get consentGateSignOutError =>
      'Abmeldung fehlgeschlagen. Bitte versuche es erneut.';

  @override
  String get consentGateActionPrompt => 'Was möchten Sie tun?';

  @override
  String get privacyPolicyTitle => 'Datenschutzrichtlinie';

  @override
  String get settingsPrivacySectionTitle => 'DATENSCHUTZ UND DATEN';

  @override
  String get settingsPrivacyPolicyTile => 'Datenschutzrichtlinie';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Unsere Datenschutzpraktiken ansehen';

  @override
  String get settingsRevokeConsentTile => 'Einwilligung widerrufen';

  @override
  String get settingsRevokeConsentSubtitle =>
      'Zugriff auf Ihre persönlichen Daten widerrufen';

  @override
  String get settingsRevokeConsentDialogTitle => 'Einwilligung widerrufen';

  @override
  String get settingsRevokeConsentDialogBody =>
      'Sie werden sofort zur Einwilligungsseite weitergeleitet. Sie können jederzeit erneut zustimmen.';

  @override
  String get settingsRevokeConsentDialogConfirm => 'Widerrufen';

  @override
  String get settingsRevokeConsentDialogCancel => 'Abbrechen';

  @override
  String get settingsRevokeConsentError =>
      'Fehler beim Widerrufen der Einwilligung. Bitte versuchen Sie es erneut.';

  @override
  String get settingsRevokeConsentSuccess =>
      'Einwilligung widerrufen. Abmeldung läuft…';

  @override
  String get settingsDeleteAccountTile => 'Mein Konto löschen';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Löschung deiner Daten beantragen';

  @override
  String get settingsDeleteAccountDialogTitle => 'Konto löschen';

  @override
  String get settingsDeleteAccountDialogBody =>
      'Um dein Konto und alle deine persönlichen Daten zu löschen, sende eine E-Mail an:';

  @override
  String get settingsDeleteAccountDialogCopyEmail => 'E-Mail-Adresse kopieren';

  @override
  String get settingsDeleteAccountEmailCopied => 'E-Mail-Adresse kopiert';

  @override
  String importInterruptedBanner(int current, int total) {
    return 'Import unterbrochen — $current/$total Elemente hinzugefügt';
  }

  @override
  String get ok => 'OK';

  @override
  String get importDoNotClose =>
      'Schließen Sie die App nicht während des Imports';

  @override
  String importResumeBanner(int current, int total, int remaining) {
    return 'Import unterbrochen — $current/$total hinzugefügt · $remaining ausstehend';
  }

  @override
  String get importResumeConfirm => 'Fortsetzen';

  @override
  String get importResumeIgnore => 'Verwerfen';

  @override
  String get taskNewDialogTitle => 'Neue Aufgabe';

  @override
  String get taskAddedSuccess => 'Aufgabe erfolgreich hinzugefügt';

  @override
  String get taskTitleFieldLabel => 'Titel';

  @override
  String get taskDescriptionFieldLabel => 'Beschreibung (optional)';

  @override
  String get clearAllDataAction => 'Alles löschen';

  @override
  String get clearDataAndSignOut => 'Daten löschen und abmelden';

  @override
  String get tasksPageTitle => 'Meine Aufgaben';

  @override
  String get tasksFabAddLabel => 'Eine neue Aufgabe hinzufügen';

  @override
  String get tasksFabAddHint =>
      'Öffnet ein Formular zum Erstellen einer neuen Aufgabe';

  @override
  String get tasksFabAddTooltip => 'Aufgabe hinzufügen';

  @override
  String get tasksEmptyStateLabel => 'Leerer Zustand: keine Aufgaben';

  @override
  String get tasksEmptyStateHint =>
      'Nutze die Hinzufügen-Schaltfläche, um deine erste Aufgabe zu erstellen';

  @override
  String get tasksIconLabel => 'Aufgabensymbol';

  @override
  String get tasksEmptyTitle => 'Keine Aufgaben';

  @override
  String get tasksEmptyBody => 'Füge deine erste Aufgabe hinzu, um zu beginnen';

  @override
  String tasksItemLabel(String title) {
    return 'Aufgabe: $title';
  }

  @override
  String get tasksStatusCompleted => 'Abgeschlossen';

  @override
  String get tasksStatusInProgress => 'Laufend';

  @override
  String get tasksItemHintCompleted =>
      'Aufgabe abgeschlossen. Tippen für weitere Aktionen';

  @override
  String get tasksItemHintInProgress =>
      'Aufgabe läuft. Tippen für weitere Aktionen';

  @override
  String get tasksMarkDone => 'Als erledigt markieren';

  @override
  String get tasksMarkUndone => 'Als nicht erledigt markieren';

  @override
  String get tasksToggleHint =>
      'Direkt tippen, um den Aufgabenstatus umzuschalten';

  @override
  String tasksActionsLabel(String title) {
    return 'Aktionen für Aufgabe $title';
  }

  @override
  String get tasksActionsHint => 'Menü der verfügbaren Aktionen';

  @override
  String get tasksActionsTooltip => 'Aufgabenaktionen';

  @override
  String get tasksMarkDoneLong => 'Als abgeschlossen markieren';

  @override
  String get tasksMarkUndoneLong => 'Als nicht abgeschlossen markieren';

  @override
  String get tasksDeleteLabel => 'Aufgabe löschen';

  @override
  String get tasksDialogOpenAnnounce =>
      'Formular zur Aufgabenerstellung wird geöffnet';

  @override
  String get tasksCreateTooltip => 'Neue Aufgabe erstellen';

  @override
  String get taskDeletedAnnounce => 'Aufgabe gelöscht';

  @override
  String get taskUpdatedAnnounce => 'Aufgabe aktualisiert';

  @override
  String get habitCategoryDefault => 'Allgemein';

  @override
  String get habitActionCompleteLabel => 'Als abgeschlossen markieren';

  @override
  String get habitActionCompleteSubtitle => 'Hält deine Serie am Leben';

  @override
  String get habitActionSkipLabel => 'Verschieben';

  @override
  String get habitActionSkipSubtitle => 'Auf später verschieben';

  @override
  String habitStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '$days Tag',
    );
    return '$_temp0';
  }

  @override
  String habitWeeklyCompletions(int count) {
    return '$count/7 diese Woche';
  }

  @override
  String get listFormCreateTitle => 'Neue Liste erstellen';

  @override
  String get listFormEditTitle => 'Liste bearbeiten';

  @override
  String get listNameHint => 'z. B. Einkaufsliste, Paris-Reise…';

  @override
  String get listNameRequired =>
      'Der Listenname ist erforderlich, um sie zu identifizieren';

  @override
  String get listNameMinLength =>
      'Der Name muss mindestens 2 Zeichen enthalten';

  @override
  String listNameMaxLength(int count) {
    return 'Der Name darf 100 Zeichen nicht überschreiten (aktuell $count)';
  }

  @override
  String get listTypeLabel => 'Listentyp';

  @override
  String get listItemAddTitle => 'Element hinzufügen';

  @override
  String get listItemEditTitle => 'Element bearbeiten';

  @override
  String get listItemTitleHint =>
      'z. B. Projektbericht fertigstellen, Besprechungsraum buchen…';

  @override
  String get listItemTitleRequired =>
      'Der Titel ist erforderlich, um dieses Element zu identifizieren';

  @override
  String get listItemTitleMinLength =>
      'Der Titel muss mindestens 2 Zeichen enthalten';

  @override
  String listItemTitleMaxLength(int count) {
    return 'Der Titel darf 200 Zeichen nicht überschreiten (aktuell $count)';
  }

  @override
  String get categoryOptionalLabel => 'Kategorie (optional)';

  @override
  String get listItemCategoryHint => 'z. B. Arbeit, Persönlich, Dringend…';

  @override
  String get listNameRequiredLabel => 'Listenname *';

  @override
  String get customListNameHint => 'z. B. Wochenendeinkauf';

  @override
  String get customListDescriptionHint => 'Beschreibe den Inhalt dieser Liste…';

  @override
  String get listSelectionTitle => 'Listen zum Priorisieren auswählen';

  @override
  String get listSelectionEnabled => 'Nimmt an Duellen teil';

  @override
  String get listSelectionDisabled => 'Von Duellen ausgeschlossen';

  @override
  String get listSelectionRequireOne =>
      'Wähle mindestens eine Liste aus, um speichern zu können';

  @override
  String get habitDialogEditTitle => 'Gewohnheit bearbeiten';

  @override
  String get habitDialogNewTitle => 'Neue Gewohnheit';

  @override
  String habitRecordTitle(String habitName) {
    return '$habitName eintragen';
  }

  @override
  String get habitRecordCurrentValueLabel => 'Aktueller Wert für heute';

  @override
  String get habitRecordValueLabel => 'Wert';

  @override
  String habitRecordTarget(String target, String unit) {
    return 'Ziel: $target $unit';
  }

  @override
  String get logoutSuccessCleared => 'Abgemeldet und Daten gelöscht';

  @override
  String get logoutSuccessKept => 'Abgemeldet — deine Listen bleiben verfügbar';

  @override
  String get clearDataDoneTitle => 'Daten gelöscht!';

  @override
  String get clearDataTitle => 'Daten bereinigen';

  @override
  String get clearDataStatsHeader => 'Aktueller Stand deiner Daten:';

  @override
  String get clearDataStatLists => 'Benutzerdefinierte Listen';

  @override
  String get clearDataStatItems => 'Listenelemente';

  @override
  String get clearDataCleanOrphans => 'Verwaiste Daten bereinigen';

  @override
  String clearDataOrphansDetected(int count) {
    return '$count verwaiste Daten erkannt';
  }

  @override
  String get clearDataDangerZone => 'Gefahrenzone';

  @override
  String get clearDataDangerMessage =>
      'Diese Aktion löscht ALLE deine Daten (Listen, Elemente, Gewohnheiten). Diese Aktion ist unwiderruflich.';

  @override
  String get clearDataSuccessMessage =>
      'Alle deine Daten wurden erfolgreich gelöscht.';

  @override
  String get clearDataSuccessSubtext =>
      'Du kannst jetzt mit einem sauberen Neuanfang starten.';

  @override
  String get clearConfirmWarningLabel => 'Warnung - Destruktive Aktion';

  @override
  String get clearConfirmTitle => 'Daten löschen';

  @override
  String get clearConfirmBody1 =>
      'Diese Aktion löscht alle deine Listen dauerhaft von diesem Gerät.';

  @override
  String get clearConfirmBody2 =>
      'Du kannst diese Aktion nicht rückgängig machen.';

  @override
  String get clearConfirmHint =>
      'Unwiderrufliche Aktion - bestätige, um alle Daten dauerhaft zu löschen';

  @override
  String get forgotPasswordSentTitle => 'E-Mail gesendet!';

  @override
  String get forgotPasswordTitle => 'Passwort vergessen';

  @override
  String get emailAddressLabel => 'E-Mail-Adresse';

  @override
  String get emailRequired => 'E-Mail erforderlich';

  @override
  String get emailInvalid => 'Ungültige E-Mail';

  @override
  String get forgotPasswordSentTo =>
      'Eine E-Mail zum Zurücksetzen wurde gesendet an:';

  @override
  String get forgotPasswordCheckInbox =>
      'Überprüfe deinen Posteingang und folge den Anweisungen, um dein Passwort zurückzusetzen.';

  @override
  String get send => 'Senden';

  @override
  String get forgotPasswordIntro =>
      'Gib deine E-Mail-Adresse ein, um einen Link zum Zurücksetzen deines Passworts zu erhalten.';

  @override
  String get duelRankingSaved => 'Rangliste gespeichert';

  @override
  String get onboardingCaptureTitle => 'Woran denkst du gerade?';

  @override
  String get onboardingCaptureHint =>
      'Eine Aufgabe pro Zeile. Denk nicht zu lange nach.';

  @override
  String get onboardingArchetypesLabel => 'Schnelle Ideen';

  @override
  String onboardingTaskCounter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Aufgaben',
      one: '1 Aufgabe',
      zero: 'Keine Aufgaben',
    );
    return '$_temp0';
  }

  @override
  String get onboardingStartButton => 'Los geht\'s';

  @override
  String get onboardingDuelQuestion =>
      'Welche dieser beiden Aufgaben ist gerade wichtiger?';

  @override
  String onboardingDuelProgress(int index, int total) {
    return 'Duell $index/$total';
  }

  @override
  String get onboardingRevealTitle => 'Das willst du wirklich zuerst tun.';

  @override
  String get onboardingRevealContinue => 'Weiter zur App';

  @override
  String get onboardingRevealMarkDone =>
      'Als erledigt markieren, wenn es geschafft ist';

  @override
  String get onboardingSkip => 'Überspringen';

  @override
  String get onboardingArchetypeSport => 'Sport machen';

  @override
  String get onboardingArchetypeCall => 'Eine geliebte Person anrufen';

  @override
  String get onboardingArchetypeReport => 'Den Bericht fertigstellen';

  @override
  String get onboardingArchetypeEmails => 'Meine E-Mails sortieren';

  @override
  String get onboardingArchetypeGroceries => 'Einkaufen gehen';

  @override
  String get onboardingArchetypeRead => '10 Seiten lesen';

  @override
  String get onboardingArchetypeTidy => 'Den Schreibtisch aufräumen';

  @override
  String get onboardingArchetypeWater => 'Wasser trinken';
}
