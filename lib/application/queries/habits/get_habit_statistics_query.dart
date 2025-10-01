/// **GET HABIT STATISTICS QUERY** - CQRS Pattern
///
/// **LOT 5** : Query de statistiques d'habitudes extraite de God Class
/// **Responsabilité unique** : Transport des paramètres de période statistique
/// **Taille** : ~15 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';
import '../../../domain/core/value_objects/export.dart';

/// Query pour récupérer les statistiques globales des habitudes
///
/// **SRP** : Responsabilité unique de transport de la période d'analyse
/// **Flexibilité** : DateRange optionnel pour statistiques sur période personnalisée
class GetHabitStatisticsQuery extends Query {
  final DateRange? dateRange;

  GetHabitStatisticsQuery({this.dateRange});
}