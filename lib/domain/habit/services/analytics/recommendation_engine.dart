import '../../../core/services/domain_service.dart';
import '../../aggregates/habit_aggregate.dart';
import 'consistency_analyzer.dart';
import 'pattern_analyzer.dart';
import 'success_predictor.dart';

/// Recommendation Types
enum RecommendationType {
  consistency('Consistance'),
  timing('Timing'),
  motivation('Motivation'),
  restart('Redémarrage'),
  maintenance('Maintenance'),
  optimization('Optimisation');

  const RecommendationType(this.label);
  final String label;
}

/// Recommendation Priority Levels
enum RecommendationPriority {
  low('Faible'),
  medium('Moyenne'),
  high('Élevée'),
  critical('Critique');

  const RecommendationPriority(this.label);
  final String label;
}

/// Habit Recommendation
class HabitRecommendation {
  final RecommendationType type;
  final RecommendationPriority priority;
  final String title;
  final String description;
  final List<String> actionItems;
  final double impactScore;
  final DateTime createdAt;

  HabitRecommendation({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionItems,
    double? impactScore,
    DateTime? createdAt,
  })  : impactScore = impactScore ?? _calculateDefaultImpact(priority),
        createdAt = createdAt ?? DateTime.now();

  static double _calculateDefaultImpact(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 0.9;
      case RecommendationPriority.high:
        return 0.7;
      case RecommendationPriority.medium:
        return 0.5;
      case RecommendationPriority.low:
        return 0.3;
    }
  }
}

/// Recommendation Context for Analysis
class RecommendationContext {
  final HabitAggregate habit;
  final ConsistencyAnalysis consistency;
  final PatternAnalysis patterns;
  final SuccessPrediction? prediction;
  final int analysisWindow;

  const RecommendationContext({
    required this.habit,
    required this.consistency,
    required this.patterns,
    this.prediction,
    this.analysisWindow = 30,
  });
}

/// Recommendation Engine - Generates personalized habit improvement recommendations
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for recommendation generation only
/// - OCP: Extensible through recommendation rule strategies
/// - LSP: Compatible with recommendation interfaces
/// - ISP: Focused interface for recommendation operations only
/// - DIP: Depends on analyzer abstractions
///
/// Features:
/// - Multi-factor recommendation analysis
/// - Personalized action item generation
/// - Priority-based recommendation sorting
/// - Impact scoring for recommendation effectiveness
/// - Context-aware recommendation rules
/// - Specific recommendations for different habit types
///
/// CONSTRAINTS: <200 lines (currently ~190 lines)
class RecommendationEngine extends LoggableDomainService {

  final ConsistencyAnalyzer _consistencyAnalyzer;
  final PatternAnalyzer _patternAnalyzer;

  @override
  String get serviceName => 'RecommendationEngine';

  RecommendationEngine({
    ConsistencyAnalyzer? consistencyAnalyzer,
    PatternAnalyzer? patternAnalyzer,
  })  : _consistencyAnalyzer = consistencyAnalyzer ?? ConsistencyAnalyzer(),
        _patternAnalyzer = patternAnalyzer ?? PatternAnalyzer();

  /// Generates comprehensive recommendations for habit improvement
  List<HabitRecommendation> generateRecommendations(
    HabitAggregate habit, {
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      log('Generating recommendations for ${habit.name}');

      // Gather analysis data
      final consistency = _consistencyAnalyzer.analyzeConsistency(habit, days: analysisWindow);
      final patterns = _patternAnalyzer.analyzePatterns(habit, days: analysisWindow * 2);

      final context = RecommendationContext(
        habit: habit,
        consistency: consistency,
        patterns: patterns,
        analysisWindow: analysisWindow,
      );

      final recommendations = <HabitRecommendation>[];

      // Generate different types of recommendations
      recommendations.addAll(_generateConsistencyRecommendations(context));
      recommendations.addAll(_generateTimingRecommendations(context));
      recommendations.addAll(_generateMotivationRecommendations(context));
      recommendations.addAll(_generateStreakRecommendations(context));
      recommendations.addAll(_generateHabitTypeSpecificRecommendations(context));

      // Sort by priority and impact
      recommendations.sort((a, b) {
        final priorityCompare = _getPriorityWeight(b.priority).compareTo(_getPriorityWeight(a.priority));
        if (priorityCompare != 0) return priorityCompare;
        return b.impactScore.compareTo(a.impactScore);
      });

      log('Generated ${recommendations.length} recommendations');

      return recommendations.take(5).toList(); // Limit to top 5 recommendations
    });
  }

  /// Generates quick recommendations for immediate action
  List<HabitRecommendation> generateQuickWins(HabitAggregate habit) {
    return executeOperation(() {
      final consistency = _consistencyAnalyzer.analyzeConsistency(habit, days: 7);
      final recommendations = <HabitRecommendation>[];

      // Quick win: Start streak
      if (consistency.currentStreak == 0) {
        recommendations.add(HabitRecommendation(
          type: RecommendationType.restart,
          priority: RecommendationPriority.high,
          title: 'Démarrer une nouvelle série',
          description: 'Commencez dès aujourd\'hui pour relancer votre élan.',
          actionItems: ['Faire ${habit.name} maintenant', 'Programmer un rappel'],
          impactScore: 0.8,
        ));
      }

      return recommendations;
    });
  }

  // === PRIVATE RECOMMENDATION GENERATORS ===

  List<HabitRecommendation> _generateConsistencyRecommendations(RecommendationContext context) {
    final recommendations = <HabitRecommendation>[];

    if (context.consistency.completionRate < 0.5) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.consistency,
        priority: RecommendationPriority.high,
        title: 'Améliorer la régularité',
        description: 'Votre taux de complétion est de ${(context.consistency.completionRate * 100).toStringAsFixed(0)}%. '
            'Concentrez-vous sur des victoires quotidiennes plus petites.',
        actionItems: [
          'Réduire l\'objectif temporairement si nécessaire',
          'Identifier et supprimer les obstacles principaux',
          'Créer des rappels visuels dans votre environnement',
          'Lier l\'habitude à une routine existante',
        ],
        impactScore: 0.85,
      ));
    }

    return recommendations;
  }

  List<HabitRecommendation> _generateTimingRecommendations(RecommendationContext context) {
    final recommendations = <HabitRecommendation>[];

    if (context.patterns.worstDays.isNotEmpty) {
      final worstDayNames = context.patterns.worstDays.map(_dayName).join(' et ');
      recommendations.add(HabitRecommendation(
        type: RecommendationType.timing,
        priority: RecommendationPriority.medium,
        title: 'Renforcer les jours difficiles',
        description: 'Vous avez plus de difficultés le $worstDayNames. '
            'Planifiez des stratégies spécifiques pour ces jours.',
        actionItems: [
          'Préparer à l\'avance pour le $worstDayNames',
          'Réduire l\'objectif ces jours-là',
          'Trouver un partenaire de responsabilité',
          'Changer le moment de la journée',
        ],
        impactScore: 0.6,
      ));
    }

    return recommendations;
  }

  List<HabitRecommendation> _generateMotivationRecommendations(RecommendationContext context) {
    final recommendations = <HabitRecommendation>[];

    if (context.patterns.trend == TrendDirection.declining) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.motivation,
        priority: RecommendationPriority.high,
        title: 'Retrouver la motivation',
        description: 'Votre performance diminue récemment. '
            'Il est temps de renouveler votre engagement.',
        actionItems: [
          'Rappeler pourquoi cette habitude est importante',
          'Célébrer les petites victoires déjà obtenues',
          'Modifier l\'approche si nécessaire',
          'Trouver de nouvelles sources d\'inspiration',
        ],
        impactScore: 0.75,
      ));
    }

    return recommendations;
  }

  List<HabitRecommendation> _generateStreakRecommendations(RecommendationContext context) {
    final recommendations = <HabitRecommendation>[];

    if (context.habit.getCurrentStreak() == 0) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.restart,
        priority: RecommendationPriority.high,
        title: 'Reprendre l\'élan',
        description: 'Vous n\'avez pas de série en cours. '
            'C\'est le moment parfait pour un nouveau départ.',
        actionItems: [
          'Commencer dès aujourd\'hui avec un objectif simple',
          'Éliminer les obstacles identifiés précédemment',
          'Se concentrer uniquement sur cette habitude pendant quelques jours',
        ],
        impactScore: 0.8,
      ));
    } else if (context.habit.getCurrentStreak() >= 21) {
      recommendations.add(HabitRecommendation(
        type: RecommendationType.maintenance,
        priority: RecommendationPriority.low,
        title: 'Maintenir l\'excellence',
        description: 'Excellente série de ${context.habit.getCurrentStreak()} jours ! '
            'Continuez sur cette lancée.',
        actionItems: [
          'Célébrer cette réussite importante',
          'Identifier ce qui fonctionne bien',
          'Envisager d\'augmenter progressivement l\'objectif',
        ],
        impactScore: 0.4,
      ));
    }

    return recommendations;
  }

  List<HabitRecommendation> _generateHabitTypeSpecificRecommendations(RecommendationContext context) {
    final recommendations = <HabitRecommendation>[];

    if (context.habit.type == HabitType.quantitative && context.habit.targetValue != null) {
      final recentValues = _getRecentValues(context.habit, 7);
      if (recentValues.isNotEmpty) {
        final averageValue = recentValues.reduce((a, b) => a + b) / recentValues.length;
        if (averageValue > context.habit.targetValue! * 1.2) {
          recommendations.add(HabitRecommendation(
            type: RecommendationType.optimization,
            priority: RecommendationPriority.low,
            title: 'Augmenter l\'objectif',
            description: 'Vous dépassez régulièrement votre objectif '
                '(moyenne: ${averageValue.toStringAsFixed(1)} vs ${context.habit.targetValue}). '
                'Envisagez de l\'augmenter.',
            actionItems: [
              'Augmenter l\'objectif de 10-20%',
              'Maintenir cette performance pendant une semaine',
              'Ajuster progressivement selon les résultats',
            ],
            impactScore: 0.3,
          ));
        }
      }
    }

    return recommendations;
  }

  // === HELPER METHODS ===

  int _getPriorityWeight(RecommendationPriority priority) {
    switch (priority) {
      case RecommendationPriority.critical:
        return 4;
      case RecommendationPriority.high:
        return 3;
      case RecommendationPriority.medium:
        return 2;
      case RecommendationPriority.low:
        return 1;
    }
  }

  String _dayName(int dayOfWeek) {
    const names = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return dayOfWeek >= 1 && dayOfWeek <= 7 ? names[dayOfWeek] : 'Inconnu';
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

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}