import 'package:uuid/uuid.dart';
import '../../core/aggregates/aggregate_root.dart';
import '../../core/value_objects/export.dart';
import '../../core/exceptions/domain_exceptions.dart';
import '../events/habit_events.dart';

/// Types d'habitude
enum HabitType { binary, quantitative }

/// Types de récurrence pour les habitudes
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

/// Agrégat Habit - Racine d'agrégat pour les habitudes
/// 
/// Cet agrégat encapsule toute la logique métier liée aux habitudes,
/// y compris le suivi des séries, les objectifs quantitatifs et les récurrences.
class HabitAggregate extends AggregateRoot {
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

  /// Factory pour créer une nouvelle habitude
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
    if (name.trim().isEmpty) {
      throw InvalidHabitNameException('Le nom de l\'habitude ne peut pas être vide');
    }

    if (type == HabitType.quantitative && targetValue == null) {
      throw InvalidTargetValueException('Une habitude quantitative doit avoir une valeur cible');
    }

    if (type == HabitType.quantitative && targetValue != null && targetValue <= 0) {
      throw InvalidTargetValueException('La valeur cible doit être positive');
    }

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

    // Publier l'événement de création
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

  /// Met à jour le nom de l'habitude
  void updateName(String newName) {
    executeOperation(() {
      if (newName.trim().isEmpty) {
        throw InvalidHabitNameException('Le nom de l\'habitude ne peut pas être vide');
      }

      final oldName = _name;
      _name = newName.trim();

      addEvent(HabitModifiedEvent(
        habitId: id,
        changes: {'name': {'from': oldName, 'to': _name}},
        reason: 'Nom modifié',
      ));
    });
  }

  /// Met à jour la valeur cible pour les habitudes quantitatives
  void updateTargetValue(double? newTargetValue) {
    executeOperation(() {
      if (_type == HabitType.quantitative && newTargetValue == null) {
        throw InvalidTargetValueException('Une habitude quantitative doit avoir une valeur cible');
      }

      if (newTargetValue != null && newTargetValue <= 0) {
        throw InvalidTargetValueException('La valeur cible doit être positive');
      }

      final oldTargetValue = _targetValue;
      _targetValue = newTargetValue;

      addEvent(HabitModifiedEvent(
        habitId: id,
        changes: {'targetValue': {'from': oldTargetValue, 'to': _targetValue}},
        reason: 'Valeur cible modifiée',
      ));
    });
  }

  /// Enregistre une completion pour une habitude binaire
  void markCompleted(bool completed, {DateTime? date}) {
    executeOperation(() {
      if (_type != HabitType.binary) {
        throw InvalidHabitRecordException('Utilisez recordValue() pour les habitudes quantitatives');
      }

      date ??= DateTime.now();
      final dateKey = _getDateKey(date!);
      final previousValue = _completions[dateKey];
      
      _completions[dateKey] = completed;
      
      final currentStreak = getCurrentStreak();
      final targetReached = completed;

      // Vérifier les milestones de streak
      if (completed && currentStreak > 0) {
        _checkStreakMilestone(currentStreak, date!);
      }

      // Vérifier si le streak a été brisé
      if (!completed && previousValue == true) {
        final lastCompleted = _findLastCompletedDate(date!);
        if (lastCompleted != null) {
          final previousStreak = _calculateStreakBefore(lastCompleted);
          addEvent(HabitStreakBrokenEvent(
            habitId: id,
            name: _name,
            previousStreak: previousStreak,
            lastCompletedDate: lastCompleted,
            missedDate: date!,
          ));
        }
      }

      addEvent(HabitCompletedEvent(
        habitId: id,
        name: _name,
        completedDate: date!,
        value: completed,
        type: _type.name,
        currentStreak: currentStreak,
        targetReached: targetReached,
      ));
    });
  }

  /// Enregistre une valeur pour une habitude quantitative
  void recordValue(double value, {DateTime? date}) {
    executeOperation(() {
      if (_type != HabitType.quantitative) {
        throw InvalidHabitRecordException('Utilisez markCompleted() pour les habitudes binaires');
      }

      if (value < 0) {
        throw InvalidHabitRecordException('La valeur ne peut pas être négative');
      }

      date ??= DateTime.now();
      final dateKey = _getDateKey(date!);
      _completions[dateKey] = value;
      
      final currentStreak = getCurrentStreak();
      final targetReached = _targetValue != null && value >= _targetValue!;

      // Vérifier l'atteinte de l'objectif
      if (targetReached && _targetValue != null) {
        addEvent(HabitTargetReachedEvent(
          habitId: id,
          name: _name,
          targetValue: _targetValue!,
          achievedValue: value,
          achievedDate: date!,
        ));
      }

      addEvent(HabitCompletedEvent(
        habitId: id,
        name: _name,
        completedDate: date!,
        value: value,
        type: _type.name,
        currentStreak: currentStreak,
        targetReached: targetReached,
      ));
    });
  }

  /// Vérifie si l'habitude est complétée aujourd'hui
  bool isCompletedToday() {
    final today = _getDateKey(DateTime.now());
    final value = _completions[today];
    
    if (_type == HabitType.binary) {
      return value == true;
    } else {
      return value != null && 
             _targetValue != null && 
             (value as double) >= _targetValue!;
    }
  }

  /// Obtient la valeur d'aujourd'hui
  dynamic getTodayValue() {
    final today = _getDateKey(DateTime.now());
    return _completions[today];
  }

  /// Calcule le taux de réussite sur une période
  double getSuccessRate({int days = 7}) {
    final now = DateTime.now();
    var successfulDays = 0;
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = _completions[dateKey];
      
      if (_type == HabitType.binary && value == true) {
        successfulDays++;
      } else if (_type == HabitType.quantitative && 
                 value != null && 
                 _targetValue != null && 
                 (value as double) >= _targetValue!) {
        successfulDays++;
      }
    }
    
    return successfulDays / days;
  }

  /// Calcule la série actuelle (streak)
  int getCurrentStreak() {
    final now = DateTime.now();
    var streak = 0;
    
    for (int i = 0; i < 365; i++) { // Max 1 an
      final date = now.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = _completions[dateKey];
      
      bool isSuccess = false;
      if (_type == HabitType.binary && value == true) {
        isSuccess = true;
      } else if (_type == HabitType.quantitative && 
                 value != null && 
                 _targetValue != null && 
                 (value as double) >= _targetValue!) {
        isSuccess = true;
      }
      
      if (isSuccess) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  /// Calcule les statistiques de progression
  Progress calculateProgress({int days = 30}) {
    final now = DateTime.now();
    int successful = 0;
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = _completions[dateKey];
      
      if (_type == HabitType.binary && value == true) {
        successful++;
      } else if (_type == HabitType.quantitative && 
                 value != null && 
                 _targetValue != null && 
                 (value as double) >= _targetValue!) {
        successful++;
      }
    }
    
    return Progress.fromCounts(
      completed: successful,
      total: days,
      lastUpdated: DateTime.now(),
    );
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _checkStreakMilestone(int streak, DateTime achievedAt) {
    // Vérifier les milestones importants
    final milestones = [3, 7, 30, 100, 365];
    if (milestones.contains(streak)) {
      addEvent(HabitStreakMilestoneEvent.create(
        habitId: id,
        name: _name,
        streakLength: streak,
        achievedAt: achievedAt,
      ));
    }
  }

  DateTime? _findLastCompletedDate(DateTime before) {
    for (int i = 1; i <= 365; i++) {
      final date = before.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = _completions[dateKey];
      
      bool wasCompleted = false;
      if (_type == HabitType.binary && value == true) {
        wasCompleted = true;
      } else if (_type == HabitType.quantitative && 
                 value != null && 
                 _targetValue != null && 
                 (value as double) >= _targetValue!) {
        wasCompleted = true;
      }
      
      if (wasCompleted) {
        return date;
      }
    }
    return null;
  }

  int _calculateStreakBefore(DateTime date) {
    var streak = 0;
    
    for (int i = 0; i < 365; i++) {
      final checkDate = date.subtract(Duration(days: i));
      final dateKey = _getDateKey(checkDate);
      final value = _completions[dateKey];
      
      bool isSuccess = false;
      if (_type == HabitType.binary && value == true) {
        isSuccess = true;
      } else if (_type == HabitType.quantitative && 
                 value != null && 
                 _targetValue != null && 
                 (value as double) >= _targetValue!) {
        isSuccess = true;
      }
      
      if (isSuccess) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  @override
  void validateInvariants() {
    if (_name.trim().isEmpty) {
      throw DomainInvariantException('Le nom de l\'habitude ne peut pas être vide');
    }

    if (_type == HabitType.quantitative && _targetValue == null) {
      throw DomainInvariantException('Une habitude quantitative doit avoir une valeur cible');
    }

    if (_targetValue != null && _targetValue! <= 0) {
      throw DomainInvariantException('La valeur cible doit être positive');
    }
  }

  @override
  String toString() {
    return 'HabitAggregate(id: $id, name: $_name, type: ${_type.name}, streak: ${getCurrentStreak()})';
  }
}