import '../../core/interfaces/repository.dart';
import '../../core/specifications/specification.dart';
import '../../core/value_objects/export.dart';
import '../aggregates/task_aggregate.dart';

/// Repository pour les tâches dans le domaine
/// 
/// Cette interface définit les opérations de persistance spécifiques
/// aux tâches. L'implémentation concrète sera dans la couche infrastructure.
abstract class TaskRepository extends PaginatedRepository<TaskAggregate> 
    implements SearchableRepository<TaskAggregate> {

  /// Trouve les tâches par catégorie
  Future<List<TaskAggregate>> findByCategory(String category);

  /// Trouve les tâches dues avant une date
  Future<List<TaskAggregate>> findDueBefore(DateTime date);

  /// Trouve les tâches dues dans une plage de dates
  Future<List<TaskAggregate>> findDueBetween(DateTime start, DateTime end);

  /// Trouve les tâches par plage de score ELO
  Future<List<TaskAggregate>> findByEloRange(double minElo, double maxElo);

  /// Trouve les tâches non complétées
  Future<List<TaskAggregate>> findIncomplete();

  /// Trouve les tâches complétées dans une période
  Future<List<TaskAggregate>> findCompletedBetween(DateTime start, DateTime end);

  /// Trouve les tâches en retard
  Future<List<TaskAggregate>> findOverdue();

  /// Trouve les tâches par niveau de priorité
  Future<List<TaskAggregate>> findByPriority(PriorityLevel priority);

  /// Trouve les tâches candidats pour un duel avec la tâche donnée
  Future<List<TaskAggregate>> findDuelCandidates(
    TaskAggregate task, {
    double eloTolerance = 200,
    int limit = 10,
  });

  /// Trouve les tâches les plus anciennes non complétées
  Future<List<TaskAggregate>> findOldestIncomplete({int limit = 10});

  /// Trouve les tâches par mot-clé dans le titre ou la description
  Future<List<TaskAggregate>> findByKeyword(String keyword);

  /// Obtient les statistiques des tâches
  Future<TaskStatistics> getStatistics({DateRange? dateRange});

  /// Obtient la distribution des scores ELO
  Future<Map<EloCategory, int>> getEloDistribution();

  /// Obtient les catégories les plus utilisées
  Future<Map<String, int>> getCategoryUsage({int limit = 10});

  /// Sauvegarde plusieurs tâches en lot
  Future<void> saveAll(List<TaskAggregate> tasks);

  /// Supprime les tâches complétées avant une date (archivage)
  Future<int> archiveCompletedBefore(DateTime date);

  /// Met à jour le score ELO d'une tâche
  Future<void> updateEloScore(String taskId, EloScore newScore);

  /// Réorganise les tâches selon un critère
  Future<List<TaskAggregate>> reorderBy(TaskOrderCriteria criteria);
}

/// Critères de tri pour les tâches
enum TaskOrderCriteria {
  priority,
  elo,
  dueDate,
  createdDate,
  completedDate,
  title,
  category,
}

/// Statistiques des tâches
class TaskStatistics {
  final int totalTasks;
  final int completedTasks;
  final int incompleteTasks;
  final int overdueTasks;
  final double completionRate;
  final double averageElo;
  final Duration averageCompletionTime;
  final Map<String, int> tasksByCategory;
  final Map<PriorityLevel, int> tasksByPriority;
  final Map<EloCategory, int> tasksByEloCategory;

  const TaskStatistics({
    required this.totalTasks,
    required this.completedTasks,
    required this.incompleteTasks,
    required this.overdueTasks,
    required this.completionRate,
    required this.averageElo,
    required this.averageCompletionTime,
    required this.tasksByCategory,
    required this.tasksByPriority,
    required this.tasksByEloCategory,
  });

  factory TaskStatistics.empty() {
    return const TaskStatistics(
      totalTasks: 0,
      completedTasks: 0,
      incompleteTasks: 0,
      overdueTasks: 0,
      completionRate: 0.0,
      averageElo: 0.0,
      averageCompletionTime: Duration.zero,
      tasksByCategory: {},
      tasksByPriority: {},
      tasksByEloCategory: {},
    );
  }
}

/// Extensions utiles pour le repository des tâches
extension TaskRepositoryExtensions on TaskRepository {
  /// Trouve les tâches à prioriser aujourd'hui
  Future<List<TaskAggregate>> findTodaysPriorities() async {
    final today = DateRange.today();
    final overdue = await findOverdue();
    final dueToday = await findDueBetween(today.start, today.end);
    final highPriority = await findByPriority(PriorityLevel.high);
    
    // Combiner et dédupliquer
    final allTasks = <String, TaskAggregate>{};
    
    for (final task in [...overdue, ...dueToday, ...highPriority]) {
      allTasks[task.id] = task;
    }
    
    final tasks = allTasks.values.toList();
    tasks.sort((a, b) => a.priority.compareTo(b.priority));
    
    return tasks;
  }

  /// Trouve les tâches pour la revue hebdomadaire
  Future<List<TaskAggregate>> findWeeklyReview() async {
    final lastWeek = DateRange.lastWeeks(1);
    return await findCompletedBetween(lastWeek.start, lastWeek.end);
  }

  /// Trouve les tâches stagnantes (anciennes et non complétées)
  Future<List<TaskAggregate>> findStagnantTasks({int daysOld = 14}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    
    final specification = Specifications.fromPredicate<TaskAggregate>(
      (task) => !task.isCompleted && task.createdAt.isBefore(cutoffDate),
      'Tâches stagnantes depuis plus de $daysOld jours',
    );
    
    return await findBySpecification(specification);
  }

  /// Trouve les meilleures tâches à faire maintenant
  Future<List<TaskAggregate>> findBestTasksNow({int limit = 5}) async {
    final incomplete = await findIncomplete();
    
    // Trier par un score composite (priorité + urgence - difficulté)
    incomplete.sort((a, b) {
      final scoreA = _calculateUrgencyScore(a);
      final scoreB = _calculateUrgencyScore(b);
      return scoreB.compareTo(scoreA);
    });
    
    return incomplete.take(limit).toList();
  }

  double _calculateUrgencyScore(TaskAggregate task) {
    double score = task.priority.score; // Base: priorité
    
    // Bonus pour les tâches en retard
    if (task.isOverdue) {
      score += 1.0 + (task.daysPastDue * 0.1);
    }
    
    // Bonus pour les tâches dues bientôt
    if (task.dueDate != null) {
      final daysUntilDue = task.dueDate!.difference(DateTime.now()).inDays;
      if (daysUntilDue <= 3) {
        score += (3 - daysUntilDue) * 0.3;
      }
    }
    
    // Malus pour la difficulté (ELO très élevé)
    if (task.eloScore.value > 1600) {
      score -= 0.2;
    }
    
    return score;
  }
}