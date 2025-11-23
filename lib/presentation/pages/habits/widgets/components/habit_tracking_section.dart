import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

import '../habit_form_widget.dart';

class HabitTrackingSection extends StatelessWidget {
  const HabitTrackingSection({
    super.key,
    required this.trackingMode,
    required this.period,
    required this.intervalUnit,
    required this.timesController,
    required this.intervalCountController,
    required this.intervalEveryController,
    required this.onTimesChanged,
    required this.onIntervalCountChanged,
    required this.onIntervalEveryChanged,
    required this.onPeriodChanged,
    required this.onIntervalUnitChanged,
    required this.onSwitchToPeriod,
  });

  final TrackingMode trackingMode;
  final TrackingPeriodOption period;
  final TrackingIntervalUnit intervalUnit;
  final TextEditingController timesController;
  final TextEditingController intervalCountController;
  final TextEditingController intervalEveryController;

  final ValueChanged<String> onTimesChanged;
  final ValueChanged<String> onIntervalCountChanged;
  final ValueChanged<String> onIntervalEveryChanged;
  final ValueChanged<TrackingPeriodOption?> onPeriodChanged;
  final ValueChanged<TrackingIntervalUnit> onIntervalUnitChanged;
  final VoidCallback onSwitchToPeriod;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitTrackingTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          if (trackingMode == TrackingMode.period)
            _buildPeriodPhrase(l10n)
          else
            _buildIntervalPhrase(l10n),
          const SizedBox(height: 8),
          Text(
            l10n.habitTrackingTip,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
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
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
