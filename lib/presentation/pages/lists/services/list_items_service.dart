import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';

/// Service responsable des opérations sur les éléments de liste
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur les interactions avec les éléments de liste.
class ListItemsService {
  final ListItemRepository _repository;

  ListItemsService(this._repository);

  /// Ajoute un élément à une liste
  Future<void> addItem(ListItem item) async {
    await _repository.add(item);
  }

  /// Met à jour un élément
  Future<void> updateItem(ListItem item) async {
    await _repository.update(item);
  }

  /// Supprime un élément
  Future<void> removeItem(String itemId) async {
    await _repository.delete(itemId);
  }

  /// Récupère tous les éléments d'une liste
  Future<List<ListItem>> getItemsForList(String listId) async {
    return await _repository.getByListId(listId);
  }

  /// Marque un élément comme complété
  Future<void> completeItem(String itemId) async {
    final item = await _repository.getById(itemId);
    if (item != null) {
      final completedItem = item.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
      await _repository.update(completedItem);
    }
  }

  /// Marque un élément comme non complété
  Future<void> uncompleteItem(String itemId) async {
    final item = await _repository.getById(itemId);
    if (item != null) {
      final uncompletedItem = item.copyWith(
        isCompleted: false,
        completedAt: null,
      );
      await _repository.update(uncompletedItem);
    }
  }
}