import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits/services/habit_category_service.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/export.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';

class HabitFormWidget extends StatefulWidget {
  const HabitFormWidget({
    super.key,
    required this.onSubmit,
    required this.availableCategories,
    this.initialHabit,
    this.categoryService = const HabitCategoryService(),
  });

  final Habit? initialHabit;
  final List<String> availableCategories;
  final void Function(Habit) onSubmit;
  final HabitCategoryService categoryService;

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

    return HabitFormContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: _buildFormContent(isEditing),
      ),
    );
  }

  List<Widget> _buildFormContent(bool isEditing) {
    return [
      HabitFormHeader(isEditing: isEditing),
      const SizedBox(height: 24),
      _buildNameField(),
      const SizedBox(height: 16),
      _buildCategoryDropdown(),
      const SizedBox(height: 16),
      _buildTypeSelector(),
      const SizedBox(height: 16),
      _buildRecurrenceSelector(),
      if (_selectedType == HabitType.quantitative) ...[
        const SizedBox(height: 16),
        _buildQuantitativeSection(),
      ],
      const SizedBox(height: 24),
      HabitSubmitButton(
        isEditing: isEditing,
        onPressed: _submitForm,
      ),
    ];
  }

  Widget _buildNameField() {
    return CommonTextField(
      fieldKey: const ValueKey('habit-name-field'),
      controller: _nameController,
      label: 'Nom de l\'habitude',
      hint: 'Ex : Boire 8 verres d\'eau',
      prefix: const Icon(Icons.edit),
    );
  }

  Widget _buildCategoryDropdown() {
    return HabitCategoryDropdown(
      selectedValue: _selectedCategory,
      categories: _categorySuggestions,
      createCategoryValue: _createCategoryValue,
      onCategorySelected: _handleCategorySelection,
      onCreateCategory: _handleCreateCategory,
    );
  }

  Widget _buildTypeSelector() {
    return HabitTypeSelector(
      selectedType: _selectedType,
      onTypeSelected: (type) {
        setState(() {
          _selectedType = type;
        });
      },
    );
  }

  Widget _buildRecurrenceSelector() {
    return HabitRecurrenceSelector(
      selectedRecurrence: _selectedRecurrence,
      onRecurrenceChanged: (recurrence) {
        setState(() {
          _selectedRecurrence = recurrence;
        });
      },
    );
  }

  Widget _buildQuantitativeSection() {
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
      _showValidationError('Veuillez saisir un nom pour l\'habitude');
      return;
    }

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
        backgroundColor: Colors.red.shade700,
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
