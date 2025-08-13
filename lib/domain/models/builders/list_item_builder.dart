import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'dart:math';

class ListItemBuilder {
  String? _id;
  String? _title;
  String? _description;
  String? _category;
  double _eloScore = 1200.0; // Score ELO par défaut
  bool _isCompleted = false;
  DateTime? _createdAt;
  DateTime? _completedAt;
  DateTime? _dueDate;
  String? _notes;
  String? _listId;

  final _random = Random();

  ListItemBuilder withId(String id) {
    _id = id;
    return this;
  }

  ListItemBuilder withTitle(String title) {
    if (title.trim().isEmpty) {
      throw ArgumentError('Le titre ne peut pas être vide');
    }
    if (title.length > 200) {
      throw ArgumentError('Le titre ne peut pas dépasser 200 caractères');
    }
    _title = title.trim();
    return this;
  }

  ListItemBuilder withDescription(String description) {
    if (description.length > 1000) {
      throw ArgumentError('La description ne peut pas dépasser 1000 caractères');
    }
    _description = description.trim().isEmpty ? null : description.trim();
    return this;
  }

  ListItemBuilder withCategory(String category) {
    if (category.length > 50) {
      throw ArgumentError('La catégorie ne peut pas dépasser 50 caractères');
    }
    _category = category.trim().isEmpty ? null : category.trim();
    return this;
  }

  ListItemBuilder withEloScore(double eloScore) {
    if (eloScore < 0) {
      throw ArgumentError('Le score ELO doit être positif');
    }
    _eloScore = eloScore;
    return this;
  }

  ListItemBuilder withIsCompleted(bool isCompleted) {
    _isCompleted = isCompleted;
    return this;
  }

  ListItemBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  ListItemBuilder withCompletedAt(DateTime? completedAt) {
    _completedAt = completedAt;
    return this;
  }

  ListItemBuilder withDueDate(DateTime? dueDate) {
    _dueDate = dueDate;
    return this;
  }

  ListItemBuilder withNotes(String? notes) {
    _notes = notes;
    return this;
  }

  ListItemBuilder withListId(String listId) {
    _listId = listId;
    return this;
  }

  ListItemBuilder reset() {
    _id = null;
    _title = null;
    _description = null;
    _category = null;
    _eloScore = 1200.0;
    _isCompleted = false;
    _createdAt = null;
    _completedAt = null;
    _dueDate = null;
    _notes = null;
    _listId = null;
    return this;
  }

  ListItem build() {
    // Gestion préalable des dates avant validation
    final now = DateTime.now();
    final createdAt = _createdAt ?? now;
    
    // Si l'élément est marqué comme complété mais n'a pas de date de complétion, utiliser maintenant
    DateTime? completedAt = _completedAt;
    if (_isCompleted && completedAt == null) {
      completedAt = now;
    }
    
    // Validation après gestion des dates
    if (_title == null || _title!.isEmpty) {
      throw StateError('Le titre est requis pour créer un ListItem');
    }
    if (_isCompleted && completedAt == null) {
      throw StateError('Un élément complété doit avoir une date de complétion');
    }
    if (!_isCompleted && completedAt != null) {
      throw StateError('Un élément non complété ne peut pas avoir de date de complétion');
    }
    
    return ListItem(
      id: _id ?? '${DateTime.now().microsecondsSinceEpoch}-${_random.nextInt(100000)}',
      title: _title!,
      description: _description,
      category: _category,
      eloScore: _eloScore,
      isCompleted: _isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      dueDate: _dueDate,
      notes: _notes,
      listId: _listId ?? 'default',
    );
  }

  static ListItemBuilder fromTemplate(ListItem template) {
    return ListItemBuilder()
      .withId(template.id)
      .withTitle(template.title)
      .withDescription(template.description ?? '')
      .withCategory(template.category ?? '')
      .withEloScore(template.eloScore)
      .withIsCompleted(template.isCompleted)
      .withCreatedAt(template.createdAt)
      .withCompletedAt(template.completedAt)
      .withDueDate(template.dueDate)
      .withNotes(template.notes);
  }

  // Méthodes de factory basées sur le score ELO
  static ListItemBuilder highScoreItem() {
    return ListItemBuilder().withEloScore(1500.0);
  }

  static ListItemBuilder mediumScoreItem() {
    return ListItemBuilder().withEloScore(1200.0);
  }

  static ListItemBuilder lowScoreItem() {
    return ListItemBuilder().withEloScore(900.0);
  }

  static ListItemBuilder completedItem() {
    return ListItemBuilder().withIsCompleted(true);
  }

  static ListItemBuilder incompleteItem() {
    return ListItemBuilder().withIsCompleted(false);
  }

  // --- Legacy aliases pour compatibilité tests existants ---
  ListItemBuilder withCompletionStatus(bool completed) => withIsCompleted(completed);

  ListItemBuilder markAsCompleted() => withIsCompleted(true);

  ListItemBuilder markAsIncomplete() => withIsCompleted(false).withCompletedAt(null);

  /// Crée un builder préconfiguré selon le type de liste
  static ListItemBuilder forListType(ListType type) {
    // Simple factory: définit un score ELO en fonction du type
    switch (type) {
      case ListType.SHOPPING:
        return ListItemBuilder().withEloScore(1100.0);
      case ListType.TRAVEL:
        return ListItemBuilder().withEloScore(1300.0);
      case ListType.MOVIES:
        return ListItemBuilder().withEloScore(1000.0);
      case ListType.BOOKS:
        return ListItemBuilder().withEloScore(1200.0);
      case ListType.RESTAURANTS:
        return ListItemBuilder().withEloScore(1150.0);
      case ListType.PROJECTS:
        return ListItemBuilder().withEloScore(1400.0);
      case ListType.CUSTOM:
        return ListItemBuilder().withEloScore(1200.0);
    }
  }

  /// Crée un élément avec score aléatoire pour les tests
  static ListItemBuilder randomItem() {
    final random = Random();
    final score = 800.0 + random.nextDouble() * 800.0; // Entre 800 et 1600
    return ListItemBuilder().withEloScore(score);
    }

  /// Crée un élément de type tâche
  static ListItemBuilder taskItem() {
    return ListItemBuilder()
      .withEloScore(1200.0)
      .withCategory('Tâche');
  }

  /// Crée un élément de type habitude
  static ListItemBuilder habitItem() {
    return ListItemBuilder()
      .withEloScore(1300.0)
      .withCategory('Habitude');
  }
}
