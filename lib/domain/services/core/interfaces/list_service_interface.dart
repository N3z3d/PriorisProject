import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Interface pour les opérations CRUD sur les listes
/// 
/// Respecte le principe Single Responsibility en se concentrant
/// uniquement sur les opérations de base.
abstract class ListCrudInterface {
  /// Retourne toutes les listes
  Future<List<CustomList>> getAllLists();

  /// Ajoute une nouvelle liste
  Future<void> addList(CustomList list);

  /// Met à jour une liste existante
  Future<void> updateList(CustomList list);

  /// Supprime une liste par son ID
  Future<void> deleteList(String listId);

  /// Supprime toutes les listes
  Future<void> clearAllLists();
}

/// Interface pour la recherche et le filtrage des listes
/// 
/// Séparée des opérations CRUD selon le principe
/// Interface Segregation.
abstract class ListSearchInterface {
  /// Recherche les listes par type
  Future<List<CustomList>> getListsByType(ListType type);

  /// Recherche les listes contenant un mot-clé
  Future<List<CustomList>> searchLists(String keyword);
}

/// Interface pour les statistiques des listes
/// 
/// Permet d'obtenir des informations statistiques sur les listes
/// sans coupler à l'implémentation du service.
abstract class ListStatsInterface {
  /// Calcule la progression globale sur toutes les listes
  Future<double> getGlobalProgress();

  /// Retourne des statistiques globales sur les listes
  Future<Map<String, dynamic>> getStats();
}