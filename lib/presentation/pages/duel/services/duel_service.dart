import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/repositories/task_repository.dart';

/// Service métier pour la gestion des duels de tâches
///
/// Applique SRP: Une seule responsabilité = logique de duel
/// Applique DIP: Dépend d'abstractions via Ref
class DuelService {
  final Ref _ref;
  static const int _maxTasksForPrioritization = 50;

  DuelService(this._ref);

  /// S'assure que les listes sont chargées
  Future<void> ensureListsLoaded() async {
    await _ref.read(listsControllerProvider.notifier).loadLists();
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Charge les tâches disponibles pour un duel
  Future<List<Task>> loadDuelTasks() async {
    print('🔍 DEBUG: Début chargement tâches pour duel');

    final allTasks = await _loadAllAvailableTasks();
    final preparedTasks = _prepareTasksForDuel(allTasks);

    if (preparedTasks.length >= 2) {
      preparedTasks.shuffle();
      return preparedTasks.take(2).toList();
    }

    return [];
  }

  /// Charge toutes les tâches disponibles (Tasks + ListItems convertis)
  Future<List<Task>> _loadAllAvailableTasks() async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    final classicTasks = await unifiedService.getTasksForPrioritization();

    print('🔍 DEBUG: Tasks classiques: ${classicTasks.length}');

    final combinedTasks = await _combineWithListItems(classicTasks, unifiedService);

    print('🔍 DEBUG: Total tasks: ${combinedTasks.length}');

    return combinedTasks;
  }

  /// Combine les tâches avec les ListItems convertis
  Future<List<Task>> _combineWithListItems(
    List<Task> classicTasks,
    dynamic unifiedService,
  ) async {
    final listsState = _ref.read(listsControllerProvider);

    print('🔍 DEBUG: Listes disponibles: ${listsState.lists.length}');

    if (listsState.lists.isEmpty) {
      return classicTasks;
    }

    final allListItems = listsState.lists.expand((list) => list.items).toList();

    print('🔍 DEBUG: Items de liste: ${allListItems.length}');

    final listItemTasks = unifiedService.getListItemsAsTasks(allListItems);

    print('🔍 DEBUG: Items convertis: ${listItemTasks.length}');

    return [...classicTasks, ...listItemTasks];
  }

  /// Prépare les tâches pour le duel (filtrage et limitation)
  List<Task> _prepareTasksForDuel(List<Task> allTasks) {
    final incompleteTasks = allTasks.where((task) => !task.isCompleted).toList();

    print('🔍 DEBUG: Total: ${allTasks.length}, Incomplètes: ${incompleteTasks.length}');

    return _limitTasksForPerformance(incompleteTasks);
  }

  /// Limite le nombre de tâches pour éviter la surcharge
  List<Task> _limitTasksForPerformance(List<Task> tasks) {
    if (tasks.length <= _maxTasksForPrioritization) {
      return tasks;
    }

    print('🔍 DEBUG: Limitation à $_maxTasksForPrioritization tâches');

    return tasks.take(_maxTasksForPrioritization).toList();
  }

  /// Traite le résultat d'un duel (gagnant vs perdant)
  Future<void> processWinner(Task winner, Task loser) async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    await unifiedService.updateEloScoresFromDuel(winner, loser);

    // Invalider les caches
    _ref.invalidate(tasksSortedByEloProvider);
    _ref.invalidate(allPrioritizationTasksProvider);
  }

  /// Sélectionne une tâche aléatoirement
  Task selectRandom(List<Task> tasks) {
    if (tasks.isEmpty) {
      throw Exception('Aucune tâche disponible pour sélection aléatoire');
    }

    final random = math.Random();
    return tasks[random.nextInt(tasks.length)];
  }

  /// Met à jour une tâche
  Future<void> updateTask(Task task) async {
    final taskRepository = _ref.read(taskRepositoryProvider);
    await taskRepository.updateTask(task);

    // Invalider les caches
    _ref.invalidate(tasksSortedByEloProvider);
    _ref.invalidate(allPrioritizationTasksProvider);
  }

  /// Charge toutes les tâches pour sélection aléatoire complète
  Future<List<Task>> loadAllTasksForRandomSelection() async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    final allTasks = await unifiedService.getTasksForPrioritization();

    // Ajouter les ListItems convertis
    final listsState = _ref.read(listsControllerProvider);
    if (listsState.lists.isNotEmpty) {
      final allListItems = listsState.lists.expand((list) => list.items).toList();
      final listItemTasks = unifiedService.getListItemsAsTasks(allListItems);
      allTasks.addAll(listItemTasks);
    }

    // Filtrer les tâches incomplètes
    return allTasks.where((task) => !task.isCompleted).toList();
  }
}
