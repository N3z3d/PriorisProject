import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/export.dart';
import 'package:prioris/presentation/styles/ui_color_utils.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:uuid/uuid.dart';

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

  late final TextEditingController _nameController;
  late final TextEditingController _targetController;
  late final TextEditingController _unitController;

  HabitType _selectedType = HabitType.binary;
  RecurrenceType _selectedRecurrence = RecurrenceType.dailyInterval;
  double _targetValue = 1.0;
  String _unit = '';
  late List<String> _categorySuggestions;
  String _selectedCategory = '';

  HabitCategoryService get _categoryService => widget.categoryService;
  Color _errorTone(int level) => tone(widget.validationErrorColor, level: level);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _targetController = TextEditingController();
    _unitController = TextEditingController();
    _categorySuggestions =
        _categoryService.normalizeCategories(widget.availableCategories);

    if (widget.initialHabit != null) {
      _applyHabit(widget.initialHabit!);
    }
  }

  @override
  void didUpdateWidget(covariant HabitFormWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!listEquals(oldWidget.availableCategories, widget.availableCategories)) {
      _syncCategoriesFromWidget(widget.availableCategories);
    }

    final newHabit = widget.initialHabit;
    final previousHabit = oldWidget.initialHabit;

    if (newHabit != null && newHabit.id != previousHabit?.id) {
      setState(() {
        _applyHabit(newHabit);
      });
    } else if (newHabit == null && previousHabit != null) {
      setState(() {
        _resetForm(notifyListeners: false);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialHabit != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 680;
        final content = isWide
            ? _buildWideLayout(context, isEditing)
            : _buildNarrowLayout(context, isEditing);
        return HabitFormContainer(child: content);
      },
    );
  }

  Widget _buildNarrowLayout(BuildContext context, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HabitFormHeader(isEditing: isEditing),
        const SizedBox(height: 16),
        _buildIntro(context),
        const SizedBox(height: 24),
        _buildNameField(context),
        const SizedBox(height: 16),
        _buildCategoryDropdown(context),
        const SizedBox(height: 20),
        _buildPlanningCard(context),
        const SizedBox(height: 24),
        HabitSubmitButton(
          isEditing: isEditing,
          onPressed: _submitForm,
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, bool isEditing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        HabitFormHeader(isEditing: isEditing),
        const SizedBox(height: 16),
        _buildIntro(context),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildNameField(context)),
            const SizedBox(width: 20),
            Expanded(child: _buildCategoryDropdown(context)),
          ],
        ),
        const SizedBox(height: 20),
        _buildPlanningCard(context),
        const SizedBox(height: 24),
        HabitSubmitButton(
          isEditing: isEditing,
          onPressed: _submitForm,
        ),
      ],
    );
  }

  Widget _buildIntro(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Text(
      l10n.habitFormIntro,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: AppTheme.textSecondary.withValues(alpha: 0.85),
        height: 1.45,
      ),
    );
  }

  Widget _buildPlanningCard(BuildContext context) {
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
          HabitTypeSelector(
            selectedType: _selectedType,
            onTypeSelected: (type) {
              if (type == _selectedType) {
                return;
              }
              setState(() {
                _selectedType = type;
                if (_selectedType != HabitType.quantitative) {
                  _targetController.clear();
                  _unitController.clear();
                  _targetValue = 1.0;
                  _unit = '';
                }
              });
            },
          ),
          const SizedBox(height: 20),
          HabitRecurrenceSelector(
            selectedRecurrence: _selectedRecurrence,
            onRecurrenceChanged: (value) {
              setState(() {
                _selectedRecurrence = value;
              });
            },
          ),
          if (_selectedType == HabitType.quantitative) ...[
            const SizedBox(height: 20),
            _buildQuantitativeSection(context),
          ],
        ],
      ),
    );
  }

  Widget _buildNameField(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CommonTextField(
      fieldKey: const ValueKey('habit-name-field'),
      controller: _nameController,
      label: l10n.habitFormNameLabel,
      hint: l10n.habitFormNameHint,
      prefix: const Icon(Icons.edit),
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return HabitCategoryDropdown(
      selectedValue: _selectedCategory,
      categories: _categorySuggestions,
      createCategoryValue: _createCategoryValue,
      onCategorySelected: _handleCategorySelection,
      onCreateCategory: _handleCreateCategory,
    );
  }

  Widget _buildQuantitativeSection(BuildContext context) {
    return HabitQuantitativeSection(
      targetController: _targetController,
      unitController: _unitController,
      targetFieldKey: const ValueKey('habit-target-field'),
      unitFieldKey: const ValueKey('habit-unit-field'),
      onTargetChanged: (value) {
        setState(() {
          _targetValue = value;
        });
      },
      onUnitChanged: (unit) {
        setState(() {
          _unit = unit;
        });
      },
    );
  }

  void _applyHabit(Habit habit) {
    _nameController.text = habit.name;
    _selectedCategory = habit.category ?? '';
    _selectedType = habit.type;
    _selectedRecurrence = habit.recurrenceType ?? RecurrenceType.dailyInterval;
    _targetValue = habit.targetValue ?? 1.0;
    _unit = habit.unit ?? '';

    if (_selectedType == HabitType.quantitative) {
      if (habit.targetValue != null) {
        _targetController.text = habit.targetValue!.toString();
      }
      _unitController.text = habit.unit ?? '';
    } else {
      _targetController.clear();
      _unitController.clear();
    }

    _ensureSelectedCategoryIsAvailable();
  }

  void _ensureSelectedCategoryIsAvailable() {
    if (_selectedCategory.isEmpty) {
      return;
    }
    _categorySuggestions = _categoryService.addCategoryIfMissing(
      _categorySuggestions,
      _selectedCategory,
    );
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

  void _submitForm() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showValidationError(
        AppLocalizations.of(context)!.habitFormValidationNameRequired,
      );
      return;
    }

    // Get current user info for multi-user support
    final authService = widget.authService ?? AuthService.instance;
    final currentUser = authService.currentUser;

    final habit = Habit(
      id: widget.initialHabit?.id ?? const Uuid().v4(),
      name: name,
      category: _selectedCategory.isEmpty ? null : _selectedCategory,
      type: _selectedType,
      recurrenceType: _selectedRecurrence,
      targetValue: _selectedType == HabitType.quantitative ? _targetValue : null,
      unit: _selectedType == HabitType.quantitative && _unit.trim().isNotEmpty
          ? _unit.trim()
          : null,
      createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),
      // Critical: Set user_id and user_email for multi-user persistence
      userId: currentUser?.id ?? widget.initialHabit?.userId,
      userEmail: currentUser?.email ?? widget.initialHabit?.userEmail,
    );

    widget.onSubmit(habit);

    if (widget.initialHabit == null) {
      _resetForm();
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
    _targetController.clear();
    _unitController.clear();

    void applyReset() {
      _selectedType = HabitType.binary;
      _selectedRecurrence = RecurrenceType.dailyInterval;
      _targetValue = 1.0;
      _unit = '';
      _selectedCategory = '';
    }

    if (notifyListeners) {
      setState(applyReset);
    } else {
      applyReset();
    }
  }
}
