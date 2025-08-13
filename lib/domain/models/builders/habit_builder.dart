import 'package:prioris/domain/models/core/entities/habit.dart';


/// Builder Pattern pour la classe Habit
/// Simplifie la création d'instances avec 18 paramètres
class HabitBuilder {
  String? _id;
  String? _name;
  String? _description;
  HabitType? _type;
  String? _category;
  double? _targetValue;
  String? _unit;
  DateTime? _createdAt;
  Map<String, dynamic>? _completions;
  RecurrenceType? _recurrenceType;
  int? _intervalDays;
  List<int>? _weekdays;
  int? _timesTarget;
  int? _monthlyDay;
  int? _quarterMonth;
  int? _yearlyMonth;
  int? _yearlyDay;
  int? _hourlyInterval;

  /// Définir l'ID de l'habitude
  HabitBuilder withId(String id) {
    _id = id;
    return this;
  }

  /// Définir le nom de l'habitude (requis)
  HabitBuilder withName(String name) {
    _name = name;
    return this;
  }

  /// Définir la description de l'habitude
  HabitBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  /// Définir le type d'habitude (requis)
  HabitBuilder withType(HabitType type) {
    _type = type;
    return this;
  }

  /// Définir la catégorie de l'habitude
  HabitBuilder withCategory(String category) {
    _category = category;
    return this;
  }

  /// Définir la valeur cible pour les habitudes quantitatives
  HabitBuilder withTargetValue(double targetValue) {
    _targetValue = targetValue;
    return this;
  }

  /// Définir l'unité de mesure
  HabitBuilder withUnit(String unit) {
    _unit = unit;
    return this;
  }

  /// Définir la date de création
  HabitBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  /// Définir les complétions existantes
  HabitBuilder withCompletions(Map<String, dynamic> completions) {
    _completions = completions;
    return this;
  }

  /// Définir le type de récurrence
  HabitBuilder withRecurrenceType(RecurrenceType recurrenceType) {
    _recurrenceType = recurrenceType;
    return this;
  }

  /// Définir l'intervalle en jours
  HabitBuilder withIntervalDays(int intervalDays) {
    _intervalDays = intervalDays;
    return this;
  }

  /// Définir les jours de la semaine
  HabitBuilder withWeekdays(List<int> weekdays) {
    _weekdays = weekdays;
    return this;
  }

  /// Définir le nombre de fois cible
  HabitBuilder withTimesTarget(int timesTarget) {
    _timesTarget = timesTarget;
    return this;
  }

  /// Définir le jour du mois pour les récurrences mensuelles
  HabitBuilder withMonthlyDay(int monthlyDay) {
    _monthlyDay = monthlyDay;
    return this;
  }

  /// Définir le mois du trimestre pour les récurrences trimestrielles
  HabitBuilder withQuarterMonth(int quarterMonth) {
    _quarterMonth = quarterMonth;
    return this;
  }

  /// Définir le mois de l'année pour les récurrences annuelles
  HabitBuilder withYearlyMonth(int yearlyMonth) {
    _yearlyMonth = yearlyMonth;
    return this;
  }

  /// Définir le jour de l'année pour les récurrences annuelles
  HabitBuilder withYearlyDay(int yearlyDay) {
    _yearlyDay = yearlyDay;
    return this;
  }

  /// Définir l'intervalle horaire
  HabitBuilder withHourlyInterval(int hourlyInterval) {
    _hourlyInterval = hourlyInterval;
    return this;
  }

  /// Méthodes de configuration pour les types d'habitudes courants

  /// Créer une habitude binaire simple
  HabitBuilder asBinaryHabit(String name) {
    return withName(name).withType(HabitType.binary);
  }

  /// Créer une habitude quantitative simple
  HabitBuilder asQuantitativeHabit(String name, double targetValue, String unit) {
    return withName(name)
        .withType(HabitType.quantitative)
        .withTargetValue(targetValue)
        .withUnit(unit);
  }

  /// Configurer une récurrence quotidienne
  HabitBuilder withDailyRecurrence() {
    return withRecurrenceType(RecurrenceType.dailyInterval).withIntervalDays(1);
  }

  /// Configurer une récurrence hebdomadaire
  HabitBuilder withWeeklyRecurrence(List<int> weekdays) {
    return withRecurrenceType(RecurrenceType.weeklyDays).withWeekdays(weekdays);
  }

  /// Configurer une récurrence mensuelle
  HabitBuilder withMonthlyRecurrence(int dayOfMonth) {
    return withRecurrenceType(RecurrenceType.monthlyDay).withMonthlyDay(dayOfMonth);
  }

  /// Configurer une récurrence annuelle
  HabitBuilder withYearlyRecurrence(int month, int day) {
    return withRecurrenceType(RecurrenceType.yearly)
        .withYearlyMonth(month)
        .withYearlyDay(day);
  }

  /// Configurer une récurrence en semaine uniquement
  HabitBuilder withWeekdaysOnly() {
    return withRecurrenceType(RecurrenceType.weekdays);
  }

  /// Configurer une récurrence en weekend uniquement
  HabitBuilder withWeekendsOnly() {
    return withRecurrenceType(RecurrenceType.weekends);
  }

  /// Construire l'instance Habit
  /// Lance une exception si les paramètres requis ne sont pas définis
  Habit build() {
    if (_name == null) {
      throw ArgumentError('Le nom de l\'habitude est requis');
    }
    if (_type == null) {
      throw ArgumentError('Le type d\'habitude est requis');
    }

    return Habit(
      id: _id,
      name: _name!,
      description: _description,
      type: _type!,
      category: _category,
      targetValue: _targetValue,
      unit: _unit,
      createdAt: _createdAt,
      completions: _completions,
      recurrenceType: _recurrenceType,
      intervalDays: _intervalDays,
      weekdays: _weekdays,
      timesTarget: _timesTarget,
      monthlyDay: _monthlyDay,
      quarterMonth: _quarterMonth,
      yearlyMonth: _yearlyMonth,
      yearlyDay: _yearlyDay,
      hourlyInterval: _hourlyInterval,
    );
  }

  /// Réinitialiser le builder pour une nouvelle construction
  HabitBuilder reset() {
    _id = null;
    _name = null;
    _description = null;
    _type = null;
    _category = null;
    _targetValue = null;
    _unit = null;
    _createdAt = null;
    _completions = null;
    _recurrenceType = null;
    _intervalDays = null;
    _weekdays = null;
    _timesTarget = null;
    _monthlyDay = null;
    _quarterMonth = null;
    _yearlyMonth = null;
    _yearlyDay = null;
    _hourlyInterval = null;
    return this;
  }
} 
