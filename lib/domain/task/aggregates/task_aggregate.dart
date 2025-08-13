import 'package:uuid/uuid.dart';
import '../../core/aggregates/aggregate_root.dart';
import '../../core/value_objects/export.dart';
import '../../core/exceptions/domain_exceptions.dart';
import '../events/task_events.dart';

/// Agrégat Task - Racine d'agrégat pour les tâches
/// 
/// Cet agrégat encapsule toute la logique métier liée aux tâches,
/// y compris le système de score ELO, les duels et la gestion des priorités.
class TaskAggregate extends AggregateRoot {
  @override
  final String id;
  
  String _title;
  String? _description;
  EloScore _eloScore;
  bool _isCompleted;
  final DateTime _createdAt;
  DateTime? _completedAt;
  String? _category;
  DateTime? _dueDate;

  TaskAggregate._({
    required this.id,
    required String title,
    String? description,
    required EloScore eloScore,
    bool isCompleted = false,
    required DateTime createdAt,
    DateTime? completedAt,
    String? category,
    DateTime? dueDate,
  }) : _title = title,
       _description = description,
       _eloScore = eloScore,
       _isCompleted = isCompleted,
       _createdAt = createdAt,
       _completedAt = completedAt,
       _category = category,
       _dueDate = dueDate;

  /// Factory pour créer une nouvelle tâche
  factory TaskAggregate.create({
    String? id,
    required String title,
    String? description,
    EloScore? eloScore,
    String? category,
    DateTime? dueDate,
  }) {
    if (title.trim().isEmpty) {
      throw InvalidTaskTitleException('Le titre de la tâche ne peut pas être vide');
    }

    final taskId = id ?? const Uuid().v4();
    final initialElo = eloScore ?? EloScore.initial();
    final createdAt = DateTime.now();

    final task = TaskAggregate._(
      id: taskId,
      title: title.trim(),
      description: description?.trim(),
      eloScore: initialElo,
      createdAt: createdAt,
      category: category?.trim(),
      dueDate: dueDate,
    );

    // Publier l'événement de création
    task.addEvent(TaskCreatedEvent(
      taskId: taskId,
      title: title.trim(),
      category: category?.trim(),
      initialEloScore: initialElo.value,
    ));

    return task;
  }

  /// Factory pour reconstituer une tâche depuis la persistence
  factory TaskAggregate.reconstitute({
    required String id,
    required String title,
    String? description,
    required double eloScore,
    bool isCompleted = false,
    required DateTime createdAt,
    DateTime? completedAt,
    String? category,
    DateTime? dueDate,
  }) {
    return TaskAggregate._(
      id: id,
      title: title,
      description: description,
      eloScore: EloScore.fromValue(eloScore),
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      category: category,
      dueDate: dueDate,
    );
  }

  // Getters
  String get title => _title;
  String? get description => _description;
  EloScore get eloScore => _eloScore;
  bool get isCompleted => _isCompleted;
  DateTime get createdAt => _createdAt;
  DateTime? get completedAt => _completedAt;
  String? get category => _category;
  DateTime? get dueDate => _dueDate;

  /// Calcule la priorité actuelle de la tâche
  Priority get priority {
    return Priority.fromEloAndDueDate(
      eloScore: _eloScore.value,
      dueDate: _dueDate,
    );
  }

  /// Vérifie si la tâche est en retard
  bool get isOverdue {
    if (_dueDate == null || _isCompleted) return false;
    return DateTime.now().isAfter(_dueDate!);
  }

  /// Calcule le nombre de jours de retard
  int get daysPastDue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(_dueDate!).inDays;
  }

  /// Met à jour le titre de la tâche
  void updateTitle(String newTitle) {
    executeOperation(() {
      if (newTitle.trim().isEmpty) {
        throw InvalidTaskTitleException('Le titre de la tâche ne peut pas être vide');
      }

      if (_isCompleted) {
        throw TaskAlreadyCompletedException('Impossible de modifier une tâche complétée');
      }

      final oldTitle = _title;
      _title = newTitle.trim();

      addEvent(TaskModifiedEvent(
        taskId: id,
        changes: {'title': {'from': oldTitle, 'to': _title}},
        reason: 'Titre modifié',
      ));
    });
  }

  /// Met à jour la description de la tâche
  void updateDescription(String? newDescription) {
    executeOperation(() {
      if (_isCompleted) {
        throw TaskAlreadyCompletedException('Impossible de modifier une tâche complétée');
      }

      final oldDescription = _description;
      _description = newDescription?.trim();

      addEvent(TaskModifiedEvent(
        taskId: id,
        changes: {'description': {'from': oldDescription, 'to': _description}},
        reason: 'Description modifiée',
      ));
    });
  }

  /// Met à jour la catégorie de la tâche
  void updateCategory(String? newCategory) {
    executeOperation(() {
      if (_isCompleted) {
        throw TaskAlreadyCompletedException('Impossible de modifier une tâche complétée');
      }

      final oldCategory = _category;
      _category = newCategory?.trim();

      addEvent(TaskModifiedEvent(
        taskId: id,
        changes: {'category': {'from': oldCategory, 'to': _category}},
        reason: 'Catégorie modifiée',
      ));
    });
  }

  /// Met à jour la date d'échéance
  void updateDueDate(DateTime? newDueDate) {
    executeOperation(() {
      if (_isCompleted) {
        throw TaskAlreadyCompletedException('Impossible de modifier une tâche complétée');
      }

      final oldDueDate = _dueDate;
      _dueDate = newDueDate;

      addEvent(TaskModifiedEvent(
        taskId: id,
        changes: {'dueDate': {'from': oldDueDate?.toIso8601String(), 'to': newDueDate?.toIso8601String()}},
        reason: 'Date d\'échéance modifiée',
      ));
    });
  }

  /// Marque la tâche comme complétée
  void complete() {
    executeOperation(() {
      if (_isCompleted) {
        throw TaskAlreadyCompletedException('La tâche est déjà complétée');
      }

      _isCompleted = true;
      _completedAt = DateTime.now();

      final completionTime = _completedAt!.difference(_createdAt);

      addEvent(TaskCompletedEvent(
        taskId: id,
        title: _title,
        eloScore: _eloScore.value,
        completedAt: _completedAt!,
        category: _category,
        completionTime: completionTime,
      ));
    });
  }

  /// Marque la tâche comme non complétée (réouvre)
  void reopen() {
    executeOperation(() {
      if (!_isCompleted) {
        throw TaskNotCompletedException('La tâche n\'est pas complétée');
      }

      _isCompleted = false;
      _completedAt = null;

      addEvent(TaskModifiedEvent(
        taskId: id,
        changes: {'isCompleted': {'from': true, 'to': false}},
        reason: 'Tâche réouverte',
      ));
    });
  }

  /// Effectue un duel contre une autre tâche
  void duelAgainst(TaskAggregate opponent, bool won) {
    executeOperation(() {
      if (_isCompleted || opponent._isCompleted) {
        throw TaskAlreadyCompletedException('Les tâches complétées ne peuvent pas participer aux duels');
      }

      final previousElo = _eloScore;
      final opponentPreviousElo = opponent._eloScore;

      // Mise à jour des scores ELO
      _eloScore = _eloScore.updateAfterDuel(
        opponent: opponent._eloScore,
        won: won,
      );

      opponent._eloScore = opponent._eloScore.updateAfterDuel(
        opponent: previousElo,
        won: !won,
      );

      // Publier les événements
      addEvent(TaskEloUpdatedEvent(
        taskId: id,
        previousElo: previousElo.value,
        newElo: _eloScore.value,
        reason: won ? 'Victoire en duel' : 'Défaite en duel',
      ));

      opponent.addEvent(TaskEloUpdatedEvent(
        taskId: opponent.id,
        previousElo: opponentPreviousElo.value,
        newElo: opponent._eloScore.value,
        reason: !won ? 'Victoire en duel' : 'Défaite en duel',
      ));

      addEvent(TaskDuelCompletedEvent(
        winnerTaskId: won ? id : opponent.id,
        loserTaskId: won ? opponent.id : id,
        winnerPreviousElo: won ? previousElo.value : opponentPreviousElo.value,
        winnerNewElo: won ? _eloScore.value : opponent._eloScore.value,
        loserPreviousElo: won ? opponentPreviousElo.value : previousElo.value,
        loserNewElo: won ? opponent._eloScore.value : _eloScore.value,
      ));
    });
  }

  /// Génère un événement de rappel si la tâche est en retard
  void checkOverdue() {
    if (isOverdue) {
      addEvent(TaskOverdueEvent(
        taskId: id,
        title: _title,
        dueDate: _dueDate!,
        daysPastDue: daysPastDue,
        eloScore: _eloScore.value,
      ));
    }
  }

  @override
  void validateInvariants() {
    if (_title.trim().isEmpty) {
      throw DomainInvariantException('Le titre de la tâche ne peut pas être vide');
    }

    if (_isCompleted && _completedAt == null) {
      throw DomainInvariantException('Une tâche complétée doit avoir une date de complétion');
    }

    if (!_isCompleted && _completedAt != null) {
      throw DomainInvariantException('Une tâche non complétée ne peut pas avoir une date de complétion');
    }

    if (_completedAt != null && _completedAt!.isBefore(_createdAt)) {
      throw DomainInvariantException('La date de complétion ne peut pas être antérieure à la date de création');
    }
  }

  /// Copie avec modifications
  TaskAggregate copyWith({
    String? title,
    String? description,
    EloScore? eloScore,
    bool? isCompleted,
    DateTime? completedAt,
    String? category,
    DateTime? dueDate,
  }) {
    return TaskAggregate._(
      id: id,
      title: title ?? _title,
      description: description ?? _description,
      eloScore: eloScore ?? _eloScore,
      isCompleted: isCompleted ?? _isCompleted,
      createdAt: _createdAt,
      completedAt: completedAt ?? _completedAt,
      category: category ?? _category,
      dueDate: dueDate ?? _dueDate,
    );
  }

  @override
  String toString() {
    return 'TaskAggregate(id: $id, title: $_title, eloScore: ${_eloScore.value.toStringAsFixed(0)}, completed: $_isCompleted)';
  }
}