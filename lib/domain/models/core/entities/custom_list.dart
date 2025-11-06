import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

part 'custom_list.g.dart';

/// Liste personnalisée contenant des éléments
/// 
/// Représente une liste thématique (ex: "Liste de courses", "Films à regarder")
@HiveType(typeId: 0)
class CustomList extends HiveObject {
  /// Identifiant unique de la liste
  @HiveField(0)
  final String id;
  
  /// Nom de la liste (obligatoire)
  @HiveField(1)
  final String name;
  
  /// Type de la liste (prédéfini ou personnalisé)
  @HiveField(2)
  final ListType type;
  
  /// Description de la liste (optionnelle)
  @HiveField(3)
  final String? description;
  
  /// Éléments de la liste
  @HiveField(4)
  final List<ListItem> items;
  
  /// Date de création
  @HiveField(5)
  final DateTime createdAt;
  
  /// Date de dernière modification
  @HiveField(6)
  final DateTime updatedAt;

  /// Constructeur avec paramètres nommés
  CustomList({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
  }) {
    _validate();
  }

  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError('L\'identifiant de la liste ne peut pas être vide');
    }
    if (name.trim().isEmpty) {
      throw ArgumentError('Le nom de la liste ne peut pas être vide');
    }
    if (updatedAt.isBefore(createdAt)) {
      throw ArgumentError('updatedAt doit être >= createdAt');
    }
    final idSet = <String>{};
    for (final item in items) {
      if (!idSet.add(item.id)) {
        throw ArgumentError('Les éléments de la liste doivent avoir des IDs uniques');
      }
    }
  }

  /// Crée une copie de la liste avec des modifications
  CustomList copyWith({
    String? id,
    String? name,
    ListType? type,
    String? description,
    List<ListItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomList(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Ajoute un élément à la liste
  CustomList addItem(ListItem item) {
    // Vérifier que l'élément n'existe pas déjà
    if (items.any((existingItem) => existingItem.id == item.id)) {
      return this;
    }
    
    return copyWith(
      items: [...items, item],
      updatedAt: DateTime.now(),
    );
  }

  /// Supprime un élément de la liste par son ID
  CustomList removeItem(String itemId) {
    final newItems = items.where((item) => item.id != itemId).toList();
    
    if (newItems.length == items.length) {
      // L'élément n'existait pas
      return this;
    }
    
    return copyWith(
      items: newItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Met à jour un élément existant
  CustomList updateItem(ListItem updatedItem) {
    final itemIndex = items.indexWhere((item) => item.id == updatedItem.id);
    
    if (itemIndex == -1) {
      // L'élément n'existe pas
      return this;
    }
    
    final newItems = List<ListItem>.from(items);
    newItems[itemIndex] = updatedItem;
    
    return copyWith(
      items: newItems,
      updatedAt: DateTime.now(),
    );
  }

  /// Retourne les éléments complétés
  List<ListItem> getCompletedItems() {
    return items.where((item) => item.isCompleted).toList();
  }

  /// Retourne les éléments non complétés
  List<ListItem> getIncompleteItems() {
    return items.where((item) => !item.isCompleted).toList();
  }

  /// Calcule le pourcentage de progression (0.0 à 1.0)
  double getProgress() {
    if (items.isEmpty) return 0.0;
    return getCompletedItems().length / items.length;
  }

  /// Retourne le nombre total d'éléments
  int get itemCount => items.length;

  /// Retourne le nombre d'éléments complétés
  int get completedCount => getCompletedItems().length;

  /// Retourne le nombre d'éléments non complétés
  int get incompleteCount => getIncompleteItems().length;

  /// Vérifie si la liste est vide
  bool get isEmpty => items.isEmpty;

  /// Vérifie si la liste est complétée (tous les éléments sont faits)
  bool get isCompleted => items.isNotEmpty && getCompletedItems().length == items.length;

  /// Retourne les éléments triés par ELO (plus haut en premier)
  List<ListItem> getItemsSortedByElo() {
    final sortedItems = List<ListItem>.from(items);
    sortedItems.sort((a, b) => b.eloScore.compareTo(a.eloScore));
    return sortedItems;
  }

  /// Retourne les éléments triés par date de création (plus récents en premier)
  List<ListItem> getItemsSortedByDate() {
    final sortedItems = List<ListItem>.from(items);
    sortedItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedItems;
  }

  /// Retourne les éléments d'une catégorie spécifique
  List<ListItem> getItemsByCategory(String category) {
    return items.where((item) => item.category == category).toList();
  }

  /// Retourne les éléments par plage ELO
  List<ListItem> getItemsByEloRange(String range) {
    switch (range) {
      case 'high':
        return items.where((item) => item.eloScore >= 1400).toList();
      case 'medium':
        return items.where((item) => item.eloScore >= 1200 && item.eloScore < 1400).toList();
      case 'low':
        return items.where((item) => item.eloScore < 1200).toList();
      default:
        return items.toList();
    }
  }

  /// Retourne toutes les catégories utilisées dans la liste
  Set<String> getCategories() {
    return items
        .where((item) => item.category != null)
        .map((item) => item.category!)
        .toSet();
  }

  /// Retourne les statistiques ELO de la liste
  Map<String, dynamic> getEloStats() {
    if (items.isEmpty) {
      return {'average': 0.0, 'highest': 0.0, 'lowest': 0.0, 'count': 0};
    }
    
    final scores = items.map((item) => item.eloScore).toList();
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

  /// Convertit la liste en Map pour la sérialisation JSON (format Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': name,           // Supabase uses 'title' column
      'list_type': type.name,  // Supabase uses 'list_type'
      'type': type.name,
      'description': description,
      'color': 2196243,        // Valeur plus petite pour éviter l'overflow PostgreSQL (bleu)
      'icon': 58826,           // 0xe5ca en decimal
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),  // Supabase uses snake_case
      'updated_at': updatedAt.toIso8601String(),  // Supabase uses snake_case
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convertit la liste en Map pour compatibilité locale (Hive/tests)
  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'description': description,
      'items': items.map((item) => item.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Crée une liste à partir d'une Map (désérialisation JSON)
  factory CustomList.fromJson(Map<String, dynamic> json) {
    return CustomList(
      id: json['id'] as String,
      // Support both 'title' (Supabase) and 'name' (backward compatibility)
      name: (json['title'] ?? json['name']) as String,
      type: ListType.values.firstWhere(
        // Support both 'list_type' (Supabase) and 'type' (backward compatibility)
        (e) => e.name == (json['list_type'] ?? json['type']),
        orElse: () => ListType.CUSTOM,
      ),
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
          ?.map((itemJson) => ListItem.fromJson(itemJson as Map<String, dynamic>))
          .toList() ?? [],
      // Support both snake_case (Supabase) and camelCase (backward compatibility)
      createdAt: DateTime.parse((json['created_at'] ?? json['createdAt']) as String),
      updatedAt: DateTime.parse((json['updated_at'] ?? json['updatedAt']) as String),
    );
  }

  /// Vérifie l'égalité entre deux listes
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomList &&
        other.id == id &&
        other.name == name &&
        other.type == type &&
        other.description == description &&
        listEquals(other.items, items) &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  /// Génère le hash code de la liste
  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      type,
      description,
      Object.hashAll(items),
      createdAt,
      updatedAt,
    );
  }

  /// Représentation textuelle de la liste
  @override
  String toString() {
    final progressPercent = (getProgress() * 100).toStringAsFixed(1);
    return 'CustomList(id: $id, name: $name, type: ${type.name}, items: $itemCount, progress: $progressPercent%)';
  }

  /// --- Legacy compatibility for old tests ---
  /// --- Fin compat ---
}
