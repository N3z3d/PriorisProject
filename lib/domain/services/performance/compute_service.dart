import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service pour exécuter des calculs lourds dans des isolates
/// 
/// Utilise compute() de Flutter pour décharger les calculs intensifs
/// du thread principal, maintenant ainsi 60 FPS.
class ComputeService {
  static final ComputeService _instance = ComputeService._internal();
  factory ComputeService() => _instance;
  ComputeService._internal();

  // Cache des résultats de calculs récents
  final Map<String, _CachedResult> _cache = {};
  final Duration _cacheExpiration = const Duration(minutes: 5);
  
  // Gestion de la file d'attente pour éviter la surcharge
  final List<_ComputeTask> _queue = [];
  bool _isProcessing = false;
  final int _maxConcurrent = 3;
  int _currentRunning = 0;

  /// Exécute un calcul lourd dans un isolate
  Future<T> executeCompute<T, P>({
    required T Function(P) callback,
    required P parameter,
    String? cacheKey,
    bool useCache = true,
  }) async {
    // Vérifier le cache si applicable
    if (useCache && cacheKey != null) {
      final cached = _getFromCache<T>(cacheKey);
      if (cached != null) {
        debugPrint('ComputeService: Cache hit for $cacheKey');
        return cached;
      }
    }

    // Exécuter le calcul
    final result = await _executeCompute(callback, parameter);

    // Mettre en cache si applicable
    if (useCache && cacheKey != null) {
      _addToCache(cacheKey, result);
    }

    return result;
  }

  /// Exécute plusieurs calculs en parallèle
  Future<List<T>> computeMany<T, P>({
    required T Function(P) callback,
    required List<P> parameters,
    int maxParallel = 3,
  }) async {
    final results = <T>[];
    final chunks = _chunkList(parameters, maxParallel);
    
    for (final chunk in chunks) {
      final chunkResults = await Future.wait(
        chunk.map((param) => _executeCompute(callback, param)),
      );
      results.addAll(chunkResults);
    }
    
    return results;
  }

  /// Divise une liste en chunks pour traitement parallèle
  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    final chunks = <List<T>>[];
    for (var i = 0; i < list.length; i += chunkSize) {
      final end = (i + chunkSize < list.length) ? i + chunkSize : list.length;
      chunks.add(list.sublist(i, end));
    }
    return chunks;
  }

  /// Exécute le calcul avec gestion de la file d'attente
  Future<T> _executeCompute<T, P>(
    T Function(P) callback,
    P parameter,
  ) async {
    // Si on dépasse la limite, mettre en queue
    if (_currentRunning >= _maxConcurrent) {
      final completer = Completer<T>();
      _queue.add(_ComputeTask(
        callback: () async {
          final result = await compute(callback, parameter);
          completer.complete(result);
        },
      ));
      _processQueue();
      return completer.future;
    }

    // Exécuter directement
    _currentRunning++;
    try {
      return await compute(callback, parameter);
    } finally {
      _currentRunning--;
      _processQueue();
    }
  }

  /// Traite la file d'attente des calculs
  void _processQueue() {
    if (_isProcessing || _queue.isEmpty || _currentRunning >= _maxConcurrent) {
      return;
    }

    _isProcessing = true;
    
    while (_queue.isNotEmpty && _currentRunning < _maxConcurrent) {
      final task = _queue.removeAt(0);
      _currentRunning++;
      task.callback().whenComplete(() {
        _currentRunning--;
        _processQueue();
      });
    }
    
    _isProcessing = false;
  }

  /// Récupère un résultat du cache
  T? _getFromCache<T>(String key) {
    final cached = _cache[key];
    if (cached == null) return null;
    
    if (DateTime.now().difference(cached.timestamp) > _cacheExpiration) {
      _cache.remove(key);
      return null;
    }
    
    return cached.value as T?;
  }

  /// Ajoute un résultat au cache
  void _addToCache<T>(String key, T value) {
    _cache[key] = _CachedResult(
      value: value,
      timestamp: DateTime.now(),
    );
    
    // Nettoyer les entrées expirées
    _cleanCache();
  }

  /// Nettoie le cache des entrées expirées
  void _cleanCache() {
    final now = DateTime.now();
    _cache.removeWhere((key, value) => 
      now.difference(value.timestamp) > _cacheExpiration
    );
  }

  /// Vide complètement le cache
  void clearCache() {
    _cache.clear();
  }

  /// Obtient des statistiques sur le service
  Map<String, dynamic> getStats() {
    return {
      'cacheSize': _cache.length,
      'queueLength': _queue.length,
      'currentRunning': _currentRunning,
      'maxConcurrent': _maxConcurrent,
    };
  }
}

/// Tâche de calcul en attente
class _ComputeTask {
  final Future<void> Function() callback;
  
  _ComputeTask({required this.callback});
}

/// Résultat mis en cache
class _CachedResult {
  final dynamic value;
  final DateTime timestamp;
  
  _CachedResult({
    required this.value,
    required this.timestamp,
  });
}

// ========== FONCTIONS DE CALCUL OPTIMISÉES ==========

/// Calcule les statistiques d'une liste de tâches
Map<String, dynamic> computeTaskStatistics(List<Map<String, dynamic>> tasks) {
  final total = tasks.length;
  final completed = tasks.where((t) => t['isCompleted'] == true).length;
  final overdue = tasks.where((t) {
    final dueDate = t['dueDate'] as DateTime?;
    return dueDate != null && 
           dueDate.isBefore(DateTime.now()) && 
           t['isCompleted'] != true;
  }).length;
  
  double totalElo = 0;
  final priorityCounts = <int, int>{};
  final tagCounts = <String, int>{};
  
  for (final task in tasks) {
    totalElo += (task['eloScore'] as num?)?.toDouble() ?? 0;
    
    final priority = task['priority'] as int?;
    if (priority != null) {
      priorityCounts[priority] = (priorityCounts[priority] ?? 0) + 1;
    }
    
    final tags = task['tags'] as List<String>?;
    if (tags != null) {
      for (final tag in tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }
  }
  
  return {
    'total': total,
    'completed': completed,
    'pending': total - completed,
    'overdue': overdue,
    'completionRate': total > 0 ? completed / total : 0.0,
    'averageElo': total > 0 ? totalElo / total : 0.0,
    'priorityDistribution': priorityCounts,
    'topTags': Map.fromEntries(
      tagCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(10)
    ),
  };
}

/// Calcule les prédictions d'habitudes basées sur l'historique
Map<String, dynamic> computeHabitPredictions(List<Map<String, dynamic>> history) {
  if (history.isEmpty) {
    return {
      'nextBestTime': null,
      'successProbability': 0.0,
      'suggestedDuration': 0,
      'patterns': [],
    };
  }
  
  // Analyser les patterns de succès
  final successfulSessions = history.where((h) => h['completed'] == true).toList();
  final timeDistribution = <int, int>{};
  final dayDistribution = <int, int>{};
  final durationSum = <int>[];
  
  for (final session in successfulSessions) {
    final date = session['date'] as DateTime;
    timeDistribution[date.hour] = (timeDistribution[date.hour] ?? 0) + 1;
    dayDistribution[date.weekday] = (dayDistribution[date.weekday] ?? 0) + 1;
    
    final duration = session['duration'] as int?;
    if (duration != null) {
      durationSum.add(duration);
    }
  }
  
  // Trouver le meilleur moment
  int? bestHour;
  int maxCount = 0;
  timeDistribution.forEach((hour, count) {
    if (count > maxCount) {
      maxCount = count;
      bestHour = hour;
    }
  });
  
  // Calculer la probabilité de succès
  final totalSessions = history.length;
  final successRate = successfulSessions.length / totalSessions;
  
  // Calculer la durée suggérée
  final avgDuration = durationSum.isEmpty 
    ? 0 
    : durationSum.reduce((a, b) => a + b) ~/ durationSum.length;
  
  // Identifier les patterns
  final patterns = <String>[];
  
  // Pattern de jour de la semaine
  int? bestDay;
  maxCount = 0;
  dayDistribution.forEach((day, count) {
    if (count > maxCount) {
      maxCount = count;
      bestDay = day;
    }
  });
  
  if (bestDay != null) {
    final dayNames = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    patterns.add('Plus de succès le ${dayNames[bestDay! - 1]}');
  }
  
  // Pattern de streak
  int currentStreak = 0;
  int maxStreak = 0;
  for (final session in history) {
    if (session['completed'] == true) {
      currentStreak++;
      maxStreak = currentStreak > maxStreak ? currentStreak : maxStreak;
    } else {
      currentStreak = 0;
    }
  }
  
  if (maxStreak > 3) {
    patterns.add('Meilleure série: $maxStreak jours consécutifs');
  }
  
  return {
    'nextBestTime': bestHour != null 
      ? DateTime.now().copyWith(hour: bestHour, minute: 0)
      : null,
    'successProbability': successRate,
    'suggestedDuration': avgDuration,
    'patterns': patterns,
    'bestDay': bestDay,
    'bestHour': bestHour,
    'averageStreak': maxStreak,
  };
}

/// Optimise l'ordre des éléments d'une liste selon plusieurs critères
List<Map<String, dynamic>> computeOptimalListOrder(
  List<Map<String, dynamic>> items,
  Map<String, double> weights,
) {
  // Calculer le score composite pour chaque élément
  final scoredItems = items.map((item) {
    double score = 0;
    
    // Score ELO
    if (weights.containsKey('elo')) {
      score += (item['eloScore'] as num? ?? 0) * weights['elo']!;
    }
    
    // Score d'urgence (basé sur la date d'échéance)
    if (weights.containsKey('urgency')) {
      final dueDate = item['dueDate'] as DateTime?;
      if (dueDate != null) {
        final daysUntilDue = dueDate.difference(DateTime.now()).inDays;
        final urgencyScore = daysUntilDue <= 0 
          ? 100 
          : (100 / (daysUntilDue + 1));
        score += urgencyScore * weights['urgency']!;
      }
    }
    
    // Score de priorité
    if (weights.containsKey('priority')) {
      final priority = item['priority'] as int? ?? 3;
      score += priority * 20 * weights['priority']!;
    }
    
    // Score de progression (favoriser les éléments presque terminés)
    if (weights.containsKey('progress')) {
      final progress = item['progress'] as double? ?? 0;
      if (progress > 0.7) {
        score += progress * 50 * weights['progress']!;
      }
    }
    
    // Score de dépendance (éléments bloquants)
    if (weights.containsKey('blocking')) {
      final isBlocking = item['isBlocking'] as bool? ?? false;
      if (isBlocking) {
        score += 80 * weights['blocking']!;
      }
    }
    
    return {
      'item': item,
      'score': score,
    };
  }).toList();
  
  // Trier par score décroissant
  scoredItems.sort((a, b) => 
    (b['score'] as double).compareTo(a['score'] as double)
  );
  
  // Retourner les éléments triés
  return scoredItems.map((s) => s['item'] as Map<String, dynamic>).toList();
}

/// Calcule des insights intelligents basés sur les données
List<String> computeSmartInsights(Map<String, dynamic> data) {
  final insights = <String>[];
  
  // Analyser les tâches
  final tasks = data['tasks'] as List<Map<String, dynamic>>?;
  if (tasks != null && tasks.isNotEmpty) {
    final stats = computeTaskStatistics(tasks);
    
    if ((stats['completionRate'] as double) < 0.3) {
      insights.add('📊 Votre taux de complétion est bas. Essayez de réduire le nombre de tâches actives.');
    }
    
    if ((stats['overdue'] as int) > 5) {
      insights.add('⚠️ ${stats['overdue']} tâches en retard. Priorisez-les aujourd\'hui!');
    }
    
    final avgElo = stats['averageElo'] as double;
    if (avgElo > 1500) {
      insights.add('🔥 Score ELO élevé détecté. Vos tâches sont très prioritaires!');
    }
  }
  
  // Analyser les habitudes
  final habits = data['habits'] as List<Map<String, dynamic>>?;
  if (habits != null && habits.isNotEmpty) {
    int totalStreak = 0;
    int brokenStreaks = 0;
    
    for (final habit in habits) {
      final streak = habit['currentStreak'] as int? ?? 0;
      totalStreak += streak;
      
      if (habit['streakBroken'] == true) {
        brokenStreaks++;
      }
    }
    
    if (totalStreak > 50) {
      insights.add('🏆 Excellentes séries! Total de $totalStreak jours cumulés.');
    }
    
    if (brokenStreaks > 3) {
      insights.add('💡 $brokenStreaks habitudes interrompues. Revoyez vos objectifs.');
    }
  }
  
  // Analyser la productivité globale
  final productivity = data['productivity'] as Map<String, dynamic>?;
  if (productivity != null) {
    final todayCompleted = productivity['todayCompleted'] as int? ?? 0;
    final weekAverage = productivity['weekAverage'] as double? ?? 0;
    
    if (todayCompleted > weekAverage * 1.5) {
      insights.add('🚀 Journée très productive! $todayCompleted tâches complétées.');
    }
    
    final bestTime = productivity['bestProductiveTime'] as String?;
    if (bestTime != null) {
      insights.add('⏰ Votre meilleur moment: $bestTime. Planifiez vos tâches importantes.');
    }
  }
  
  // Suggestions d'amélioration
  if (insights.length < 3) {
    insights.add('💪 Continuez ainsi! Votre productivité est stable.');
  }
  
  return insights;
}

// Extension pour faciliter l'utilisation
extension ComputeServiceExtension on ComputeService {
  /// Calcule les statistiques de tâches de manière optimisée
  Future<Map<String, dynamic>> computeTaskStats(
    List<Map<String, dynamic>> tasks,
  ) {
    return compute(computeTaskStatistics, tasks);
  }
  
  /// Calcule les prédictions d'habitudes
  Future<Map<String, dynamic>> computeHabitPreds(
    List<Map<String, dynamic>> history,
  ) {
    return compute(computeHabitPredictions, history);
  }
  
  /// Optimise l'ordre d'une liste
  Future<List<Map<String, dynamic>>> optimizeListOrder(
    List<Map<String, dynamic>> items,
    Map<String, double> weights,
  ) async {
    return await compute(
      (Map<String, dynamic> params) {
        return computeOptimalListOrder(
          params['items'] as List<Map<String, dynamic>>,
          params['weights'] as Map<String, double>,
        );
      },
      {'items': items, 'weights': weights},
    );
  }
  
  /// Génère des insights intelligents
  Future<List<String>> generateInsights(
    Map<String, dynamic> data,
  ) async {
    return await compute(
      computeSmartInsights,
      data,
    );
  }
}