import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Données de test pour les tests unitaires
class TestData {
  static int _itemCounter = 0;
  
  /// Crée une liste de test basique
  static CustomList createTestList({
    String? id,
    String? name,
    ListType? type,
    List<ListItem>? items,
  }) {
    final now = DateTime.now();
    return CustomList(
      id: id ?? 'test-list-1',
      name: name ?? 'Ma liste de test',
      type: type ?? ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
      items: items ?? [
        createTestListItem(id: 'test-item-1', title: 'Premier élément'),
        createTestListItem(id: 'test-item-2', title: 'Deuxième élément'),
      ],
    );
  }

  /// Crée un élément de liste de test
  static ListItem createTestListItem({
    String? id,
    String? title,
    String? description,
    String? listId,
  }) {
    _itemCounter++;
    return ListItem(
      id: id ?? 'test-item-${_itemCounter}-${DateTime.now().millisecondsSinceEpoch}',
      title: title ?? 'Élément de test',
      description: description,
      listId: listId ?? 'test-list-1',
      createdAt: DateTime.now(),
    );
  }

  /// Crée une liste vide pour les tests
  static CustomList createEmptyTestList({String? id, String? name}) {
    final now = DateTime.now();
    return CustomList(
      id: id ?? 'empty-list',
      name: name ?? 'Liste vide',
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
      items: [],
    );
  }

  /// Crée plusieurs listes de test
  static List<CustomList> createTestLists() {
    return [
      createTestList(id: 'list-1', name: 'Première liste'),
      createTestList(id: 'list-2', name: 'Deuxième liste'),
      createEmptyTestList(id: 'list-3', name: 'Liste vide'),
    ];
  }
}