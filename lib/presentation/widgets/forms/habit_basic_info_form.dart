import 'package:flutter/material.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import '../selectors/category_selector.dart';

class HabitBasicInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController categoryController;
  final HabitType selectedType;
  final List<String> existingCategories;
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
        _buildNameField(),
        const SizedBox(height: 16),
        _buildDescriptionField(),
        const SizedBox(height: 16),
        _buildCategorySelector(),
        const SizedBox(height: 16),
        _buildTypeDropdown(),
      ],
    );
  }

  Widget _buildNameField() {
    return TextFormField(
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
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
    );
  }

  Widget _buildCategorySelector() {
    final currentCategory = categoryController.text.trim();
    return CategorySelector(
      selectedCategory: currentCategory.isEmpty ? null : currentCategory,
      categories: existingCategories,
      onChanged: (value) => categoryController.text = value ?? '',
      hintText: 'Categorie (optionnelle)',
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<HabitType>(
      value: selectedType,
      decoration: const InputDecoration(
        labelText: "Type d'habitude",
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
    );
  }
}
