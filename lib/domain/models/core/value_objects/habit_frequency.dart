import 'package:prioris/domain/models/core/entities/habit.dart';

/// Parametric frequency model to replace 12 RecurrenceType options
enum FrequencyModel {
  /// Model A: "n times per period" (timesPerHour/Day/Week/Month/Year)
  timesPerPeriod,

  /// Model B: "every X units" (hourly/daily/weekly/monthly/quarterly/yearly intervals)
  everyXUnits,
}

/// Period for Model A (times per period)
enum FrequencyPeriod {
  hour,   // times per hour
  day,    // times per day
  week,   // times per week
  month,  // times per month (NEW)
  year,   // times per year (NEW)
}

/// Unit for Model B (every X units)
enum FrequencyUnit {
  hours,      // every X hours
  days,       // every X days
  weeks,      // every X weeks (NEW)
  months,     // every X months
  quarters,   // every X quarters
  years,      // every X years
}

/// Day filter for Model B (optional)
enum DayFilter {
  none,       // all days
  weekdays,   // Monday-Friday only
  weekends,   // Saturday-Sunday only
}

/// Parametric frequency configuration
class HabitFrequency {
  final FrequencyModel model;

  // Model A fields
  final int? timesCount;          // "n times"
  final FrequencyPeriod? period;  // "per period"

  // Model B fields
  final int? interval;            // "every X"
  final FrequencyUnit? unit;      // "units"
  final DayFilter dayFilter;      // optional day restriction

  // Model B - Weekly specific
  final List<int>? specificWeekdays; // [0-6] for weeklyDays pattern

  // Model B - Monthly/Yearly specific
  final int? monthlyDay;    // 1-31
  final int? yearlyMonth;   // 1-12
  final int? yearlyDay;     // 1-31

  const HabitFrequency({
    required this.model,
    this.timesCount,
    this.period,
    this.interval,
    this.unit,
    this.dayFilter = DayFilter.none,
    this.specificWeekdays,
    this.monthlyDay,
    this.yearlyMonth,
    this.yearlyDay,
  });

  /// Detect frequency model from legacy RecurrenceType
  factory HabitFrequency.fromRecurrenceType(
    RecurrenceType recurrenceType, {
    int? intervalDays,
    List<int>? weekdays,
    int? timesTarget,
    int? hourlyInterval,
    int? monthlyDay,
    int? yearlyMonth,
    int? yearlyDay,
  }) {
    switch (recurrenceType) {
      // Model A: times per period
      case RecurrenceType.timesPerHour:
        return HabitFrequency(
          model: FrequencyModel.timesPerPeriod,
          timesCount: timesTarget ?? 1,
          period: FrequencyPeriod.hour,
        );

      case RecurrenceType.timesPerDay:
        return HabitFrequency(
          model: FrequencyModel.timesPerPeriod,
          timesCount: timesTarget ?? 1,
          period: FrequencyPeriod.day,
        );

      case RecurrenceType.timesPerWeek:
        return HabitFrequency(
          model: FrequencyModel.timesPerPeriod,
          timesCount: timesTarget ?? 1,
          period: FrequencyPeriod.week,
        );

      // Model B: every X units
      case RecurrenceType.hourlyInterval:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: hourlyInterval ?? 1,
          unit: FrequencyUnit.hours,
        );

      case RecurrenceType.dailyInterval:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: intervalDays ?? 1,
          unit: FrequencyUnit.days,
        );

      case RecurrenceType.weeklyDays:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.weeks,
          specificWeekdays: weekdays,
        );

      case RecurrenceType.monthly:
      case RecurrenceType.monthlyDay:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.months,
          monthlyDay: monthlyDay,
        );

      case RecurrenceType.quarterly:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.quarters,
        );

      case RecurrenceType.yearly:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.years,
          yearlyMonth: yearlyMonth,
          yearlyDay: yearlyDay,
        );

      case RecurrenceType.weekdays:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.days,
          dayFilter: DayFilter.weekdays,
        );

      case RecurrenceType.weekends:
        return HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.days,
          dayFilter: DayFilter.weekends,
        );
    }
  }

  /// Convert back to RecurrenceType for backward compatibility
  RecurrenceType toRecurrenceType() {
    if (model == FrequencyModel.timesPerPeriod) {
      switch (period) {
        case FrequencyPeriod.hour:
          return RecurrenceType.timesPerHour;
        case FrequencyPeriod.day:
          return RecurrenceType.timesPerDay;
        case FrequencyPeriod.week:
          return RecurrenceType.timesPerWeek;
        case FrequencyPeriod.month:
          // Map to timesPerWeek as closest approximation
          return RecurrenceType.timesPerWeek;
        case FrequencyPeriod.year:
          // Map to yearly as closest approximation
          return RecurrenceType.yearly;
        case null:
          return RecurrenceType.dailyInterval;
      }
    } else {
      // Model B: everyXUnits
      if (dayFilter == DayFilter.weekdays) {
        return RecurrenceType.weekdays;
      }
      if (dayFilter == DayFilter.weekends) {
        return RecurrenceType.weekends;
      }

      switch (unit) {
        case FrequencyUnit.hours:
          return RecurrenceType.hourlyInterval;
        case FrequencyUnit.days:
          return RecurrenceType.dailyInterval;
        case FrequencyUnit.weeks:
          return specificWeekdays != null
              ? RecurrenceType.weeklyDays
              : RecurrenceType.dailyInterval;
        case FrequencyUnit.months:
          return monthlyDay != null
              ? RecurrenceType.monthlyDay
              : RecurrenceType.monthly;
        case FrequencyUnit.quarters:
          return RecurrenceType.quarterly;
        case FrequencyUnit.years:
          return RecurrenceType.yearly;
        case null:
          return RecurrenceType.dailyInterval;
      }
    }
  }

  HabitFrequency copyWith({
    FrequencyModel? model,
    int? timesCount,
    FrequencyPeriod? period,
    int? interval,
    FrequencyUnit? unit,
    DayFilter? dayFilter,
    List<int>? specificWeekdays,
    int? monthlyDay,
    int? yearlyMonth,
    int? yearlyDay,
  }) {
    return HabitFrequency(
      model: model ?? this.model,
      timesCount: timesCount ?? this.timesCount,
      period: period ?? this.period,
      interval: interval ?? this.interval,
      unit: unit ?? this.unit,
      dayFilter: dayFilter ?? this.dayFilter,
      specificWeekdays: specificWeekdays ?? this.specificWeekdays,
      monthlyDay: monthlyDay ?? this.monthlyDay,
      yearlyMonth: yearlyMonth ?? this.yearlyMonth,
      yearlyDay: yearlyDay ?? this.yearlyDay,
    );
  }
}
