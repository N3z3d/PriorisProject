import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_category_dropdown.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_form_container.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_form_header.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_identity_section.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_summary_section.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_tracking_section.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:uuid/uuid.dart';

enum TrackingMode { period, interval }
enum TrackingPeriodOption { day, week, month, year }
enum TrackingIntervalUnit { hours, days, weeks, months }
class HabitFormWidget extends StatefulWidget {
  const HabitFormWidget({
    super.key,
    required this.onSubmit,
    required this.availableCategories,
    this.initialHabit,
    this.categoryService = const HabitCategoryService(),
    this.authService,
    this.validationErrorColor = Colors.red,
  });

  final Habit? initialHabit;
  final List<String> availableCategories;
  final void Function(Habit) onSubmit;
  final HabitCategoryService categoryService;
  final AuthService? authService;
  final Color validationErrorColor;
  @override
  State<HabitFormWidget> createState() => _HabitFormWidgetState();
}
class _HabitFormWidgetState extends State<HabitFormWidget> {
  static const String _createCategoryValue = '__create_category__';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _timesController = TextEditingController(text: '1');
  final TextEditingController _intervalCountController =
      TextEditingController(text: '1');
  final TextEditingController _intervalEveryController =
      TextEditingController(text: '1');

  String _selectedCategory = '';
  List<String> _categorySuggestions = [];

  TrackingMode _trackingMode = TrackingMode.period;
  TrackingPeriodOption _period = TrackingPeriodOption.day;
  TrackingIntervalUnit _intervalUnit = TrackingIntervalUnit.hours;
  int _timesCount = 1;
  int _intervalCount = 1;
  int _intervalEvery = 1;
  bool _hasValidName = false;
  HabitCategoryService get _categoryService => widget.categoryService;
  Color _errorTone(int level) => tone(widget.validationErrorColor, level: level);
  @override
  void initState() {
    super.initState();
    _nameController.addListener(_handleNameChange);
    _categorySuggestions =
        _categoryService.normalizeCategories(widget.availableCategories);
    if (widget.initialHabit != null) {
      _applyHabit(widget.initialHabit!);
    } else {
      _hasValidName = false;
    }
  }
  @override
  void didUpdateWidget(covariant HabitFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(oldWidget.availableCategories, widget.availableCategories)) {
      _syncCategoriesFromWidget(widget.availableCategories);
    }
    final newHabit = widget.initialHabit;
    if (newHabit != null && newHabit.id != oldWidget.initialHabit?.id) {
      _applyHabit(newHabit);
    } else if (newHabit == null && oldWidget.initialHabit != null) {
      _resetForm(notifyListeners: false);
    }
  }
  @override
  void dispose() {
    _nameController.removeListener(_handleNameChange);
    _nameController.dispose();
    _timesController.dispose();
    _intervalCountController.dispose();
    _intervalEveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialHabit != null;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        return HabitFormContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              HabitFormHeader(isEditing: isEditing),
              const SizedBox(height: 16),
              _buildIntro(context),
              const SizedBox(height: 24),
              HabitIdentitySection(
                isWide: isWide,
                nameController: _nameController,
                categorySuggestions: _categorySuggestions,
                selectedCategory: _selectedCategory,
                createCategoryValue: _createCategoryValue,
                onCategorySelected: _handleCategorySelection,
                onCreateCategory: _handleCreateCategory,
                onNameChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),
              _buildTrackingBlock(context),
              const SizedBox(height: 20),
              HabitSummarySection(
                summaryText: _buildSummaryText(),
                title: AppLocalizations.of(context)?.habitSummaryTitle ?? 'Résumé',
              ),
              const SizedBox(height: 24),
              _buildSubmitButton(isEditing),
            ],
          ),
        );
      },
    );
  }
  Widget _buildIntro(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final intro = l10n?.habitFormIntro ??
        'D\u00e9finissez une habitude simple et son rythme.';
    return Text(
      intro,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary.withValues(alpha: 0.85),
            height: 1.45,
          ),
    );
  }
  Widget _buildTrackingBlock(BuildContext context) {
    return HabitTrackingSection(
      trackingMode: _trackingMode,
      period: _period,
      intervalUnit: _intervalUnit,
      timesController: _timesController,
      intervalCountController: _intervalCountController,
      intervalEveryController: _intervalEveryController,
      onTimesChanged: (value) =>
          _updateTimesCount(value, isIntervalCount: false),
      onIntervalCountChanged: (value) =>
          _updateTimesCount(value, isIntervalCount: true),
      onIntervalEveryChanged: _updateIntervalEvery,
      onPeriodChanged: (value) {
        if (value == null) {
          setState(() => _trackingMode = TrackingMode.interval);
          return;
        }
        setState(() {
          _trackingMode = TrackingMode.period;
          _period = value;
        });
      },
      onIntervalUnitChanged: (value) {
        setState(() {
          _trackingMode = TrackingMode.interval;
          _intervalUnit = value;
        });
      },
      onSwitchToPeriod: () {
        setState(() {
          _trackingMode = TrackingMode.period;
          _period = TrackingPeriodOption.day;
        });
      },
    );
  }
  Widget _buildSubmitButton(bool isEditing) {
    final l10n = AppLocalizations.of(context);
    final label = isEditing
        ? (l10n?.save ?? 'Enregistrer')
        : (l10n?.habitFormSubmitCreate ?? 'Cr\u00e9er l\'habitude');
    final onPressed = _isFormValid ? _submitForm : null;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(isEditing ? Icons.save : Icons.add),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          disabledBackgroundColor: AppTheme.dividerColor.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white70,
        ),
      ),
    );
  }
  String _buildSummaryText() {
    final l10n = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return l10n?.habitSummaryPlaceholder ??
          'Compl\u00e9tez le nom et la fr\u00e9quence pour voir le r\u00e9sum\u00e9.';
    }
    final timesText =
        l10n?.habitSummaryTimes(_trackingMode == TrackingMode.period ? _timesCount : _intervalCount) ??
            '${_trackingMode == TrackingMode.period ? _timesCount : _intervalCount}';
    if (_trackingMode == TrackingMode.period) {
      final periodLabel = switch (_period) {
        TrackingPeriodOption.day => l10n?.habitTrackingPeriodDay ?? 'par jour',
        TrackingPeriodOption.week =>
          l10n?.habitTrackingPeriodWeek ?? 'par semaine',
        TrackingPeriodOption.month =>
          l10n?.habitTrackingPeriodMonth ?? 'par mois',
        TrackingPeriodOption.year =>
          l10n?.habitTrackingPeriodYear ?? 'par an',
      };
      final action = l10n?.habitSummaryAction(name) ?? 'Vous voulez $name';
      return '$action $timesText $periodLabel.';
    }

    final unitLabel = switch (_intervalUnit) {
      TrackingIntervalUnit.hours => l10n?.habitTrackingUnitHours ?? 'heures',
      TrackingIntervalUnit.days => l10n?.habitTrackingUnitDays ?? 'jours',
      TrackingIntervalUnit.weeks => l10n?.habitTrackingUnitWeeks ?? 'semaines',
      TrackingIntervalUnit.months => l10n?.habitTrackingUnitMonths ?? 'mois',
    };
    final action = l10n?.habitSummaryAction(name) ?? 'Vous voulez $name';
    final every = l10n?.habitTrackingEveryWord ?? 'toutes les';
    return '$action $timesText $every $_intervalEvery $unitLabel.';
  }
  void _updateTimesCount(String rawValue, {required bool isIntervalCount}) {
    final sanitized = _sanitizePositiveInt(rawValue);
    final controller = isIntervalCount ? _intervalCountController : _timesController;
    if (controller.text != sanitized.toString()) {
      controller.value = TextEditingValue(
        text: sanitized.toString(),
        selection: TextSelection.collapsed(offset: sanitized.toString().length),
      );
    }

    setState(() {
      if (isIntervalCount) {
        _intervalCount = sanitized;
      } else {
        _timesCount = sanitized;
      }
    });
  }

  void _updateIntervalEvery(String rawValue) {
    final sanitized = _sanitizePositiveInt(rawValue);
    if (_intervalEveryController.text != sanitized.toString()) {
      _intervalEveryController.value = TextEditingValue(
        text: sanitized.toString(),
        selection: TextSelection.collapsed(offset: sanitized.toString().length),
      );
    }
    setState(() {
      _intervalEvery = sanitized;
    });
  }

  int _sanitizePositiveInt(String rawValue) {
    final parsed = int.tryParse(rawValue.trim());
    if (parsed == null || parsed < 1) {
      return 1;
    }
    return parsed;
  }

  void _handleCategorySelection(String value) {
    setState(() {
      _selectedCategory = value;
    });
  }

  Future<String?> _handleCreateCategory() async {
    final created = await _categoryService.promptCreateCategory(context);
    if (!mounted || created == null || created.trim().isEmpty) {
      return null;
    }

    final normalized = created.trim();
    setState(() {
      _categorySuggestions = _categoryService.addCategoryIfMissing(
        _categorySuggestions,
        normalized,
      );
      _selectedCategory = normalized;
    });

    return normalized;
  }

  void _syncCategoriesFromWidget(List<String> categories) {
    final normalized = _categoryService.normalizeCategories(categories);
    if (_selectedCategory.isNotEmpty &&
        !normalized.contains(_selectedCategory)) {
      normalized.add(_selectedCategory);
    }
    normalized.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    setState(() {
      _categorySuggestions = normalized;
    });
  }

  void _applyHabit(Habit habit) {
    _nameController.text = habit.name;
    _hasValidName = _nameController.text.trim().isNotEmpty;
    _selectedCategory = habit.category ?? '';
    _timesCount = habit.timesTarget ?? (habit.targetValue?.toInt() ?? 1);
    _intervalCount = _timesCount;
    _intervalEvery = habit.intervalDays ?? 1;
    _timesController.text = _timesCount.toString();
    _intervalCountController.text = _intervalCount.toString();
    _intervalEveryController.text = _intervalEvery.toString();

    _trackingMode = _deriveMode(habit);
    _period = _derivePeriod(habit.recurrenceType);
    _intervalUnit = _deriveIntervalUnit(habit);
  }

  TrackingMode _deriveMode(Habit habit) {
    if (habit.recurrenceType == null) {
      return TrackingMode.period;
    }
    final periodTypes = {
      RecurrenceType.timesPerDay,
      RecurrenceType.timesPerWeek,
      RecurrenceType.monthly,
      RecurrenceType.yearly,
    };
    return periodTypes.contains(habit.recurrenceType)
        ? TrackingMode.period
        : TrackingMode.interval;
  }

  TrackingPeriodOption _derivePeriod(RecurrenceType? recurrenceType) {
    return switch (recurrenceType) {
      RecurrenceType.timesPerWeek => TrackingPeriodOption.week,
      RecurrenceType.monthly => TrackingPeriodOption.month,
      RecurrenceType.yearly => TrackingPeriodOption.year,
      _ => TrackingPeriodOption.day,
    };
  }

  TrackingIntervalUnit _deriveIntervalUnit(Habit habit) {
    return switch (habit.recurrenceType) {
      RecurrenceType.hourlyInterval => TrackingIntervalUnit.hours,
      RecurrenceType.dailyInterval => TrackingIntervalUnit.days,
      RecurrenceType.weeklyDays => TrackingIntervalUnit.weeks,
      RecurrenceType.monthly => TrackingIntervalUnit.months,
      _ => TrackingIntervalUnit.hours,
    };
  }

  bool get _isFormValid {
    final name = _nameController.text.trim();
    final hasName = _hasValidName && name.length <= 80;
    final trackingValid = _trackingMode == TrackingMode.period
        ? _timesCount >= 1
        : _intervalEvery >= 1 && _intervalCount >= 1;
    return hasName && trackingValid;
  }

  void _submitForm() {
    final name = _nameController.text.trim();
    if (name.isEmpty || name.length > 80) {
      _showValidationError(
        AppLocalizations.of(context)?.habitFormValidationNameRequired ??
            'Veuillez saisir un nom pour l\'habitude (1-80 caracteres).',
      );
      return;
    }

    final habit = _buildHabitFromState(name);
    widget.onSubmit(habit);

    if (widget.initialHabit == null) {
      _resetForm();
    }
  }

  Habit _buildHabitFromState(String name) {
    final currentUser = _safeCurrentUser();
    final isBinary =
        _trackingMode == TrackingMode.period && _timesCount == 1;

    return Habit(
      id: widget.initialHabit?.id ?? const Uuid().v4(),
      name: name,
      category: _selectedCategory.isEmpty ? null : _selectedCategory,
      type: isBinary ? HabitType.binary : HabitType.quantitative,
      targetValue: isBinary ? null : _timesCount.toDouble(),
      unit: null,
      createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),
      recurrenceType: _mapRecurrenceType(),
      intervalDays: _trackingMode == TrackingMode.interval
          ? _mapIntervalDays()
          : null,
      timesTarget:
          _trackingMode == TrackingMode.period ? _timesCount : _intervalCount,
      hourlyInterval: _trackingMode == TrackingMode.interval &&
              _intervalUnit == TrackingIntervalUnit.hours
          ? _intervalEvery
          : null,
      userId: currentUser?.id ?? widget.initialHabit?.userId,
      userEmail: currentUser?.email ?? widget.initialHabit?.userEmail,
    );
  }

  RecurrenceType _mapRecurrenceType() {
    if (_trackingMode == TrackingMode.period) {
      return switch (_period) {
        TrackingPeriodOption.day => RecurrenceType.timesPerDay,
        TrackingPeriodOption.week => RecurrenceType.timesPerWeek,
        TrackingPeriodOption.month => RecurrenceType.monthly,
        TrackingPeriodOption.year => RecurrenceType.yearly,
      };
    }

    if (_intervalUnit == TrackingIntervalUnit.hours) {
      return RecurrenceType.hourlyInterval;
    }
    return RecurrenceType.dailyInterval;
  }

  int? _mapIntervalDays() {
    return switch (_intervalUnit) {
      TrackingIntervalUnit.hours => null,
      TrackingIntervalUnit.days => _intervalEvery,
      TrackingIntervalUnit.weeks => _intervalEvery * 7,
      TrackingIntervalUnit.months => _intervalEvery * 30,
    };
  }

  void _handleNameChange() {
    final normalized = _nameController.text.trim();
    final nextValue = normalized.isNotEmpty;
    if (nextValue != _hasValidName) {
      setState(() {
        _hasValidName = nextValue;
      });
    }
  }

  dynamic _safeCurrentUser() {
    try {
      return (widget.authService ?? AuthService.instance).currentUser;
    } catch (_) {
      return null;
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorTone(700),
      ),
    );
  }

  void _resetForm({bool notifyListeners = true}) {
    _nameController.clear();
    _timesController.text = '1';
    _intervalCountController.text = '1';
    _intervalEveryController.text = '1';

    void applyReset() {
      _trackingMode = TrackingMode.period;
      _period = TrackingPeriodOption.day;
      _intervalUnit = TrackingIntervalUnit.hours;
      _timesCount = 1;
      _intervalCount = 1;
      _intervalEvery = 1;
      _selectedCategory = '';
      _hasValidName = false;
    }

    if (notifyListeners) {
      setState(applyReset);
    } else {
      applyReset();
    }
  }
}
