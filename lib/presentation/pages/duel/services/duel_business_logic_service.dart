import 'dart:math' as dart_math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../../../../data/repositories/task_repository.dart';
import '../../../../data/providers/prioritization_providers.dart';
import '../../../../infrastructure/services/logger_service.dart';

/// Service spécialisé pour la logique métier du duel - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique pour la logique de priorisation et ELO
/// - OCP: Extensible via strategies de scoring et de duel
/// - LSP: Compatible avec les interfaces de logique métier
/// - ISP: Interface focalisée sur les opérations de business logic uniquement
/// - DIP: Dépend des abstractions (repositories, services)
///
/// Features:
/// - Gestion des duels et sélection des gagnants
/// - Calculs et mises à jour des scores ELO
/// - Invalidation des caches de priorisation
/// - Logique de mise à jour des tâches
/// - Gestion transactionnelle des scores
///
/// CONSTRAINTS: <200 lignes
class DuelBusinessLogicService {
  final Ref _ref;

  DuelBusinessLogicService(this._ref);

  /// Traite la sélection d'un gagnant dans le duel
  Future<DuelResult> processWinnerSelection(Task winner, Task loser) async {
    LoggerService.instance.info(
      'Traitement duel: "${winner.title}" vs "${loser.title}"',
      context: 'DuelBusinessLogicService',
    );

    try {
      // SOLID SRP: Mise à jour des scores ELO via service spécialisé
      final duelResult = await _updateEloScores(winner, loser);

      // SOLID SRP: Invalidation des caches de priorisation
      await _invalidatePrioritizationCaches();

      LoggerService.instance.info(
        'Duel traité avec succès - Gagnant: "${duelResult.winner.title}"',
        context: 'DuelBusinessLogicService',
      );

      return duelResult;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors du traitement du duel: $e',
        context: 'DuelBusinessLogicService',
        error: e,
      );
      rethrow;
    }
  }

  /// Met à jour une tâche avec validation et persistence
  Future<bool> updateTask(Task updatedTask) async {
    LoggerService.instance.info(
      'Mise à jour tâche: "${updatedTask.title}"',
      context: 'DuelBusinessLogicService',
    );

    try {
      // SOLID DIP: Utilisation de l'abstraction repository
      final taskRepository = _ref.read(taskRepositoryProvider);
      await taskRepository.updateTask(updatedTask);

      // SOLID SRP: Invalidation des caches après modification
      await _invalidatePrioritizationCaches();

      LoggerService.instance.info(
        'Tâche mise à jour avec succès: "${updatedTask.title}"',
        context: 'DuelBusinessLogicService',
      );

      return true;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors de la mise à jour de la tâche: $e',
        context: 'DuelBusinessLogicService',
        error: e,
      );
      return false;
    }
  }

  /// Valide si un duel peut être créé avec les tâches fournies
  bool validateDuelRequirements(List<Task> tasks) {
    if (tasks.length < 2) {
      LoggerService.instance.warning(
        'Validation échouée: Pas assez de tâches (${tasks.length} < 2)',
        context: 'DuelBusinessLogicService',
      );
      return false;
    }

    // SOLID SRP: Validation des tâches incomplètes
    final incompleteTasks = tasks.where((task) => !task.isCompleted).length;
    if (incompleteTasks < 2) {
      LoggerService.instance.warning(
        'Validation échouée: Pas assez de tâches incomplètes ($incompleteTasks < 2)',
        context: 'DuelBusinessLogicService',
      );
      return false;
    }

    LoggerService.instance.debug(
      'Validation réussie: ${tasks.length} tâches, $incompleteTasks incomplètes',
      context: 'DuelBusinessLogicService',
    );

    return true;
  }

  /// Calcule le score de priorité relatif entre deux tâches
  double calculateRelativePriority(Task task1, Task task2) {
    // SOLID SRP: Calcul basé sur les scores ELO existants
    final score1 = task1.eloScore;
    final score2 = task2.eloScore;

    if (score1 == score2) return 0.5; // Égalité parfaite

    // Calcul de probabilité basé sur la différence ELO
    final difference = score1 - score2;
    final probability = 1.0 / (1.0 + dart_math.pow(10, -difference / 400));

    LoggerService.instance.debug(
      'Priorité relative calculée: ${probability.toStringAsFixed(3)}',
      context: 'DuelBusinessLogicService',
    );

    return probability.clamp(0.0, 1.0);
  }

  /// Génère des statistiques du duel pour analyse
  DuelStatistics generateDuelStatistics(Task winner, Task loser, double scoreDifference) {
    return DuelStatistics(
      winnerEloScore: winner.eloScore,
      loserEloScore: loser.eloScore,
      scoreDifference: scoreDifference,
      winnerTitle: winner.title,
      loserTitle: loser.title,
      duelDateTime: DateTime.now(),
      expectedWinProbability: calculateRelativePriority(winner, loser),
    );
  }

  // === PRIVATE HELPER METHODS ===

  /// Met à jour les scores ELO via le service unifié
  Future<DuelResult> _updateEloScores(Task winner, Task loser) async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    return await unifiedService.updateEloScoresFromDuel(winner, loser);
  }

  /// Invalide tous les caches liés à la priorisation
  Future<void> _invalidatePrioritizationCaches() async {
    // SOLID SRP: Invalidation centralisée des providers
    _ref.invalidate(tasksSortedByEloProvider);
    _ref.invalidate(allPrioritizationTasksProvider);

    LoggerService.instance.debug(
      'Caches de priorisation invalidés',
      context: 'DuelBusinessLogicService',
    );

    // Petite pause pour permettre la propagation
    await Future.delayed(const Duration(milliseconds: 50));
  }
}

/// Résultat d'un duel avec métadonnées
class DuelResult {
  final Task winner;
  final Task loser;
  final double scoreDifference;
  final DateTime processedAt;
  final DuelStatistics statistics;

  DuelResult({
    required this.winner,
    required this.loser,
    required this.scoreDifference,
    required this.processedAt,
    required this.statistics,
  });

  factory DuelResult.create(Task winner, Task loser, double scoreDifference) {
    final processedAt = DateTime.now();
    final statistics = DuelStatistics(
      winnerEloScore: winner.eloScore,
      loserEloScore: loser.eloScore,
      scoreDifference: scoreDifference,
      winnerTitle: winner.title,
      loserTitle: loser.title,
      duelDateTime: processedAt,
      expectedWinProbability: 0.5, // Valeur par défaut
    );

    return DuelResult(
      winner: winner,
      loser: loser,
      scoreDifference: scoreDifference,
      processedAt: processedAt,
      statistics: statistics,
    );
  }
}

/// Statistiques détaillées d'un duel
class DuelStatistics {
  final double winnerEloScore;
  final double loserEloScore;
  final double scoreDifference;
  final String winnerTitle;
  final String loserTitle;
  final DateTime duelDateTime;
  final double expectedWinProbability;

  DuelStatistics({
    required this.winnerEloScore,
    required this.loserEloScore,
    required this.scoreDifference,
    required this.winnerTitle,
    required this.loserTitle,
    required this.duelDateTime,
    required this.expectedWinProbability,
  });

  /// Indique si le résultat était prévisible (forte différence de scores)
  bool get wasPredictable => (winnerEloScore - loserEloScore).abs() > 200;

  /// Calcule l'impact du duel sur la hiérarchie
  String get impactLevel {
    if (scoreDifference.abs() > 30) return 'Fort';
    if (scoreDifference.abs() > 15) return 'Modéré';
    return 'Faible';
  }
}

