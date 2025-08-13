import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import '../selectors/category_selector.dart';

/// Widget pour les informations de base d'une habitude (nom, description, catégorie, type)
class HabitBasicInfoForm extends StatelessWidget {
  /// Contrôleur pour le nom
  final TextEditingController nameController;
  
  /// Contrôleur pour la description
  final TextEditingController descriptionController;
  
  /// Contrôleur pour la catégorie
  final TextEditingController categoryController;
  
  /// Type d'habitude sélectionné
  final HabitType selectedType;
  
  /// Liste des catégories existantes
  final List<String> existingCategories;
  
  /// Callback appelé quand le type change
  final ValueChanged<HabitType> onTypeChanged;

  const HabitBasicInfoForm({
    super.key,
    required this.nameController,
    required this.descriptionController,
    required this.categoryController,
    required this.selectedType,
    required this.existingCategories,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Nom *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        CategorySelector(
          selectedCategory: categoryController.text.trim().isEmpty ? null : categoryController.text.trim(),
          categories: existingCategories,
          onChanged: (value) {
            categoryController.text = value ?? '';
          },
          hintText: 'Catégorie (optionnelle)',
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<HabitType>(
          value: selectedType,
          decoration: const InputDecoration(
            labelText: 'Type d\'habitude',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: HabitType.binary,
              child: Text('Binaire (Oui/Non)'),
            ),
            DropdownMenuItem(
              value: HabitType.quantitative,
              child: Text('Quantitatif (Nombre)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              onTypeChanged(value);
            }
          },
        ),
      ],
    );
  }
} 
