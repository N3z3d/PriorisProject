/// **UPDATE HABIT COMMAND** - CQRS Pattern
///
/// **LOT 5** : Commande de modification d'habitude extraite de God Class
/// **Responsabilité unique** : Validation et transport des données de modification
/// **Taille** : ~35 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';

/// Commande pour modifier une habitude existante
///
/// **SRP** : Responsabilité unique de validation des modifications
/// **Flexibilité** : Champs optionnels pour modification partielle
class UpdateHabitCommand extends Command {
  final String habitId;
  final String? name;
  final String? description;
  final String? category;
  final double? targetValue;
  final String? unit;

  UpdateHabitCommand({
    required this.habitId,
    this.name,
    this.description,
    this.category,
    this.targetValue,
    this.unit,
  });

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'UpdateHabit',
      );
    }

    if (name != null && name!.trim().isEmpty) {
      throw BusinessValidationException(
        'Le nom ne peut pas être vide',
        ['Le nom de l\'habitude ne peut pas être vide'],
        operationName: 'UpdateHabit',
      );
    }

    if (targetValue != null && targetValue! <= 0) {
      throw BusinessValidationException(
        'Valeur cible invalide',
        ['La valeur cible doit être positive'],
        operationName: 'UpdateHabit',
      );
    }
  }
}