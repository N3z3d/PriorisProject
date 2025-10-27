import 'package:flutter/material.dart';

/// Service responsable de la création et de la normalisation des catégories
/// d'habitudes.
class HabitCategoryService {
  const HabitCategoryService();

  /// Ouvre une boîte de dialogue permettant de créer une nouvelle catégorie.
  Future<String?> promptCreateCategory(BuildContext context) async {
    final controller = TextEditingController();

    final created = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvelle catégorie'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nom de la catégorie',
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.of(dialogContext).pop(value.isEmpty ? null : value);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final normalized = created?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  /// Nettoie les catégories (trim + suppression doublons + tri insensible à la casse).
  List<String> normalizeCategories(Iterable<String> categories) {
    final normalized = categories
        .map((category) => category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    normalized.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return normalized;
  }

  /// Ajoute une catégorie à la liste si absente (comparaison insensible à la casse).
  List<String> addCategoryIfMissing(List<String> categories, String category) {
    final normalized = category.trim();
    if (normalized.isEmpty) {
      return List<String>.from(categories);
    }

    final exists = categories.any(
      (item) => item.toLowerCase() == normalized.toLowerCase(),
    );

    if (exists) {
      final result = List<String>.from(categories);
      result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return result;
    }

    final result = List<String>.from(categories)..add(normalized);
    result.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return result;
  }
}
