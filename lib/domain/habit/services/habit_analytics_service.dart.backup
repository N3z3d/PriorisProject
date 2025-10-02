import 'dart:math' as math;
import '../../core/services/domain_service.dart';
import '../aggregates/habit_aggregate.dart';

/// Service du domaine pour l'analyse des habitudes
/// 
/// Ce service fournit des analyses avancées des patterns d'habitudes,
/// des prédictions de succès et des recommandations d'amélioration.
class HabitAnalyticsService extends LoggableDomainService {
  
  @override
  String get serviceName => 'HabitAnalyticsService';

  /// Analyse la consistance d'une habitude sur une période
  ConsistencyAnalysis analyzeConsistency(
    HabitAggregate habit, {
    int days = 30,
  }) {
    return executeOperation(() {
      log('Analyse de consistance pour ${habit.name} sur $days jours');
      
      final now = DateTime.now();
      final completions = <DateTime>[];
      final gaps = <Duration>[];
      
      DateTime? lastCompletion;
      
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = _getDateKey(date);
        final value = habit.completions[dateKey];
        
        bool wasCompleted = false;
        if (habit.type == HabitType.binary && value == true) {
          wasCompleted = true;
        } else if (habit.type == HabitType.quantitative && 
                   value != null && 
                   habit.targetValue != null && 
                   (value as double) >= habit.targetValue!) {
          wasCompleted = true;
        }
        
        if (wasCompleted) {
          completions.add(date);
          if (lastCompletion != null) {
            gaps.add(lastCompletion.difference(date));
          }
          lastCompletion = date;
        }
      }
      
      // Calculer les métriques de consistance
      final completionRate = completions.length / days;
      final averageGap = gaps.isEmpty 
        ? Duration.zero 
        : Duration(
            milliseconds: gaps
              .map((gap) => gap.inMilliseconds)
              .reduce((a, b) => a + b) ~/ gaps.length
          );
      
      final maxGap = gaps.isEmpty 
        ? Duration.zero
        : gaps.reduce((a, b) => a.inMilliseconds > b.inMilliseconds ? a : b);
      
      // Calculer la variabilité (écart-type des intervalles)
      double variability = 0;
      if (gaps.length > 1) {
        final avgGapMillis = averageGap.inMilliseconds;
        final variance = gaps
          .map((gap) => math.pow(gap.inMilliseconds - avgGapMillis, 2))
          .reduce((a, b) => a + b) / gaps.length;
        variability = math.sqrt(variance);
      }
      
      final analysis = ConsistencyAnalysis(
        completionRate: completionRate,
        totalCompletions: completions.length,
        totalDays: days,
        averageGapDays: averageGap.inDays.toDouble(),
        maxGapDays: maxGap.inDays.toDouble(),
        variabilityScore: variability / Duration.millisecondsPerDay,
        currentStreak: habit.getCurrentStreak(),
        consistency: _calculateConsistencyScore(completionRate, variability),
      );
      
      log('Analyse terminée - Taux: ${(completionRate * 100).toStringAsFixed(1)}%, Consistance: ${analysis.consistency.label}');
      
      return analysis;
    });
  }

  /// Prédit la probabilité de succès pour les prochains jours
  SuccessPrediction predictSuccess(
    HabitAggregate habit, {
    int predictionDays = 7,
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      log('Prédiction de succès pour ${habit.name} sur $predictionDays jours');
      
      final consistency = analyzeConsistency(habit, days: analysisWindow);
      final patterns = analyzePatterns(habit, days: analysisWindow);
      
      // Facteurs influençant la prédiction
      final consistencyFactor = consistency.completionRate;
      final streakFactor = math.min(habit.getCurrentStreak() / 21, 1.0); // Plafond à 21 jours
      final patternFactor = _calculatePatternStrength(patterns);
      final decayFactor = _calculateDecayFactor(habit, analysisWindow);
      
      // Calcul de la probabilité composite
      final baseProbability = (consistencyFactor * 0.4) + 
                             (streakFactor * 0.3) + 
                             (patternFactor * 0.2) + 
                             (decayFactor * 0.1);
      
      // Ajustements contextuels
      final adjustedProbability = _applyContextualAdjustments(
        baseProbability, 
        habit, 
        consistency
      );
      
      final predictions = <DayPrediction>[];
      
      for (int i = 1; i <= predictionDays; i++) {
        final date = DateTime.now().add(Duration(days: i));
        final dayProbability = _calculateDayProbability(
          adjustedProbability, 
          i, 
          date, 
          patterns
        );
        
        predictions.add(DayPrediction(
          date: date,
          probability: dayProbability,
          confidence: _calculateConfidence(consistency, patterns),
          factors: _identifyKeyFactors(dayProbability, consistency, patterns),
        ));
      }
      
      final prediction = SuccessPrediction(
        habit: habit,
        predictions: predictions,
        overallProbability: adjustedProbability,
        confidenceLevel: _calculateOverallConfidence(predictions),
        keyFactors: _identifyMainFactors(consistency, patterns),
        recommendations: _generateRecommendations(habit, consistency, patterns),
      );
      
      log('Prédiction générée - Probabilité globale: ${(adjustedProbability * 100).toStringAsFixed(1)}%');
      
      return prediction;
    });
  }

  /// Analyse les patterns temporels d'une habitude
  PatternAnalysis analyzePatterns(
    HabitAggregate habit, {
    int days = 60,
  }) {
    return executeOperation(() {
      log('Analyse des patterns pour ${habit.name} sur $days jours');
      
      final completionsByDay = <int, int>{}; // Jour de la semaine -> nombre de complétions
      // final completionsByHour = <int, int>{}; // Heure -> nombre de complétions (si disponible) // TODO: Implémenter l'analyse par heure
      final weeklyTrends = <int, double>{}; // Semaine -> taux de complétion
      
      final now = DateTime.now();
      
      for (int i = 0; i < days; i++) {
        final date = now.subtract(Duration(days: i));
        final dateKey = _getDateKey(date);
        final value = habit.completions[dateKey];
        
        bool wasCompleted = false;
        if (habit.type == HabitType.binary && value == true) {
          wasCompleted = true;
        } else if (habit.type == HabitType.quantitative && 
                   value != null && 
                   habit.targetValue != null && 
                   (value as double) >= habit.targetValue!) {
          wasCompleted = true;
        }
        
        if (wasCompleted) {
          // Pattern par jour de la semaine (1 = lundi, 7 = dimanche)
          final dayOfWeek = date.weekday;
          completionsByDay[dayOfWeek] = (completionsByDay[dayOfWeek] ?? 0) + 1;
        }
        
        // Trend hebdomadaire
        final weekNumber = (i ~/ 7);
        if (!weeklyTrends.containsKey(weekNumber)) {
          weeklyTrends[weekNumber] = 0;
        }
        if (wasCompleted) {
          weeklyTrends[weekNumber] = weeklyTrends[weekNumber]! + (1.0 / 7);
        }
      }
      
      // Identifier les jours favorables et défavorables
      final totalCompletions = completionsByDay.values.fold<int>(0, (a, b) => a + b);
      final bestDays = <int>[];
      final worstDays = <int>[];
      
      if (totalCompletions > 0) {
        final sortedDays = completionsByDay.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        
        if (sortedDays.isNotEmpty) {
          bestDays.add(sortedDays.first.key);
          worstDays.add(sortedDays.last.key);
        }
      }
      
      // Calculer la tendance générale
      final trend = _calculateTrend(weeklyTrends);
      
      final analysis = PatternAnalysis(
        completionsByDayOfWeek: completionsByDay,
        weeklyTrends: weeklyTrends,
        bestDays: bestDays,
        worstDays: worstDays,
        trend: trend,
        seasonality: _detectSeasonality(weeklyTrends),
        predictability: _calculatePredictability(completionsByDay, weeklyTrends),
      );
      
      log('Patterns analysés - Meilleurs jours: ${bestDays.map((d) => _dayName(d)).join(", ")}');
      
      return analysis;
    });
  }

  /// Génère des recommandations personnalisées pour améliorer l'habitude
  List<HabitRecommendation> generateRecommendations(
    HabitAggregate habit, {
    int analysisWindow = 30,
  }) {
    return executeOperation(() {
      log('Génération de recommandations pour ${habit.name}');
      
      final consistency = analyzeConsistency(habit, days: analysisWindow);
      final patterns = analyzePatterns(habit, days: analysisWindow * 2);
      // final prediction = predictSuccess(habit, predictionDays: 7, analysisWindow: analysisWindow); // TODO: Utiliser la prédiction
      
      final recommendations = <HabitRecommendation>[];
      
      // Recommandations basées sur la consistance
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
      
      // Recommandations basées sur les patterns
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
      
      // Recommandations basées sur la tendance
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
      
      // Recommandations basées sur le streak
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
      
      // Recommandations spécifiques aux habitudes quantitatives
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
      
      log('${recommendations.length} recommandations générées');
      
      return recommendations;
    });
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  ConsistencyLevel _calculateConsistencyScore(double completionRate, double variability) {
    if (completionRate >= 0.9 && variability < 1.5) return ConsistencyLevel.excellent;
    if (completionRate >= 0.8 && variability < 2.0) return ConsistencyLevel.good;
    if (completionRate >= 0.6) return ConsistencyLevel.fair;
    if (completionRate >= 0.3) return ConsistencyLevel.poor;
    return ConsistencyLevel.veryPoor;
  }

  double _calculatePatternStrength(PatternAnalysis patterns) {
    return math.min(patterns.predictability, 1.0);
  }

  double _calculateDecayFactor(HabitAggregate habit, int days) {
    final age = DateTime.now().difference(habit.createdAt).inDays;
    if (age < 7) return 0.7; // Nouvelles habitudes sont moins fiables
    if (age < 30) return 0.85;
    return 1.0; // Habitudes établies
  }

  double _applyContextualAdjustments(double baseProbability, HabitAggregate habit, ConsistencyAnalysis consistency) {
    double adjusted = baseProbability;
    
    // Ajustement basé sur la récence des échecs
    if (consistency.currentStreak == 0) {
      adjusted *= 0.8; // Réduction si pas de streak actuel
    }
    
    // Ajustement basé sur le type d'habitude
    if (habit.type == HabitType.quantitative) {
      adjusted *= 0.95; // Les habitudes quantitatives sont légèrement plus difficiles
    }
    
    return math.max(0, math.min(1, adjusted));
  }

  double _calculateDayProbability(double baseProbability, int dayOffset, DateTime date, PatternAnalysis patterns) {
    double dayProbability = baseProbability;
    
    // Ajustement basé sur le jour de la semaine
    final dayOfWeek = date.weekday;
    final totalCompletions = patterns.completionsByDayOfWeek.values.fold<int>(0, (a, b) => a + b);
    
    if (totalCompletions > 0) {
      final dayCompletions = patterns.completionsByDayOfWeek[dayOfWeek] ?? 0;
      final dayFactor = (dayCompletions / (totalCompletions / 7)) / 7; // Normaliser
      dayProbability *= (0.7 + dayFactor * 0.6); // Influence modérée
    }
    
    // Dégradation avec la distance temporelle
    dayProbability *= math.pow(0.95, dayOffset - 1);
    
    return math.max(0, math.min(1, dayProbability));
  }

  double _calculateConfidence(ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final dataPoints = consistency.totalCompletions;
    final consistencyFactor = consistency.completionRate > 0.1 ? 1.0 : 0.5;
    final patternStrength = patterns.predictability;
    
    return math.min(1.0, (dataPoints / 30) * consistencyFactor * patternStrength);
  }

  List<String> _identifyKeyFactors(double probability, ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final factors = <String>[];
    
    if (consistency.currentStreak > 5) {
      factors.add('Série actuelle forte (${consistency.currentStreak} jours)');
    }
    
    if (consistency.completionRate > 0.8) {
      factors.add('Excellente consistance historique');
    }
    
    if (patterns.trend == TrendDirection.improving) {
      factors.add('Tendance positive récente');
    }
    
    return factors;
  }

  double _calculateOverallConfidence(List<DayPrediction> predictions) {
    if (predictions.isEmpty) return 0.0;
    return predictions.map((p) => p.confidence).reduce((a, b) => a + b) / predictions.length;
  }

  List<String> _identifyMainFactors(ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    final factors = <String>[];
    
    factors.add('Taux de complétion: ${(consistency.completionRate * 100).toStringAsFixed(0)}%');
    factors.add('Consistance: ${consistency.consistency.label}');
    factors.add('Tendance: ${patterns.trend.label}');
    
    return factors;
  }

  List<HabitRecommendation> _generateRecommendations(HabitAggregate habit, ConsistencyAnalysis consistency, PatternAnalysis patterns) {
    // Cette méthode est un wrapper pour generateRecommendations
    // Elle pourrait être utilisée pour des recommandations rapides
    return [];
  }

  TrendDirection _calculateTrend(Map<int, double> weeklyTrends) {
    if (weeklyTrends.length < 2) return TrendDirection.stable;
    
    final weeks = weeklyTrends.keys.toList()..sort();
    final recent = weeks.take(weeks.length ~/ 2).map((w) => weeklyTrends[w]!).toList();
    final older = weeks.skip(weeks.length ~/ 2).map((w) => weeklyTrends[w]!).toList();
    
    if (recent.isEmpty || older.isEmpty) return TrendDirection.stable;
    
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    
    final difference = recentAvg - olderAvg;
    
    if (difference > 0.1) return TrendDirection.improving;
    if (difference < -0.1) return TrendDirection.declining;
    return TrendDirection.stable;
  }

  double _detectSeasonality(Map<int, double> weeklyTrends) {
    // Implémentation simple pour détecter les patterns saisonniers
    if (weeklyTrends.length < 4) return 0.0;
    
    // Pour le moment, retourne une valeur basique
    // Une implémentation plus sophistiquée utiliserait l'analyse de Fourier
    return 0.3;
  }

  double _calculatePredictability(Map<int, int> dayPatterns, Map<int, double> weeklyTrends) {
    // Calculer la prévisibilité basée sur la variance des patterns
    if (dayPatterns.isEmpty) return 0.0;
    
    final values = dayPatterns.values.toList();
    if (values.length < 2) return 0.0;
    
    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => math.pow(v - avg, 2)).reduce((a, b) => a + b) / values.length;
    
    // Convertir la variance en score de prévisibilité (inverse)
    return math.max(0.0, 1.0 - (variance / (avg + 1)));
  }

  String _dayName(int dayOfWeek) {
    const names = ['', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return names[dayOfWeek];
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
}

// Modèles de données pour l'analyse

class ConsistencyAnalysis {
  final double completionRate;
  final int totalCompletions;
  final int totalDays;
  final double averageGapDays;
  final double maxGapDays;
  final double variabilityScore;
  final int currentStreak;
  final ConsistencyLevel consistency;

  const ConsistencyAnalysis({
    required this.completionRate,
    required this.totalCompletions,
    required this.totalDays,
    required this.averageGapDays,
    required this.maxGapDays,
    required this.variabilityScore,
    required this.currentStreak,
    required this.consistency,
  });
}

enum ConsistencyLevel {
  excellent('Excellent'),
  good('Bon'),
  fair('Moyen'),
  poor('Faible'),
  veryPoor('Très faible');

  const ConsistencyLevel(this.label);
  final String label;
}

class SuccessPrediction {
  final HabitAggregate habit;
  final List<DayPrediction> predictions;
  final double overallProbability;
  final double confidenceLevel;
  final List<String> keyFactors;
  final List<HabitRecommendation> recommendations;

  const SuccessPrediction({
    required this.habit,
    required this.predictions,
    required this.overallProbability,
    required this.confidenceLevel,
    required this.keyFactors,
    required this.recommendations,
  });
}

class DayPrediction {
  final DateTime date;
  final double probability;
  final double confidence;
  final List<String> factors;

  const DayPrediction({
    required this.date,
    required this.probability,
    required this.confidence,
    required this.factors,
  });
}

class PatternAnalysis {
  final Map<int, int> completionsByDayOfWeek;
  final Map<int, double> weeklyTrends;
  final List<int> bestDays;
  final List<int> worstDays;
  final TrendDirection trend;
  final double seasonality;
  final double predictability;

  const PatternAnalysis({
    required this.completionsByDayOfWeek,
    required this.weeklyTrends,
    required this.bestDays,
    required this.worstDays,
    required this.trend,
    required this.seasonality,
    required this.predictability,
  });
}

enum TrendDirection {
  improving('En amélioration'),
  declining('En déclin'),
  stable('Stable');

  const TrendDirection(this.label);
  final String label;
}

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