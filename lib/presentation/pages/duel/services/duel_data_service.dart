import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import '../../../../data/providers/prioritization_providers.dart';
import '../../lists/controllers/lists_controller.dart';
import '../../../../infrastructure/services/logger_service.dart';

/// Service spécialisé pour la gestion des données du duel - SOLID COMPLIANT
///
/// SOLID COMPLIANCE:
/// - SRP: Responsabilité unique de chargement et préparation des données
/// - OCP: Extensible via strategies de chargement de données
/// - LSP: Compatible avec les interfaces de données
/// - ISP: Interface focalisée sur les opérations de données uniquement
/// - DIP: Dépend des abstractions (providers, repositories)
///
/// Features:
/// - Chargement unifié des tâches et list items
/// - Combinaison intelligente des sources de données
/// - Filtrage et limitation pour performances
/// - Gestion d'erreurs centralisée
/// - Logging intégré pour debugging
///
/// CONSTRAINTS: <200 lignes
class DuelDataService {
  final Ref _ref;

  DuelDataService(this._ref);

  /// Charge toutes les tâches disponibles pour la priorisation
  Future<List<Task>> loadAllAvailableTasks() async {
    LoggerService.instance.info(
      'Début du chargement des tâches disponibles',
      context: 'DuelDataService',
    );

    try {
      // SOLID SRP: Chargement des tâches classiques
      final allTasks = await _loadClassicTasks();
      LoggerService.instance.debug(
        'Tasks classiques chargées: ${allTasks.length}',
        context: 'DuelDataService',
      );

      // SOLID SRP: Combinaison avec les list items convertis
      final combinedTasks = await _combineTasksAndListItems(allTasks);
      LoggerService.instance.info(
        'Total tâches après combinaison: ${combinedTasks.length}',
        context: 'DuelDataService',
      );

      return combinedTasks;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors du chargement des tâches: $e',
        context: 'DuelDataService',
        error: e,
      );
      rethrow;
    }
  }

  /// Prépare les tâches pour le duel (filtrage et optimisation)
  List<Task> prepareTasksForDuel(List<Task> allTasks) {
    LoggerService.instance.debug(
      'Préparation de ${allTasks.length} tâches pour le duel',
      context: 'DuelDataService',
    );

    // SOLID SRP: Filtrage des tâches incomplètes uniquement
    final incompleteTasks = _filterIncompleteTasks(allTasks);

    // SOLID SRP: Limitation pour performances
    final optimizedTasks = _limitTasksForPerformance(incompleteTasks);

    LoggerService.instance.info(
      'Tâches préparées: ${allTasks.length} → ${optimizedTasks.length}',
      context: 'DuelDataService',
    );

    return optimizedTasks;
  }

  /// Crée une paire de tâches pour le duel
  List<Task>? createDuelPair(List<Task> availableTasks) {
    if (availableTasks.length < 2) {
      LoggerService.instance.warning(
        'Pas assez de tâches pour créer un duel: ${availableTasks.length}',
        context: 'DuelDataService',
      );
      return null;
    }

    // SOLID SRP: Sélection aléatoire simple et efficace
    availableTasks.shuffle();
    final duelPair = availableTasks.take(2).toList();

    LoggerService.instance.debug(
      'Duel créé: "${duelPair[0].title}" vs "${duelPair[1].title}"',
      context: 'DuelDataService',
    );

    return duelPair;
  }

  /// Vérifie si les données des listes sont disponibles
  Future<bool> ensureListsDataAvailable() async {
    try {
      final listsState = _ref.read(listsControllerProvider);

      if (listsState.lists.isEmpty && !listsState.isLoading) {
        LoggerService.instance.info(
          'Chargement explicite des listes requis',
          context: 'DuelDataService',
        );

        await _ref.read(listsControllerProvider.notifier).loadLists();

        // Délai de propagation d'état
        await Future.delayed(const Duration(milliseconds: 100));

        final updatedState = _ref.read(listsControllerProvider);
        LoggerService.instance.debug(
          'Listes chargées: ${updatedState.lists.length}',
          context: 'DuelDataService',
        );
      }

      return _ref.read(listsControllerProvider).lists.isNotEmpty;
    } catch (e) {
      LoggerService.instance.error(
        'Erreur lors du chargement des listes: $e',
        context: 'DuelDataService',
        error: e,
      );
      return false;
    }
  }

  /// Sélectionne une tâche aléatoire de la liste disponible
  Task? selectRandomTask(List<Task> availableTasks) {
    if (availableTasks.isEmpty) {
      LoggerService.instance.warning(
        'Aucune tâche disponible pour sélection aléatoire',
        context: 'DuelDataService',
      );
      return null;
    }

    // SOLID SRP: Sélection aléatoire basée sur le temps
    final random = DateTime.now().millisecondsSinceEpoch;
    final selectedIndex = random % availableTasks.length;
    final selectedTask = availableTasks[selectedIndex];

    LoggerService.instance.info(
      'Tâche sélectionnée aléatoirement: "${selectedTask.title}"',
      context: 'DuelDataService',
    );

    return selectedTask;
  }

  // === PRIVATE HELPER METHODS ===

  /// Charge les tâches classiques depuis le service unifié
  Future<List<Task>> _loadClassicTasks() async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    return await unifiedService.getTasksForPrioritization();
  }

  /// Combine les tâches classiques avec les list items convertis
  Future<List<Task>> _combineTasksAndListItems(List<Task> classicTasks) async {
    final listsState = _ref.read(listsControllerProvider);

    if (listsState.lists.isEmpty) {
      return classicTasks;
    }

    // Extraire tous les items des listes
    final allListItems = listsState.lists
        .expand((list) => list.items)
        .toList();

    LoggerService.instance.debug(
      'Items de listes trouvés: ${allListItems.length}',
      context: 'DuelDataService',
    );

    // Convertir en tâches via le service unifié
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    final listItemTasks = unifiedService.getListItemsAsTasks(allListItems);

    return [...classicTasks, ...listItemTasks];
  }

  /// Filtre les tâches incomplètes
  List<Task> _filterIncompleteTasks(List<Task> allTasks) {
    return allTasks.where((task) => !task.isCompleted).toList();
  }

  /// Limite le nombre de tâches pour optimiser les performances
  List<Task> _limitTasksForPerformance(List<Task> tasks) {
    const maxTasksForPrioritization = 50;

    if (tasks.length <= maxTasksForPrioritization) {
      return tasks;
    }

    LoggerService.instance.warning(
      'Limitation à $maxTasksForPrioritization tâches pour performances',
      context: 'DuelDataService',
    );

    return tasks.take(maxTasksForPrioritization).toList();
  }
}