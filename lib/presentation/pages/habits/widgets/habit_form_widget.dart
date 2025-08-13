import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

/// Widget pour le formulaire d'ajout/édition d'habitudes
/// 
/// Gère la saisie de tous les paramètres d'une habitude avec
/// validation et interface utilisateur intuitive.
class HabitFormWidget extends StatefulWidget {
  final Function(Habit) onSubmit;
  final Habit? initialHabit;

  const HabitFormWidget({
    super.key,
    required this.onSubmit,
    this.initialHabit,
  });

  @override
  State<HabitFormWidget> createState() => _HabitFormWidgetState();
}

class _HabitFormWidgetState extends State<HabitFormWidget> {
  final _nameController = TextEditingController();
  String _selectedCategory = 'Santé';
  HabitType _selectedType = HabitType.binary;
  RecurrenceType _selectedRecurrence = RecurrenceType.dailyInterval;
  double _targetValue = 1.0;
  String _unit = '';
  
  final List<String> _categories = [
    'Santé',
    'Sport',
    'Productivité',
    'Développement personnel',
    'Créativité',
    'Sociale',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialHabit != null) {
      _initializeWithHabit(widget.initialHabit!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Style professionnel avec fond uni
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: AppTheme.grey300.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildNameField(),
          const SizedBox(height: 16),
          _buildCategorySelector(),
          const SizedBox(height: 16),
          _buildTypeSelector(),
          const SizedBox(height: 16),
          _buildRecurrenceSelector(),
          if (_selectedType == HabitType.quantitative) ...[
            const SizedBox(height: 16),
            _buildQuantitativeFields(),
          ],
          const SizedBox(height: 24),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  /// Initialise le formulaire avec une habitude existante
  void _initializeWithHabit(Habit habit) {
    _nameController.text = habit.name;
    _selectedCategory = habit.category ?? 'Général';
    _selectedType = habit.type;
    _selectedRecurrence = habit.recurrenceType ?? RecurrenceType.dailyInterval;
    _targetValue = habit.targetValue ?? 0.0;
    _unit = habit.unit ?? '';
  }

  /// Construit l'en-tête du formulaire
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          Icons.add_circle_outline,
          color: AppTheme.accentColor,
          size: 32,
        ),
        const SizedBox(width: 16),
        Text(
          widget.initialHabit == null ? 'Nouvelle Habitude' : 'Modifier Habitude',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Construit le champ nom
  Widget _buildNameField() {
    return CommonTextField(
      controller: _nameController,
      label: 'Nom de l\'habitude',
      hint: 'Ex: Boire 8 verres d\'eau',
      prefix: const Icon(Icons.edit),
    );
  }

  /// Construit le sélecteur de catégorie
  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.category, color: AppTheme.accentColor),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value!;
            });
          },
        ),
      ],
    );
  }

  /// Construit le sélecteur de type
  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type d\'habitude',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildTypeOption(HabitType.binary, 'Oui/Non', Icons.check_circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeOption(HabitType.quantitative, 'Quantité', Icons.show_chart),
            ),
          ],
        ),
      ],
    );
  }

  /// Construit une option de type
  Widget _buildTypeOption(HabitType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppTheme.accentColor : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.accentColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.accentColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit le sélecteur de récurrence
  Widget _buildRecurrenceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fréquence',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<RecurrenceType>(
          value: _selectedRecurrence,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: Icon(Icons.schedule, color: AppTheme.accentColor),
          ),
          items: RecurrenceType.values.map((recurrence) {
            return DropdownMenuItem(
              value: recurrence,
              child: Text(_getRecurrenceDisplayName(recurrence)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedRecurrence = value!;
            });
          },
        ),
      ],
    );
  }

  /// Construit les champs pour les habitudes quantitatives
  Widget _buildQuantitativeFields() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: CommonTextField(
            label: 'Objectif',
            hint: '8',
            keyboardType: TextInputType.number,
            onChanged: (value) {
              _targetValue = double.tryParse(value ?? '') ?? 1.0;
            },
            prefix: const Icon(Icons.flag),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CommonTextField(
            label: 'Unité',
            hint: 'verres',
            onChanged: (value) {
              _unit = value ?? '';
            },
            prefix: const Icon(Icons.straighten),
          ),
        ),
      ],
    );
  }

  /// Construit le bouton de soumission
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: CommonButton(
        text: widget.initialHabit == null ? 'Créer l\'habitude' : 'Sauvegarder',
        onPressed: _submitForm,
        type: ButtonType.primary,
        icon: widget.initialHabit == null ? Icons.add : Icons.save,
      ),
    );
  }

  /// Soumet le formulaire
  void _submitForm() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer un nom pour l\'habitude'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final habit = Habit(
      id: widget.initialHabit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _selectedCategory,
      type: _selectedType,
      recurrenceType: _selectedRecurrence,
      targetValue: _targetValue,
      unit: _unit.isEmpty ? null : _unit,
      createdAt: widget.initialHabit?.createdAt ?? DateTime.now(),
    );

    widget.onSubmit(habit);
    
    if (widget.initialHabit == null) {
      // Réinitialiser le formulaire pour une nouvelle habitude
      _nameController.clear();
      setState(() {
        _selectedCategory = 'Santé';
        _selectedType = HabitType.binary;
        _selectedRecurrence = RecurrenceType.dailyInterval;
        _targetValue = 1.0;
        _unit = '';
      });
    }
  }

  /// Retourne le nom d'affichage pour un type de récurrence
  String _getRecurrenceDisplayName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.dailyInterval:
        return 'Quotidienne';
      case RecurrenceType.weeklyDays:
        return 'Hebdomadaire';
      case RecurrenceType.monthly:
        return 'Mensuelle';
      default:
        return type.toString();
    }
  }
} 
