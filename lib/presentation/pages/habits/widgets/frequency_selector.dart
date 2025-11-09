import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/value_objects/habit_frequency.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Parametric frequency selector with 2 models
class FrequencySelector extends StatefulWidget {
  final HabitFrequency initialFrequency;
  final ValueChanged<HabitFrequency> onChanged;

  const FrequencySelector({
    super.key,
    required this.initialFrequency,
    required this.onChanged,
  });

  @override
  State<FrequencySelector> createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  late FrequencyModel _selectedModel;
  late HabitFrequency _currentFrequency;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialFrequency.model;
    _currentFrequency = widget.initialFrequency;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.habitFrequencySelectorTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
        ),
        const SizedBox(height: 16),
        _buildModelSelector(l10n),
        const SizedBox(height: 24),
        _buildParameterFields(l10n),
      ],
    );
  }

  Widget _buildModelSelector(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.dividerColor.withValues(alpha: 0.5),
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _buildModelOption(
            l10n,
            FrequencyModel.timesPerPeriod,
            l10n.habitFrequencyModelATitle,
            l10n.habitFrequencyModelADescription,
          ),
          const SizedBox(height: 12),
          _buildModelOption(
            l10n,
            FrequencyModel.everyXUnits,
            l10n.habitFrequencyModelBTitle,
            l10n.habitFrequencyModelBDescription,
          ),
        ],
      ),
    );
  }

  Widget _buildModelOption(
    AppLocalizations l10n,
    FrequencyModel model,
    String title,
    String description,
  ) {
    final isSelected = _selectedModel == model;

    return InkWell(
      onTap: () => _onModelChanged(model),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.5)
                : AppTheme.dividerColor.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<FrequencyModel>(
              value: model,
              groupValue: _selectedModel,
              onChanged: (value) {
                if (value != null) _onModelChanged(value);
              },
              activeColor: AppTheme.primaryColor,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParameterFields(AppLocalizations l10n) {
    if (_selectedModel == FrequencyModel.timesPerPeriod) {
      return _buildModelAFields(l10n);
    } else {
      return _buildModelBFields(l10n);
    }
  }

  /// Model A: "n times per period"
  Widget _buildModelAFields(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitFrequencyModelAFieldsLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildNumberField(
                  l10n,
                  label: l10n.habitFrequencyTimesLabel,
                  value: _currentFrequency.timesCount ?? 1,
                  onChanged: (value) {
                    _updateFrequency(
                      _currentFrequency.copyWith(timesCount: value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildPeriodDropdown(l10n),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<FrequencyPeriod>(
      value: _currentFrequency.period ?? FrequencyPeriod.day,
      decoration: InputDecoration(
        labelText: l10n.habitFrequencyPeriodLabel,
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: FrequencyPeriod.hour,
          child: Text(l10n.habitFrequencyPeriodHour),
        ),
        DropdownMenuItem(
          value: FrequencyPeriod.day,
          child: Text(l10n.habitFrequencyPeriodDay),
        ),
        DropdownMenuItem(
          value: FrequencyPeriod.week,
          child: Text(l10n.habitFrequencyPeriodWeek),
        ),
        DropdownMenuItem(
          value: FrequencyPeriod.month,
          child: Text(l10n.habitFrequencyPeriodMonth),
        ),
        DropdownMenuItem(
          value: FrequencyPeriod.year,
          child: Text(l10n.habitFrequencyPeriodYear),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          _updateFrequency(_currentFrequency.copyWith(period: value));
        }
      },
    );
  }

  /// Model B: "every X units"
  Widget _buildModelBFields(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.grey50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.habitFrequencyModelBFieldsLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildNumberField(
                  l10n,
                  label: l10n.habitFrequencyIntervalLabel,
                  value: _currentFrequency.interval ?? 1,
                  onChanged: (value) {
                    _updateFrequency(
                      _currentFrequency.copyWith(interval: value),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _buildUnitDropdown(l10n),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildDayFilterSelector(l10n),
        ],
      ),
    );
  }

  Widget _buildUnitDropdown(AppLocalizations l10n) {
    return DropdownButtonFormField<FrequencyUnit>(
      value: _currentFrequency.unit ?? FrequencyUnit.days,
      decoration: InputDecoration(
        labelText: l10n.habitFrequencyUnitLabel,
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      items: [
        DropdownMenuItem(
          value: FrequencyUnit.hours,
          child: Text(l10n.habitFrequencyUnitHours),
        ),
        DropdownMenuItem(
          value: FrequencyUnit.days,
          child: Text(l10n.habitFrequencyUnitDays),
        ),
        DropdownMenuItem(
          value: FrequencyUnit.weeks,
          child: Text(l10n.habitFrequencyUnitWeeks),
        ),
        DropdownMenuItem(
          value: FrequencyUnit.months,
          child: Text(l10n.habitFrequencyUnitMonths),
        ),
        DropdownMenuItem(
          value: FrequencyUnit.quarters,
          child: Text(l10n.habitFrequencyUnitQuarters),
        ),
        DropdownMenuItem(
          value: FrequencyUnit.years,
          child: Text(l10n.habitFrequencyUnitYears),
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          _updateFrequency(_currentFrequency.copyWith(unit: value));
        }
      },
    );
  }

  Widget _buildDayFilterSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.habitFrequencyDayFilterLabel,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            FilterChip(
              label: Text(l10n.habitFrequencyDayFilterAllDays),
              selected: _currentFrequency.dayFilter == DayFilter.none,
              onSelected: (selected) {
                if (selected) {
                  _updateFrequency(
                    _currentFrequency.copyWith(dayFilter: DayFilter.none),
                  );
                }
              },
            ),
            FilterChip(
              label: Text(l10n.habitFrequencyDayFilterWeekdays),
              selected: _currentFrequency.dayFilter == DayFilter.weekdays,
              onSelected: (selected) {
                if (selected) {
                  _updateFrequency(
                    _currentFrequency.copyWith(dayFilter: DayFilter.weekdays),
                  );
                }
              },
            ),
            FilterChip(
              label: Text(l10n.habitFrequencyDayFilterWeekends),
              selected: _currentFrequency.dayFilter == DayFilter.weekends,
              onSelected: (selected) {
                if (selected) {
                  _updateFrequency(
                    _currentFrequency.copyWith(dayFilter: DayFilter.weekends),
                  );
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberField(
    AppLocalizations l10n, {
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return TextFormField(
      initialValue: value.toString(),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppTheme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.dividerColor),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: (text) {
        final parsed = int.tryParse(text);
        if (parsed != null && parsed > 0) {
          onChanged(parsed);
        }
      },
    );
  }

  void _onModelChanged(FrequencyModel newModel) {
    setState(() {
      _selectedModel = newModel;

      if (newModel == FrequencyModel.timesPerPeriod) {
        // Switch to Model A with defaults
        _currentFrequency = HabitFrequency(
          model: FrequencyModel.timesPerPeriod,
          timesCount: 1,
          period: FrequencyPeriod.day,
        );
      } else {
        // Switch to Model B with defaults
        _currentFrequency = HabitFrequency(
          model: FrequencyModel.everyXUnits,
          interval: 1,
          unit: FrequencyUnit.days,
          dayFilter: DayFilter.none,
        );
      }

      widget.onChanged(_currentFrequency);
    });
  }

  void _updateFrequency(HabitFrequency newFrequency) {
    setState(() {
      _currentFrequency = newFrequency;
    });
    widget.onChanged(newFrequency);
  }
}
