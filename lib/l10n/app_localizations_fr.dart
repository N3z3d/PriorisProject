// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Prioris';

  @override
  String get home => 'Accueil';

  @override
  String get habits => 'Habitudes';

  @override
  String get tasks => 'Tâches';

  @override
  String get lists => 'Listes';

  @override
  String get habitFormTitleNew => 'Nouvelle habitude';

  @override
  String get habitFormTitleEdit => 'Modifier l\'habitude';

  @override
  String get habitFormIntro =>
      'Donnez un nom clair, associez une catégorie et choisissez comment suivre votre progression.';

  @override
  String get habitFormNameLabel => 'Nom de l\'habitude';

  @override
  String get habitFormNameHint => 'Ex : Boire 8 verres d\'eau';

  @override
  String get habitFormCategoryLabel => 'Catégorie';

  @override
  String get habitFormCategoryHint => 'Sélectionner une catégorie';

  @override
  String get habitFormCategoryNone => 'Aucune catégorie';

  @override
  String get habitFormCategoryCreate => '+ Créer une nouvelle catégorie…';

  @override
  String get habitCategoryHelper =>
      'Conseillé : choisissez une catégorie pour de meilleures statistiques.';

  @override
  String get habitCategoryWarningTitle => 'Catégorie non choisie';

  @override
  String get habitCategoryWarningMessage =>
      'Vous n\'avez pas choisi de catégorie, continuer quand même ?';

  @override
  String get habitFormQuantTargetLabel => 'Objectif';

  @override
  String get habitFormQuantTargetHint => '8';

  @override
  String get habitFormQuantUnitLabel => 'Unité';

  @override
  String get habitFormQuantUnitHint => 'verres';

  @override
  String get habitTrackingTitle =>
      'Comment voulez-vous suivre cette habitude ?';

  @override
  String get habitTrackingTip =>
      'Astuce : mettez 1 si une seule fois par période suffit (équivalent à \"fait / pas fait\").';

  @override
  String get habitTrackingPrefix => 'Je veux faire cette habitude';

  @override
  String get habitTrackingTimesWord => 'fois';

  @override
  String get habitTrackingEveryWord => 'toutes les';

  @override
  String get habitTrackingModeCycle => 'M jours sur N';

  @override
  String get habitTrackingModeWeekdays => 'Jours spécifiques';

  @override
  String get habitTrackingModeSpecificDate => 'À une date précise';

  @override
  String get habitTrackingCycleLabel => 'Cycle';

  @override
  String get habitTrackingCycleActiveDays => 'Jours actifs (M)';

  @override
  String get habitTrackingCycleLength => 'Longueur du cycle (N)';

  @override
  String get habitTrackingCycleStartDate => 'Date de début du cycle';

  @override
  String get habitTrackingWeekdaysLabel => 'Sélectionnez les jours';

  @override
  String get habitTrackingSpecificDateLabel => 'Date';

  @override
  String get habitTrackingRepeatEveryYear => 'Répéter chaque année';

  @override
  String get habitTrackingBackToPeriod => 'Revenir au mode \"par période\"';

  @override
  String get habitTrackingPeriodDay => 'par jour';

  @override
  String get habitTrackingPeriodWeek => 'par semaine';

  @override
  String get habitTrackingPeriodMonth => 'par mois';

  @override
  String get habitTrackingPeriodQuarter => 'par trimestre';

  @override
  String get habitTrackingPeriodSemester => 'par semestre';

  @override
  String get habitTrackingPeriodYear => 'par an';

  @override
  String get habitTrackingCustomInterval => 'tous les...';

  @override
  String get habitTrackingUnitHours => 'heures';

  @override
  String get habitTrackingUnitDays => 'jours';

  @override
  String get habitTrackingUnitWeeks => 'semaines';

  @override
  String get habitTrackingUnitMonths => 'mois';

  @override
  String get habitSummaryTitle => 'Résumé';

  @override
  String get habitSummaryPlaceholder =>
      'Complétez le nom et la fréquence pour voir le résumé.';

  @override
  String habitSummaryAction(Object name) {
    return 'Vous voulez $name';
  }

  @override
  String habitSummaryTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '$count fois',
    );
    return '$_temp0';
  }

  @override
  String listItemDateLabel(String date) {
    return 'Ajouté le $date';
  }

  @override
  String get listItemDateUnknown => 'Sans date';

  @override
  String get listItemActionComplete => 'Compléter';

  @override
  String get listItemActionReopen => 'Rouvrir';

  @override
  String get listEditTooltip => 'Modifier la liste';

  @override
  String get listDeleteTooltip => 'Supprimer la liste';

  @override
  String get listEditDialogTitle => 'Modifier la liste';

  @override
  String get listEditNameLabel => 'Nom de la liste';

  @override
  String get listEditSaved => 'Liste mise à jour.';

  @override
  String get habitFormTypePrompt => 'Je veux suivre cette habitude en';

  @override
  String get habitFormTypeBinaryOption => 'cochant quand c\'est fait';

  @override
  String get habitFormTypeQuantOption => 'notant une quantité accomplie';

  @override
  String get habitFormTypeBinaryDescription =>
      'Idéal pour une vérification oui/non : cochez simplement chaque fois que l\'habitude est accomplie.';

  @override
  String get habitFormTypeQuantDescription =>
      'Suivez une quantité mesurable avec un objectif chiffré et une unité personnalisée.';

  @override
  String get habitRecurrenceDaily => 'Quotidienne';

  @override
  String get habitRecurrenceWeekly => 'Hebdomadaire';

  @override
  String get habitRecurrenceMonthly => 'Mensuelle';

  @override
  String get habitRecurrenceTimesPerWeek => 'Plusieurs fois par semaine';

  @override
  String get habitRecurrenceTimesPerDay => 'Plusieurs fois par jour';

  @override
  String get habitRecurrenceMonthlyDay => 'Jour fixe du mois';

  @override
  String get habitRecurrenceQuarterly => 'Trimestrielle';

  @override
  String get habitRecurrenceYearly => 'Annuelle';

  @override
  String get habitRecurrenceHourlyInterval => 'Toutes les X heures';

  @override
  String get habitRecurrenceTimesPerHour => 'Plusieurs fois par heure';

  @override
  String get habitRecurrenceWeekends => 'Week-ends';

  @override
  String get habitRecurrenceWeekdays => 'Jours de semaine';

  @override
  String get habitRecurrenceEveryXDays => 'Tous les X jours';

  @override
  String get habitRecurrenceSpecificWeekdays => 'Certains jours de la semaine';

  @override
  String get habitFormSubmitCreate => 'Créer l\'habitude';

  @override
  String get habitFormValidationNameRequired =>
      'Veuillez saisir un nom pour l\'habitude';

  @override
  String get statistics => 'Statistiques';

  @override
  String get prioritize => 'Prioriser';

  @override
  String get addHabit => 'Ajouter une habitude';

  @override
  String get addTask => 'Ajouter une tâche';

  @override
  String get addList => 'Ajouter une liste';

  @override
  String get listsEmptyTitle => 'Aucune liste';

  @override
  String get listsEmptySubtitle =>
      'Ajoutez votre premiere liste pour commencer';

  @override
  String get listEmptyTitle => 'Aucun element trouve';

  @override
  String get listEmptySearchBody => 'Essayez un autre terme de recherche';

  @override
  String get listEmptyNoItemsBody =>
      'Ajoutez votre premier element pour commencer';

  @override
  String get listsOverviewTitle => 'Organisez vos listes en un coup d\'oeil';

  @override
  String listsOverviewSubtitle(int totalLists, int totalItems) {
    return '$totalLists listes | $totalItems elements actifs';
  }

  @override
  String get name => 'Nom';

  @override
  String get description => 'Description';

  @override
  String get category => 'Catégorie';

  @override
  String get priority => 'Priorité';

  @override
  String get frequency => 'Fréquence';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get create => 'Créer';

  @override
  String get completed => 'Terminé';

  @override
  String get incomplete => 'Incomplet';

  @override
  String get hideCompleted => 'Masquer terminés';

  @override
  String get showCompleted => 'Afficher terminés';

  @override
  String get hideEloScores => 'Masquer scores ELO';

  @override
  String get showEloScores => 'Afficher scores ELO';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get insightsTabOverview => 'Aperçu';

  @override
  String get insightsTabTrends => 'Tendances';

  @override
  String get insightsCtaCreateHabit => 'Créer une habitude';

  @override
  String get insightsTrendsSuccessRate => 'Taux de réussite';

  @override
  String get insightsTrendsStreak => 'Série actuelle';

  @override
  String insightsTrendsStreakDays(int count) {
    return '$count j.';
  }

  @override
  String get insightsTrendsToday => 'Complété aujourd\'hui';

  @override
  String get habitsTab => 'Habitudes';

  @override
  String get tasksTab => 'Tâches';

  @override
  String get totalPoints => 'Points totaux';

  @override
  String get successRate => 'Taux de réussite';

  @override
  String get currentStreak => 'Série actuelle';

  @override
  String get longestStreak => 'Plus longue série';

  @override
  String get language => 'Langue';

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsGeneralSectionTitle => 'Général';

  @override
  String get settingsPilotSectionTitle => 'Pilote';

  @override
  String get pilotIdentityBadge => 'Pilote externe';

  @override
  String get settingsHelpFeedbackSectionTitle => 'Aide et retour';

  @override
  String get settingsAboutSectionTitle => 'À propos';

  @override
  String get settingsPilotStatusTitle => 'Statut du pilote';

  @override
  String get settingsPilotStatusBody =>
      'Pilote externe limite. Prioris couvre aujourd\'hui le shell, les listes, la priorisation et les habitudes de base.';

  @override
  String get settingsPilotLimitsTitle => 'Limites actuelles';

  @override
  String get settingsPilotLimitsBody =>
      'Pas de billing, pas de support public, pas de centre d\'aide hébergé et pas de promesse au-delà du périmètre actuel.';

  @override
  String settingsVersionValue(String version) {
    return '$version';
  }

  @override
  String get settingsVersionFallbackLabel => 'Build pilote externe';

  @override
  String settingsLanguageChanged(String language) {
    return 'Langue changée : $language';
  }

  @override
  String get logout => 'Se déconnecter';

  @override
  String get homeLogoutHint => 'Deconnecte l\'utilisateur actuel';

  @override
  String get homeSettingsHint =>
      'Ouvre la page des parametres de l\'application';

  @override
  String get homeMainContentLabel => 'Contenu principal';

  @override
  String get homePrimaryNavigationLabel => 'Navigation principale';

  @override
  String get homePrimaryNavigationHint =>
      'Utilisez les elements de navigation pour changer de section';

  @override
  String homeNavigationAnnouncement(String section) {
    return 'Navigation vers $section';
  }

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get loading => 'Chargement...';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get confirm => 'Confirmer';

  @override
  String get back => 'Retour';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get clear => 'Effacer';

  @override
  String get apply => 'Appliquer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get close => 'Fermer';

  @override
  String get open => 'Ouvrir';

  @override
  String get refresh => 'Actualiser';

  @override
  String get export => 'Exporter';

  @override
  String get import => 'Importer';

  @override
  String get share => 'Partager';

  @override
  String get copy => 'Copier';

  @override
  String get paste => 'Coller';

  @override
  String get cut => 'Couper';

  @override
  String get undo => 'Annuler';

  @override
  String get redo => 'Rétablir';

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get deselectAll => 'Tout désélectionner';

  @override
  String get select => 'Sélectionner';

  @override
  String get deselect => 'Désélectionner';

  @override
  String get all => 'Tout';

  @override
  String get none => 'Aucun';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get todayPanelSubtitle =>
      'Les quelques elements qui meritent votre attention maintenant';

  @override
  String todayPanelCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elements fiables',
      one: '$count element fiable',
    );
    return '$_temp0';
  }

  @override
  String get todayPanelLoading => 'Preparation de votre vue du jour...';

  @override
  String get todayPanelCalmTitle => 'Rien d\'urgent pour l\'instant';

  @override
  String get todayPanelCalmBody =>
      'La vue du jour reste calme. Continuez depuis vos listes ou vos habitudes si vous voulez avancer.';

  @override
  String get todayPanelFirstUseTitle => 'Votre espace est pret';

  @override
  String get todayPanelFirstUseBody =>
      'Commencez par creer une premiere liste ou une habitude. Vos prochaines actions apparaitront ici.';

  @override
  String get todayPanelPartial =>
      'Vue partielle : certains signaux sont encore en cours de chargement.';

  @override
  String get todayPanelError => 'La vue du jour est temporairement limitee.';

  @override
  String get todayPanelTaskKind => 'Tache';

  @override
  String get todayPanelHabitKind => 'Habitude';

  @override
  String get todayPanelStatusOverdue => 'En retard';

  @override
  String get todayPanelStatusDueToday => 'Aujourd\'hui';

  @override
  String get todayPanelStatusPending => 'A arbitrer';

  @override
  String get todayPanelReasonOverdueTask => 'Tache deja en retard';

  @override
  String get todayPanelReasonDueTodayTask => 'Echeance aujourd\'hui';

  @override
  String get todayPanelReasonPriorityTask => 'Tache a fort levier';

  @override
  String get todayPanelReasonDueTodayHabit => 'Habitude attendue aujourd\'hui';

  @override
  String todayPanelParentListLabel(Object title) {
    return 'Liste : $title';
  }

  @override
  String get todayPanelActionOpenList => 'Ouvrir la liste';

  @override
  String get todayPanelActionOpenDuel => 'Arbitrer';

  @override
  String get todayPanelActionRecordHabit => 'Marquer fait';

  @override
  String get todayPanelActionRecordValue => 'Saisir';

  @override
  String get todayPanelActionOpenHabits => 'Voir habitudes';

  @override
  String get todayPanelActionUnavailable =>
      'Cette action n\'est plus disponible dans l\'etat actuel.';

  @override
  String get yesterday => 'Hier';

  @override
  String get tomorrow => 'Demain';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get lastWeek => 'Semaine dernière';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get lastMonth => 'Mois dernier';

  @override
  String get thisYear => 'Cette année';

  @override
  String get lastYear => 'Année dernière';

  @override
  String get days => 'jours';

  @override
  String get hours => 'heures';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'secondes';

  @override
  String get points => 'points';

  @override
  String get items => 'éléments';

  @override
  String get tasksCompleted => 'tâches terminées';

  @override
  String get habitsCompleted => 'habitudes terminées';

  @override
  String get listsCompleted => 'listes terminees';

  @override
  String listCompletionLabel(int completed, int total) {
    return '$completed sur $total elements termines';
  }

  @override
  String listCompletionProgress(String percent) {
    return '$percent% termine';
  }

  @override
  String get progress => 'Progression';

  @override
  String get performance => 'Performance';

  @override
  String get analytics => 'Analyses';

  @override
  String get insights => 'Aperçus';

  @override
  String get insightsHeaderTitle => 'Analysez vos progres';

  @override
  String get insightsHeaderSubtitleEmpty =>
      'Creez des habitudes pour faire apparaitre vos premiers reperes.';

  @override
  String insightsHeaderSubtitleWithHabits(int count) {
    return 'Apercu et tendances de vos $count habitudes';
  }

  @override
  String get insightsEmptyTitle => 'Pas encore d\'analyses';

  @override
  String get insightsEmptyBody =>
      'Creez votre premiere habitude pour faire apparaitre vos premiers reperes ici.';

  @override
  String get insightsOverviewPlaceholder =>
      'Votre apercu apparaitra bientot ici.';

  @override
  String get insightsTrendsPlaceholder =>
      'Vos tendances apparaitront bientot ici.';

  @override
  String get recommendations => 'Recommandations';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get tips => 'Conseils';

  @override
  String get help => 'Aide';

  @override
  String get settingsHelpSubtitle =>
      'Comprendre comment obtenir de l\'aide pendant ce pilote.';

  @override
  String get settingsHelpDialogBody =>
      'Le support du pilote reste manuel et borne. Utilisez le canal de retour du pilote pour poser une question, signaler un probleme ou partager un besoin. Aucune assistance en temps reel ni SLA public n\'est promis.';

  @override
  String get about => 'À propos';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Développeur';

  @override
  String get contact => 'Contact';

  @override
  String get feedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Ouvrir le canal de retour du pilote.';

  @override
  String get settingsFeedbackDialogBody =>
      'Le canal de retour du pilote ouvre un formulaire simple dans votre navigateur. Il sert aussi pour l\'aide, les bugs et les demandes de fonctionnalites.';

  @override
  String get reportBug => 'Signaler un bug';

  @override
  String get settingsReportBugSubtitle =>
      'Utiliser le meme canal pilote pour signaler un bug.';

  @override
  String get settingsReportBugDialogBody =>
      'Le signalement de bug passe par le meme canal pilote que le retour general. Decrivez le contexte visible, l\'appareil et le resultat observe.';

  @override
  String get requestFeature => 'Demander une fonctionnalité';

  @override
  String get settingsRequestFeatureSubtitle =>
      'Utiliser le meme canal pilote pour partager un besoin.';

  @override
  String get settingsRequestFeatureDialogBody =>
      'Les demandes de fonctionnalites passent par le meme canal pilote. Elles sont lues manuellement et ne valent pas engagement de livraison.';

  @override
  String get settingsSupportLaunchFailureBody =>
      'Impossible d\'ouvrir automatiquement ce canal. Utilisez ce lien dans votre navigateur :';

  @override
  String get settingsSupportUnavailableBody =>
      'Cette build ne configure pas encore de canal de support pilote. Ajoutez une URL de feedback ou un email de support avant diffusion externe.';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get settingsPrivacySubtitle =>
      'Lire comment les donnees du pilote sont traitees.';

  @override
  String get settingsPrivacyDialogBody =>
      'Prioris enregistre uniquement les donnees necessaires au pilote : compte, listes, taches, habitudes et signaux de synchro associes. Ces donnees servent a faire fonctionner le produit, corriger les problemes signales et evaluer le pilote. Pour toute question sur vos donnees, utilisez le canal de retour du pilote.';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get settingsTermsSubtitle =>
      'Lire le cadre d\'usage minimal du pilote.';

  @override
  String get settingsTermsDialogBody =>
      'Ce pilote est reserve a un petit groupe invite. L\'acces, les fonctionnalites et la disponibilite peuvent changer sans preavis. N\'utilisez pas Prioris comme systeme critique ni comme source unique de verite pour des decisions sensibles. Les retours sont bienvenus, mais aucune correction immediate ni ouverture publique n\'est garantie.';

  @override
  String get license => 'Licence';

  @override
  String get settingsLicenseSubtitle =>
      'Ouvrir les licences incluses dans cette version.';

  @override
  String get settingsAboutLegalese =>
      'Pilote externe limite. Support manuel via le canal du pilote, sans pricing ni engagement public.';

  @override
  String get credits => 'Crédits';

  @override
  String get changelog => 'Journal des modifications';

  @override
  String get updateAvailable => 'Mise à jour disponible';

  @override
  String get updateNow => 'Mettre à jour maintenant';

  @override
  String get later => 'Plus tard';

  @override
  String get never => 'Jamais';

  @override
  String get always => 'Toujours';

  @override
  String get sometimes => 'Parfois';

  @override
  String get rarely => 'Rarement';

  @override
  String get often => 'Souvent';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get yearly => 'Annuel';

  @override
  String get custom => 'Personnalisé';

  @override
  String get automatic => 'Automatique';

  @override
  String get manual => 'Manuel';

  @override
  String get enabled => 'Activé';

  @override
  String get disabled => 'Désactivé';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get online => 'En ligne';

  @override
  String get offline => 'Hors ligne';

  @override
  String get connected => 'Connecté';

  @override
  String get disconnected => 'Déconnecté';

  @override
  String get synchronized => 'Synchronisé';

  @override
  String get notSynchronized => 'Non synchronisé';

  @override
  String get synchronizing => 'Synchronisation...';

  @override
  String get syncFailed => 'Échec de synchronisation';

  @override
  String get retry => 'Réessayer';

  @override
  String get skip => 'Passer';

  @override
  String get finish => 'Terminer';

  @override
  String get complete => 'Compléter';

  @override
  String get pending => 'En attente';

  @override
  String get processing => 'Traitement...';

  @override
  String get waiting => 'En attente...';

  @override
  String get ready => 'Prêt';

  @override
  String get notReady => 'Pas prêt';

  @override
  String get available => 'Disponible';

  @override
  String get unavailable => 'Indisponible';

  @override
  String get busy => 'Occupé';

  @override
  String get free => 'Libre';

  @override
  String get occupied => 'Occupé';

  @override
  String get empty => 'Vide';

  @override
  String get full => 'Plein';

  @override
  String get partial => 'Partiel';

  @override
  String get exact => 'Exact';

  @override
  String get approximate => 'Approximatif';

  @override
  String get estimated => 'Estimé';

  @override
  String get actual => 'Réel';

  @override
  String get planned => 'Planifié';

  @override
  String get unplanned => 'Non planifié';

  @override
  String get scheduled => 'Programmé';

  @override
  String get unscheduled => 'Non programmé';

  @override
  String get overdue => 'En retard';

  @override
  String get onTime => 'À l\'heure';

  @override
  String get early => 'En avance';

  @override
  String get late => 'En retard';

  @override
  String get urgent => 'Urgent';

  @override
  String get high => 'Élevée';

  @override
  String get medium => 'Moyenne';

  @override
  String get low => 'Faible';

  @override
  String get critical => 'Critique';

  @override
  String get important => 'Important';

  @override
  String get normal => 'Normal';

  @override
  String get minor => 'Mineur';

  @override
  String get trivial => 'Trivial';

  @override
  String get personal => 'Personnel';

  @override
  String get work => 'Travail';

  @override
  String get health => 'Santé';

  @override
  String get fitness => 'Fitness';

  @override
  String get education => 'Éducation';

  @override
  String get finance => 'Finance';

  @override
  String get social => 'Social';

  @override
  String get family => 'Famille';

  @override
  String get hobby => 'Loisir';

  @override
  String get travel => 'Voyage';

  @override
  String get shopping => 'Shopping';

  @override
  String get entertainment => 'Divertissement';

  @override
  String get other => 'Autre';

  @override
  String get defaultValue => 'Par défaut';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get duelPriorityTitle => 'Priorisé';

  @override
  String get duelPrioritySubtitle => 'Quelle tâche préférez-vous ?';

  @override
  String get duelPriorityHint =>
      'Touchez la carte que vous souhaitez prioriser.';

  @override
  String get duelSkipAction => 'Passer le duel';

  @override
  String get duelRandomAction => 'Résultat aléatoire';

  @override
  String get duelShowElo => 'Afficher l’Élo';

  @override
  String get duelHideElo => 'Masquer l’Élo';

  @override
  String get duelModeLabel => 'Mode du duel';

  @override
  String get duelModeWinner => 'Vainqueur';

  @override
  String get duelModeRanking => 'Classement';

  @override
  String get duelCardsPerRoundLabel => 'Nombre de cartes par manche';

  @override
  String duelCardsPerRoundOption(int count) {
    return '$count cartes';
  }

  @override
  String duelModeSummary(String mode, int count) {
    return 'Mode du duel : $mode - $count cartes';
  }

  @override
  String get duelSubmitRanking => 'Valider le classement';

  @override
  String get duelPreferenceSaved => 'Préférence enregistrée.';

  @override
  String duelRemainingDuels(int count) {
    return '$count duels restants aujourd’hui';
  }

  @override
  String get duelConfigureLists => 'Choisir les listes pour les duels';

  @override
  String get duelNoAvailableLists => 'Aucune liste disponible';

  @override
  String get duelNoAvailableListsForPrioritization =>
      'Aucune liste disponible pour la priorisation';

  @override
  String get duelListsUpdated => 'Listes de priorisation mises à jour';

  @override
  String get duelNewDuel => 'Nouveau duel';

  @override
  String get duelNotEnoughTasksTitle => 'Pas assez de tâches';

  @override
  String get duelNotEnoughTasksMessage =>
      'Ajoutez au moins deux tâches pour commencer à prioriser.';

  @override
  String get duelErrorMessage => 'Impossible de charger le duel. Réessayez.';

  @override
  String get habitsActionCreateSuccess => 'Habitude créée ✅';

  @override
  String habitsActionCreateError(String error) {
    return 'Erreur lors de la création : $error';
  }

  @override
  String habitsActionUpdateSuccess(String habitName) {
    return 'Habitude \"$habitName\" mise à jour';
  }

  @override
  String habitsActionUpdateError(String error) {
    return 'Erreur lors de la mise à jour : $error';
  }

  @override
  String habitsActionDeleteSuccess(String habitName) {
    return 'Habitude \"$habitName\" supprimée';
  }

  @override
  String habitsActionDeleteError(String error) {
    return 'Impossible de supprimer l\'habitude : $error';
  }

  @override
  String habitsActionRecordSuccess(String habitName) {
    return 'Habitude \"$habitName\" enregistrée';
  }

  @override
  String habitsActionRecordError(String error) {
    return 'Erreur lors de l\'enregistrement : $error';
  }

  @override
  String get habitsLoadingRecord => 'Enregistrement...';

  @override
  String get habitsLoadingDelete => 'Suppression...';

  @override
  String habitsActionUnsupported(String action) {
    return 'Action non supportée : $action';
  }

  @override
  String get habitsDialogDeleteTitle => 'Supprimer l\'habitude';

  @override
  String habitsDialogDeleteMessage(String habitName) {
    return 'Supprimer \"$habitName\" ?\nCette action est irréversible et supprime aussi l\'historique.';
  }

  @override
  String get habitsButtonCreate => 'Créer une habitude';

  @override
  String get habitsHeaderTitle => 'Mes habitudes';

  @override
  String get habitsHeaderSubtitle => 'Suivez vos progrès au quotidien';

  @override
  String get habitsHeroTitle => 'Mes Habitudes';

  @override
  String get habitsHeroSubtitle => 'Créez et suivez vos habitudes quotidiennes';

  @override
  String get habitsTabHabits => 'Habitudes';

  @override
  String get habitsTabAdd => 'Ajouter';

  @override
  String get habitCategoryDialogTitle => 'Nouvelle catégorie';

  @override
  String get habitCategoryDialogFieldHint => 'Nom de la catégorie';

  @override
  String get habitsEmptyTitle => 'Aucune habitude pour l\'instant';

  @override
  String get habitsEmptySubtitle =>
      'Créez votre première habitude pour suivre vos progrès.';

  @override
  String get habitsErrorTitle => 'Erreur de chargement';

  @override
  String habitsErrorLoadFailure(Object error) {
    return 'Impossible de charger les habitudes : $error';
  }

  @override
  String get habitsMenuTooltip => 'Afficher le menu';

  @override
  String get habitsMenuRecord => 'Marquer comme fait';

  @override
  String get habitsRecordValueTooltip => 'Enregistrer une valeur';

  @override
  String get habitsMenuEdit => 'Modifier';

  @override
  String get habitsMenuDelete => 'Supprimer';

  @override
  String get habitsCategoryDefault => 'Général';

  @override
  String get habitProgressThisWeek => 'cette semaine';

  @override
  String habitProgressStreakDays(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '$count jour',
    );
    return '$_temp0';
  }

  @override
  String habitProgressSuccessfulDays(Object successful, Object total) {
    return '$successful/$total jours réussis';
  }

  @override
  String get habitProgressCompletedToday => 'Fait aujourd\'hui';

  @override
  String get habitsErrorNetwork =>
      'Problème de connexion réseau.\\nVérifiez votre connexion internet.';

  @override
  String get habitsErrorTimeout =>
      'La requête a pris trop de temps.\\nVeuillez réessayer.';

  @override
  String get habitsErrorPermission =>
      'Permissions insuffisantes.\\nVérifiez vos autorisations.';

  @override
  String get habitsErrorUnexpected =>
      'Une erreur inattendue s\'est produite.\\nVeuillez réessayer plus tard.';

  @override
  String get habitFrequencySelectorTitle => 'Fréquence';

  @override
  String get habitFrequencyModelATitle =>
      'Définir un nombre de fois par période';

  @override
  String get habitFrequencyModelADescription =>
      'Exemple : 3 fois par jour, 5 fois par semaine';

  @override
  String get habitFrequencyModelBTitle => 'Définir un intervalle';

  @override
  String get habitFrequencyModelBDescription =>
      'Exemple : tous les 2 jours, tous les mois';

  @override
  String get habitFrequencyModelAFieldsLabel => 'Combien de fois ?';

  @override
  String get habitFrequencyModelBFieldsLabel => 'À quelle fréquence ?';

  @override
  String get habitFrequencyTimesLabel => 'Fois';

  @override
  String get habitFrequencyIntervalLabel => 'Tous les';

  @override
  String get habitFrequencyPeriodLabel => 'Période';

  @override
  String get habitFrequencyUnitLabel => 'Unité';

  @override
  String get habitFrequencyPeriodHour => 'heure';

  @override
  String get habitFrequencyPeriodDay => 'jour';

  @override
  String get habitFrequencyPeriodWeek => 'semaine';

  @override
  String get habitFrequencyPeriodMonth => 'mois';

  @override
  String get habitFrequencyPeriodYear => 'an';

  @override
  String get habitFrequencyUnitHours => 'heures';

  @override
  String get habitFrequencyUnitDays => 'jours';

  @override
  String get habitFrequencyUnitWeeks => 'semaines';

  @override
  String get habitFrequencyUnitMonths => 'mois';

  @override
  String get habitFrequencyUnitQuarters => 'trimestres';

  @override
  String get habitFrequencyUnitYears => 'ans';

  @override
  String get habitFrequencyDayFilterLabel => 'Filtre de jours (optionnel)';

  @override
  String get habitFrequencyDayFilterAllDays => 'Tous les jours';

  @override
  String get habitFrequencyDayFilterWeekdays => 'Jours de semaine uniquement';

  @override
  String get habitFrequencyDayFilterWeekends => 'Week-ends uniquement';

  @override
  String habitFrequencyTimesPerHour(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par heure',
      one: '$count fois par heure',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerDay(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par jour',
      one: '$count fois par jour',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerWeek(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par semaine',
      one: '$count fois par semaine',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerMonth(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par mois',
      one: '$count fois par mois',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerQuarter(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par trimestre',
      one: '$count fois par trimestre',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerSemester(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par semestre',
      one: '$count fois par semestre',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerYear(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois par an',
      one: '$count fois par an',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryHours(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'toutes les $interval heures',
      one: 'toutes les heures',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryDays(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'tous les $interval jours',
      one: 'quotidien',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryWeeks(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'toutes les $interval semaines',
      one: 'hebdomadaire',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryMonths(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'tous les $interval mois',
      one: 'mensuel',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryQuarters(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'tous les $interval trimestres',
      one: 'trimestriel',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyDaysPerCycle(Object daysActive, Object daysCycle) {
    return '$daysActive jours sur $daysCycle';
  }

  @override
  String habitFrequencySpecificDateAnnual(String date) {
    return 'Chaque année le $date';
  }

  @override
  String habitFrequencySpecificDateOnce(String date) {
    return 'Le $date';
  }

  @override
  String habitFrequencyEveryYears(num interval) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'tous les $interval ans',
      one: 'annuel',
    );
    return '$_temp0';
  }

  @override
  String get habitFrequencyWeekdaysOnly =>
      'Jours de semaine uniquement (Lun-Ven)';

  @override
  String get habitFrequencyWeekendsOnly => 'Week-ends uniquement (Sam-Dim)';

  @override
  String habitFrequencySpecificDays(Object days) {
    return 'Le : $days';
  }

  @override
  String habitFrequencyMonthlyOnDay(Object day) {
    return 'Mensuel le $day';
  }

  @override
  String habitFrequencyYearlyOnDate(Object day, Object month) {
    return 'Annuel le $day $month';
  }

  @override
  String get habitWeekdayMonday => 'Lun';

  @override
  String get habitWeekdayTuesday => 'Mar';

  @override
  String get habitWeekdayWednesday => 'Mer';

  @override
  String get habitWeekdayThursday => 'Jeu';

  @override
  String get habitWeekdayFriday => 'Ven';

  @override
  String get habitWeekdaySaturday => 'Sam';

  @override
  String get habitWeekdaySunday => 'Dim';

  @override
  String get habitMonthJanuary => 'Janvier';

  @override
  String get habitMonthFebruary => 'Février';

  @override
  String get habitMonthMarch => 'Mars';

  @override
  String get habitMonthApril => 'Avril';

  @override
  String get habitMonthMay => 'Mai';

  @override
  String get habitMonthJune => 'Juin';

  @override
  String get habitMonthJuly => 'Juillet';

  @override
  String get habitMonthAugust => 'Août';

  @override
  String get habitMonthSeptember => 'Septembre';

  @override
  String get habitMonthOctober => 'Octobre';

  @override
  String get habitMonthNovember => 'Novembre';

  @override
  String get habitMonthDecember => 'Décembre';

  @override
  String get sortBy => 'Trier par';

  @override
  String get scoreElo => 'Score Élo';

  @override
  String get random => 'Aléatoire';

  @override
  String get orderAscending => 'Ordre croissant';

  @override
  String get orderDescending => 'Ordre décroissant';

  @override
  String itemsCount(int count) {
    return '$count éléments';
  }

  @override
  String get add => 'Ajouter';

  @override
  String get keepOpenAfterAdd => 'Garder ouvert après ajout';

  @override
  String get bulkAddSingleHint => 'Ajouter un élément...';

  @override
  String get bulkAddMultipleHint =>
      'Ajouter plusieurs éléments (un par ligne)...';

  @override
  String get bulkAddHelpText => 'Une nouvelle ligne = un nouvel élément';

  @override
  String get closeDialog => 'Fermer';

  @override
  String get bulkAddDefaultTitle => 'Ajouter des éléments';

  @override
  String get bulkAddSubmitting => 'Ajout des éléments...';

  @override
  String get bulkAddModeSingle => 'Simple';

  @override
  String get bulkAddModeMultiple => 'Multiple';

  @override
  String bulkAddImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments importés',
      one: '$count élément importé',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddImportError => 'Erreur lors de l\'import';

  @override
  String get listDeleteDialogTitle => 'Supprimer la liste';

  @override
  String listDeleteDialogMessage(String listName) {
    return 'Êtes-vous sûr de vouloir supprimer \"$listName\" ?';
  }

  @override
  String get listDeleteConfirm => 'Supprimer';

  @override
  String get listRenameDialogTitle => 'Renommer l\'élément';

  @override
  String get listRenameDialogLabel => 'Nom de l\'élément';

  @override
  String get listRenameSaved => 'Élément renommé.';

  @override
  String get listMoveDialogTitle => 'Déplacer l\'élément';

  @override
  String get listMoveDialogLabel => 'Liste de destination';

  @override
  String get listMoveNoOtherList => 'Aucune autre liste disponible';

  @override
  String get listMoveSaved => 'Élément déplacé.';

  @override
  String get listDuplicateSaved => 'Élément dupliqué.';

  @override
  String get listConfirmDeleteItemTitle => 'Supprimer l\'élément';

  @override
  String listConfirmDeleteItemMessage(String itemTitle) {
    return 'Êtes-vous sûr de vouloir supprimer \"$itemTitle\" ?';
  }

  @override
  String get more => 'Autres actions';

  @override
  String get rename => 'Renommer';

  @override
  String get move => 'Déplacer...';

  @override
  String get duplicate => 'Dupliquer';

  @override
  String get authOfflineSignInError =>
      'Connexion indisponible en mode hors ligne. Configurez de vrais identifiants Supabase dans .env pour activer les fonctionnalites en ligne.';

  @override
  String get authOfflineSignUpError =>
      'Inscription indisponible en mode hors ligne. Configurez de vrais identifiants Supabase dans .env pour activer les fonctionnalites en ligne.';

  @override
  String get authLoginTitle => 'Connectez-vous';

  @override
  String get authSignUpTitle => 'Creer un compte';

  @override
  String get authSignInAction => 'Se connecter';

  @override
  String get authSignUpAction => 'Creer le compte';

  @override
  String get authToggleToSignUp => 'Pas de compte ? Creer un compte';

  @override
  String get authToggleToSignIn => 'Deja un compte ? Se connecter';

  @override
  String get authForgotPasswordAction => 'Mot de passe oublie ?';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'votre@email.com';

  @override
  String get authPasswordLabel => 'Mot de passe';

  @override
  String get authPasswordHint => '********';

  @override
  String get authTechnicalFieldLabel => 'Champ technique (laisser vide)';

  @override
  String get authPendingConfirmationTitle => 'Confirmation requise';

  @override
  String authPendingConfirmationMessage(String email) {
    return 'Un email de validation a ete envoye a $email. Confirmez votre adresse email pour terminer l\'inscription, puis reconnectez-vous.';
  }

  @override
  String get authCallbackExpiredMessage =>
      'Votre lien de connexion est expiré ou a été ouvert depuis un autre navigateur. Veuillez vous connecter.';

  @override
  String get duplicateWarningTitle => 'Doublon détecté';

  @override
  String duplicateWarningSingle(String title) {
    return 'L\'élément \"$title\" est déjà dans votre liste.';
  }

  @override
  String duplicateWarningMultiple(int duplicateCount, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      duplicateCount,
      locale: localeName,
      other: '$duplicateCount éléments sont déjà',
      one: '$duplicateCount élément est déjà',
    );
    return '$_temp0 dans votre liste (sur $total).';
  }

  @override
  String duplicateWarningSkipAction(int uniqueCount) {
    return 'Ignorer ($uniqueCount à ajouter)';
  }

  @override
  String get duplicateWarningAddAllSingle => 'Ajouter quand même';

  @override
  String duplicateWarningAddAllBulk(int count) {
    return 'Tout ajouter ($count)';
  }

  @override
  String bulkAddImportSuccessWithSkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments importés',
      one: '$count élément importé',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped doublons ignorés',
      one: '$skipped doublon ignoré',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String get errorGenericTitle => 'Une erreur est survenue';

  @override
  String get errorNetworkTitle => 'Problème de connexion';

  @override
  String get errorNetworkMessage =>
      'Vérifiez votre connexion internet et réessayez.';

  @override
  String get errorGenericMessage =>
      'Une erreur inattendue s\'est produite. Veuillez réessayer.';

  @override
  String get loadingListDetail => 'Chargement de votre liste...';

  @override
  String get noListsTitle => 'Aucune liste disponible';

  @override
  String get noListsBody => 'Créez votre première liste pour commencer.';

  @override
  String get settingsFeatureInDevelopment =>
      'Fonctionnalité en cours de développement';

  @override
  String get archiveAction => 'Archiver';

  @override
  String get listCreateDialogTitle => 'Nouvelle liste';

  @override
  String get listCreateError => 'Impossible de créer la liste. Réessayez.';

  @override
  String listEditError(String error) {
    return 'Erreur lors de la modification : $error';
  }

  @override
  String listDeleteError(String error) {
    return 'Erreur lors de la suppression : $error';
  }

  @override
  String get logoutKeepDataAction => 'Garder mes données';

  @override
  String get logoutClearDataAction => 'Effacer mes données';

  @override
  String listCreatedSuccess(String title) {
    return 'Liste \"$title\" créée avec succès';
  }

  @override
  String listUpdatedSuccess(String name) {
    return 'Liste \"$name\" modifiée avec succès';
  }

  @override
  String listDeletedSuccess(String name) {
    return 'Liste \"$name\" supprimée avec succès';
  }

  @override
  String get logoutDataQuestion =>
      'Que souhaitez-vous faire avec vos données locales ?';

  @override
  String get logoutLocalDataInfo =>
      'Vos listes sont stockées localement sur cet appareil';

  @override
  String get privacyConsentTitle => 'Protection de vos données';

  @override
  String get privacyConsentBody =>
      'Sans votre consentement, nous ne pouvons pas traiter vos données personnelles (tâches, habitudes, profil). Elles sont stockées de façon sécurisée et ne sont jamais partagées avec des tiers à des fins publicitaires.';

  @override
  String get privacyConsentAcceptButton => 'J\'accepte et je continue';

  @override
  String get privacyConsentReadPolicyLink =>
      'Lire la politique de confidentialité';

  @override
  String get consentGateSignOutError => 'La déconnexion a échoué. Réessayez.';

  @override
  String get consentGateActionPrompt => 'Que souhaitez-vous faire ?';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get settingsPrivacySectionTitle => 'CONFIDENTIALITÉ ET DONNÉES';

  @override
  String get settingsPrivacyPolicyTile => 'Politique de confidentialité';

  @override
  String get settingsPrivacyPolicySubtitle =>
      'Consulter nos pratiques de confidentialité';

  @override
  String get settingsRevokeConsentTile => 'Retirer mon consentement';

  @override
  String get settingsRevokeConsentSubtitle =>
      'Révoquer l\'accès à vos données personnelles';

  @override
  String get settingsRevokeConsentDialogTitle => 'Retirer votre consentement';

  @override
  String get settingsRevokeConsentDialogBody =>
      'Vous serez immédiatement redirigé vers la page de consentement. Vous pouvez accepter à nouveau à tout moment.';

  @override
  String get settingsRevokeConsentDialogConfirm => 'Retirer';

  @override
  String get settingsRevokeConsentDialogCancel => 'Annuler';

  @override
  String get settingsRevokeConsentError =>
      'Erreur lors du retrait du consentement. Veuillez réessayer.';

  @override
  String get settingsRevokeConsentSuccess =>
      'Consentement retiré. Déconnexion en cours…';

  @override
  String get settingsDeleteAccountTile => 'Supprimer mon compte';

  @override
  String get settingsDeleteAccountSubtitle =>
      'Demander la suppression de vos données';

  @override
  String get settingsDeleteAccountDialogTitle => 'Supprimer votre compte';

  @override
  String get settingsDeleteAccountDialogBody =>
      'Pour supprimer votre compte et toutes vos données personnelles, envoyez un email à :';

  @override
  String get settingsDeleteAccountDialogCopyEmail => 'Copier l\'adresse email';

  @override
  String get settingsDeleteAccountEmailCopied => 'Adresse email copiée';

  @override
  String importInterruptedBanner(int current, int total) {
    return 'Import interrompu — $current/$total éléments ajoutés';
  }

  @override
  String get ok => 'OK';

  @override
  String get importDoNotClose =>
      'Ne fermez pas l\'application pendant l\'import';

  @override
  String importResumeBanner(int current, int total, int remaining) {
    return 'Import interrompu — $current/$total ajoutés · $remaining en attente';
  }

  @override
  String get importResumeConfirm => 'Reprendre';

  @override
  String get importResumeIgnore => 'Ignorer';

  @override
  String get taskNewDialogTitle => 'Nouvelle tâche';

  @override
  String get taskAddedSuccess => 'Tâche ajoutée avec succès';

  @override
  String get taskTitleFieldLabel => 'Titre';

  @override
  String get taskDescriptionFieldLabel => 'Description (optionnel)';

  @override
  String get clearAllDataAction => 'Tout supprimer';

  @override
  String get clearDataAndSignOut => 'Effacer et se déconnecter';

  @override
  String get tasksPageTitle => 'Mes Tâches';

  @override
  String get tasksFabAddLabel => 'Ajouter une nouvelle tâche';

  @override
  String get tasksFabAddHint =>
      'Ouvre un formulaire pour créer une nouvelle tâche';

  @override
  String get tasksFabAddTooltip => 'Ajouter une tâche';

  @override
  String get tasksEmptyStateLabel => 'État vide : aucune tâche';

  @override
  String get tasksEmptyStateHint =>
      'Utilisez le bouton d\'ajout pour créer votre première tâche';

  @override
  String get tasksIconLabel => 'Icône de tâche';

  @override
  String get tasksEmptyTitle => 'Aucune tâche';

  @override
  String get tasksEmptyBody => 'Ajoutez votre première tâche pour commencer';

  @override
  String tasksItemLabel(String title) {
    return 'Tâche : $title';
  }

  @override
  String get tasksStatusCompleted => 'Terminée';

  @override
  String get tasksStatusInProgress => 'En cours';

  @override
  String get tasksItemHintCompleted =>
      'Tâche terminée. Appuyez pour plus d\'actions';

  @override
  String get tasksItemHintInProgress =>
      'Tâche en cours. Appuyez pour plus d\'actions';

  @override
  String get tasksMarkDone => 'Marquer fait';

  @override
  String get tasksMarkUndone => 'Marquer non fait';

  @override
  String get tasksToggleHint => 'Clic direct pour basculer l\'état de la tâche';

  @override
  String tasksActionsLabel(String title) {
    return 'Actions pour la tâche $title';
  }

  @override
  String get tasksActionsHint => 'Menu des actions disponibles';

  @override
  String get tasksActionsTooltip => 'Actions de la tâche';

  @override
  String get tasksMarkDoneLong => 'Marquer comme terminée';

  @override
  String get tasksMarkUndoneLong => 'Marquer comme non terminée';

  @override
  String get tasksDeleteLabel => 'Supprimer la tâche';

  @override
  String get tasksDialogOpenAnnounce =>
      'Ouverture du formulaire de création de tâche';

  @override
  String get tasksCreateTooltip => 'Créer la nouvelle tâche';

  @override
  String get taskDeletedAnnounce => 'Tâche supprimée';

  @override
  String get taskUpdatedAnnounce => 'Tâche mise à jour';

  @override
  String get habitCategoryDefault => 'Général';

  @override
  String get habitActionCompleteLabel => 'Marquer comme terminée';

  @override
  String get habitActionCompleteSubtitle => 'Garde votre streak actif';

  @override
  String get habitActionSkipLabel => 'Reporter';

  @override
  String get habitActionSkipSubtitle => 'Déplacer à plus tard';

  @override
  String habitStreakDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours',
      one: '$days jour',
    );
    return '$_temp0';
  }

  @override
  String habitWeeklyCompletions(int count) {
    return '$count/7 cette semaine';
  }

  @override
  String get listFormCreateTitle => 'Créer une nouvelle liste';

  @override
  String get listFormEditTitle => 'Modifier la liste';

  @override
  String get listNameHint => 'Ex : Liste de courses, Voyage Paris…';

  @override
  String get listNameRequired =>
      'Le nom de la liste est obligatoire pour l\'identifier';

  @override
  String get listNameMinLength => 'Le nom doit contenir au moins 2 caractères';

  @override
  String listNameMaxLength(int count) {
    return 'Le nom ne peut pas dépasser 100 caractères (actuellement $count)';
  }

  @override
  String get listTypeLabel => 'Type de liste';

  @override
  String get listItemAddTitle => 'Ajouter un élément';

  @override
  String get listItemEditTitle => 'Modifier l\'élément';

  @override
  String get listItemTitleHint =>
      'Ex : Terminer rapport projet, Réserver salle réunion…';

  @override
  String get listItemTitleRequired =>
      'Le titre est obligatoire pour identifier cet élément';

  @override
  String get listItemTitleMinLength =>
      'Le titre doit contenir au moins 2 caractères';

  @override
  String listItemTitleMaxLength(int count) {
    return 'Le titre ne peut pas dépasser 200 caractères (actuellement $count)';
  }

  @override
  String get categoryOptionalLabel => 'Catégorie (optionnel)';

  @override
  String get listItemCategoryHint => 'Ex : Travail, Personnel, Urgent…';

  @override
  String get listNameRequiredLabel => 'Nom de la liste *';

  @override
  String get customListNameHint => 'Ex : Courses du week-end';

  @override
  String get customListDescriptionHint => 'Décrivez le contenu de cette liste…';

  @override
  String get listSelectionTitle => 'Sélectionner les listes à prioriser';

  @override
  String get listSelectionEnabled => 'Participera aux duels';

  @override
  String get listSelectionDisabled => 'Exclue des duels';

  @override
  String get listSelectionRequireOne =>
      'Sélectionne au moins une liste pour pouvoir sauvegarder';

  @override
  String get habitDialogEditTitle => 'Modifier l\'habitude';

  @override
  String get habitDialogNewTitle => 'Nouvelle habitude';

  @override
  String habitRecordTitle(String habitName) {
    return 'Enregistrer $habitName';
  }

  @override
  String get habitRecordCurrentValueLabel =>
      'Valeur actuelle pour aujourd\'hui';

  @override
  String get habitRecordValueLabel => 'Valeur';

  @override
  String habitRecordTarget(String target, String unit) {
    return 'Objectif : $target $unit';
  }

  @override
  String get logoutSuccessCleared => 'Déconnecté et données effacées';

  @override
  String get logoutSuccessKept => 'Déconnecté — vos listes restent disponibles';

  @override
  String get clearDataDoneTitle => 'Données supprimées !';

  @override
  String get clearDataTitle => 'Nettoyer les données';

  @override
  String get clearDataStatsHeader => 'État actuel de vos données :';

  @override
  String get clearDataStatLists => 'Listes personnalisées';

  @override
  String get clearDataStatItems => 'Éléments de liste';

  @override
  String get clearDataCleanOrphans => 'Nettoyer les données orphelines';

  @override
  String clearDataOrphansDetected(int count) {
    return '$count données orphelines détectées';
  }

  @override
  String get clearDataDangerZone => 'Zone de danger';

  @override
  String get clearDataDangerMessage =>
      'Cette action supprimera TOUTES vos données (listes, éléments, habitudes). Cette action est irréversible.';

  @override
  String get clearDataSuccessMessage =>
      'Toutes vos données ont été supprimées avec succès.';

  @override
  String get clearDataSuccessSubtext =>
      'Vous pouvez maintenant recommencer avec une ardoise vierge.';

  @override
  String get clearConfirmWarningLabel => 'Avertissement - Action destructive';

  @override
  String get clearConfirmTitle => 'Effacer les données';

  @override
  String get clearConfirmBody1 =>
      'Cette action supprimera définitivement toutes vos listes de cet appareil.';

  @override
  String get clearConfirmBody2 => 'Vous ne pourrez pas annuler cette action.';

  @override
  String get clearConfirmHint =>
      'Action irréversible - confirmez pour effacer définitivement toutes les données';

  @override
  String get forgotPasswordSentTitle => 'Email envoyé !';

  @override
  String get forgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get emailAddressLabel => 'Adresse email';

  @override
  String get emailRequired => 'Email requis';

  @override
  String get emailInvalid => 'Email invalide';

  @override
  String get forgotPasswordSentTo =>
      'Un email de réinitialisation a été envoyé à :';

  @override
  String get forgotPasswordCheckInbox =>
      'Vérifiez votre boîte de réception et suivez les instructions pour réinitialiser votre mot de passe.';

  @override
  String get send => 'Envoyer';

  @override
  String get forgotPasswordIntro =>
      'Entrez votre adresse email pour recevoir un lien de réinitialisation de votre mot de passe.';

  @override
  String get duelRankingSaved => 'Classement enregistré';

  @override
  String get onboardingCaptureTitle => 'Tu penses à quoi en ce moment ?';

  @override
  String get onboardingCaptureHint =>
      'Une tâche par ligne. Ne réfléchis pas trop.';

  @override
  String get onboardingArchetypesLabel => 'Idées rapides';

  @override
  String onboardingTaskCounter(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tâches',
      one: '1 tâche',
      zero: 'Aucune tâche',
    );
    return '$_temp0';
  }

  @override
  String get onboardingStartButton => 'C\'est parti';

  @override
  String get onboardingDuelQuestion =>
      'Entre ces deux tâches, laquelle compte le plus maintenant ?';

  @override
  String onboardingDuelProgress(int index, int total) {
    return 'Duel $index/$total';
  }

  @override
  String get onboardingRevealTitle =>
      'Voici ce que tu veux vraiment faire en premier.';

  @override
  String get onboardingRevealContinue => 'Continuer vers l\'app';

  @override
  String get onboardingRevealMarkDone =>
      'Marquer comme fait quand c\'est accompli';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingArchetypeSport => 'Faire du sport';

  @override
  String get onboardingArchetypeCall => 'Appeler un proche';

  @override
  String get onboardingArchetypeReport => 'Terminer le rapport';

  @override
  String get onboardingArchetypeEmails => 'Trier mes emails';

  @override
  String get onboardingArchetypeGroceries => 'Faire les courses';

  @override
  String get onboardingArchetypeRead => 'Lire 10 pages';

  @override
  String get onboardingArchetypeTidy => 'Ranger le bureau';

  @override
  String get onboardingArchetypeWater => 'Boire de l\'eau';
}
