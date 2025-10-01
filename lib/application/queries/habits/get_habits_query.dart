/// **GET HABITS QUERY** - CQRS Pattern
///
/// **LOT 5** : Query de lecture d'habitudes avec filtres extraite de God Class
/// **Responsabilité unique** : Validation et transport des critères de filtrage
/// **Taille** : ~50 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';
import '../../../domain/core/value_objects/export.dart';

/// Query pour récupérer une liste d'habitudes avec filtres optionnels
///
/// **SRP** : Responsabilité unique de validation des critères de recherche
/// **Flexibilité** : Multiples filtres optionnels pour requêtes précises
class GetHabitsQuery extends Query {
  final String? category;
  final HabitType? type;
  final bool? completedToday;
  final int? minStreak;
  final double? minSuccessRate;
  final int? limit;
  final String? searchText;

  GetHabitsQuery({
    this.category,
    this.type,
    this.completedToday,
    this.minStreak,
    this.minSuccessRate,
    this.limit,
    this.searchText,
  });

  @override
  void validate() {
    if (limit != null && limit! <= 0) {
      throw BusinessValidationException(
        'Limite invalide',
        ['La limite doit être supérieure à 0'],
        operationName: 'GetHabits',
      );
    }

    if (minStreak != null && minStreak! < 0) {
      throw BusinessValidationException(
        'Streak minimum invalide',
        ['Le streak minimum ne peut pas être négatif'],
        operationName: 'GetHabits',
      );
    }

    if (minSuccessRate != null && (minSuccessRate! < 0 || minSuccessRate! > 1)) {
      throw BusinessValidationException(
        'Taux de réussite invalide',
        ['Le taux de réussite minimum doit être entre 0 et 1'],
        operationName: 'GetHabits',
      );
    }
  }
}