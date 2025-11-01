import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/list_prioritization_settings_provider.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';

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
  late final DuelTaskLoader _taskLoader;
  static const int _maxTasksForPrioritization = 50;

  DuelService(
    this._ref, {
    DuelTaskFilter? taskFilter,
    DuelTaskLoader? taskLoader,
  }) : _taskFilter = taskFilter ?? const DuelTaskFilter() {
    _taskLoader = taskLoader ??
        ResilientTaskLoader(
          loadTasks: _loadAllAvailableTasks,
          logger: LoggerService.instance,
        );
  }

  /// Ensure lists are available before running duels.
  @override
  Future<void> ensureListsLoaded() async {
    await _ref.read(listsControllerProvider.notifier).loadLists();
    await _waitForListsToFinishLoading();
  }

  /// Load two tasks eligible for a duel.
  @override
  Future<List<Task>> loadDuelTasks({required int count}) async {
    final allTasks = await _taskLoader.load();
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
    final allTasks = await _taskLoader.load();
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

abstract class DuelTaskLoader {
  Future<List<Task>> load();
  List<Task> get lastSuccessfulTasks;
}

class ResilientTaskLoader implements DuelTaskLoader {
  ResilientTaskLoader({
    required Future<List<Task>> Function() loadTasks,
    LoggerService? logger,
    Duration Function(int attempt)? delayBuilder,
    int retries = 2,
  })  : _loadTasks = loadTasks,
        _logger = logger ?? LoggerService.instance,
        _delayBuilder = delayBuilder ?? _defaultDelay,
        _retries = retries;

  final Future<List<Task>> Function() _loadTasks;
  final LoggerService _logger;
  final Duration Function(int attempt) _delayBuilder;
  final int _retries;
  List<Task> _cache = const [];

  @override
  List<Task> get lastSuccessfulTasks => List.unmodifiable(_cache);

  @override
  Future<List<Task>> load() async {
    Object? lastError;

    for (var attempt = 0; attempt <= _retries; attempt++) {
      try {
        final tasks = await _loadTasks();
        if (tasks.isNotEmpty) {
          _cache = List<Task>.from(tasks);
        }
        return tasks;
      } catch (error, stack) {
        lastError = error;
        _logger.warning(
          'Echec du chargement des taches (tentative ${attempt + 1}/${_retries + 1})',
          context: 'ResilientTaskLoader',
        );

        if (attempt < _retries) {
          final delay = _delayBuilder(attempt);
          if (delay > Duration.zero) {
            await Future<void>.delayed(delay);
          }
        } else {
          _logger.error(
            'Echec definitif du chargement des taches',
            context: 'ResilientTaskLoader',
            error: error,
            stackTrace: stack,
          );
        }
      }
    }

    if (_cache.isNotEmpty) {
      _logger.info(
        'Utilisation du cache des taches duel',
        context: 'ResilientTaskLoader',
      );
      return List<Task>.from(_cache);
    }

    throw DuelLoadingException(
      'Chargement des taches indisponible',
      lastError,
    );
  }

  static Duration _defaultDelay(int attempt) =>
      Duration(milliseconds: 120 * (attempt + 1));
}

class DuelLoadingException implements Exception {
  final String message;
  final Object? cause;

  DuelLoadingException(this.message, [this.cause]);

  @override
  String toString() => message;
}
