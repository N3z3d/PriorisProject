import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Utility responsible for extracting eligible list items for duels
/// while respecting user prioritization settings.
class DuelTaskFilter {
  const DuelTaskFilter();

  List<ListItem> extractEligibleItems({
    required List<CustomList> lists,
    required ListPrioritizationSettings settings,
  }) {
    if (lists.isEmpty) {
      return const [];
    }

    final Iterable<CustomList> eligibleLists = settings.isAllListsEnabled
        ? lists
        : lists.where((list) => settings.isListEnabled(list.id));

    return eligibleLists
        .expand((list) => list.items.where((item) => !item.isCompleted))
        .toList(growable: false);
  }
}
