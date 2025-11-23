import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/habits/widgets/components/habit_category_dropdown.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';

class HabitIdentitySection extends StatelessWidget {
  const HabitIdentitySection({
    super.key,
    required this.isWide,
    required this.nameController,
    required this.categorySuggestions,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.onCreateCategory,
    required this.createCategoryValue,
    this.onNameChanged,
  });

  final bool isWide;
  final TextEditingController nameController;
  final List<String> categorySuggestions;
  final String selectedCategory;
  final String createCategoryValue;
  final ValueChanged<String> onCategorySelected;
  final Future<String?> Function() onCreateCategory;
  final ValueChanged<String?>? onNameChanged;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Flexible(
        flex: 7,
        child: _buildNameField(context),
      ),
      if (isWide) const SizedBox(width: 20) else const SizedBox(height: 12),
      Flexible(
        flex: 3,
        child: HabitCategoryDropdown(
          selectedValue: selectedCategory,
          categories: categorySuggestions,
          createCategoryValue: createCategoryValue,
          onCategorySelected: onCategorySelected,
          onCreateCategory: onCreateCategory,
        ),
      ),
    ];

    return isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
  }

  Widget _buildNameField(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return CommonTextField(
      fieldKey: const ValueKey('habit-name-field'),
      controller: nameController,
      label: l10n?.habitFormNameLabel ?? 'Nom de l\'habitude*',
      hint: l10n?.habitFormNameHint ?? 'Ex. : Boire 8 verres d\'eau',
      prefix: const Icon(Icons.edit),
      maxLength: 80,
      onChanged: onNameChanged,
    );
  }
}
