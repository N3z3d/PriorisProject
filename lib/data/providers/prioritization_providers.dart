import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/task/services/unified_prioritization_service.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/data/repositories/task_repository.dart';
import 'package:prioris/domain/models/core/entities/task.dart';

/// Provider pour le service de conversion ListItem/Task
final listItemTaskConverterProvider = Provider<ListItemTaskConverter>((ref) {
  return ListItemTaskConverter();
});

/// Provider pour le service unifié de priorisation
final unifiedPrioritizationServiceProvider = Provider<UnifiedPrioritizationService>((ref) {
  final taskRepository = ref.read(taskRepositoryProvider);
  final converter = ref.read(listItemTaskConverterProvider);
  
  return UnifiedPrioritizationService(
    taskRepository: taskRepository,
    converter: converter,
  );
});

/// Provider pour obtenir toutes les tâches pour la priorisation
/// (unifie Task et ListItem)
final allPrioritizationTasksProvider = FutureProvider<List<Task>>((ref) async {
  final prioritizationService = ref.read(unifiedPrioritizationServiceProvider);
  
  // Récupérer les tâches directes
  final tasks = await prioritizationService.getTasksForPrioritization();
  
  // Pending: Récupérer aussi les ListItems des listes actives
  // Pour l'instant, on retourne seulement les Task
  
  return tasks;
});

/// Provider pour créer un duel à partir d'une liste spécifique
final listDuelProvider = FutureProvider.family<List<Task>?, String>((ref, listId) async {
  // Pending: Intégrer avec listsControllerProvider pour récupérer les vrais ListItems
  
  // Pour l'instant, retourner null pour déclencher l'ancien comportement
  return null;
});