import 'package:uuid/uuid.dart';
import '../../core/aggregates/aggregate_root.dart';
import '../../core/value_objects/export.dart';
import '../../core/exceptions/domain_exceptions.dart';
import '../events/list_events.dart';
import '../value_objects/list_item.dart';

/// Types de listes
enum ListType {
  CUSTOM,
  SHOPPING,
  TODO,
  MOVIES,
  BOOKS,
  PLACES,
  GOALS,
}

/// Agrégat CustomList - Racine d'agrégat pour les listes personnalisées
/// 
/// Cet agrégat encapsule toute la logique métier liée aux listes,
/// y compris la gestion des éléments, le système ELO et les progressions.
class CustomListAggregate extends AggregateRoot {
  @override
  final String id;

  String _name;
  ListType _type;
  String? _description;
  final List<ListItem> _items;
  final DateTime _createdAt;
  DateTime _updatedAt;

  CustomListAggregate._({
    required this.id,
    required String name,
    required ListType type,
    String? description,
    List<ListItem>? items,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : _name = name,
       _type = type,
       _description = description,
       _items = items ?? [],
       _createdAt = createdAt,
       _updatedAt = updatedAt;

  /// Factory pour créer une nouvelle liste
  factory CustomListAggregate.create({
    String? id,
    required String name,
    required ListType type,
    String? description,
  }) {
    if (name.trim().isEmpty) {
      throw InvalidListNameException('Le nom de la liste ne peut pas être vide');
    }

    final listId = id ?? const Uuid().v4();
    final now = DateTime.now();

    final list = CustomListAggregate._(
      id: listId,
      name: name.trim(),
      type: type,
      description: description?.trim(),
      createdAt: now,
      updatedAt: now,
    );

    // Publier l'événement de création
    list.addEvent(ListCreatedEvent(
      listId: listId,
      name: name.trim(),
      type: type.name,
      description: description?.trim(),
    ));

    return list;
  }

  /// Factory pour reconstituer une liste depuis la persistence
  factory CustomListAggregate.reconstitute({
    required String id,
    required String name,
    required ListType type,
    String? description,
    List<ListItem>? items,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return CustomListAggregate._(
      id: id,
      name: name,
      type: type,
      description: description,
      items: items ?? [],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Getters
  String get name => _name;
  ListType get type => _type;
  String? get description => _description;
  List<ListItem> get items => List.unmodifiable(_items);
  DateTime get createdAt => _createdAt;
  DateTime get updatedAt => _updatedAt;

  /// Calcule la progression de la liste
  Progress get progress {
    final completed = _items.where((item) => item.isCompleted).length;
    return Progress.fromCounts(
      completed: completed,
      total: _items.length,
      lastUpdated: _updatedAt,
    );
  }

  /// Vérifie si la liste est complète
  bool get isCompleted => _items.isNotEmpty && _items.every((item) => item.isCompleted);

  /// Vérifie si la liste est vide
  bool get isEmpty => _items.isEmpty;

  /// Met à jour le nom de la liste
  void updateName(String newName) {
    executeOperation(() {
      if (newName.trim().isEmpty) {
        throw InvalidListNameException('Le nom de la liste ne peut pas être vide');
      }

      final oldName = _name;
      _name = newName.trim();
      _updatedAt = DateTime.now();

      addEvent(ListModifiedEvent(
        listId: id,
        changes: {'name': {'from': oldName, 'to': _name}},
        reason: 'Nom modifié',
      ));
    });
  }

  /// Met à jour la description de la liste
  void updateDescription(String? newDescription) {
    executeOperation(() {
      final oldDescription = _description;
      _description = newDescription?.trim();
      _updatedAt = DateTime.now();

      addEvent(ListModifiedEvent(
        listId: id,
        changes: {'description': {'from': oldDescription, 'to': _description}},
        reason: 'Description modifiée',
      ));
    });
  }

  /// Ajoute un élément à la liste
  void addItem(ListItem item) {
    executeOperation(() {
      // Vérifier que l'élément n'existe pas déjà
      if (_items.any((existingItem) => existingItem.id == item.id)) {
        throw DuplicateListItemException(item.id);
      }

      _items.add(item);
      _updatedAt = DateTime.now();

      addEvent(ListItemAddedEvent(
        listId: id,
        itemId: item.id,
        itemName: item.name,
        category: item.category,
        initialElo: item.eloScore.value,
      ));
    });
  }

  /// Supprime un élément de la liste
  void removeItem(String itemId) {
    executeOperation(() {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      
      if (itemIndex == -1) {
        throw ListItemNotFoundException(itemId);
      }

      final item = _items[itemIndex];
      _items.removeAt(itemIndex);
      _updatedAt = DateTime.now();

      addEvent(ListItemRemovedEvent(
        listId: id,
        itemId: item.id,
        itemName: item.name,
        wasCompleted: item.isCompleted,
        eloScore: item.eloScore.value,
        reason: 'Suppression manuelle',
      ));
    });
  }

  /// Met à jour un élément existant
  void updateItem(ListItem updatedItem) {
    executeOperation(() {
      final itemIndex = _items.indexWhere((item) => item.id == updatedItem.id);
      
      if (itemIndex == -1) {
        throw ListItemNotFoundException(updatedItem.id);
      }

      _items[itemIndex] = updatedItem;
      _updatedAt = DateTime.now();

      addEvent(ListModifiedEvent(
        listId: id,
        changes: {'item_updated': {'itemId': updatedItem.id}},
        reason: 'Élément modifié',
      ));
    });
  }

  /// Marque un élément comme complété
  void completeItem(String itemId) {
    executeOperation(() {
      final itemIndex = _items.indexWhere((item) => item.id == itemId);
      
      if (itemIndex == -1) {
        throw ListItemNotFoundException(itemId);
      }

      final item = _items[itemIndex];
      if (item.isCompleted) {
        return; // Déjà complété
      }

      final completedItem = item.complete();
      _items[itemIndex] = completedItem;
      _updatedAt = DateTime.now();

      addEvent(ListItemCompletedEvent(
        listId: id,
        itemId: item.id,
        itemName: item.name,
        eloScore: item.eloScore.value,
        completedAt: completedItem.completedAt!,
      ));

      // Vérifier les milestones de progression
      final currentProgress = progress;
      if (currentProgress.isComplete) {
        final timeTaken = _updatedAt.difference(_createdAt);
        final averageElo = _calculateAverageElo();

        addEvent(ListCompletedEvent(
          listId: id,
          listName: _name,
          totalItems: _items.length,
          completedAt: _updatedAt,
          timeTaken: timeTaken,
          averageElo: averageElo,
        ));
      } else {
        // Vérifier les milestones de progression
        addEvent(ListProgressMilestoneEvent.create(
          listId: id,
          listName: _name,
          completedItems: currentProgress.completed,
          totalItems: currentProgress.total,
        ));
      }
    });
  }

  /// Effectue un duel entre deux éléments de la liste
  void duelItems(String winnerItemId, String loserItemId) {
    executeOperation(() {
      final winnerIndex = _items.indexWhere((item) => item.id == winnerItemId);
      final loserIndex = _items.indexWhere((item) => item.id == loserItemId);
      
      if (winnerIndex == -1) {
        throw ListItemNotFoundException(winnerItemId);
      }
      if (loserIndex == -1) {
        throw ListItemNotFoundException(loserItemId);
      }

      final winner = _items[winnerIndex];
      final loser = _items[loserIndex];

      // Calculer les nouveaux scores ELO
      final newWinnerElo = winner.eloScore.updateAfterDuel(
        opponent: loser.eloScore,
        won: true,
      );
      
      final newLoserElo = loser.eloScore.updateAfterDuel(
        opponent: winner.eloScore,
        won: false,
      );

      // Mettre à jour les éléments
      _items[winnerIndex] = winner.updateEloScore(newWinnerElo);
      _items[loserIndex] = loser.updateEloScore(newLoserElo);
      _updatedAt = DateTime.now();

      final eloChange = newWinnerElo.value - winner.eloScore.value;

      addEvent(ListItemDuelEvent(
        listId: id,
        winnerItemId: winnerItemId,
        loserItemId: loserItemId,
        winnerNewElo: newWinnerElo.value,
        loserNewElo: newLoserElo.value,
        eloChange: eloChange,
      ));
    });
  }

  /// Réorganise les éléments selon un critère
  void reorganize(String sortType) {
    executeOperation(() {
      List<ListItem> sortedItems = List.from(_items);
      
      switch (sortType) {
        case 'elo_desc':
          sortedItems.sort((a, b) => b.eloScore.value.compareTo(a.eloScore.value));
          break;
        case 'elo_asc':
          sortedItems.sort((a, b) => a.eloScore.value.compareTo(b.eloScore.value));
          break;
        case 'name_asc':
          sortedItems.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'name_desc':
          sortedItems.sort((a, b) => b.name.compareTo(a.name));
          break;
        case 'created_asc':
          sortedItems.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case 'created_desc':
          sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        default:
          return; // Type de tri non reconnu
      }

      _items.clear();
      _items.addAll(sortedItems);
      _updatedAt = DateTime.now();

      addEvent(ListReorganizedEvent(
        listId: id,
        reorganizationType: sortType,
        reorganizationData: {
          'itemCount': _items.length,
          'timestamp': _updatedAt.toIso8601String(),
        },
      ));
    });
  }

  /// Retourne les éléments complétés
  List<ListItem> getCompletedItems() {
    return _items.where((item) => item.isCompleted).toList();
  }

  /// Retourne les éléments non complétés
  List<ListItem> getIncompleteItems() {
    return _items.where((item) => !item.isCompleted).toList();
  }

  /// Retourne les éléments par catégorie
  List<ListItem> getItemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  /// Retourne toutes les catégories utilisées
  Set<String> getCategories() {
    return _items
        .where((item) => item.category != null)
        .map((item) => item.category!)
        .toSet();
  }

  /// Retourne les statistiques ELO de la liste
  Map<String, dynamic> getEloStats() {
    if (_items.isEmpty) {
      return {'average': 0.0, 'highest': 0.0, 'lowest': 0.0, 'count': 0};
    }
    
    final scores = _items.map((item) => item.eloScore.value).toList();
    final average = scores.reduce((a, b) => a + b) / scores.length;
    final highest = scores.reduce((a, b) => a > b ? a : b);
    final lowest = scores.reduce((a, b) => a < b ? a : b);
    
    return {
      'average': average,
      'highest': highest,
      'lowest': lowest,
      'count': scores.length,
    };
  }

  double _calculateAverageElo() {
    if (_items.isEmpty) return 0.0;
    final total = _items.fold<double>(
      0.0, 
      (sum, item) => sum + item.eloScore.value,
    );
    return total / _items.length;
  }

  @override
  void validateInvariants() {
    if (_name.trim().isEmpty) {
      throw DomainInvariantException('Le nom de la liste ne peut pas être vide');
    }

    if (_updatedAt.isBefore(_createdAt)) {
      throw DomainInvariantException('updatedAt doit être >= createdAt');
    }

    // Vérifier l'unicité des IDs des éléments
    final idSet = <String>{};
    for (final item in _items) {
      if (!idSet.add(item.id)) {
        throw DomainInvariantException('Les éléments de la liste doivent avoir des IDs uniques');
      }
    }
  }

  @override
  String toString() {
    final progressPercent = (progress.percentage * 100).toStringAsFixed(1);
    return 'CustomListAggregate(id: $id, name: $_name, items: ${_items.length}, progress: $progressPercent%)';
  }
}