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
  String get habitFormCategoryLabel => 'Category (optional)';

  @override
  String get habitFormCategoryHint => 'Select a category';

  @override
  String get habitFormCategoryNone => 'No category';

  @override
  String get habitFormCategoryCreate => '+ Create a new category…';

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
  String get habitTrackingBackToPeriod => 'Back to \"per period\" mode';

  @override
  String get habitTrackingPeriodDay => 'per day';

  @override
  String get habitTrackingPeriodWeek => 'per week';

  @override
  String get habitTrackingPeriodMonth => 'per month';

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
  String get addList => 'Add List';

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
  String get recommendations => 'Recommendations';

  @override
  String get suggestions => 'Suggestions';

  @override
  String get tips => 'Tips';

  @override
  String get help => 'Help';

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
  String get reportBug => 'Report Bug';

  @override
  String get requestFeature => 'Request Feature';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get license => 'License';

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
  String habitFrequencyEveryQuarters(num interval, Object count) {
    String _temp0 = intl.Intl.pluralLogic(
      interval,
      locale: localeName,
      other: 'every $interval quarters',
      one: 'quarterly',
    );
    return '$_temp0';
  }

  @override
  String habitFrequencyEveryYears(num interval, Object count) {
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
}
