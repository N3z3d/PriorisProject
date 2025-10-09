import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import '../forms/habit_basic_info_form.dart';
import '../forms/habit_quantitative_form.dart';
import '../forms/habit_recurrence_form.dart';

class AddHabitDialog extends ConsumerStatefulWidget {
  final Habit? habit;
  final Function(Habit) onSave;

  const AddHabitDialog({
    super.key,
    this.habit,
    required this.onSave,
  });

  @override
  ConsumerState<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends ConsumerState<AddHabitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _unitController = TextEditingController();
  
  HabitType _selectedType = HabitType.binary;
  List<String> _existingCategories = [];
  
  // -------------------- Nouvelles variables pour récurrence --------------------
  RecurrenceType? _selectedRecurrenceType;
  int _intervalDays = 1;
  List<int> _selectedWeekdays = [];
  int _timesTarget = 1;

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      _nameController.text = widget.habit!.name;
      _descriptionController.text = widget.habit!.description ?? '';
      _categoryController.text = widget.habit!.category ?? '';
      _selectedType = widget.habit!.type;
      if (widget.habit!.targetValue != null) {
        _targetValueController.text = widget.habit!.targetValue!.toString();
      }
      _unitController.text = widget.habit!.unit ?? '';
      
      // -------------------- Chargement récurrence existante --------------------
      _selectedRecurrenceType = widget.habit!.recurrenceType;
      _intervalDays = widget.habit!.intervalDays ?? 1;
      _selectedWeekdays = widget.habit!.weekdays ?? [];
      _timesTarget = widget.habit!.timesTarget ?? 1;
    }
    _loadExistingCategories();
  }

  void _loadExistingCategories() async {
    final repository = ref.read(habitRepositoryProvider);
    final habits = await repository.getAllHabits();
    final categories = habits
        .where((habit) => habit.category != null && habit.category!.isNotEmpty)
        .map((habit) => habit.category!)
        .toSet()
        .toList();
    categories.sort();
    setState(() {
      _existingCategories = categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.habit != null;

    return AlertDialog(
      title: Text(isEdit ? "Modifier l'habitude" : "Nouvelle habitude"),
      content: _buildDialogContent(),
      actions: _buildDialogActions(isEdit),
    );
  }

  Widget _buildDialogContent() {
    return SizedBox(
      width: double.maxFinite,
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              HabitBasicInfoForm(
                nameController: _nameController,
                descriptionController: _descriptionController,
                categoryController: _categoryController,
                selectedType: _selectedType,
                existingCategories: _existingCategories,
                onTypeChanged: (type) => setState(() => _selectedType = type),
              ),
              HabitQuantitativeForm(
                targetValueController: _targetValueController,
                unitController: _unitController,
                selectedType: _selectedType,
              ),
              HabitRecurrenceForm(
                selectedRecurrenceType: _selectedRecurrenceType,
                onRecurrenceTypeChanged: (type) => setState(() => _selectedRecurrenceType = type),
                intervalDays: _intervalDays,
                onIntervalDaysChanged: (days) => setState(() => _intervalDays = days),
                selectedWeekdays: _selectedWeekdays,
                onWeekdaysChanged: (days) => setState(() => _selectedWeekdays = days),
                timesTarget: _timesTarget,
                onTimesTargetChanged: (t) => setState(() => _timesTarget = t),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDialogActions(bool isEdit) {
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Annuler'),
      ),
      ElevatedButton(
        onPressed: _saveHabit,
        child: Text(isEdit ? 'Modifier' : 'Ajouter'),
      ),
    ];
  }


  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final habit = Habit(
        id: widget.habit?.id ?? const Uuid().v4(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        type: _selectedType,
        category: _categoryController.text.trim().isEmpty 
            ? null 
            : _categoryController.text.trim(),
        targetValue: _selectedType == HabitType.quantitative 
            ? double.tryParse(_targetValueController.text) 
            : null,
        unit: _selectedType == HabitType.quantitative 
            ? (_unitController.text.trim().isEmpty ? null : _unitController.text.trim())
            : null,
        completions: widget.habit?.completions ?? {},
        // -------------------- Ajout des données de récurrence --------------------
        recurrenceType: _selectedRecurrenceType,
        intervalDays: _selectedRecurrenceType == RecurrenceType.dailyInterval ? _intervalDays : null,
        weekdays: _selectedRecurrenceType == RecurrenceType.weeklyDays ? _selectedWeekdays : null,
        timesTarget: (_selectedRecurrenceType == RecurrenceType.timesPerWeek || 
                     _selectedRecurrenceType == RecurrenceType.timesPerDay) ? _timesTarget : null,
      );

      widget.onSave(habit);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _targetValueController.dispose();
    _unitController.dispose();
    super.dispose();
  }
} 
