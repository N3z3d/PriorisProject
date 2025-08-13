library;

/// Exceptions du domaine
/// 
/// Ces exceptions représentent les erreurs métier et les violations
/// des règles du domaine.

/// Exception de base pour toutes les exceptions du domaine
abstract class DomainException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;

  const DomainException(this.message, {this.code, this.context});

  @override
  String toString() => 'DomainException: $message';
}

/// Exception pour les violations d'invariants du domaine
class DomainInvariantException extends DomainException {
  const DomainInvariantException(super.message, {super.code, super.context});
}

/// Exception pour les entités non trouvées
class EntityNotFoundException extends DomainException {
  const EntityNotFoundException(String entityType, String entityId)
      : super('$entityType avec l\'ID $entityId non trouvé', code: 'ENTITY_NOT_FOUND');
}

/// Exception pour les opérations non autorisées
class OperationNotAllowedException extends DomainException {
  const OperationNotAllowedException(super.message, {super.context})
      : super(code: 'OPERATION_NOT_ALLOWED');
}

/// Exception pour les valeurs invalides
class InvalidValueException extends DomainException {
  const InvalidValueException(String fieldName, dynamic value, String reason)
      : super('Valeur invalide pour $fieldName: $value. Raison: $reason', code: 'INVALID_VALUE');
}

// === Exceptions spécifiques aux tâches ===

/// Exception pour les titres de tâche invalides
class InvalidTaskTitleException extends DomainException {
  const InvalidTaskTitleException(super.message)
      : super(code: 'INVALID_TASK_TITLE');
}

/// Exception pour les tâches déjà complétées
class TaskAlreadyCompletedException extends DomainException {
  const TaskAlreadyCompletedException(super.message)
      : super(code: 'TASK_ALREADY_COMPLETED');
}

/// Exception pour les tâches non complétées
class TaskNotCompletedException extends DomainException {
  const TaskNotCompletedException(super.message)
      : super(code: 'TASK_NOT_COMPLETED');
}

// === Exceptions spécifiques aux habitudes ===

/// Exception pour les noms d'habitude invalides
class InvalidHabitNameException extends DomainException {
  const InvalidHabitNameException(super.message)
      : super(code: 'INVALID_HABIT_NAME');
}

/// Exception pour les valeurs cibles invalides
class InvalidTargetValueException extends DomainException {
  const InvalidTargetValueException(super.message)
      : super(code: 'INVALID_TARGET_VALUE');
}

/// Exception pour les types de récurrence invalides
class InvalidRecurrenceException extends DomainException {
  const InvalidRecurrenceException(super.message)
      : super(code: 'INVALID_RECURRENCE');
}

/// Exception pour les enregistrements d'habitude invalides
class InvalidHabitRecordException extends DomainException {
  const InvalidHabitRecordException(super.message)
      : super(code: 'INVALID_HABIT_RECORD');
}

// === Exceptions spécifiques aux listes ===

/// Exception pour les noms de liste invalides
class InvalidListNameException extends DomainException {
  const InvalidListNameException(super.message)
      : super(code: 'INVALID_LIST_NAME');
}

/// Exception pour les éléments de liste dupliqués
class DuplicateListItemException extends DomainException {
  const DuplicateListItemException(String itemId)
      : super('Élément avec l\'ID $itemId existe déjà dans la liste', code: 'DUPLICATE_LIST_ITEM');
}

/// Exception pour les éléments de liste non trouvés
class ListItemNotFoundException extends DomainException {
  const ListItemNotFoundException(String itemId)
      : super('Élément avec l\'ID $itemId non trouvé dans la liste', code: 'LIST_ITEM_NOT_FOUND');
}

/// Exception pour les listes vides
class EmptyListException extends DomainException {
  const EmptyListException(String operation)
      : super('Impossible d\'effectuer l\'opération "$operation" sur une liste vide', code: 'EMPTY_LIST');
}

// === Exceptions spécifiques aux Value Objects ===

/// Exception pour les scores ELO invalides
class InvalidEloScoreException extends DomainException {
  const InvalidEloScoreException(double value)
      : super('Score ELO invalide: $value. Le score doit être entre 0 et 3000', code: 'INVALID_ELO_SCORE');
}

/// Exception pour les priorités invalides
class InvalidPriorityException extends DomainException {
  const InvalidPriorityException(super.message)
      : super(code: 'INVALID_PRIORITY');
}

/// Exception pour les plages de dates invalides
class InvalidDateRangeException extends DomainException {
  const InvalidDateRangeException(super.message)
      : super(code: 'INVALID_DATE_RANGE');
}

/// Exception pour les progressions invalides
class InvalidProgressException extends DomainException {
  const InvalidProgressException(super.message)
      : super(code: 'INVALID_PROGRESS');
}

// === Exceptions de concurrence ===

/// Exception pour les conflits de version (concurrence optimiste)
class ConcurrencyException extends DomainException {
  const ConcurrencyException(String entityType, String entityId, int expectedVersion, int actualVersion)
      : super('Conflit de concurrence pour $entityType $entityId: version attendue $expectedVersion, version actuelle $actualVersion',
              code: 'CONCURRENCY_CONFLICT');
}

// === Exceptions de repository ===

/// Exception pour les erreurs de persistance
class PersistenceException extends DomainException {
  const PersistenceException(super.message, {super.context})
      : super(code: 'PERSISTENCE_ERROR');
}

/// Exception pour les données corrompues
class DataCorruptionException extends DomainException {
  const DataCorruptionException(String entityType, String entityId, String details)
      : super('Données corrompues pour $entityType $entityId: $details', code: 'DATA_CORRUPTION');
}