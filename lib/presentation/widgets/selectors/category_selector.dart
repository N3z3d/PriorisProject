import 'package:flutter/material.dart';

/// Widget pour sélectionner une catégorie
class CategorySelector extends StatelessWidget {
  final String? selectedCategory;
  final List<String> categories;
  final ValueChanged<String?> onChanged;
  final String hintText;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.categories,
    required this.onChanged,
    this.hintText = 'Sélectionner une catégorie',
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      hint: Text(hintText),
      decoration: const InputDecoration(
        labelText: 'Catégorie',
        border: OutlineInputBorder(),
      ),
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
} 
