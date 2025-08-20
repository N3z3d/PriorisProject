import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/data/repositories/task_repository.dart';

/// Résultat d'un duel entre deux tâches
class DuelResult {
  final Task winner;
  final Task loser;

  const DuelResult({required this.winner, required this.loser});
}

/// Service unifié de priorisation qui gère Task et ListItem
/// 
/// Ce service permet de faire la priorisation sur les éléments de listes
/// en les convertissant temporairement en tâches.
class UnifiedPrioritizationService {
  final TaskRepository taskRepository;
  final ListItemTaskConverter converter;

  const UnifiedPrioritizationService({
    required this.taskRepository,
    required this.converter,
  });

  /// Récupère toutes les tâches pour la priorisation
  /// 
  /// Filtre les tâches complétées et les trie par score ELO
  Future<List<Task>> getTasksForPrioritization() async {
    final allTasks = await taskRepository.getAllTasks();
    final incompleteTasks = allTasks.where((task) => !task.isCompleted).toList();
    
    // Trier par score ELO décroissant
    incompleteTasks.sort((a, b) => b.eloScore.compareTo(a.eloScore));
    
    return incompleteTasks;
  }

  /// Convertit les ListItems en Tasks pour la priorisation
  /// 
  /// Filtre les éléments complétés et les trie par score ELO
  List<Task> getListItemsAsTasks(List<ListItem> listItems) {
    final incompleteItems = listItems.where((item) => !item.isCompleted).toList();
    final tasks = converter.convertListItemsToTasks(incompleteItems);
    
    // Trier par score ELO décroissant
    tasks.sort((a, b) => b.eloScore.compareTo(a.eloScore));
    
    return tasks;
  }

  /// Crée un duel à partir de ListItems
  /// 
  /// Convertit en Tasks et sélectionne 2 éléments aléatoirement
  List<Task>? createDuelFromListItems(List<ListItem> listItems) {
    final availableTasks = getListItemsAsTasks(listItems);
    
    if (availableTasks.length < 2) {
      return null; // Pas assez d'éléments pour un duel
    }
    
    // Sélection aléatoire de 2 tâches
    availableTasks.shuffle();
    return availableTasks.take(2).toList();
  }

  /// Met à jour les scores ELO après un duel
  /// 
  /// Utilise le système ELO existant et retourne les tâches mises à jour
  Future<DuelResult> updateEloScoresFromDuel(Task winner, Task loser) async {
    // Sauvegarder les scores initiaux pour calculer les changements
    final initialWinnerScore = winner.eloScore;
    final initialLoserScore = loser.eloScore;
    
    // Calculer les nouveaux scores
    final winnerProbability = winner.calculateWinProbability(loser);
    const kFactor = 32.0;
    
    final winnerNewScore = initialWinnerScore + kFactor * (1.0 - winnerProbability);
    final loserNewScore = initialLoserScore + kFactor * (0.0 - (1.0 - winnerProbability));
    
    // Créer les tâches mises à jour
    final updatedWinner = winner.copyWith(eloScore: winnerNewScore);
    final updatedLoser = loser.copyWith(eloScore: loserNewScore);
    
    // Persister les changements
    await taskRepository.updateEloScores(updatedWinner, updatedLoser);
    
    return DuelResult(winner: updatedWinner, loser: updatedLoser);
  }

  /// Convertit un Task vers un ListItem pour persister les changements ELO
  /// 
  /// Utile quand on fait de la priorisation sur des éléments de liste
  ListItem convertTaskBackToListItem(Task task, {String? listId}) {
    return converter.convertTaskToListItem(task, listId: listId);
  }
}