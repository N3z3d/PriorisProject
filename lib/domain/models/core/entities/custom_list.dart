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
  static const int _defaultColorValue = 2196243;
  static const int _defaultIconCodePoint = 58826; // 0xe5ca
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

  @HiveField(7)
  final int color;

  @HiveField(8)
  final int iconCodePoint;

  @HiveField(9)
  final bool isDeleted;

  @HiveField(10)
  final String? userId;

  @HiveField(11)
  final String? userEmail;

  /// Constructeur avec paramètres nommés
  CustomList({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.items = const [],
    required this.createdAt,
    required this.updatedAt,
    this.color = _defaultColorValue,
    this.iconCodePoint = _defaultIconCodePoint,
    this.isDeleted = false,
    this.userId,
    this.userEmail,
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
    int? color,
    int? iconCodePoint,
    bool? isDeleted,
    String? userId,
    String? userEmail,
  }) {
    return CustomList(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      isDeleted: isDeleted ?? this.isDeleted,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
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
    final json = <String, dynamic>{
      'id': id,
      'title': name,
      'list_type': type.name,
      'description': description,
      'color': color,
      'icon': iconCodePoint,
      'is_deleted': isDeleted,
      'items': items.map((item) => item.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };

    if (userId != null && userId!.isNotEmpty) {
      json['user_id'] = userId;
    }
    if (userEmail != null && userEmail!.isNotEmpty) {
      json['user_email'] = userEmail;
    }

    return json;
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
      'color': color,
      'icon': iconCodePoint,
      'isDeleted': isDeleted,
      'userId': userId,
      'userEmail': userEmail,
    };
  }

  /// Crée une liste à partir d'une Map (désérialisation JSON)
  factory CustomList.fromJson(Map<String, dynamic> json) {
    final rawTitle = json['title'] ?? json['name'];
    if (rawTitle == null) {
      throw ArgumentError('Le champ name/title est requis pour CustomList');
    }
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final rawUpdatedAt = json['updated_at'] ?? json['updatedAt'];
    if (rawCreatedAt == null || rawUpdatedAt == null) {
      throw ArgumentError('Les champs createdAt/updatedAt sont requis');
    }

    return CustomList(
      id: json['id'] as String,
      name: rawTitle as String,
      type: ListType.values.firstWhere(
        (e) => e.name == (json['list_type'] ?? json['type']),
        orElse: () => ListType.CUSTOM,
      ),
      description: json['description'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((itemJson) => ListItem.fromJson(itemJson as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(rawCreatedAt as String),
      updatedAt: DateTime.parse(rawUpdatedAt as String),
      color: (json['color'] as int?) ?? _defaultColorValue,
      iconCodePoint: (json['icon'] as int?) ?? _defaultIconCodePoint,
      isDeleted: (json['is_deleted'] ?? json['isDeleted']) as bool? ?? false,
      userId: json['user_id'] as String? ?? json['userId'] as String?,
      userEmail: json['user_email'] as String? ?? json['userEmail'] as String?,
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
        other.updatedAt == updatedAt &&
        other.color == color &&
        other.iconCodePoint == iconCodePoint &&
        other.isDeleted == isDeleted &&
        other.userId == userId &&
        other.userEmail == userEmail;
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
      color,
      iconCodePoint,
      isDeleted,
      userId,
      userEmail,
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
