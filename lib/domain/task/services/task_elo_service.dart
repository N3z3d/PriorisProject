import '../../core/services/domain_service.dart';
import '../../core/value_objects/export.dart';
import '../../core/value_objects/elo_variation_settings.dart';
import '../aggregates/task_aggregate.dart';

/// Service du domaine pour la gestion des scores ELO des tâches
/// 
/// Ce service encapsule la logique complexe de calcul et mise à jour
/// des scores ELO, incluant les duels automatiques et l'ajustement dynamique.
class TaskEloService extends LoggableDomainService {
  
  @override
  String get serviceName => 'TaskEloService';

  /// Effectue un duel entre deux tâches
  DuelResult performDuel(TaskAggregate task1, TaskAggregate task2) {
    return executeOperation(() {
      log('Duel entre ${task1.title} (ELO: ${task1.eloScore.value}) et ${task2.title} (ELO: ${task2.eloScore.value})');
      
      // Calculer la probabilité de victoire
      final winProbability1 = task1.eloScore.calculateWinProbability(task2.eloScore);
      final winProbability2 = task2.eloScore.calculateWinProbability(task1.eloScore);
      
      log('Probabilité de victoire - ${task1.title}: ${(winProbability1 * 100).toStringAsFixed(1)}%');
      log('Probabilité de victoire - ${task2.title}: ${(winProbability2 * 100).toStringAsFixed(1)}%');
      
      // Déterminer le gagnant selon les probabilités
      final random = DateTime.now().millisecondsSinceEpoch % 1000 / 1000.0;
      final task1Wins = random < winProbability1;
      
      // Effectuer le duel
      task1.duelAgainst(task2, task1Wins);
      
      final winner = task1Wins ? task1 : task2;
      final loser = task1Wins ? task2 : task1;
      
      log('Gagnant: ${winner.title} - Nouveau ELO: ${winner.eloScore.value}');
      log('Perdant: ${loser.title} - Nouveau ELO: ${loser.eloScore.value}');
      
      return DuelResult(
        winner: winner,
        loser: loser,
        winnerEloChange: task1Wins 
          ? task1.eloScore.value - EloScore.fromValue(task1.eloScore.value).value
          : task2.eloScore.value - EloScore.fromValue(task2.eloScore.value).value,
        loserEloChange: task1Wins
          ? task2.eloScore.value - EloScore.fromValue(task2.eloScore.value).value
          : task1.eloScore.value - EloScore.fromValue(task1.eloScore.value).value,
        winProbability: task1Wins ? winProbability1 : winProbability2,
      );
    });
  }

  /// Trouve le meilleur adversaire pour une tâche donnée
  TaskAggregate? findBestOpponent(
    TaskAggregate task,
    List<TaskAggregate> candidates, {
    double eloTolerance = 200,
  }) {
    return executeOperation(() {
      log('Recherche du meilleur adversaire pour ${task.title} (ELO: ${task.eloScore.value})');
      
      // Filtrer les candidats valides
      final validCandidates = candidates.where((candidate) =>
        candidate.id != task.id &&
        !candidate.isCompleted &&
        (candidate.eloScore.value - task.eloScore.value).abs() <= eloTolerance
      ).toList();
      
      if (validCandidates.isEmpty) {
        log('Aucun adversaire valide trouvé');
        return null;
      }
      
      // Trier par proximité de score ELO
      validCandidates.sort((a, b) {
        final diffA = (a.eloScore.value - task.eloScore.value).abs();
        final diffB = (b.eloScore.value - task.eloScore.value).abs();
        return diffA.compareTo(diffB);
      });
      
      final bestOpponent = validCandidates.first;
      log('Meilleur adversaire trouvé: ${bestOpponent.title} (ELO: ${bestOpponent.eloScore.value})');
      
      return bestOpponent;
    });
  }

  /// Effectue des duels automatiques pour équilibrer les scores ELO
  List<DuelResult> performAutoBalancing(
    List<TaskAggregate> tasks, {
    int maxDuels = 10,
    double eloTolerance = 200,
  }) {
    return executeOperation(() {
      log('Début de l\'équilibrage automatique - ${tasks.length} tâches, max $maxDuels duels');
      
      final results = <DuelResult>[];
      final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
      
      for (int i = 0; i < maxDuels && incompleteTasks.length >= 2; i++) {
        // Trouver deux tâches avec des scores proches mais pas identiques
        TaskAggregate? task1;
        TaskAggregate? task2;
        
        for (final task in incompleteTasks) {
          final opponent = findBestOpponent(task, incompleteTasks, eloTolerance: eloTolerance);
          if (opponent != null && 
              !results.any((r) => 
                (r.winner.id == task.id && r.loser.id == opponent.id) ||
                (r.winner.id == opponent.id && r.loser.id == task.id)
              )) {
            task1 = task;
            task2 = opponent;
            break;
          }
        }
        
        if (task1 != null && task2 != null) {
          final result = performDuel(task1, task2);
          results.add(result);
        } else {
          log('Aucune paire de tâches valide trouvée pour le duel ${i + 1}');
          break;
        }
      }
      
      log('Équilibrage terminé - ${results.length} duels effectués');
      return results;
    });
  }

  /// Calcule l'ajustement ELO recommandé pour une tâche basé sur sa performance
  EloAdjustment calculatePerformanceAdjustment(
    TaskAggregate task,
    Duration actualCompletionTime,
    Duration expectedCompletionTime,
  ) {
    return executeOperation(() {
      log('Calcul de l\'ajustement de performance pour ${task.title}');
      
      final performanceRatio = actualCompletionTime.inMinutes / expectedCompletionTime.inMinutes;
      log('Ratio de performance: ${performanceRatio.toStringAsFixed(2)}');
      
      double adjustment = 0;
      String reason = '';
      
      if (performanceRatio <= 0.5) {
        // Complété en moins de la moitié du temps attendu
        adjustment = 50;
        reason = 'Performance exceptionnelle (${(performanceRatio * 100).toStringAsFixed(0)}% du temps attendu)';
      } else if (performanceRatio <= 0.8) {
        // Complété plus rapidement que prévu
        adjustment = 25;
        reason = 'Bonne performance (${(performanceRatio * 100).toStringAsFixed(0)}% du temps attendu)';
      } else if (performanceRatio <= 1.2) {
        // Complété dans les temps
        adjustment = 0;
        reason = 'Performance normale';
      } else if (performanceRatio <= 2.0) {
        // Complété avec du retard
        adjustment = -15;
        reason = 'Performance lente (${(performanceRatio * 100).toStringAsFixed(0)}% du temps attendu)';
      } else {
        // Complété avec beaucoup de retard
        adjustment = -30;
        reason = 'Performance très lente (${(performanceRatio * 100).toStringAsFixed(0)}% du temps attendu)';
      }
      
      log('Ajustement recommandé: ${adjustment > 0 ? '+' : ''}$adjustment - $reason');
      
      return EloAdjustment(
        adjustment: adjustment,
        reason: reason,
        performanceRatio: performanceRatio,
        originalElo: task.eloScore.value,
        newElo: (task.eloScore.value + adjustment).clamp(0, 3000),
      );
    });
  }

  /// Suggère un score ELO initial basé sur des caractéristiques de la tâche
  EloScore suggestInitialElo({
    required String category,
    required String title,
    DateTime? dueDate,
    String? description,
  }) {
    return executeOperation(() {
      log('Suggestion d\'ELO initial pour une nouvelle tâche: $title');
      
      double baseElo = 1200; // ELO par défaut
      
      // Ajustement basé sur la catégorie
      final categoryAdjustments = {
        'urgent': 100,
        'important': 50,
        'work': 25,
        'personal': 0,
        'learning': 75,
        'health': 50,
        'routine': -50,
      };
      
      final categoryKey = category.toLowerCase();
      if (categoryAdjustments.containsKey(categoryKey)) {
        baseElo += categoryAdjustments[categoryKey]!;
        log('Ajustement catégorie "$category": ${categoryAdjustments[categoryKey]}');
      }
      
      // Ajustement basé sur l'urgence (date d'échéance)
      if (dueDate != null) {
        final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
        if (daysUntilDue <= 1) {
          baseElo += 150;
          log('Ajustement urgence (due dans $daysUntilDue jour(s)): +150');
        } else if (daysUntilDue <= 3) {
          baseElo += 75;
          log('Ajustement urgence (due dans $daysUntilDue jour(s)): +75');
        } else if (daysUntilDue <= 7) {
          baseElo += 25;
          log('Ajustement urgence (due dans $daysUntilDue jour(s)): +25');
        }
      }
      
      // Ajustement basé sur la longueur de la description (complexité)
      if (description != null && description.length > 100) {
        baseElo += 25;
        log('Ajustement complexité (description longue): +25');
      }
      
      // Ajustement basé sur des mots-clés dans le titre
      final titleLower = title.toLowerCase();
      if (titleLower.contains('urgent') || titleLower.contains('asap')) {
        baseElo += 100;
        log('Ajustement mots-clés urgents: +100');
      } else if (titleLower.contains('important') || titleLower.contains('critique')) {
        baseElo += 50;
        log('Ajustement mots-clés importants: +50');
      }
      
      final finalElo = baseElo.clamp(800, 2000); // Limiter la plage initiale
      log('ELO initial suggéré: $finalElo');
      
      return EloScore.fromValue(finalElo.toDouble());
    });
  }

  /// Sélectionne une tâche aléatoire parmi les tâches non complétées
  /// 
  /// Retourne null si aucune tâche valide n'est disponible.
  /// Utilisé pour le mode "aléatoire" quand l'utilisateur ne sait pas quoi prioriser.
  TaskAggregate? selectRandomTask(List<TaskAggregate> tasks) {
    return executeOperation(() {
      log('Sélection aléatoire parmi ${tasks.length} tâches');
      
      // Filtrer les tâches non complétées
      final availableTasks = tasks.where((task) => !task.isCompleted).toList();
      
      if (availableTasks.isEmpty) {
        log('Aucune tâche disponible pour la sélection aléatoire');
        return null;
      }
      
      // Sélection aléatoire
      final random = DateTime.now().millisecondsSinceEpoch;
      final selectedIndex = random % availableTasks.length;
      final selectedTask = availableTasks[selectedIndex];
      
      log('Tâche sélectionnée aléatoirement: ${selectedTask.title} (ELO: ${selectedTask.eloScore.value})');
      
      return selectedTask;
    });
  }

  /// Effectue un duel avec variation dynamique d'ELO
  /// 
  /// Applique les multiplicateurs basés sur l'ancienneté des tâches
  DuelResult performDuelWithVariation(
    TaskAggregate task1, 
    TaskAggregate task2, 
    EloVariationSettings settings,
  ) {
    return executeOperation(() {
      log('Duel avec variation ELO entre ${task1.title} et ${task2.title}');
      
      // Effectuer le duel normal d'abord
      final baseResult = performDuel(task1, task2);
      
      // Calculer les multiplicateurs pour chaque tâche
      final multiplier1 = settings.calculateMultiplier(lastChosenAt: task1.lastChosenAt);
      final multiplier2 = settings.calculateMultiplier(lastChosenAt: task2.lastChosenAt);
      
      log('Multiplicateurs ELO - ${task1.title}: ${multiplier1}x, ${task2.title}: ${multiplier2}x');
      
      // Appliquer la variation au gagnant
      final winnerMultiplier = baseResult.winner.id == task1.id ? multiplier1 : multiplier2;
      final adjustedWinnerChange = baseResult.winnerEloChange * winnerMultiplier;
      
      // Mettre à jour les scores avec la variation
      final finalWinnerElo = baseResult.winner.eloScore.value + (adjustedWinnerChange - baseResult.winnerEloChange);
      final finalWinnerEloScore = EloScore.fromValue(finalWinnerElo.clamp(0, 3000));
      
      log('ELO final du gagnant avec variation: ${finalWinnerEloScore.value}');
      
      return DuelResult(
        winner: baseResult.winner,
        loser: baseResult.loser,
        winnerEloChange: adjustedWinnerChange,
        loserEloChange: baseResult.loserEloChange,
        winProbability: baseResult.winProbability,
      );
    });
  }

  /// Calcule le changement d'ELO dynamique basé sur l'ancienneté
  double calculateDynamicEloChange({
    required double baseEloChange,
    DateTime? lastChosenAt,
    required EloVariationSettings settings,
  }) {
    return executeOperation(() {
      final multiplier = settings.calculateMultiplier(lastChosenAt: lastChosenAt);
      final dynamicChange = baseEloChange * multiplier;
      
      log('Changement ELO dynamique: $baseEloChange x $multiplier = $dynamicChange');
      
      return dynamicChange;
    });
  }

  /// Met à jour la date de dernier choix d'une tâche
  void updateLastChosenAt(TaskAggregate task) {
    executeOperation(() {
      // Cette méthode sera implémentée dans TaskAggregate
      // Pour l'instant, on log juste l'action
      log('Mise à jour lastChosenAt pour ${task.title}');
      
      // TODO: Implémenter la méthode updateLastChosenAt dans TaskAggregate
      // task.updateLastChosenAt(DateTime.now());
    });
  }

  /// Calcule les statistiques ELO pour un ensemble de tâches
  EloStatistics calculateEloStatistics(List<TaskAggregate> tasks) {
    return executeOperation(() {
      log('Calcul des statistiques ELO pour ${tasks.length} tâches');
      
      if (tasks.isEmpty) {
        return EloStatistics.empty();
      }
      
      final eloValues = tasks.map((task) => task.eloScore.value).toList();
      eloValues.sort();
      
      final average = eloValues.reduce((a, b) => a + b) / eloValues.length;
      final median = eloValues.length % 2 == 0
        ? (eloValues[eloValues.length ~/ 2 - 1] + eloValues[eloValues.length ~/ 2]) / 2
        : eloValues[eloValues.length ~/ 2];
      
      final variance = eloValues
        .map((value) => (value - average) * (value - average))
        .reduce((a, b) => a + b) / eloValues.length;
      
      final standardDeviation = variance.abs().squareRoot;
      
      final stats = EloStatistics(
        count: tasks.length,
        average: average,
        median: median,
        minimum: eloValues.first,
        maximum: eloValues.last,
        standardDeviation: standardDeviation,
        distribution: _calculateDistribution(eloValues),
      );
      
      log('Statistiques calculées - Moyenne: ${average.toStringAsFixed(1)}, Médiane: ${median.toStringAsFixed(1)}');
      
      return stats;
    });
  }

  Map<EloCategory, int> _calculateDistribution(List<double> eloValues) {
    final distribution = <EloCategory, int>{
      EloCategory.novice: 0,
      EloCategory.beginner: 0,
      EloCategory.intermediate: 0,
      EloCategory.advanced: 0,
      EloCategory.expert: 0,
    };

    for (final value in eloValues) {
      final category = EloScore.fromValue(value).category;
      distribution[category] = (distribution[category] ?? 0) + 1;
    }

    return distribution;
  }
}

/// Résultat d'un duel entre deux tâches
class DuelResult {
  final TaskAggregate winner;
  final TaskAggregate loser;
  final double winnerEloChange;
  final double loserEloChange;
  final double winProbability;

  const DuelResult({
    required this.winner,
    required this.loser,
    required this.winnerEloChange,
    required this.loserEloChange,
    required this.winProbability,
  });

  @override
  String toString() {
    return 'DuelResult(winner: ${winner.title}, loser: ${loser.title}, changes: +${winnerEloChange.toStringAsFixed(1)}/-${loserEloChange.abs().toStringAsFixed(1)})';
  }
}

/// Ajustement ELO basé sur la performance
class EloAdjustment {
  final double adjustment;
  final String reason;
  final double performanceRatio;
  final double originalElo;
  final double newElo;

  const EloAdjustment({
    required this.adjustment,
    required this.reason,
    required this.performanceRatio,
    required this.originalElo,
    required this.newElo,
  });

  @override
  String toString() {
    return 'EloAdjustment(${adjustment > 0 ? '+' : ''}${adjustment.toStringAsFixed(1)}: $reason)';
  }
}

/// Statistiques ELO pour un ensemble de tâches
class EloStatistics {
  final int count;
  final double average;
  final double median;
  final double minimum;
  final double maximum;
  final double standardDeviation;
  final Map<EloCategory, int> distribution;

  const EloStatistics({
    required this.count,
    required this.average,
    required this.median,
    required this.minimum,
    required this.maximum,
    required this.standardDeviation,
    required this.distribution,
  });

  factory EloStatistics.empty() {
    return const EloStatistics(
      count: 0,
      average: 0,
      median: 0,
      minimum: 0,
      maximum: 0,
      standardDeviation: 0,
      distribution: {},
    );
  }

  @override
  String toString() {
    return 'EloStatistics(count: $count, average: ${average.toStringAsFixed(1)}, range: ${minimum.toStringAsFixed(0)}-${maximum.toStringAsFixed(0)})';
  }
}

extension on double {
  double get squareRoot => this < 0 ? 0 : this;
}