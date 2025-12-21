import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/widgets/habit_form_widget.dart';

class AdvancedHabitTrackingSection extends StatelessWidget {
  const AdvancedHabitTrackingSection({
    super.key,
    required this.trackingMode,
    required this.period,
    required this.intervalUnit,
    required this.onModeChanged,
    required this.timesController,
    required this.intervalCountController,
    required this.intervalEveryController,
    required this.cycleActiveController,
    required this.cycleLengthController,
    required this.onTimesChanged,
    required this.onIntervalCountChanged,
    required this.onIntervalEveryChanged,
    required this.onPeriodChanged,
    required this.onIntervalUnitChanged,
    required this.onSwitchToPeriod,
    required this.cycleStartDate,
    required this.onCycleStartDateChanged,
    required this.selectedWeekdays,
    required this.onWeekdaysChanged,
    required this.specificDate,
    required this.onSpecificDateChanged,
    required this.repeatEveryYear,
    required this.onRepeatEveryYearChanged,
  });

  final TrackingMode trackingMode;
  final TrackingPeriodOption period;
  final TrackingIntervalUnit intervalUnit;
  final ValueChanged<TrackingMode> onModeChanged;
  final TextEditingController timesController;
  final TextEditingController intervalCountController;
  final TextEditingController intervalEveryController;
  final TextEditingController cycleActiveController;
  final TextEditingController cycleLengthController;
  final ValueChanged<String> onTimesChanged;
  final ValueChanged<String> onIntervalCountChanged;
  final ValueChanged<String> onIntervalEveryChanged;
  final ValueChanged<TrackingPeriodOption?> onPeriodChanged;
  final ValueChanged<TrackingIntervalUnit> onIntervalUnitChanged;
  final VoidCallback onSwitchToPeriod;
  final DateTime? cycleStartDate;
  final ValueChanged<DateTime?> onCycleStartDateChanged;
  final List<int> selectedWeekdays;
  final ValueChanged<List<int>> onWeekdaysChanged;
  final DateTime? specificDate;
  final ValueChanged<DateTime?> onSpecificDateChanged;
  final bool repeatEveryYear;
  final ValueChanged<bool> onRepeatEveryYearChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _modeChip(l10n.habitTrackingPrefix, TrackingMode.period),
            _modeChip(l10n.habitTrackingEveryWord, TrackingMode.interval),
            _modeChip(l10n.habitTrackingModeCycle, TrackingMode.cycle),
            _modeChip(l10n.habitTrackingModeWeekdays, TrackingMode.weekdays),
            _modeChip(
              l10n.habitTrackingModeSpecificDate,
              TrackingMode.specificDate,
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildModeContent(context, l10n),
      ],
    );
  }

  Widget _modeChip(String label, TrackingMode mode) {
    final selected = trackingMode == mode;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onModeChanged(mode),
    );
  }

  Widget _buildModeContent(BuildContext context, AppLocalizations l10n) {
    switch (trackingMode) {
      case TrackingMode.period:
        return _buildPeriodPhrase(l10n);
      case TrackingMode.interval:
        return _buildIntervalPhrase(l10n);
      case TrackingMode.cycle:
        return _buildCycleFields(context, l10n);
      case TrackingMode.weekdays:
        return _buildWeekdaysPicker(l10n);
      case TrackingMode.specificDate:
        return _buildSpecificDatePicker(context, l10n);
    }
  }

  Widget _buildPeriodPhrase(AppLocalizations l10n) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(l10n.habitTrackingPrefix),
        _buildCompactNumberField(
          key: const ValueKey('habit-tracking-times-field'),
          controller: timesController,
          onChanged: onTimesChanged,
        ),
        Text(l10n.habitTrackingTimesWord),
        _buildPeriodDropdown(l10n),
      ],
    );
  }

  Widget _buildIntervalPhrase(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(l10n.habitTrackingPrefix),
            _buildCompactNumberField(
              key: const ValueKey('habit-interval-count-field'),
              controller: intervalCountController,
              onChanged: onIntervalCountChanged,
            ),
            Text(l10n.habitTrackingTimesWord),
            Text(l10n.habitTrackingEveryWord),
            _buildCompactNumberField(
              key: const ValueKey('habit-interval-every-field'),
              controller: intervalEveryController,
              onChanged: onIntervalEveryChanged,
            ),
            _buildIntervalDropdown(l10n),
          ],
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onSwitchToPeriod,
          icon: const Icon(Icons.arrow_back),
          label: Text(l10n.habitTrackingBackToPeriod),
        ),
      ],
    );
  }

  Widget _buildCycleFields(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.habitTrackingModeCycle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCompactNumberField(
              key: const ValueKey('habit-cycle-active'),
              controller: cycleActiveController,
              onChanged: onTimesChanged,
            ),
            _buildCompactNumberField(
              key: const ValueKey('habit-cycle-length'),
              controller: cycleLengthController,
              onChanged: onIntervalEveryChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: cycleStartDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            onCycleStartDateChanged(picked);
          },
          icon: const Icon(Icons.date_range),
          label: Text(
            cycleStartDate == null
                ? l10n.habitTrackingCycleStartDate
                : '${l10n.habitTrackingCycleStartDate}: ${cycleStartDate!.toLocal().toString().split(' ').first}',
          ),
        ),
      ],
    );
  }

  Widget _buildWeekdaysPicker(AppLocalizations l10n) {
    final dayLabels = [
      l10n.habitWeekdayMonday,
      l10n.habitWeekdayTuesday,
      l10n.habitWeekdayWednesday,
      l10n.habitWeekdayThursday,
      l10n.habitWeekdayFriday,
      l10n.habitWeekdaySaturday,
      l10n.habitWeekdaySunday,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.habitTrackingWeekdaysLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          children: List.generate(7, (index) {
            final selected = selectedWeekdays.contains(index);
            return FilterChip(
              label: Text(dayLabels[index]),
              selected: selected,
              onSelected: (_) {
                final next = [...selectedWeekdays];
                selected ? next.remove(index) : next.add(index);
                onWeekdaysChanged(next..sort());
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSpecificDatePicker(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: specificDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            onSpecificDateChanged(picked);
          },
          icon: const Icon(Icons.event),
          label: Text(
            specificDate == null
                ? l10n.habitTrackingSpecificDateLabel
                : specificDate!.toLocal().toString().split(' ').first,
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: repeatEveryYear,
              onChanged: (v) => onRepeatEveryYearChanged(v ?? false),
            ),
            Text(l10n.habitTrackingRepeatEveryYear),
          ],
        ),
      ],
    );
  }

  Widget _buildPeriodDropdown(AppLocalizations l10n) {
    return DropdownButton<TrackingPeriodOption?>(
      key: const ValueKey('habit-period-dropdown'),
      value: trackingMode == TrackingMode.period ? period : null,
      onChanged: onPeriodChanged,
      items: [
        DropdownMenuItem(
          value: TrackingPeriodOption.day,
          child: Text(l10n.habitTrackingPeriodDay),
        ),
        DropdownMenuItem(
          value: TrackingPeriodOption.week,
          child: Text(l10n.habitTrackingPeriodWeek),
        ),
        DropdownMenuItem(
          value: TrackingPeriodOption.month,
          child: Text(l10n.habitTrackingPeriodMonth),
        ),
        DropdownMenuItem(
          value: TrackingPeriodOption.quarter,
          child: Text(l10n.habitTrackingPeriodQuarter),
        ),
        DropdownMenuItem(
          value: TrackingPeriodOption.semester,
          child: Text(l10n.habitTrackingPeriodSemester),
        ),
        DropdownMenuItem(
          value: TrackingPeriodOption.year,
          child: Text(l10n.habitTrackingPeriodYear),
        ),
        DropdownMenuItem(
          value: null,
          child: Text(l10n.habitTrackingCustomInterval),
        ),
      ],
    );
  }

  Widget _buildIntervalDropdown(AppLocalizations l10n) {
    return DropdownButton<TrackingIntervalUnit>(
      key: const ValueKey('habit-interval-unit-dropdown'),
      value: intervalUnit,
      onChanged: (value) {
        if (value != null) {
          onIntervalUnitChanged(value);
        }
      },
      items: [
        DropdownMenuItem(
          value: TrackingIntervalUnit.hours,
          child: Text(l10n.habitTrackingUnitHours),
        ),
        DropdownMenuItem(
          value: TrackingIntervalUnit.days,
          child: Text(l10n.habitTrackingUnitDays),
        ),
        DropdownMenuItem(
          value: TrackingIntervalUnit.weeks,
          child: Text(l10n.habitTrackingUnitWeeks),
        ),
        DropdownMenuItem(
          value: TrackingIntervalUnit.months,
          child: Text(l10n.habitTrackingUnitMonths),
        ),
      ],
    );
  }

  Widget _buildCompactNumberField({
    required Key key,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 80,
      child: TextField(
        key: key,
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: AppTheme.accentColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
