import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

class HabitFormStateMapper {
  const HabitFormStateMapper();

  Habit buildHabit({
    required Habit? initialHabit,
    required String name,
    required String selectedCategory,
    required bool isBinary,
    required TrackingMode trackingMode,
    required TrackingPeriodOption period,
    required TrackingIntervalUnit intervalUnit,
    required int timesCount,
    required int intervalCount,
    required int intervalEvery,
    required int cycleActive,
    required int cycleLength,
    required DateTime? cycleStartDate,
    required List<int> selectedWeekdays,
    required DateTime? specificDate,
    required bool repeatEveryYear,
    required String? userId,
    required String? userEmail,
  }) {
    final recurrenceType = mapRecurrenceType(trackingMode, period, intervalUnit);
    final intervalDays = trackingMode == TrackingMode.interval
        ? mapIntervalDays(intervalUnit, intervalEvery)
        : null;
    return Habit(
      id: initialHabit?.id ?? const Uuid().v4(),
      name: name,
      category: selectedCategory.isEmpty ? null : selectedCategory,
      type: isBinary ? HabitType.binary : HabitType.quantitative,
      targetValue: isBinary ? null : timesCount.toDouble(),
      unit: null,
      createdAt: initialHabit?.createdAt ?? DateTime.now(),
      recurrenceType: recurrenceType,
      intervalDays: intervalDays,
      timesTarget:
          trackingMode == TrackingMode.period ? timesCount : intervalCount,
      hourlyInterval: trackingMode == TrackingMode.interval &&
              intervalUnit == TrackingIntervalUnit.hours
          ? intervalEvery
          : null,
      daysActive: trackingMode == TrackingMode.cycle ? cycleActive : null,
      daysCycle: trackingMode == TrackingMode.cycle ? cycleLength : null,
      cycleStartDate:
          trackingMode == TrackingMode.cycle ? cycleStartDate : null,
      specificWeekdays:
          trackingMode == TrackingMode.weekdays ? selectedWeekdays : null,
      specificDate:
          trackingMode == TrackingMode.specificDate ? specificDate : null,
      repeatEveryYear:
          trackingMode == TrackingMode.specificDate ? repeatEveryYear : false,
      userId: userId,
      userEmail: userEmail,
    );
  }

  TrackingMode deriveMode(Habit habit) {
    if (habit.specificWeekdays != null && habit.specificWeekdays!.isNotEmpty) {
      return TrackingMode.weekdays;
    }
    if (habit.daysCycle != null && habit.daysActive != null) {
      return TrackingMode.cycle;
    }
    if (habit.specificDate != null) {
      return TrackingMode.specificDate;
    }
    if (habit.recurrenceType == null) return TrackingMode.period;
    const periodTypes = {
      RecurrenceType.timesPerDay,
      RecurrenceType.timesPerWeek,
      RecurrenceType.monthly,
      RecurrenceType.yearly,
      RecurrenceType.quarterly,
    };
    return periodTypes.contains(habit.recurrenceType)
        ? TrackingMode.period
        : TrackingMode.interval;
  }

  TrackingPeriodOption derivePeriod(RecurrenceType? recurrenceType) {
    if (recurrenceType == null) return TrackingPeriodOption.day;
    return switch (recurrenceType) {
      RecurrenceType.timesPerWeek => TrackingPeriodOption.week,
      RecurrenceType.monthly => TrackingPeriodOption.month,
      RecurrenceType.quarterly => TrackingPeriodOption.quarter,
      RecurrenceType.yearly => TrackingPeriodOption.year,
      _ => TrackingPeriodOption.day,
    };
  }

  TrackingIntervalUnit deriveIntervalUnit(Habit habit) {
    return switch (habit.recurrenceType) {
      RecurrenceType.hourlyInterval => TrackingIntervalUnit.hours,
      RecurrenceType.dailyInterval => TrackingIntervalUnit.days,
      RecurrenceType.weeklyDays => TrackingIntervalUnit.weeks,
      RecurrenceType.monthly => TrackingIntervalUnit.months,
      _ => TrackingIntervalUnit.hours,
    };
  }

  static RecurrenceType mapRecurrenceType(
    TrackingMode mode,
    TrackingPeriodOption period,
    TrackingIntervalUnit unit,
  ) {
    switch (mode) {
      case TrackingMode.period:
        return switch (period) {
          TrackingPeriodOption.day => RecurrenceType.timesPerDay,
          TrackingPeriodOption.week => RecurrenceType.timesPerWeek,
          TrackingPeriodOption.month => RecurrenceType.monthly,
          TrackingPeriodOption.quarter => RecurrenceType.quarterly,
          TrackingPeriodOption.semester => RecurrenceType.yearly,
          TrackingPeriodOption.year => RecurrenceType.yearly,
        };
      case TrackingMode.interval:
        return unit == TrackingIntervalUnit.hours
            ? RecurrenceType.hourlyInterval
            : RecurrenceType.dailyInterval;
      case TrackingMode.weekdays:
        return RecurrenceType.weeklyDays;
      case TrackingMode.cycle:
        return RecurrenceType.dailyInterval;
      case TrackingMode.specificDate:
        return RecurrenceType.yearly;
    }
  }

  static int? mapIntervalDays(TrackingIntervalUnit unit, int every) {
    return switch (unit) {
      TrackingIntervalUnit.hours => null,
      TrackingIntervalUnit.days => every,
      TrackingIntervalUnit.weeks => every * 7,
      TrackingIntervalUnit.months => every * 30,
    };
  }
}
