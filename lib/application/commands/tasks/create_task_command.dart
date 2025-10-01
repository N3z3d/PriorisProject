/// **CREATE TASK COMMAND** - CQRS Pattern
///
/// **LOT 5** : Commande de création de tâche extraite de God Class
/// **Responsabilité unique** : Validation et transport des données de création
/// **Taille** : ~40 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';
import '../../../domain/core/value_objects/export.dart';

/// Commande pour créer une nouvelle tâche
///
/// **SRP** : Responsabilité unique de validation et transport des données
/// **Validation** : Règles métier encapsulées pour titre, description, échéance
class CreateTaskCommand extends Command {
  final String title;
  final String? description;
  final String? category;
  final DateTime? dueDate;
  final EloScore? initialElo;

  CreateTaskCommand({
    required this.title,
    this.description,
    this.category,
    this.dueDate,
    this.initialElo,
  });

  @override
  void validate() {
    if (title.trim().isEmpty) {
      throw BusinessValidationException(
        'Le titre est requis',
        ['Le titre de la tâche ne peut pas être vide'],
        operationName: 'CreateTask',
      );
    }

    if (title.length > 200) {
      throw BusinessValidationException(
        'Le titre est trop long',
        ['Le titre ne peut pas dépasser 200 caractères'],
        operationName: 'CreateTask',
      );
    }

    if (description != null && description!.length > 1000) {
      throw BusinessValidationException(
        'La description est trop longue',
        ['La description ne peut pas dépasser 1000 caractères'],
        operationName: 'CreateTask',
      );
    }

    if (dueDate != null && dueDate!.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw BusinessValidationException(
        'Date d\'échéance invalide',
        ['La date d\'échéance ne peut pas être dans le passé'],
        operationName: 'CreateTask',
      );
    }
  }
}