/// **DELETE HABIT COMMAND** - CQRS Pattern
///
/// **LOT 5** : Commande de suppression d'habitude extraite de God Class
/// **Responsabilité unique** : Validation et transport de l'ID de suppression
/// **Taille** : ~20 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';

/// Commande pour supprimer une habitude existante
///
/// **SRP** : Responsabilité unique de validation de l'ID à supprimer
/// **Simplicité** : Command minimal pour opération de suppression
class DeleteHabitCommand extends Command {
  final String habitId;

  DeleteHabitCommand({required this.habitId});

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'DeleteHabit',
      );
    }
  }
}