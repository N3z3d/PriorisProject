/// **CREATE HABIT COMMAND** - CQRS Pattern
///
/// **LOT 5** : Commande de création d'habitude extraite de God Class
/// **Responsabilité unique** : Validation et transport des données de création
/// **Taille** : ~40 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';
import '../../../domain/core/value_objects/export.dart';

/// Commande pour créer une nouvelle habitude
///
/// **SRP** : Responsabilité unique de validation et transport des données
/// **Validation** : Règles métier encapsulées dans la commande
class CreateHabitCommand extends Command {
  final String name;
  final String? description;
  final HabitType type;
  final String? category;
  final double? targetValue;
  final String? unit;
  final RecurrenceType? recurrenceType;
  final int? intervalDays;
  final List<int>? weekdays;
  final int? timesTarget;

  CreateHabitCommand({
    required this.name,
    this.description,
    required this.type,
    this.category,
    this.targetValue,
    this.unit,
    this.recurrenceType,
    this.intervalDays,
    this.weekdays,
    this.timesTarget,
  });

  @override
  void validate() {
    if (name.trim().isEmpty) {
      throw BusinessValidationException(
        'Le nom est requis',
        ['Le nom de l\'habitude ne peut pas être vide'],
        operationName: 'CreateHabit',
      );
    }

    if (name.length > 100) {
      throw BusinessValidationException(
        'Le nom est trop long',
        ['Le nom ne peut pas dépasser 100 caractères'],
        operationName: 'CreateHabit',
      );
    }

    if (type == HabitType.quantitative) {
      if (targetValue == null || targetValue! <= 0) {
        throw BusinessValidationException(
          'Valeur cible invalide',
          ['Une habitude quantitative doit avoir une valeur cible positive'],
          operationName: 'CreateHabit',
        );
      }

      if (unit == null || unit!.trim().isEmpty) {
        throw BusinessValidationException(
          'Unité requise',
          ['Une habitude quantitative doit avoir une unité'],
          operationName: 'CreateHabit',
        );
      }
    }

    if (weekdays != null) {
      for (final day in weekdays!) {
        if (day < 1 || day > 7) {
          throw BusinessValidationException(
            'Jour invalide',
            ['Les jours de la semaine doivent être entre 1 (lundi) et 7 (dimanche)'],
            operationName: 'CreateHabit',
          );
        }
      }
    }
  }
}