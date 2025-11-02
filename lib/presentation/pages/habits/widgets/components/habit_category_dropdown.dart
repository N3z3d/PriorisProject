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
    final theme = Theme.of(context);
    final effectiveValue = selectedValue.isEmpty ? '' : selectedValue;

    return DropdownButtonFormField<String>(
      key: const ValueKey('habit-category-dropdown'),
      value: effectiveValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Catégorie (facultatif)',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
          key: const ValueKey('habit-category-create-item'),
          value: createCategoryValue,
          child: Text.rich(
            TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: AppTheme.accentColor,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(width: 8),
                ),
                TextSpan(
                  text: '+ Créer une nouvelle catégorie…',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
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
