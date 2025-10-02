import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';
import 'habit_consistency_calculator.dart';
import 'habit_pattern_analyzer.dart';

/// Service spécialisé pour la génération de recommandations d'habitudes
/// Applique SRP - Une seule responsabilité: générer des recommandations
class HabitRecommendationEngine extends LoggableDomainService {
  final HabitConsistencyCalculator _consistencyCalculator;
  final HabitPatternAnalyzer _patternAnalyzer;

  HabitRecommendationEngine({
    HabitConsistencyCalculator? consistencyCalculator,
    HabitPatternAnalyzer? patternAnalyzer,
  })  : _consistencyCalculator = consistencyCalculator ?? HabitConsistencyCalculator(),
        _patternAnalyzer = patternAnalyzer ?? HabitPatternAnalyzer();

  @override
  String get serviceName => 'HabitRecommendationEngine';

  /// Génère des recommandations personnalisées pour améliorer l'habitude
  List<HabitRecommendation> generate(
    HabitAggregate habit, {
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      log('Génération de recommandations pour ${habit.name}');

      final consistency = _consistencyCalculator.calculate(habit, days: analysisWindow);
      final patterns = _patternAnalyzer.analyze(habit, days: analysisWindow * 2);

      final recommendations = <HabitRecommendation>[];

      // Recommandations basées sur la consistance
      _addConsistencyRecommendations(recommendations, consistency);

      // Recommandations basées sur les patterns
      _addPatternRecommendations(recommendations, patterns);

      // Recommandations basées sur la tendance
      _addTrendRecommendations(recommendations, patterns);

      // Recommandations basées sur le streak
      _addStreakRecommendations(recommendations, habit);

      // Recommandations spécifiques aux habitudes quantitatives
      _addQuantitativeRecommendations(recommendations, habit);

      log('${recommendations.length} recommandations générées');

      return recommendations;
    });
  }

  void _addConsistencyRecommendations(List<HabitRecommendation> recommendations, ConsistencyAnalysis consistency) {
    if (consistency.completionRate < 0.5) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.consistency,
        priority: RecommendationPriority.high,
        title: 'Améliorer la régularité',
        description: 'Votre taux de complétion est de ${(consistency.completionRate * 100).toStringAsFixed(0)}%. Essayez de vous concentrer sur de petites victoires quotidiennes.',
        actionItems: [
          'Réduire temporairement l\'objectif si nécessaire',
          'Identifier et supprimer les obstacles principaux',
          'Créer des rappels visuels',
        ],
      ));
    }
  }

  void _addPatternRecommendations(List<HabitRecommendation> recommendations, PatternAnalysis patterns) {
    if (patterns.worstDays.isNotEmpty) {
      final worstDayNames = patterns.worstDays.map(_dayName).join(' et ');
      recommendations.add(HabitRecommendation(
        type: RecommendationType.timing,
        priority: RecommendationPriority.medium,
        title: 'Renforcer les jours difficiles',
        description: 'Vous avez plus de difficultés le $worstDayNames. Planifiez des stratégies spécifiques pour ces jours.',
        actionItems: [
          'Préparer à l\'avance pour le $worstDayNames',
          'Réduire l\'objectif ces jours-là',
          'Trouver un partenaire de responsabilité',
        ],
      ));
    }
  }

  void _addTrendRecommendations(List<HabitRecommendation> recommendations, PatternAnalysis patterns) {
    if (patterns.trend == TrendDirection.declining) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.motivation,
        priority: RecommendationPriority.high,
        title: 'Retrouver la motivation',
        description: 'Votre performance diminue récemment. Il est temps de renouveler votre engagement.',
        actionItems: [
          'Rappeler pourquoi cette habitude est importante',
          'Célébrer les petites victoires',
          'Modifier l\'approche si nécessaire',
        ],
      ));
    }
  }

  void _addStreakRecommendations(List<HabitRecommendation> recommendations, HabitAggregate habit) {
    if (habit.getCurrentStreak() == 0) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.restart,
        priority: RecommendationPriority.high,
        title: 'Reprendre l\'élan',
        description: 'Vous n\'avez pas de série en cours. C\'est le moment parfait pour un nouveau départ.',
        actionItems: [
          'Commencer dès aujourd\'hui avec un objectif simple',
          'Éliminer les obstacles identifiés',
          'Se concentrer uniquement sur cette habitude pendant quelques jours',
        ],
      ));
    } else if (habit.getCurrentStreak() >= 21) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.maintenance,
        priority: RecommendationPriority.low,
        title: 'Maintenir l\'excellence',
        description: 'Excellente série de ${habit.getCurrentStreak()} jours ! Continuez sur cette lancée.',
        actionItems: [
          'Célébrer cette réussite',
          'Identifier ce qui fonctionne bien',
          'Envisager d\'augmenter progressivement l\'objectif',
        ],
      ));
    }
  }

  void _addQuantitativeRecommendations(List<HabitRecommendation> recommendations, HabitAggregate habit) {
    if (habit.type == HabitType.quantitative && habit.targetValue != null) {
      final recentValues = _getRecentValues(habit, 7);
      if (recentValues.isNotEmpty) {
        final averageValue = recentValues.reduce((a, b) => a + b) / recentValues.length;
        if (averageValue > habit.targetValue! * 1.2) {
          recommendations.add(HabitRecommendation(
            type: RecommendationType.optimization,
            priority: RecommendationPriority.low,
            title: 'Augmenter l\'objectif',
            description: 'Vous dépassez régulièrement votre objectif (moyenne: ${averageValue.toStringAsFixed(1)} vs ${habit.targetValue}). Envisagez de l\'augmenter.',
            actionItems: [
              'Augmenter l\'objectif de 10-20%',
              'Maintenir cette performance pendant une semaine',
              'Ajuster progressivement',
            ],
          ));
        }
      }
    }
  }

  List<double> _getRecentValues(HabitAggregate habit, int days) {
    final values = <double>[];
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _getDateKey(date);
      final value = habit.completions[dateKey];

      if (value != null && value is double) {
        values.add(value);
      }
    }

    return values;
  }

  String _dayName(int dayOfWeek) {
    const names = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return names[dayOfWeek];
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// Recommandation pour améliorer une habitude
class HabitRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final List<String> actionItems;

  const HabitRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionItems,
  });
}

enum RecommendationType {
  consistency,
  timing,
  motivation,
  restart,
  maintenance,
  optimization,
}

enum RecommendationPriority {
  high,
  medium,
  low,
}
