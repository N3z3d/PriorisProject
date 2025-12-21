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
    required RecurrenceType recurrenceType,
    required int? intervalDays,
  }) {
    return Habit(
      id: initialHabit?.id,
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
}
