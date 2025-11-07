import 'package:uuid/uuid.dart';
import '../../core/aggregates/aggregate_root.dart';
import '../../core/value_objects/export.dart';
import '../../core/exceptions/domain_exceptions.dart';
import '../../core/events/domain_event.dart';
import '../events/habit_events.dart';
import '../services/habit_completion_service.dart';
import '../services/habit_streak_calculator.dart';
import '../services/habit_progress_calculator.dart';

typedef HabitEvent = DomainEvent;

/// Types d'habitude
enum HabitType { binary, quantitative }

/// Types de r??currence pour les habitudes
enum RecurrenceType {
  dailyInterval,
  weeklyDays,
  timesPerWeek,
  timesPerDay,
  monthly,
  monthlyDay,
  quarterly,
  yearly,
  hourlyInterval,
  timesPerHour,
  weekends,
  weekdays,
}

/// Agr??gat Habit - Racine d'agr??gat pour les habitudes
///
/// Cet agr??gat encapsule la logique m??tier des habitudes selon les principes DDD.
/// Les calculs complexes sont d??l??gu??s ?? des services m??tier d??di??s.
class HabitAggregate extends AggregateRoot {
  // Services m??tier (injection de d??pendances via DIP)
  static const _completionService = HabitCompletionService();
  static const _streakCalculator = HabitStreakCalculator();
  static const _progressCalculator = HabitProgressCalculator();

  @override
  final String id;

  String _name;
  String? _description;
  HabitType _type;
  String? _category;
  double? _targetValue;
  String? _unit;
  final DateTime _createdAt;
  Map<String, dynamic> _completions;
  RecurrenceType? _recurrenceType;
  int? _intervalDays;
  List<int>? _weekdays;
  int? _timesTarget;
  int? _monthlyDay;
  int? _quarterMonth;
  int? _yearlyMonth;
  int? _yearlyDay;
  int? _hourlyInterval;

  HabitAggregate._({
    required this.id,
    required String name,
    String? description,
    required HabitType type,
    String? category,
    double? targetValue,
    String? unit,
    required DateTime createdAt,
    Map<String, dynamic>? completions,
    RecurrenceType? recurrenceType,
    int? intervalDays,
    List<int>? weekdays,
    int? timesTarget,
    int? monthlyDay,
    int? quarterMonth,
    int? yearlyMonth,
    int? yearlyDay,
    int? hourlyInterval,
  }) : _name = name,
       _description = description,
       _type = type,
       _category = category,
       _targetValue = targetValue,
       _unit = unit,
       _createdAt = createdAt,
       _completions = completions ?? {},
       _recurrenceType = recurrenceType,
       _intervalDays = intervalDays,
       _weekdays = weekdays,
       _timesTarget = timesTarget,
       _monthlyDay = monthlyDay,
       _quarterMonth = quarterMonth,
       _yearlyMonth = yearlyMonth,
       _yearlyDay = yearlyDay,
       _hourlyInterval = hourlyInterval;

  /// Factory pour cr??er une nouvelle habitude
  factory HabitAggregate.create({
    String? id,
    required String name,
    String? description,
    required HabitType type,
    String? category,
    double? targetValue,
    String? unit,
    RecurrenceType? recurrenceType,
    int? intervalDays,
    List<int>? weekdays,
    int? timesTarget,
    int? monthlyDay,
    int? quarterMonth,
    int? yearlyMonth,
    int? yearlyDay,
    int? hourlyInterval,
  }) {
    _validateCreationParameters(name, type, targetValue);

    final habitId = id ?? const Uuid().v4();
    final createdAt = DateTime.now();

    final habit = HabitAggregate._(
      id: habitId,
      name: name.trim(),
      description: description?.trim(),
      type: type,
      category: category?.trim(),
      targetValue: targetValue,
      unit: unit?.trim(),
      createdAt: createdAt,
      recurrenceType: recurrenceType,
      intervalDays: intervalDays,
      weekdays: weekdays,
      timesTarget: timesTarget,
      monthlyDay: monthlyDay,
      quarterMonth: quarterMonth,
      yearlyMonth: yearlyMonth,
      yearlyDay: yearlyDay,
      hourlyInterval: hourlyInterval,
    );

    habit.addEvent(HabitCreatedEvent(
      habitId: habitId,
      name: name.trim(),
      type: type.name,
      category: category?.trim(),
      targetValue: targetValue,
    ));

    return habit;
  }

  /// Factory pour reconstituer une habitude depuis la persistence
  factory HabitAggregate.reconstitute({
    required String id,
    required String name,
    String? description,
    required HabitType type,
    String? category,
    double? targetValue,
    String? unit,
    required DateTime createdAt,
    Map<String, dynamic>? completions,
    RecurrenceType? recurrenceType,
    int? intervalDays,
    List<int>? weekdays,
    int? timesTarget,
    int? monthlyDay,
    int? quarterMonth,
    int? yearlyMonth,
    int? yearlyDay,
    int? hourlyInterval,
  }) {
    return HabitAggregate._(
      id: id,
      name: name,
      description: description,
      type: type,
      category: category,
      targetValue: targetValue,
      unit: unit,
      createdAt: createdAt,
      completions: completions ?? {},
      recurrenceType: recurrenceType,
      intervalDays: intervalDays,
      weekdays: weekdays,
      timesTarget: timesTarget,
      monthlyDay: monthlyDay,
      quarterMonth: quarterMonth,
      yearlyMonth: yearlyMonth,
      yearlyDay: yearlyDay,
      hourlyInterval: hourlyInterval,
    );
  }

  // Getters
  String get name => _name;
  String? get description => _description;
  HabitType get type => _type;
  String? get category => _category;
  double? get targetValue => _targetValue;
  String? get unit => _unit;
  DateTime get createdAt => _createdAt;
  Map<String, dynamic> get completions => Map.unmodifiable(_completions);
  RecurrenceType? get recurrenceType => _recurrenceType;
  int? get intervalDays => _intervalDays;
  List<int>? get weekdays => _weekdays;
  int? get timesTarget => _timesTarget;
  int? get monthlyDay => _monthlyDay;
  int? get quarterMonth => _quarterMonth;
  int? get yearlyMonth => _yearlyMonth;
  int? get yearlyDay => _yearlyDay;
  int? get hourlyInterval => _hourlyInterval;

  /// Met ?? jour le nom de l'habitude
  void updateName(String newName) {
    executeOperation(() {
      if (newName.trim().isEmpty) {
        throw InvalidHabitNameException(
          'Le nom de l\'habitude ne peut pas ??tre vide'
        );
      }

      final oldName = _name;
      _name = newName.trim();

      addEvent(HabitModifiedEvent(
        habitId: id,
        changes: {'name': {'from': oldName, 'to': _name}},
        reason: 'Nom modifi??',
      ));
    });
  }

  /// Met ?? jour la valeur cible pour les habitudes quantitatives
  void updateTargetValue(double? newTargetValue) {
    executeOperation(() {
      if (_type == HabitType.quantitative && newTargetValue == null) {
        throw InvalidTargetValueException(
          'Une habitude quantitative doit avoir une valeur cible'
        );
      }

      if (newTargetValue != null && newTargetValue <= 0) {
        throw InvalidTargetValueException('La valeur cible doit ??tre positive');
      }

      final oldTargetValue = _targetValue;
      _targetValue = newTargetValue;

      addEvent(HabitModifiedEvent(
        habitId: id,
        changes: {'targetValue': {'from': oldTargetValue, 'to': _targetValue}},
        reason: 'Valeur cible modifi??e',
      ));
    });
  }

  /// Enregistre une completion pour une habitude binaire
  void markCompleted(bool completed, {DateTime? date}) {
    executeOperation(() {
      if (_type == HabitType.quantitative) {
        throw const InvalidHabitRecordException(
          'Impossible de valider une habitude quantitative avec un boolen',
        );
      }
      final completionDate = date ?? DateTime.now();
      _updateCompletionMap(completed, completionDate);

      final currentStreak = getCurrentStreak();
      final events = _completionService.markCompleted(
        habitId: id,
        habitName: _name,
        type: _type,
        completed: completed,
        date: completionDate,
        completions: _completions,
        currentStreak: currentStreak,
        onCheckMilestone: _handleMilestoneAchieved,
        onFindLastCompleted: _handleStreakBreak,
      );

      for (final event in events) {
        addEvent(event);
      }
    });
  }

  void _updateCompletionMap(bool completed, DateTime completionDate) {
    final dateKey = _getDateKey(completionDate);
    _completions[dateKey] = completed;
  }

  void _handleMilestoneAchieved(int streak, DateTime achievedAt) {
    final event = _streakCalculator.checkStreakMilestone(
      habitId: id,
      habitName: _name,
      streak: streak,
      achievedAt: achievedAt,
    );
    if (event != null) {
      addEvent(event);
    }
  }

  List<HabitEvent> _handleStreakBreak(DateTime beforeDate) {
    final lastCompleted = _streakCalculator.findLastCompletedDate(
      before: beforeDate,
      type: _type,
      completions: _completions,
      targetValue: _targetValue,
    );

    if (lastCompleted == null) {
      return const [];
    }

    final previousStreak = _streakCalculator.calculateStreakBefore(
      date: lastCompleted,
      type: _type,
      completions: _completions,
      targetValue: _targetValue,
    );

    final event = _streakCalculator.createStreakBrokenEvent(
      habitId: id,
      habitName: _name,
      previousStreak: previousStreak,
      lastCompletedDate: lastCompleted,
      missedDate: beforeDate,
    );

    return [event];
  }
  /// Enregistre une valeur pour une habitude quantitative
  void recordValue(double value, {DateTime? date}) {
    executeOperation(() {
      date ??= DateTime.now();
      final dateKey = _getDateKey(date!);
      _completions[dateKey] = value;

      final currentStreak = getCurrentStreak();
      final targetReached = _targetValue != null && value >= _targetValue!;

      // V??rifier l'atteinte de l'objectif
      if (targetReached && _targetValue != null) {
        addEvent(HabitTargetReachedEvent(
          habitId: id,
          name: _name,
          targetValue: _targetValue!,
          achievedValue: value,
          achievedDate: date!,
        ));
      }

      // D??l??guer la logique au service de completion
      _completionService.recordValue(
        habitId: id,
        habitName: _name,
        type: _type,
        value: value,
        date: date!,
        targetValue: _targetValue,
        currentStreak: currentStreak,
      ).forEach(addEvent);
    });
  }

  /// V??rifie si l'habitude est compl??t??e aujourd'hui
  bool isCompletedToday() {
    return _completionService.isCompletedOnDate(
      date: DateTime.now(),
      type: _type,
      completions: _completions,
      targetValue: _targetValue,
    );
  }

  /// Obtient la valeur d'aujourd'hui
  dynamic getTodayValue() {
    return _completionService.getValueForDate(
      date: DateTime.now(),
      completions: _completions,
    );
  }

  /// Calcule le taux de r??ussite sur une p??riode
  double getSuccessRate({int days = 7}) {
    return _progressCalculator.calculateSuccessRate(
      fromDate: DateTime.now(),
      type: _type,
      completions: _completions,
      targetValue: _targetValue,
      days: days,
    );
  }

  /// Calcule la s??rie actuelle (streak)
  int getCurrentStreak() {
    return _streakCalculator.calculateCurrentStreak(
      fromDate: DateTime.now(),
      type: _type,
      completions: _completions,
      targetValue: _targetValue,
    );
  }

  /// Calcule les statistiques de progression
  Progress calculateProgress({int days = 30}) {
    return _progressCalculator.calculateProgress(
      fromDate: DateTime.now(),
      type: _type,
      completions: _completions,
      targetValue: _targetValue,
      days: days,
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void validateInvariants() {
    if (_name.trim().isEmpty) {
      throw DomainInvariantException(
        'Le nom de l\'habitude ne peut pas ??tre vide'
      );
    }

    if (_type == HabitType.quantitative && _targetValue == null) {
      throw DomainInvariantException(
        'Une habitude quantitative doit avoir une valeur cible'
      );
    }

    if (_targetValue != null && _targetValue! <= 0) {
      throw DomainInvariantException('La valeur cible doit ??tre positive');
    }
  }

  @override
  String toString() {
    return 'HabitAggregate(id: $id, name: $_name, type: ${_type.name}, streak: ${getCurrentStreak()})';
  }

  // Validation statique des param??tres de cr??ation
  static void _validateCreationParameters(
    String name,
    HabitType type,
    double? targetValue,
  ) {
    if (name.trim().isEmpty) {
      throw InvalidHabitNameException(
        'Le nom de l\'habitude ne peut pas ??tre vide'
      );
    }

    if (type == HabitType.quantitative && targetValue == null) {
      throw InvalidTargetValueException(
        'Une habitude quantitative doit avoir une valeur cible'
      );
    }

    if (type == HabitType.quantitative && targetValue != null && targetValue <= 0) {
      throw InvalidTargetValueException('La valeur cible doit ??tre positive');
    }
  }
}
