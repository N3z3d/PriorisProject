import 'dart:math';

import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/services/text/text_normalization_service.dart';
import 'package:prioris/presentation/pages/lists/models/task_sort_field.dart';

/// Tri pur des éléments de liste (extrait de ListDetailPage).
///
/// Logique sans état ni widget : testable unitairement.
class ListItemsSorter {
  const ListItemsSorter();

  /// Retourne une copie triée de [items] selon [field].
  ///
  /// [randomSeed] pilote le tri aléatoire : même seed, même ordre.
  List<ListItem> sort(
    List<ListItem> items,
    TaskSortField field, {
    required bool isAscending,
    required int randomSeed,
  }) {
    final sorted = [...items];
    switch (field) {
      case TaskSortField.elo:
        sorted.sort((a, b) => isAscending
            ? a.eloScore.compareTo(b.eloScore)
            : b.eloScore.compareTo(a.eloScore));
        break;
      case TaskSortField.name:
        // Tri insensible aux accents via TextNormalizationService
        const normalizer = TextNormalizationService();
        sorted.sort((a, b) {
          final comparison =
              normalizer.compareIgnoringAccents(a.title, b.title);
          return isAscending ? comparison : -comparison;
        });
        break;
      case TaskSortField.random:
        final random = Random(randomSeed);
        for (var i = sorted.length - 1; i > 0; i--) {
          final j = random.nextInt(i + 1);
          final tmp = sorted[i];
          sorted[i] = sorted[j];
          sorted[j] = tmp;
        }
        break;
    }
    return sorted;
  }

  /// Ramène un seed brut dans la plage positive attendue par [Random].
  static int normalizeSeed(int rawSeed) {
    final normalized = rawSeed & 0x7fffffff;
    return normalized == 0 ? 1 : normalized;
  }

  /// Dérive un nouveau seed depuis [baseSeed] salé par l'horloge.
  ///
  /// [now] : horloge injectable pour des tests déterministes (défaut : DateTime.now)
  static int reshuffleSeed(int baseSeed, {DateTime Function() now = DateTime.now}) {
    final salt = now().microsecondsSinceEpoch & 0x7fffffff;
    return normalizeSeed(baseSeed ^ salt);
  }
}
