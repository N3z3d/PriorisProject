import 'package:flutter/material.dart';
import 'package:prioris/presentation/theme/app_theme.dart';

class HabitCategoryDropdown extends StatelessWidget {
  const HabitCategoryDropdown({
    super.key,
    required this.selectedValue,
    required this.categories,
    required this.createCategoryValue,
    required this.onCategorySelected,
    required this.onCreateCategory,
  });

  final String selectedValue;
  final List<String> categories;
  final String createCategoryValue;
  final ValueChanged<String> onCategorySelected;
  final Future<String?> Function() onCreateCategory;

  @override
  Widget build(BuildContext context) {
    final effectiveValue = selectedValue.isEmpty ? '' : selectedValue;

    return DropdownButtonFormField<String>(
      key: const ValueKey('habit-category-dropdown'),
      value: effectiveValue,
      decoration: const InputDecoration(
        labelText: 'Catégorie (facultatif)',
        prefixIcon: Icon(Icons.category),
      ),
      hint: const Text('Sélectionner une catégorie'),
      items: [
        const DropdownMenuItem<String>(
          value: '',
          child: Text('Aucune catégorie'),
        ),
        ...categories.map(
          (category) => DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          ),
        ),
        DropdownMenuItem<String>(
          value: createCategoryValue,
          child: Row(
            children: const [
              Icon(Icons.add, size: 18, color: AppTheme.accentColor),
              SizedBox(width: 8),
              Text('+ Créer une nouvelle catégorie…'),
            ],
          ),
        ),
      ],
      onChanged: (value) async {
        if (value == null) {
          return;
        }
        if (value == createCategoryValue) {
          final created = await onCreateCategory();
          if (created != null && created.trim().isNotEmpty) {
            onCategorySelected(created.trim());
          }
        } else {
          onCategorySelected(value);
        }
      },
    );
  }
}
