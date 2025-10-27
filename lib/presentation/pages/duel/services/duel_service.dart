import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

import 'duel_task_filter.dart';

abstract class DuelFlowService {
  Future<void> ensureListsLoaded();
  Future<List<Task>> loadDuelTasks({required int count});
  Future<List<Task>> loadAllTasksForRandomSelection();
  Future<void> processWinner(Task winner, Task loser);
  Future<void> processRanking(List<Task> orderedTasks);
  Task selectRandom(List<Task> tasks);
  Future<void> updateTask(Task task);
}

/// Domain service orchestrating the task duel flow.
class DuelService implements DuelFlowService {
  final Ref _ref;
  final DuelTaskFilter _taskFilter;
  static const int _maxTasksForPrioritization = 50;

  DuelService(
    this._ref, {
    DuelTaskFilter? taskFilter,
  }) : _taskFilter = taskFilter ?? const DuelTaskFilter();

  /// Ensure lists are available before running duels.
  @override
  Future<void> ensureListsLoaded() async {
    await _ref.read(listsControllerProvider.notifier).loadLists();
    await _waitForListsToFinishLoading();
  }

  /// Load two tasks eligible for a duel.
  @override
  Future<List<Task>> loadDuelTasks({required int count}) async {
    final allTasks = await _loadAllAvailableTasks();
    final preparedTasks = _prepareTasksForDuel(allTasks);

    if (preparedTasks.isEmpty) {
      return [];
    }

    if (preparedTasks.length >= count) {
      preparedTasks.shuffle();
      return preparedTasks.take(count).toList();
    }

    preparedTasks.shuffle();
    return preparedTasks;
  }

  Future<List<Task>> _loadAllAvailableTasks() async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    final classicTasks = await unifiedService.getTasksForPrioritization();
    return _combineWithListItems(classicTasks, unifiedService);
  }

  Future<List<Task>> _combineWithListItems(
    List<Task> classicTasks,
    dynamic unifiedService,
  ) async {
    final listsState = _ref.read(listsControllerProvider);
    final settings = _ref.read(listPrioritizationSettingsProvider);

    if (listsState.lists.isEmpty) {
      return classicTasks;
    }

    final eligibleItems = _taskFilter.extractEligibleItems(
      lists: listsState.lists,
      settings: settings,
    );

    if (eligibleItems.isEmpty) {
      return classicTasks;
    }

    final listItemTasks = unifiedService.getListItemsAsTasks(eligibleItems);
    return [...classicTasks, ...listItemTasks];
  }

  List<Task> _prepareTasksForDuel(List<Task> allTasks) {
    final incompleteTasks =
        allTasks.where((task) => !task.isCompleted).toList(growable: false);
    return _limitTasksForPerformance(incompleteTasks);
  }

  List<Task> _limitTasksForPerformance(List<Task> tasks) {
    if (tasks.length <= _maxTasksForPrioritization) {
      return tasks;
    }
    return tasks.take(_maxTasksForPrioritization).toList();
  }

  @override
  Future<void> processWinner(Task winner, Task loser) async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    await unifiedService.updateEloScoresFromDuel(winner, loser);

    _ref.invalidate(tasksSortedByEloProvider);
    _ref.invalidate(allPrioritizationTasksProvider);
  }

  @override
  Future<void> processRanking(List<Task> orderedTasks) async {
    if (orderedTasks.length < 2) {
      return;
    }

    for (var i = 0; i < orderedTasks.length; i++) {
      for (var j = i + 1; j < orderedTasks.length; j++) {
        await processWinner(orderedTasks[i], orderedTasks[j]);
      }
    }
  }

  @override
  Task selectRandom(List<Task> tasks) {
    if (tasks.isEmpty) {
      throw Exception('Aucune tache disponible pour selection aleatoire');
    }

    final random = math.Random();
    return tasks[random.nextInt(tasks.length)];
  }

  @override
  Future<void> updateTask(Task task) async {
    final taskRepository = _ref.read(taskRepositoryProvider);
    await taskRepository.updateTask(task);

    _ref.invalidate(tasksSortedByEloProvider);
    _ref.invalidate(allPrioritizationTasksProvider);
  }

  @override
  Future<List<Task>> loadAllTasksForRandomSelection() async {
    final unifiedService = _ref.read(unifiedPrioritizationServiceProvider);
    final allTasks = await unifiedService.getTasksForPrioritization();

    final listsState = _ref.read(listsControllerProvider);
    final settings = _ref.read(listPrioritizationSettingsProvider);

    if (listsState.lists.isNotEmpty) {
      final eligibleItems = _taskFilter.extractEligibleItems(
        lists: listsState.lists,
        settings: settings,
      );
      final listItemTasks = unifiedService.getListItemsAsTasks(eligibleItems);
      allTasks.addAll(listItemTasks);
    }

    return allTasks.where((task) => !task.isCompleted).toList();
  }

  Future<void> _waitForListsToFinishLoading({
    Duration pollInterval = const Duration(milliseconds: 50),
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      final state = _ref.read(listsControllerProvider);
      if (!state.isLoading) {
        break;
      }
      await Future.delayed(pollInterval);
    }
  }
}
