import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/value_objects/habit_frequency.dart';
import 'package:prioris/l10n/app_localizations.dart';

/// Service to generate human-readable frequency summaries
class HabitFrequencySummaryService {
  static String generateSummary(
    BuildContext context,
    HabitFrequency frequency,
  ) {
    final l10n = AppLocalizations.of(context)!;

    if (frequency.model == FrequencyModel.timesPerPeriod) {
      return _generateModelASummary(l10n, frequency);
    } else {
      return _generateModelBSummary(l10n, frequency);
    }
  }

  /// Model A: "n times per period"
  static String _generateModelASummary(
    AppLocalizations l10n,
    HabitFrequency frequency,
  ) {
    final count = frequency.timesCount ?? 1;

    switch (frequency.period) {
      case FrequencyPeriod.hour:
        return l10n.habitFrequencyTimesPerHour(count);
      case FrequencyPeriod.day:
        return l10n.habitFrequencyTimesPerDay(count);
      case FrequencyPeriod.week:
        return l10n.habitFrequencyTimesPerWeek(count);
      case FrequencyPeriod.month:
        return l10n.habitFrequencyTimesPerMonth(count);
      case FrequencyPeriod.year:
        return l10n.habitFrequencyTimesPerYear(count);
      case null:
        return l10n.habitFrequencyTimesPerDay(count);
    }
  }

  /// Model B: "every X units" + optional day filter
  static String _generateModelBSummary(
    AppLocalizations l10n,
    HabitFrequency frequency,
  ) {
    final interval = frequency.interval ?? 1;

    // Handle day filters first
    if (frequency.dayFilter == DayFilter.weekdays) {
      return l10n.habitFrequencyWeekdaysOnly;
    }
    if (frequency.dayFilter == DayFilter.weekends) {
      return l10n.habitFrequencyWeekendsOnly;
    }

    // Handle specific weekdays
    if (frequency.specificWeekdays != null &&
        frequency.specificWeekdays!.isNotEmpty) {
      final days = frequency.specificWeekdays!
          .map((day) => _weekdayName(l10n, day))
          .join(', ');
      return l10n.habitFrequencySpecificDays(days);
    }

    // Handle monthly/yearly specifics
    if (frequency.unit == FrequencyUnit.months && frequency.monthlyDay != null) {
      return l10n.habitFrequencyMonthlyOnDay(frequency.monthlyDay!);
    }

    if (frequency.unit == FrequencyUnit.years) {
      if (frequency.yearlyMonth != null && frequency.yearlyDay != null) {
        final monthName = _monthName(l10n, frequency.yearlyMonth!);
        return l10n.habitFrequencyYearlyOnDate(
          frequency.yearlyDay!,
          monthName,
        );
      }
      return l10n.habitFrequencyEveryYears(interval);
    }

    // Standard interval patterns
    switch (frequency.unit) {
      case FrequencyUnit.hours:
        return l10n.habitFrequencyEveryHours(interval);
      case FrequencyUnit.days:
        return l10n.habitFrequencyEveryDays(interval);
      case FrequencyUnit.weeks:
        return l10n.habitFrequencyEveryWeeks(interval);
      case FrequencyUnit.months:
        return l10n.habitFrequencyEveryMonths(interval);
      case FrequencyUnit.quarters:
        return l10n.habitFrequencyEveryQuarters(interval);
      case FrequencyUnit.years:
        return l10n.habitFrequencyEveryYears(interval);
      case null:
        return l10n.habitFrequencyEveryDays(interval);
    }
  }

  static String _weekdayName(AppLocalizations l10n, int weekday) {
    switch (weekday) {
      case 0:
        return l10n.habitWeekdayMonday;
      case 1:
        return l10n.habitWeekdayTuesday;
      case 2:
        return l10n.habitWeekdayWednesday;
      case 3:
        return l10n.habitWeekdayThursday;
      case 4:
        return l10n.habitWeekdayFriday;
      case 5:
        return l10n.habitWeekdaySaturday;
      case 6:
        return l10n.habitWeekdaySunday;
      default:
        return '';
    }
  }

  static String _monthName(AppLocalizations l10n, int month) {
    switch (month) {
      case 1:
        return l10n.habitMonthJanuary;
      case 2:
        return l10n.habitMonthFebruary;
      case 3:
        return l10n.habitMonthMarch;
      case 4:
        return l10n.habitMonthApril;
      case 5:
        return l10n.habitMonthMay;
      case 6:
        return l10n.habitMonthJune;
      case 7:
        return l10n.habitMonthJuly;
      case 8:
        return l10n.habitMonthAugust;
      case 9:
        return l10n.habitMonthSeptember;
      case 10:
        return l10n.habitMonthOctober;
      case 11:
        return l10n.habitMonthNovember;
      case 12:
        return l10n.habitMonthDecember;
      default:
        return '';
    }
  }
}
