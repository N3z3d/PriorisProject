import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Prioris'**
  String get appTitle;

  /// Home page title
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Habits page title
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habits;

  /// Tasks page title
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// Lists page title
  ///
  /// In en, this message translates to:
  /// **'Lists'**
  String get lists;

  /// No description provided for @habitFormTitleNew.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get habitFormTitleNew;

  /// No description provided for @habitFormTitleEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habitFormTitleEdit;

  /// No description provided for @habitFormIntro.
  ///
  /// In en, this message translates to:
  /// **'Give this habit a clear name, assign a category, and choose how you’ll track your progress.'**
  String get habitFormIntro;

  /// No description provided for @habitFormNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit name'**
  String get habitFormNameLabel;

  /// No description provided for @habitFormNameHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Drink 8 glasses of water'**
  String get habitFormNameHint;

  /// No description provided for @habitFormCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get habitFormCategoryLabel;

  /// No description provided for @habitFormCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get habitFormCategoryHint;

  /// No description provided for @habitFormCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get habitFormCategoryNone;

  /// No description provided for @habitFormCategoryCreate.
  ///
  /// In en, this message translates to:
  /// **'+ Create a new category…'**
  String get habitFormCategoryCreate;

  /// No description provided for @habitFormQuantTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get habitFormQuantTargetLabel;

  /// No description provided for @habitFormQuantTargetHint.
  ///
  /// In en, this message translates to:
  /// **'8'**
  String get habitFormQuantTargetHint;

  /// No description provided for @habitFormQuantUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get habitFormQuantUnitLabel;

  /// No description provided for @habitFormQuantUnitHint.
  ///
  /// In en, this message translates to:
  /// **'glasses'**
  String get habitFormQuantUnitHint;

  /// No description provided for @habitFormTypePrompt.
  ///
  /// In en, this message translates to:
  /// **'I want to track this habit by'**
  String get habitFormTypePrompt;

  /// No description provided for @habitFormTypeBinaryOption.
  ///
  /// In en, this message translates to:
  /// **'checking it off when it’s done'**
  String get habitFormTypeBinaryOption;

  /// No description provided for @habitFormTypeQuantOption.
  ///
  /// In en, this message translates to:
  /// **'recording how much I complete'**
  String get habitFormTypeQuantOption;

  /// No description provided for @habitFormTypeBinaryDescription.
  ///
  /// In en, this message translates to:
  /// **'Perfect for yes/no habits: tick it every time you complete it.'**
  String get habitFormTypeBinaryDescription;

  /// No description provided for @habitFormTypeQuantDescription.
  ///
  /// In en, this message translates to:
  /// **'Track a measurable amount with a numeric goal and custom unit.'**
  String get habitFormTypeQuantDescription;

  /// No description provided for @habitRecurrenceDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get habitRecurrenceDaily;

  /// No description provided for @habitRecurrenceWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get habitRecurrenceWeekly;

  /// No description provided for @habitRecurrenceMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get habitRecurrenceMonthly;

  /// No description provided for @habitRecurrenceTimesPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Several times per week'**
  String get habitRecurrenceTimesPerWeek;

  /// No description provided for @habitRecurrenceTimesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Several times per day'**
  String get habitRecurrenceTimesPerDay;

  /// No description provided for @habitRecurrenceMonthlyDay.
  ///
  /// In en, this message translates to:
  /// **'Specific day of the month'**
  String get habitRecurrenceMonthlyDay;

  /// No description provided for @habitRecurrenceQuarterly.
  ///
  /// In en, this message translates to:
  /// **'Quarterly'**
  String get habitRecurrenceQuarterly;

  /// No description provided for @habitRecurrenceYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get habitRecurrenceYearly;

  /// No description provided for @habitRecurrenceHourlyInterval.
  ///
  /// In en, this message translates to:
  /// **'Every X hours'**
  String get habitRecurrenceHourlyInterval;

  /// No description provided for @habitRecurrenceTimesPerHour.
  ///
  /// In en, this message translates to:
  /// **'Several times per hour'**
  String get habitRecurrenceTimesPerHour;

  /// No description provided for @habitRecurrenceWeekends.
  ///
  /// In en, this message translates to:
  /// **'Weekends'**
  String get habitRecurrenceWeekends;

  /// No description provided for @habitRecurrenceWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get habitRecurrenceWeekdays;

  /// Label for recurrence option: every X days
  ///
  /// In en, this message translates to:
  /// **'Every X days'**
  String get habitRecurrenceEveryXDays;

  /// Label for recurrence option: select specific weekdays
  ///
  /// In en, this message translates to:
  /// **'Specific days of the week'**
  String get habitRecurrenceSpecificWeekdays;

  /// No description provided for @habitFormSubmitCreate.
  ///
  /// In en, this message translates to:
  /// **'Create habit'**
  String get habitFormSubmitCreate;

  /// No description provided for @habitFormValidationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name for the habit'**
  String get habitFormValidationNameRequired;

  /// Statistics page title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Prioritize page title
  ///
  /// In en, this message translates to:
  /// **'Prioritize'**
  String get prioritize;

  /// Add habit button text
  ///
  /// In en, this message translates to:
  /// **'Add Habit'**
  String get addHabit;

  /// Add task button text
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Add list button text
  ///
  /// In en, this message translates to:
  /// **'Add List'**
  String get addList;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Priority field label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// Frequency field label
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get frequency;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Create button text
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Incomplete status
  ///
  /// In en, this message translates to:
  /// **'Incomplete'**
  String get incomplete;

  /// Hide completed items button
  ///
  /// In en, this message translates to:
  /// **'Hide Completed'**
  String get hideCompleted;

  /// Show completed items button
  ///
  /// In en, this message translates to:
  /// **'Show Completed'**
  String get showCompleted;

  /// Hide ELO scores button
  ///
  /// In en, this message translates to:
  /// **'Hide ELO Scores'**
  String get hideEloScores;

  /// Show ELO scores button
  ///
  /// In en, this message translates to:
  /// **'Show ELO Scores'**
  String get showEloScores;

  /// Overview tab title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Habits tab title
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTab;

  /// Tasks tab title
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksTab;

  /// Total points label
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// Success rate label
  ///
  /// In en, this message translates to:
  /// **'Success Rate'**
  String get successRate;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Longest streak label
  ///
  /// In en, this message translates to:
  /// **'Longest Streak'**
  String get longestStreak;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Next button text
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous button text
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Filter button text
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// Sort button text
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Open button text
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// Refresh button text
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Export button text
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Import button text
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Copy button text
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// Paste button text
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get paste;

  /// Cut button text
  ///
  /// In en, this message translates to:
  /// **'Cut'**
  String get cut;

  /// Undo button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Redo button text
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// Select all button text
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// Deselect all button text
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// Select button text
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Deselect button text
  ///
  /// In en, this message translates to:
  /// **'Deselect'**
  String get deselect;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// None filter option
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// This week label
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Last week label
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// This month label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Last month label
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// This year label
  ///
  /// In en, this message translates to:
  /// **'This Year'**
  String get thisYear;

  /// Last year label
  ///
  /// In en, this message translates to:
  /// **'Last Year'**
  String get lastYear;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get hours;

  /// Minutes unit
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Seconds unit
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Points unit
  ///
  /// In en, this message translates to:
  /// **'points'**
  String get points;

  /// Items unit
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// Tasks completed label
  ///
  /// In en, this message translates to:
  /// **'tasks completed'**
  String get tasksCompleted;

  /// Habits completed label
  ///
  /// In en, this message translates to:
  /// **'habits completed'**
  String get habitsCompleted;

  /// Lists completed label
  ///
  /// In en, this message translates to:
  /// **'lists completed'**
  String get listsCompleted;

  /// No description provided for @listCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} items done'**
  String listCompletionLabel(int completed, int total);

  /// No description provided for @listCompletionProgress.
  ///
  /// In en, this message translates to:
  /// **'{percent}% complete'**
  String listCompletionProgress(String percent);

  /// Progress label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Performance label
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get performance;

  /// Analytics label
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Insights label
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Recommendations label
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// Suggestions label
  ///
  /// In en, this message translates to:
  /// **'Suggestions'**
  String get suggestions;

  /// Tips label
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// Help label
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// About label
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Developer label
  ///
  /// In en, this message translates to:
  /// **'Developer'**
  String get developer;

  /// Contact label
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// Feedback label
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Report bug button text
  ///
  /// In en, this message translates to:
  /// **'Report Bug'**
  String get reportBug;

  /// Request feature button text
  ///
  /// In en, this message translates to:
  /// **'Request Feature'**
  String get requestFeature;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// License link
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// Credits link
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// Changelog link
  ///
  /// In en, this message translates to:
  /// **'Changelog'**
  String get changelog;

  /// Update available message
  ///
  /// In en, this message translates to:
  /// **'Update Available'**
  String get updateAvailable;

  /// Update now button text
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// Later button text
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Never button text
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// Always button text
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get always;

  /// Sometimes button text
  ///
  /// In en, this message translates to:
  /// **'Sometimes'**
  String get sometimes;

  /// Rarely button text
  ///
  /// In en, this message translates to:
  /// **'Rarely'**
  String get rarely;

  /// Often button text
  ///
  /// In en, this message translates to:
  /// **'Often'**
  String get often;

  /// Daily frequency
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// Weekly frequency
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// Monthly frequency
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Yearly frequency
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// Custom option
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Automatic option
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get automatic;

  /// Manual option
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// Enabled status
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get enabled;

  /// Disabled status
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get disabled;

  /// Active status
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Inactive status
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Connected status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected status
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Synchronized status
  ///
  /// In en, this message translates to:
  /// **'Synchronized'**
  String get synchronized;

  /// Not synchronized status
  ///
  /// In en, this message translates to:
  /// **'Not Synchronized'**
  String get notSynchronized;

  /// Synchronizing message
  ///
  /// In en, this message translates to:
  /// **'Synchronizing...'**
  String get synchronizing;

  /// Sync failed message
  ///
  /// In en, this message translates to:
  /// **'Sync Failed'**
  String get syncFailed;

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Skip button text
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Finish button text
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Complete button text
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// Waiting message
  ///
  /// In en, this message translates to:
  /// **'Waiting...'**
  String get waiting;

  /// Ready status
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// Not ready status
  ///
  /// In en, this message translates to:
  /// **'Not Ready'**
  String get notReady;

  /// Available status
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Unavailable status
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// Busy status
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Free status
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// Occupied status
  ///
  /// In en, this message translates to:
  /// **'Occupied'**
  String get occupied;

  /// Empty status
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get empty;

  /// Full status
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get full;

  /// Partial status
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get partial;

  /// Exact status
  ///
  /// In en, this message translates to:
  /// **'Exact'**
  String get exact;

  /// Approximate status
  ///
  /// In en, this message translates to:
  /// **'Approximate'**
  String get approximate;

  /// Estimated status
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get estimated;

  /// Actual status
  ///
  /// In en, this message translates to:
  /// **'Actual'**
  String get actual;

  /// Planned status
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// Unplanned status
  ///
  /// In en, this message translates to:
  /// **'Unplanned'**
  String get unplanned;

  /// Scheduled status
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get scheduled;

  /// Unscheduled status
  ///
  /// In en, this message translates to:
  /// **'Unscheduled'**
  String get unscheduled;

  /// Overdue status
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// On time status
  ///
  /// In en, this message translates to:
  /// **'On Time'**
  String get onTime;

  /// Early status
  ///
  /// In en, this message translates to:
  /// **'Early'**
  String get early;

  /// Late status
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get late;

  /// Urgent priority
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// High priority
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// Medium priority
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// Low priority
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// Critical priority
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// Important priority
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get important;

  /// Normal priority
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// Minor priority
  ///
  /// In en, this message translates to:
  /// **'Minor'**
  String get minor;

  /// Trivial priority
  ///
  /// In en, this message translates to:
  /// **'Trivial'**
  String get trivial;

  /// Personal category
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get personal;

  /// Work category
  ///
  /// In en, this message translates to:
  /// **'Work'**
  String get work;

  /// Health category
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Fitness category
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// Education category
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get education;

  /// Finance category
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// Social category
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// Family category
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get family;

  /// Hobby category
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get hobby;

  /// Travel category
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travel;

  /// Shopping category
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get shopping;

  /// Entertainment category
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get entertainment;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Default option
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultValue;

  /// Continue button label
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// Title for the priority duel page
  ///
  /// In en, this message translates to:
  /// **'Priority Mode'**
  String get duelPriorityTitle;

  /// Subtitle prompting the user to choose between two tasks
  ///
  /// In en, this message translates to:
  /// **'Which task do you prefer?'**
  String get duelPrioritySubtitle;

  /// Helper text explaining how to select a task
  ///
  /// In en, this message translates to:
  /// **'Tap the card you want to prioritise.'**
  String get duelPriorityHint;

  /// Action to skip the current duel
  ///
  /// In en, this message translates to:
  /// **'Skip duel'**
  String get duelSkipAction;

  /// Action to select a random result for the current duel
  ///
  /// In en, this message translates to:
  /// **'Random result'**
  String get duelRandomAction;

  /// Action to display Elo scores
  ///
  /// In en, this message translates to:
  /// **'Show Elo'**
  String get duelShowElo;

  /// Action to hide Elo scores
  ///
  /// In en, this message translates to:
  /// **'Hide Elo'**
  String get duelHideElo;

  /// Label displayed above the duel mode selector
  ///
  /// In en, this message translates to:
  /// **'Duel mode'**
  String get duelModeLabel;

  /// Toggle label for the winner mode
  ///
  /// In en, this message translates to:
  /// **'Winner'**
  String get duelModeWinner;

  /// Toggle label for the ranking mode
  ///
  /// In en, this message translates to:
  /// **'Ranking'**
  String get duelModeRanking;

  /// Label displayed above the cards per round selector
  ///
  /// In en, this message translates to:
  /// **'Cards per round'**
  String get duelCardsPerRoundLabel;

  /// Dropdown option describing the number of cards per round
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String duelCardsPerRoundOption(int count);

  /// Summary label combining duel mode and cards per round
  ///
  /// In en, this message translates to:
  /// **'Duel mode: {mode} - {count} cards'**
  String duelModeSummary(String mode, int count);

  /// Button label to submit the full ranking
  ///
  /// In en, this message translates to:
  /// **'Save ranking'**
  String get duelSubmitRanking;

  /// Toast message confirming the duel choice
  ///
  /// In en, this message translates to:
  /// **'Preference saved.'**
  String get duelPreferenceSaved;

  /// Informational label displaying the number of duels left today
  ///
  /// In en, this message translates to:
  /// **'{count} duels remaining today'**
  String duelRemainingDuels(int count);

  /// Action to configure which lists participate in duels
  ///
  /// In en, this message translates to:
  /// **'Choose lists for duels'**
  String get duelConfigureLists;

  /// Tooltip displayed when no list can be selected
  ///
  /// In en, this message translates to:
  /// **'No list available'**
  String get duelNoAvailableLists;

  /// Snackbar shown when no list can be selected for duels
  ///
  /// In en, this message translates to:
  /// **'No list available for prioritisation'**
  String get duelNoAvailableListsForPrioritization;

  /// Confirmation message when duel lists are updated
  ///
  /// In en, this message translates to:
  /// **'Prioritisation lists updated'**
  String get duelListsUpdated;

  /// Action to trigger a new duel
  ///
  /// In en, this message translates to:
  /// **'New duel'**
  String get duelNewDuel;

  /// Title displayed when there are not enough tasks for a duel
  ///
  /// In en, this message translates to:
  /// **'Not enough tasks'**
  String get duelNotEnoughTasksTitle;

  /// Message explaining that more tasks are needed
  ///
  /// In en, this message translates to:
  /// **'Add at least two tasks to start prioritising.'**
  String get duelNotEnoughTasksMessage;

  /// Generic error message when a duel fails to load
  ///
  /// In en, this message translates to:
  /// **'Unable to load the duel. Try again.'**
  String get duelErrorMessage;

  /// Snackbar message when a habit is created successfully
  ///
  /// In en, this message translates to:
  /// **'Habit created ✅'**
  String get habitsActionCreateSuccess;

  /// Error message when creating a habit fails
  ///
  /// In en, this message translates to:
  /// **'Error while creating: {error}'**
  String habitsActionCreateError(String error);

  /// Snackbar message when a habit is updated
  ///
  /// In en, this message translates to:
  /// **'Habit \"{habitName}\" updated'**
  String habitsActionUpdateSuccess(String habitName);

  /// Error message when updating a habit fails
  ///
  /// In en, this message translates to:
  /// **'Error while updating: {error}'**
  String habitsActionUpdateError(String error);

  /// Snackbar when a habit is deleted
  ///
  /// In en, this message translates to:
  /// **'Habit \"{habitName}\" deleted'**
  String habitsActionDeleteSuccess(String habitName);

  /// Error message when deleting a habit fails
  ///
  /// In en, this message translates to:
  /// **'Unable to delete habit: {error}'**
  String habitsActionDeleteError(String error);

  /// Snackbar when a habit is recorded
  ///
  /// In en, this message translates to:
  /// **'Habit \"{habitName}\" recorded'**
  String habitsActionRecordSuccess(String habitName);

  /// Error message when recording a habit fails
  ///
  /// In en, this message translates to:
  /// **'Error while recording: {error}'**
  String habitsActionRecordError(String error);

  /// Loading dialog text when recording a habit
  ///
  /// In en, this message translates to:
  /// **'Recording...'**
  String get habitsLoadingRecord;

  /// Loading dialog text when deleting a habit
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get habitsLoadingDelete;

  /// Error shown when an unknown habit action is requested
  ///
  /// In en, this message translates to:
  /// **'Unsupported action: {action}'**
  String habitsActionUnsupported(String action);

  /// Title of the delete habit confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get habitsDialogDeleteTitle;

  /// Warning message in delete habit dialog
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{habitName}\"?\nThis action is irreversible and removes historical data.'**
  String habitsDialogDeleteMessage(String habitName);

  /// CTA button to create a habit
  ///
  /// In en, this message translates to:
  /// **'Create a habit'**
  String get habitsButtonCreate;

  /// Header title for habits page
  ///
  /// In en, this message translates to:
  /// **'My habits'**
  String get habitsHeaderTitle;

  /// Header subtitle for habits page
  ///
  /// In en, this message translates to:
  /// **'Track your progress every day'**
  String get habitsHeaderSubtitle;

  /// Hero title in premium header
  ///
  /// In en, this message translates to:
  /// **'My Habits'**
  String get habitsHeroTitle;

  /// Hero subtitle in premium header
  ///
  /// In en, this message translates to:
  /// **'Create and track your daily habits'**
  String get habitsHeroSubtitle;

  /// Label for habits tab
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTabHabits;

  /// Label for add habit tab
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get habitsTabAdd;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
