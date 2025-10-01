import 'dart:math';
import 'package:hive/hive.dart';

part 'list_item.g.dart';

/// Élément d'une liste personnalisée
/// 
/// Représente un élément individuel dans une liste avec système ELO
@HiveType(typeId: 1)
class ListItem extends HiveObject {
  /// Identifiant unique de l'élément
  @HiveField(0)
  final String id;
  
  /// Titre de l'élément (obligatoire)
  @HiveField(1)
  final String title;
  
  /// Description détaillée (optionnelle)
  @HiveField(2)
  final String? description;
  
  /// Catégorie de l'élément (ex: "Alimentation", "Transport")
  @HiveField(3)
  final String? category;
  
  /// Score ELO de l'élément (pour la priorisation)
  @HiveField(4)
  final double eloScore;
  
  /// Indique si l'élément est complété
  @HiveField(5)
  final bool isCompleted;
  
  /// Date de création
  @HiveField(6)
  final DateTime createdAt;
  
  /// Date de complétion (null si non complété)
  @HiveField(7)
  final DateTime? completedAt;

  /// Date d'échéance (optionnelle)
  @HiveField(8)
  final DateTime? dueDate;

  /// Notes supplémentaires éventuelles
  @HiveField(9)
  final String? notes;
  
  /// ID de la liste parente
  @HiveField(10)
  final String listId;

  /// Date de dernier choix dans un duel/priorisation (pour variation ELO dynamique)
  @HiveField(11)
  final DateTime? lastChosenAt;

  /// Constructeur avec paramètres nommés
  ListItem({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.eloScore = 1200.0, // Score ELO initial standard
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.notes,
    this.listId = 'default', // Valeur par défaut pour compatibilité
    this.lastChosenAt,
  }) {
    _validate();
  }

  /// Validation interne des données
  void _validate() {
    if (id.trim().isEmpty) {
      throw ArgumentError('L\'ID ne peut pas être vide');
    }
    if (title.trim().isEmpty) {
      throw ArgumentError('Le titre ne peut pas être vide');
    }

    // Score ELO valide
    if (eloScore < 0) {
      throw ArgumentError('Le score ELO doit être positif');
    }

    // Cohérence complétion / dates
    if (!isCompleted && completedAt != null) {
      throw ArgumentError('Un élément non complété ne peut pas avoir de date de complétion');
    }
    if (completedAt != null && completedAt!.isBefore(createdAt)) {
      throw ArgumentError('completedAt doit être >= createdAt');
    }
  }

  /// Calcul de la probabilité de victoire selon ELO
  double calculateWinProbability(ListItem opponent) {
    return 1.0 / (1.0 + pow(10.0, (opponent.eloScore - eloScore) / 400.0));
  }

  /// Mise à jour du score ELO après un duel
  /// Retourne une nouvelle instance avec le score mis à jour
  ListItem updateEloScore(ListItem opponent, bool won, {double kFactor = 32.0}) {
    final expectedScore = calculateWinProbability(opponent);
    final actualScore = won ? 1.0 : 0.0;
    final newScore = eloScore + kFactor * (actualScore - expectedScore);
    
    return copyWith(eloScore: newScore);
  }

  /// Crée une copie de l'élément avec des modifications
  ListItem copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    double? eloScore,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? dueDate,
    String? notes,
    String? listId,
    bool forceCompletedAtNull = false,
  }) {
    return ListItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      eloScore: eloScore ?? this.eloScore,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: forceCompletedAtNull ? null : (completedAt ?? this.completedAt),
      dueDate: dueDate ?? this.dueDate,
      notes: notes ?? this.notes,
      listId: listId ?? this.listId,
    );
  }

  /// Marque l'élément comme complété
  ListItem markAsCompleted() {
    return copyWith(
      isCompleted: true,
      completedAt: DateTime.now(),
    );
  }

  /// Marque l'élément comme non complété
  ListItem markAsIncomplete() {
    return copyWith(
      isCompleted: false,
      forceCompletedAtNull: true,
    );
  }

  /// Convertit l'élément en Map pour la sérialisation JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'eloScore': eloScore,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'notes': notes,
      'listId': listId,
    };
  }

  /// Crée un élément à partir d'une Map (désérialisation JSON)
  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: json['category'] as String?,
      eloScore: (json['eloScore'] as num?)?.toDouble() ?? 1200.0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
      notes: json['notes'] as String?,
      listId: json['listId'] as String,
    );
  }

  /// Vérifie l'égalité entre deux éléments
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ListItem &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.category == category &&
        other.eloScore == eloScore &&
        other.isCompleted == isCompleted &&
        other.createdAt == createdAt &&
        other.completedAt == completedAt &&
        other.dueDate == dueDate &&
        other.notes == notes &&
        other.listId == listId;
  }

  /// Génère le hash code de l'élément
  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      category,
      eloScore,
      isCompleted,
      createdAt,
      completedAt,
      dueDate,
      notes,
      listId,
    );
  }

  /// Représentation textuelle de l'élément
  @override
  String toString() {
    return 'ListItem(id: $id, title: $title, eloScore: ${eloScore.toStringAsFixed(0)}, isCompleted: $isCompleted)';
  }

  /// --- Legacy compatibility pour les anciens tests ---
}
