import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';

/// Service responsable des opérations CRUD sur les listes
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur les interactions avec le repository.
class ListsCrudService {
  final CustomListRepository _repository;

  ListsCrudService(this._repository);

  /// Charge toutes les listes depuis le repository
  Future<List<CustomList>> loadAllLists() async {
    return await _repository.getAllLists();
  }

  /// Crée une nouvelle liste
  Future<void> createNewList(CustomList list) async {
    await _repository.saveList(list);
  }

  /// Met à jour une liste existante
  Future<void> updateExistingList(CustomList list) async {
    await _repository.updateList(list);
  }

  /// Supprime une liste
  Future<void> removeList(String listId) async {
    await _repository.deleteList(listId);
  }

  /// Supprime toutes les listes (pour les tests/reset)
  Future<void> clearAllLists() async {
    await _repository.clearAllLists();
  }
}