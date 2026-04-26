// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Prioris';

  @override
  String get home => 'Home';

  @override
  String get habits => 'Habits';

  @override
  String get tasks => 'Tasks';

  @override
  String get lists => 'Lists';

  @override
  String get habitFormTitleNew => 'New habit';

  @override
  String get habitFormTitleEdit => 'Edit habit';

  @override
  String get habitFormIntro =>
      'Give this habit a clear name, assign a category, and choose how you’ll track your progress.';

  @override
  String get habitFormNameLabel => 'Habit name';

  @override
  String get habitFormNameHint => 'E.g. Drink 8 glasses of water';

  @override
  String get habitFormCategoryLabel => 'Category';

  @override
  String get habitFormCategoryHint => 'Select a category';

  @override
  String get habitFormCategoryNone => 'No category';

  @override
  String get habitFormCategoryCreate => '+ Create a new category…';

  @override
  String get habitCategoryHelper =>
      'Recommended: choose a category for better statistics.';

  @override
  String get habitCategoryWarningTitle => 'No category selected';

  @override
  String get habitCategoryWarningMessage =>
      'You haven\'t chosen a category. Continue anyway?';

  @override
  String get habitFormQuantTargetLabel => 'Goal';

  @override
  String get habitFormQuantTargetHint => '8';

  @override
  String get habitFormQuantUnitLabel => 'Unit';

  @override
  String get habitFormQuantUnitHint => 'glasses';

  @override
  String get habitTrackingTitle => 'How would you like to track this habit?';

  @override
  String get habitTrackingTip =>
      'Tip: enter 1 if once per period is enough (same as done/not done).';

  @override
  String get habitTrackingPrefix => 'I want to do this habit';

  @override
  String get habitTrackingTimesWord => 'times';

  @override
  String get habitTrackingEveryWord => 'every';

  @override
  String get habitTrackingModeCycle => 'M days out of N';

  @override
  String get habitTrackingModeWeekdays => 'Specific weekdays';

  @override
  String get habitTrackingModeSpecificDate => 'On a specific date';

  @override
  String get habitTrackingCycleLabel => 'Cycle';

  @override
  String get habitTrackingCycleActiveDays => 'Active days (M)';

  @override
  String get habitTrackingCycleLength => 'Cycle length (N)';

  @override
  String get habitTrackingCycleStartDate => 'Cycle start date';

  @override
  String get habitTrackingWeekdaysLabel => 'Select weekdays';

  @override
  String get habitTrackingSpecificDateLabel => 'Date';

  @override
  String get habitTrackingRepeatEveryYear => 'Repeat every year';

  @override
  String get habitTrackingBackToPeriod => 'Back to \"per period\" mode';

  @override
  String get habitTrackingPeriodDay => 'per day';

  @override
  String get habitTrackingPeriodWeek => 'per week';

  @override
  String get habitTrackingPeriodMonth => 'per month';

  @override
  String get habitTrackingPeriodQuarter => 'per quarter';

  @override
  String get habitTrackingPeriodSemester => 'per semester';

  @override
  String get habitTrackingPeriodYear => 'per year';

  @override
  String get habitTrackingCustomInterval => 'every...';

  @override
  String get habitTrackingUnitHours => 'hours';

  @override
  String get habitTrackingUnitDays => 'days';

  @override
  String get habitTrackingUnitWeeks => 'weeks';

  @override
  String get habitTrackingUnitMonths => 'months';

  @override
  String get habitSummaryTitle => 'Summary';

  @override
  String get habitSummaryPlaceholder =>
      'Fill in the name and frequency to see the summary.';

  @override
  String habitSummaryAction(Object name) {
    return 'You want to $name';
  }

  @override
  String habitSummaryTimes(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '$count time',
    );
    return '$_temp0';
  }

  @override
  String listItemDateLabel(String date) {
    return 'Added on $date';
  }

  @override
  String get listItemDateUnknown => 'No date';

  @override
  String get listItemActionComplete => 'Complete';

  @override
  String get listItemActionReopen => 'Reopen';

  @override
  String get listEditTooltip => 'Edit list';

  @override
  String get listDeleteTooltip => 'Delete list';

  @override
  String get listEditDialogTitle => 'Edit list';

  @override
  String get listEditNameLabel => 'List name';

  @override
  String get listEditSaved => 'List updated.';

  @override
  String get habitFormTypePrompt => 'I want to track this habit by';

  @override
  String get habitFormTypeBinaryOption => 'checking it off when it’s done';

  @override
  String get habitFormTypeQuantOption => 'recording how much I complete';

  @override
  String get habitFormTypeBinaryDescription =>
      'Perfect for yes/no habits: tick it every time you complete it.';

  @override
  String get habitFormTypeQuantDescription =>
      'Track a measurable amount with a numeric goal and custom unit.';

  @override
  String get habitRecurrenceDaily => 'Daily';

  @override
  String get habitRecurrenceWeekly => 'Weekly';

  @override
  String get habitRecurrenceMonthly => 'Monthly';

  @override
  String get habitRecurrenceTimesPerWeek => 'Several times per week';

  @override
  String get habitRecurrenceTimesPerDay => 'Several times per day';

  @override
  String get habitRecurrenceMonthlyDay => 'Specific day of the month';

  @override
  String get habitRecurrenceQuarterly => 'Quarterly';

  @override
  String get habitRecurrenceYearly => 'Yearly';

  @override
  String get habitRecurrenceHourlyInterval => 'Every X hours';

  @override
  String get habitRecurrenceTimesPerHour => 'Several times per hour';

  @override
  String get habitRecurrenceWeekends => 'Weekends';

  @override
  String get habitRecurrenceWeekdays => 'Weekdays';

  @override
  String get habitRecurrenceEveryXDays => 'Every X days';

  @override
  String get habitRecurrenceSpecificWeekdays => 'Specific days of the week';

  @override
  String get habitFormSubmitCreate => 'Create habit';

  @override
  String get habitFormValidationNameRequired =>
      'Please enter a name for the habit';

  @override
  String get statistics => 'Statistics';

  @override
  String get prioritize => 'Prioritize';

  @override
  String get addHabit => 'Add Habit';

  @override
  String get addTask => 'Add Task';

  @override
  String get addList => 'Add a list';

  @override
  String get listsEmptyTitle => 'No list yet';

  @override
  String get listsEmptySubtitle => 'Add your first list to get started';

  @override
  String get listEmptyTitle => 'No items found';

  @override
  String get listEmptySearchBody => 'Try another search term';

  @override
  String get listEmptyNoItemsBody => 'Add your first item to get started';

  @override
  String get listsOverviewTitle => 'See your lists at a glance';

  @override
  String listsOverviewSubtitle(int totalLists, int totalItems) {
    return '$totalLists lists | $totalItems active items';
  }

  @override
  String get name => 'Name';

  @override
  String get description => 'Description';

  @override
  String get category => 'Category';

  @override
  String get priority => 'Priority';

  @override
  String get frequency => 'Frequency';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get create => 'Create';

  @override
  String get completed => 'Completed';

  @override
  String get incomplete => 'Incomplete';

  @override
  String get hideCompleted => 'Hide Completed';

  @override
  String get showCompleted => 'Show Completed';

  @override
  String get hideEloScores => 'Hide ELO Scores';

  @override
  String get showEloScores => 'Show ELO Scores';

  @override
  String get overview => 'Overview';

  @override
  String get insightsTabTrends => 'Trends';

  @override
  String get habitsTab => 'Habits';

  @override
  String get tasksTab => 'Tasks';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get successRate => 'Success Rate';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get longestStreak => 'Longest Streak';

  @override
  String get language => 'Language';

  @override
  String get settings => 'Settings';

  @override
  String get settingsGeneralSectionTitle => 'General';

  @override
  String get settingsPilotSectionTitle => 'Pilot';

  @override
  String get pilotIdentityBadge => 'External pilot';

  @override
  String get settingsHelpFeedbackSectionTitle => 'Help & feedback';

  @override
  String get settingsAboutSectionTitle => 'About';

  @override
  String get settingsPilotStatusTitle => 'Pilot status';

  @override
  String get settingsPilotStatusBody =>
      'Limited external pilot. Prioris currently covers the shell, lists, prioritisation, and basic habits.';

  @override
  String get settingsPilotLimitsTitle => 'Current limits';

  @override
  String get settingsPilotLimitsBody =>
      'No billing, no public support, no hosted help centre, and no promise beyond the current scope.';

  @override
  String settingsVersionValue(String version) {
    return '$version';
  }

  @override
  String get settingsVersionFallbackLabel => 'External pilot build';

  @override
  String settingsLanguageChanged(String language) {
    return 'Language changed to $language';
  }

  @override
  String get logout => 'Sign out';

  @override
  String get homeLogoutHint => 'Sign out the current user';

  @override
  String get homeSettingsHint => 'Open the application settings';

  @override
  String get homeMainContentLabel => 'Main content';

  @override
  String get homePrimaryNavigationLabel => 'Primary navigation';

  @override
  String get homePrimaryNavigationHint =>
      'Use the navigation items to move between sections';

  @override
  String homeNavigationAnnouncement(String section) {
    return 'Navigate to $section';
  }

  @override
  String get noData => 'No data available';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get confirm => 'Confirm';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get reset => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get open => 'Open';

  @override
  String get refresh => 'Refresh';

  @override
  String get export => 'Export';

  @override
  String get import => 'Import';

  @override
  String get share => 'Share';

  @override
  String get copy => 'Copy';

  @override
  String get paste => 'Paste';

  @override
  String get cut => 'Cut';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get select => 'Select';

  @override
  String get deselect => 'Deselect';

  @override
  String get all => 'All';

  @override
  String get none => 'None';

  @override
  String get today => 'Today';

  @override
  String get todayPanelSubtitle =>
      'The few items that deserve your attention now';

  @override
  String todayPanelCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reliable items',
      one: '$count reliable item',
    );
    return '$_temp0';
  }

  @override
  String get todayPanelLoading => 'Preparing your view for today...';

  @override
  String get todayPanelCalmTitle => 'Nothing urgent right now';

  @override
  String get todayPanelCalmBody =>
      'Your day looks calm. Continue from your lists or habits if you want to keep moving.';

  @override
  String get todayPanelFirstUseTitle => 'Your space is ready';

  @override
  String get todayPanelFirstUseBody =>
      'Start by creating your first list or habit. Your next actions will show up here.';

  @override
  String get todayPanelPartial =>
      'Partial view: some signals are still loading.';

  @override
  String get todayPanelError => 'The view for today is temporarily limited.';

  @override
  String get todayPanelTaskKind => 'Task';

  @override
  String get todayPanelHabitKind => 'Habit';

  @override
  String get todayPanelStatusOverdue => 'Overdue';

  @override
  String get todayPanelStatusDueToday => 'Today';

  @override
  String get todayPanelStatusPending => 'To review';

  @override
  String get todayPanelReasonOverdueTask => 'Task already overdue';

  @override
  String get todayPanelReasonDueTodayTask => 'Due today';

  @override
  String get todayPanelReasonPriorityTask => 'High-leverage task';

  @override
  String get todayPanelReasonDueTodayHabit => 'Habit expected today';

  @override
  String todayPanelParentListLabel(Object title) {
    return 'List: $title';
  }

  @override
  String get todayPanelActionOpenList => 'Open list';

  @override
  String get todayPanelActionOpenDuel => 'Prioritise';

  @override
  String get todayPanelActionRecordHabit => 'Mark done';

  @override
  String get todayPanelActionRecordValue => 'Enter value';

  @override
  String get todayPanelActionOpenHabits => 'Open habits';

  @override
  String get todayPanelActionUnavailable =>
      'This action is no longer available in the current state.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get thisYear => 'This Year';

  @override
  String get lastYear => 'Last Year';

  @override
  String get days => 'days';

  @override
  String get hours => 'hours';

  @override
  String get minutes => 'minutes';

  @override
  String get seconds => 'seconds';

  @override
  String get points => 'points';

  @override
  String get items => 'items';

  @override
  String get tasksCompleted => 'tasks completed';

  @override
  String get habitsCompleted => 'habits completed';

  @override
  String get listsCompleted => 'lists completed';

  @override
  String listCompletionLabel(int completed, int total) {
    return '$completed of $total items done';
  }

  @override
  String listCompletionProgress(String percent) {
    return '$percent% complete';
  }

  @override
  String get progress => 'Progress';

  @override
  String get performance => 'Performance';

  @override
  String get analytics => 'Analytics';

  @override
  String get insights => 'Insights';

  @override
  String get insightsHeaderTitle => 'Track your progress';

  @override
  String get insightsHeaderSubtitleEmpty =>
      'Create habits to unlock your first insights.';

  @override
  String insightsHeaderSubtitleWithHabits(int count) {
    return 'Overview and trends for your $count habits';
  }

  @override
  String get insightsEmptyTitle => 'No insights yet';

  @override
  String get insightsEmptyBody =>
      'Create your first habit to unlock your first insights here.';

  @override
  String get insightsOverviewPlaceholder =>
      'Your overview will appear here soon.';

  @override
  String get insightsTrendsPlaceholder => 'Your trends will appear here soon.';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get tips => 'Tips';

  @override
  String get help => 'Help';

  @override
  String get settingsHelpSubtitle =>
      'Understand how to get help during this pilot.';

  @override
  String get settingsHelpDialogBody =>
      'Pilot support stays manual and intentionally bounded. Use the pilot feedback channel to ask a question, report an issue, or share a need. No real-time assistance or public SLA is promised.';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get developer => 'Developer';

  @override
  String get contact => 'Contact';

  @override
  String get feedback => 'Feedback';

  @override
  String get settingsFeedbackSubtitle => 'Open the pilot feedback channel.';

  @override
  String get settingsFeedbackDialogBody =>
      'The pilot feedback channel opens a simple form in your browser. It is also used for help requests, bugs, and feature requests.';

  @override
  String get reportBug => 'Report Bug';

  @override
  String get settingsReportBugSubtitle =>
      'Use the same pilot channel to report a bug.';

  @override
  String get settingsReportBugDialogBody =>
      'Bug reports go through the same pilot channel as general feedback. Describe the visible context, the device, and the observed result.';

  @override
  String get requestFeature => 'Request Feature';

  @override
  String get settingsRequestFeatureSubtitle =>
      'Use the same pilot channel to share a need.';

  @override
  String get settingsRequestFeatureDialogBody =>
      'Feature requests go through the same pilot channel. They are reviewed manually and do not create a delivery commitment.';

  @override
  String get settingsSupportLaunchFailureBody =>
      'Unable to open this channel automatically. Use this link in your browser:';

  @override
  String get settingsSupportUnavailableBody =>
      'This build does not configure a pilot support channel yet. Add a feedback URL or a support email before any external pilot release.';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacySubtitle => 'Read how pilot data is handled.';

  @override
  String get settingsPrivacyDialogBody =>
      'Prioris only stores the data needed for this pilot: account, lists, tasks, habits, and related sync signals. This data is used to run the product, fix reported issues, and evaluate the pilot. If you have a question about your data, use the pilot feedback channel.';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get settingsTermsSubtitle =>
      'Read the minimal usage framework for this pilot.';

  @override
  String get settingsTermsDialogBody =>
      'This pilot is reserved for a small invited group. Access, features, and availability may change without notice. Do not use Prioris as a critical system or as the sole source of truth for sensitive decisions. Feedback is welcome, but no immediate fix or public rollout is guaranteed.';

  @override
  String get license => 'License';

  @override
  String get settingsLicenseSubtitle =>
      'Open the licenses shipped with this build.';

  @override
  String get settingsAboutLegalese =>
      'Limited external pilot. Manual support through the pilot channel, with no pricing or public commitment yet.';

  @override
  String get credits => 'Credits';

  @override
  String get changelog => 'Changelog';

  @override
  String get updateAvailable => 'Update Available';

  @override
  String get updateNow => 'Update Now';

  @override
  String get later => 'Later';

  @override
  String get never => 'Never';

  @override
  String get always => 'Always';

  @override
  String get sometimes => 'Sometimes';

  @override
  String get rarely => 'Rarely';

  @override
  String get often => 'Often';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get custom => 'Custom';

  @override
  String get automatic => 'Automatic';

  @override
  String get manual => 'Manual';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get synchronized => 'Synchronized';

  @override
  String get notSynchronized => 'Not Synchronized';

  @override
  String get synchronizing => 'Synchronizing...';

  @override
  String get syncFailed => 'Sync Failed';

  @override
  String get retry => 'Retry';

  @override
  String get skip => 'Skip';

  @override
  String get finish => 'Finish';

  @override
  String get complete => 'Complete';

  @override
  String get pending => 'Pending';

  @override
  String get processing => 'Processing...';

  @override
  String get waiting => 'Waiting...';

  @override
  String get ready => 'Ready';

  @override
  String get notReady => 'Not Ready';

  @override
  String get available => 'Available';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get busy => 'Busy';

  @override
  String get free => 'Free';

  @override
  String get occupied => 'Occupied';

  @override
  String get empty => 'Empty';

  @override
  String get full => 'Full';

  @override
  String get partial => 'Partial';

  @override
  String get exact => 'Exact';

  @override
  String get approximate => 'Approximate';

  @override
  String get estimated => 'Estimated';

  @override
  String get actual => 'Actual';

  @override
  String get planned => 'Planned';

  @override
  String get unplanned => 'Unplanned';

  @override
  String get scheduled => 'Scheduled';

  @override
  String get unscheduled => 'Unscheduled';

  @override
  String get overdue => 'Overdue';

  @override
  String get onTime => 'On Time';

  @override
  String get early => 'Early';

  @override
  String get late => 'Late';

  @override
  String get urgent => 'Urgent';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get critical => 'Critical';

  @override
  String get important => 'Important';

  @override
  String get normal => 'Normal';

  @override
  String get minor => 'Minor';

  @override
  String get trivial => 'Trivial';

  @override
  String get personal => 'Personal';

  @override
  String get work => 'Work';

  @override
  String get health => 'Health';

  @override
  String get fitness => 'Fitness';

  @override
  String get education => 'Education';

  @override
  String get finance => 'Finance';

  @override
  String get social => 'Social';

  @override
  String get family => 'Family';

  @override
  String get hobby => 'Hobby';

  @override
  String get travel => 'Travel';

  @override
  String get shopping => 'Shopping';

  @override
  String get entertainment => 'Entertainment';

  @override
  String get other => 'Other';

  @override
  String get defaultValue => 'Default';

  @override
  String get continueLabel => 'Continue';

  @override
  String get duelPriorityTitle => 'Priority Mode';

  @override
  String get duelPrioritySubtitle => 'Which task do you prefer?';

  @override
  String get duelPriorityHint => 'Tap the card you want to prioritise.';

  @override
  String get duelSkipAction => 'Skip duel';

  @override
  String get duelRandomAction => 'Random result';

  @override
  String get duelShowElo => 'Show Elo';

  @override
  String get duelHideElo => 'Hide Elo';

  @override
  String get duelModeLabel => 'Duel mode';

  @override
  String get duelModeWinner => 'Winner';

  @override
  String get duelModeRanking => 'Ranking';

  @override
  String get duelCardsPerRoundLabel => 'Cards per round';

  @override
  String duelCardsPerRoundOption(int count) {
    return '$count cards';
  }

  @override
  String duelModeSummary(String mode, int count) {
    return 'Duel mode: $mode - $count cards';
  }

  @override
  String get duelSubmitRanking => 'Save ranking';

  @override
  String get duelPreferenceSaved => 'Preference saved.';

  @override
  String duelRemainingDuels(int count) {
    return '$count duels remaining today';
  }

  @override
  String get duelConfigureLists => 'Choose lists for duels';

  @override
  String get duelNoAvailableLists => 'No list available';

  @override
  String get duelNoAvailableListsForPrioritization =>
      'No list available for prioritisation';

  @override
  String get duelListsUpdated => 'Prioritisation lists updated';

  @override
  String get duelNewDuel => 'New duel';

  @override
  String get duelNotEnoughTasksTitle => 'Not enough tasks';

  @override
  String get duelNotEnoughTasksMessage =>
      'Add at least two tasks to start prioritising.';

  @override
  String get duelErrorMessage => 'Unable to load the duel. Try again.';

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
  String habitFrequencyTimesPerQuarter(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per quarter',
      one: '$count time per quarter',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyTimesPerSemester(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times per semester',
      one: '$count time per semester',
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
  String habitFrequencyEveryHours(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval hours',
      one: 'every hour',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryDays(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval days',
      one: 'daily',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryWeeks(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval weeks',
      one: 'weekly',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryMonths(num interval, Object count) {
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
  String habitFrequencyDaysPerCycle(Object daysActive, Object daysCycle) {
    return '$daysActive days out of $daysCycle';
  }

  @override
  String habitFrequencySpecificDateAnnual(String date) {
    return 'Every year on $date';
  }

  @override
  String habitFrequencySpecificDateOnce(String date) {
    return 'On $date';
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

  @override
  String get sortBy => 'Sort by';

  @override
  String get scoreElo => 'Elo Score';

  @override
  String get random => 'Random';

  @override
  String get orderAscending => 'Ascending order';

  @override
  String get orderDescending => 'Descending order';

  @override
  String itemsCount(int count) {
    return '$count items';
  }

  @override
  String get add => 'Add';

  @override
  String get keepOpenAfterAdd => 'Keep open after adding';

  @override
  String get bulkAddSingleHint => 'Add an item...';

  @override
  String get bulkAddMultipleHint => 'Add multiple items (one per line)...';

  @override
  String get bulkAddHelpText => 'New line = new item';

  @override
  String get closeDialog => 'Close';

  @override
  String get bulkAddDefaultTitle => 'Add items';

  @override
  String get bulkAddSubmitting => 'Adding items...';

  @override
  String get bulkAddModeSingle => 'Single';

  @override
  String get bulkAddModeMultiple => 'Multiple';

  @override
  String bulkAddImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items imported',
      one: '$count item imported',
    );
    return '$_temp0';
  }

  @override
  String get bulkAddImportError => 'Import failed';

  @override
  String get listDeleteDialogTitle => 'Delete list';

  @override
  String listDeleteDialogMessage(String listName) {
    return 'Are you sure you want to delete \"$listName\"?';
  }

  @override
  String get listDeleteConfirm => 'Delete';

  @override
  String get listRenameDialogTitle => 'Rename item';

  @override
  String get listRenameDialogLabel => 'Item name';

  @override
  String get listRenameSaved => 'Item renamed.';

  @override
  String get listMoveDialogTitle => 'Move item';

  @override
  String get listMoveDialogLabel => 'Destination list';

  @override
  String get listMoveNoOtherList => 'No other list available';

  @override
  String get listMoveSaved => 'Item moved.';

  @override
  String get listDuplicateSaved => 'Item duplicated.';

  @override
  String get listConfirmDeleteItemTitle => 'Delete item';

  @override
  String listConfirmDeleteItemMessage(String itemTitle) {
    return 'Are you sure you want to delete \"$itemTitle\"?';
  }

  @override
  String get more => 'More';

  @override
  String get rename => 'Rename';

  @override
  String get move => 'Move...';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get authOfflineSignInError =>
      'Sign-in is unavailable in offline mode. Configure real Supabase credentials in .env to enable online features.';

  @override
  String get authOfflineSignUpError =>
      'Sign-up is unavailable in offline mode. Configure real Supabase credentials in .env to enable online features.';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authSignUpTitle => 'Create an account';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authSignUpAction => 'Create account';

  @override
  String get authToggleToSignUp => 'No account yet? Create one';

  @override
  String get authToggleToSignIn => 'Already have an account? Sign in';

  @override
  String get authForgotPasswordAction => 'Forgot password?';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailHint => 'you@example.com';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordHint => '********';

  @override
  String get authTechnicalFieldLabel => 'Technical field (leave empty)';

  @override
  String get authPendingConfirmationTitle => 'Confirmation required';

  @override
  String authPendingConfirmationMessage(String email) {
    return 'A confirmation email was sent to $email. Confirm your email address to finish the sign-up flow, then sign in again.';
  }

  @override
  String get authCallbackExpiredMessage =>
      'Your sign-in link has expired or was opened in a different browser. Please sign in again.';

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
