/// **RECORD HABIT COMMAND** - CQRS Pattern
///
/// **LOT 5** : Commande d'enregistrement d'habitude extraite de God Class
/// **Responsabilité unique** : Validation et transport des données d'enregistrement
/// **Taille** : ~30 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';

/// Commande pour enregistrer l'exécution d'une habitude
///
/// **SRP** : Responsabilité unique de validation des données d'enregistrement
/// **Polymorphisme** : Supporte bool (binaire) et double (quantitatif)
class RecordHabitCommand extends Command {
  final String habitId;
  final dynamic value; // bool pour binaire, double pour quantitatif
  final DateTime? date;

  RecordHabitCommand({
    required this.habitId,
    required this.value,
    this.date,
  });

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'RecordHabit',
      );
    }

    if (value is! bool && value is! double) {
      throw BusinessValidationException(
        'Valeur invalide',
        ['La valeur doit être un booléen ou un nombre'],
        operationName: 'RecordHabit',
      );
    }

    if (value is double && value < 0) {
      throw BusinessValidationException(
        'Valeur négative',
        ['La valeur quantitative ne peut pas être négative'],
        operationName: 'RecordHabit',
      );
    }
  }
}