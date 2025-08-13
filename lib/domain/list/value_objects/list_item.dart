import 'package:uuid/uuid.dart';
import '../../core/aggregates/aggregate_root.dart';
import '../../core/value_objects/export.dart';
import '../../core/exceptions/domain_exceptions.dart';

/// Élément de liste - Entité au sein de l'agrégat CustomList
/// 
/// Représente un élément individuel dans une liste avec son propre score ELO,
/// statut de complétion et métadonnées.
class ListItem with Entity {
  @override
  final String id;
  
  final String name;
  final String? description;
  final EloScore eloScore;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? category;
  final Priority priority;

  const ListItem._({
    required this.id,
    required this.name,
    this.description,
    required this.eloScore,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.category,
    required this.priority,
  });

  /// Factory pour créer un nouvel élément de liste
  factory ListItem.create({
    String? id,
    required String name,
    String? description,
    EloScore? eloScore,
    String? category,
    Priority? priority,
  }) {
    if (name.trim().isEmpty) {
      throw InvalidValueException('name', name, 'Le nom ne peut pas être vide');
    }

    final itemId = id ?? const Uuid().v4();
    final itemElo = eloScore ?? EloScore.initial();
    final itemPriority = priority ?? Priority.fromEloAndDueDate(eloScore: itemElo.value);
    final createdAt = DateTime.now();

    return ListItem._(
      id: itemId,
      name: name.trim(),
      description: description?.trim(),
      eloScore: itemElo,
      createdAt: createdAt,
      category: category?.trim(),
      priority: itemPriority,
    );
  }

  /// Factory pour reconstituer un élément depuis la persistence
  factory ListItem.reconstitute({
    required String id,
    required String name,
    String? description,
    required double eloScore,
    bool isCompleted = false,
    required DateTime createdAt,
    DateTime? completedAt,
    String? category,
  }) {
    final elo = EloScore.fromValue(eloScore);
    final priority = Priority.fromEloAndDueDate(eloScore: eloScore);
    
    return ListItem._(
      id: id,
      name: name,
      description: description,
      eloScore: elo,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      category: category,
      priority: priority,
    );
  }

  /// Marque l'élément comme complété
  ListItem complete() {
    if (isCompleted) {
      return this; // Déjà complété
    }

    return ListItem._(
      id: id,
      name: name,
      description: description,
      eloScore: eloScore,
      isCompleted: true,
      createdAt: createdAt,
      completedAt: DateTime.now(),
      category: category,
      priority: priority,
    );
  }

  /// Marque l'élément comme non complété
  ListItem reopen() {
    if (!isCompleted) {
      return this; // Déjà ouvert
    }

    return ListItem._(
      id: id,
      name: name,
      description: description,
      eloScore: eloScore,
      isCompleted: false,
      createdAt: createdAt,
      completedAt: null,
      category: category,
      priority: priority,
    );
  }

  /// Met à jour le score ELO
  ListItem updateEloScore(EloScore newEloScore) {
    final newPriority = Priority.fromEloAndDueDate(eloScore: newEloScore.value);
    
    return ListItem._(
      id: id,
      name: name,
      description: description,
      eloScore: newEloScore,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      category: category,
      priority: newPriority,
    );
  }

  /// Met à jour le nom de l'élément
  ListItem updateName(String newName) {
    if (newName.trim().isEmpty) {
      throw InvalidValueException('name', newName, 'Le nom ne peut pas être vide');
    }

    return ListItem._(
      id: id,
      name: newName.trim(),
      description: description,
      eloScore: eloScore,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      category: category,
      priority: priority,
    );
  }

  /// Met à jour la description de l'élément
  ListItem updateDescription(String? newDescription) {
    return ListItem._(
      id: id,
      name: name,
      description: newDescription?.trim(),
      eloScore: eloScore,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      category: category,
      priority: priority,
    );
  }

  /// Met à jour la catégorie de l'élément
  ListItem updateCategory(String? newCategory) {
    return ListItem._(
      id: id,
      name: name,
      description: description,
      eloScore: eloScore,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      category: newCategory?.trim(),
      priority: priority,
    );
  }

  /// Calcule le temps passé depuis la création
  Duration get age => DateTime.now().difference(createdAt);

  /// Calcule le temps passé depuis la complétion
  Duration? get timeSinceCompletion {
    if (completedAt == null) return null;
    return DateTime.now().difference(completedAt!);
  }

  /// Calcule le temps pris pour compléter l'élément
  Duration? get completionTime {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  /// Compare avec un autre élément par score ELO
  int compareByElo(ListItem other) {
    return other.eloScore.value.compareTo(eloScore.value); // Ordre décroissant
  }

  /// Compare avec un autre élément par priorité
  int compareByPriority(ListItem other) {
    return priority.compareTo(other.priority);
  }

  /// Compare avec un autre élément par date de création
  int compareByCreationDate(ListItem other) {
    return other.createdAt.compareTo(createdAt); // Plus récent en premier
  }

  /// Copie avec modifications
  ListItem copyWith({
    String? name,
    String? description,
    EloScore? eloScore,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    Priority? priority,
  }) {
    final newEloScore = eloScore ?? this.eloScore;
    final newPriority = priority ?? Priority.fromEloAndDueDate(eloScore: newEloScore.value);

    return ListItem._(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      eloScore: newEloScore,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
      priority: newPriority,
    );
  }

  /// Convertit en Map pour la sérialisation
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'eloScore': eloScore.value,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'category': category,
      'priority': priority.toJson(),
    };
  }

  /// Crée un élément depuis une Map (désérialisation)
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem.reconstitute(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      eloScore: json['eloScore'] as double,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'] as String)
        : null,
      category: json['category'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListItem &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.eloScore == eloScore &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.category == category;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      description,
      eloScore,
      isCompleted,
      createdAt,
      completedAt,
      category,
    );
  }

  @override
  String toString() {
    final statusIcon = isCompleted ? '✓' : '○';
    final eloDisplay = eloScore.value.toStringAsFixed(0);
    return 'ListItem($statusIcon $name, ELO: $eloDisplay)';
  }
}