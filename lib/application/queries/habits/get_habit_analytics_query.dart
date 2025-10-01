/// **GET HABIT ANALYTICS QUERY** - CQRS Pattern
///
/// **LOT 5** : Query d'analytics d'habitude extraite de God Class
/// **Responsabilité unique** : Validation et transport des paramètres d'analyse
/// **Taille** : ~30 lignes (contrainte CLAUDE.md respectée)

import '../../services/application_service.dart';

/// Query pour récupérer les analytics d'une habitude spécifique
///
/// **SRP** : Responsabilité unique de validation des paramètres d'analyse
/// **Analytics** : Fenêtre d'analyse configurable pour statistiques détaillées
class GetHabitAnalyticsQuery extends Query {
  final String habitId;
  final int? analysisWindow;

  GetHabitAnalyticsQuery({
    required this.habitId,
    this.analysisWindow,
  });

  @override
  void validate() {
    if (habitId.trim().isEmpty) {
      throw BusinessValidationException(
        'ID d\'habitude requis',
        ['L\'identifiant de l\'habitude est requis'],
        operationName: 'GetHabitAnalytics',
      );
    }

    if (analysisWindow != null && analysisWindow! <= 0) {
      throw BusinessValidationException(
        'Fenêtre d\'analyse invalide',
        ['La fenêtre d\'analyse doit être positive'],
        operationName: 'GetHabitAnalytics',
      );
    }
  }
}