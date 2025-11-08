import 'package:flutter/material.dart';
import 'package:prioris/l10n/app_localizations.dart';

/// Service responsable de la crÃ©ation et de la normalisation des catÃ©gories
/// d'habitudes.
class HabitCategoryService {
  const HabitCategoryService();

  /// Ouvre une boÃ®te de dialogue permettant de crÃ©er une nouvelle catÃ©gorie.
  Future<String?> promptCreateCategory(BuildContext context) async {
    final controller = TextEditingController();

    final created = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext)!;
        return AlertDialog(
          title: Text(l10n.habitCategoryDialogTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.habitCategoryDialogFieldHint,
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();
                Navigator.of(dialogContext).pop(value.isEmpty ? null : value);
              },
              child: Text(l10n.confirm),
            ),
          ],
        );
      },
    );

    controller.dispose();

    final normalized = created?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  /// Nettoie les catÃ©gories (trim + suppression doublons + tri insensible Ã  la casse).
  List<String> normalizeCategories(Iterable<String> categories) {
    final normalized = categories
        .map((category) => category.trim())
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    normalized.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return normalized;
  }

  /// Ajoute une catÃ©gorie Ã  la liste si absente (comparaison insensible Ã  la casse).
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
