/// **GET HABIT QUERY** - CQRS Pattern
///
/// **LOT 5** : Query de lecture d'habitude extraite de God Class
/// **Responsabilité unique** : Validation et transport de l'ID pour lecture
/// **Taille** : ~20 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';

/// Query pour récupérer une habitude spécifique
///
/// **SRP** : Responsabilité unique de validation de l'ID de lecture
/// **CQRS** : Sépare les opérations de lecture des opérations de modification
class GetHabitQuery extends Query {
  final String habitId;

  GetHabitQuery({required this.habitId});

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'GetHabit',
      );
    }
  }
}