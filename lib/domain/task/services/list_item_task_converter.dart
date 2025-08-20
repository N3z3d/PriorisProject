import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Service de conversion entre ListItem et Task
/// 
/// Permet d'unifier les deux systèmes pour la priorisation
/// et la gestion des données sans duplicata.
class ListItemTaskConverter {
  static const String _listTagPrefix = 'list-';
  
  /// Convertit un ListItem en Task
  /// 
  /// Mappe tous les champs communs et ajoute le listId dans les tags
  Task convertListItemToTask(ListItem listItem) {
    return Task(
      id: listItem.id,
      title: listItem.title,
      description: listItem.description,
      eloScore: listItem.eloScore,
      isCompleted: listItem.isCompleted,
      createdAt: listItem.createdAt,
      completedAt: listItem.completedAt,
      category: listItem.category,
      dueDate: listItem.dueDate,
      tags: [listItem.listId], // Stocker le listId dans les tags
      priority: 0, // Valeur par défaut
      lastChosenAt: listItem.lastChosenAt,
    );
  }

  /// Convertit un Task en ListItem
  /// 
  /// Extrait le listId des tags si non fourni explicitement
  ListItem convertTaskToListItem(Task task, {String? listId}) {
    final targetListId = listId ?? _extractListIdFromTags(task.tags) ?? 'default';
    
    return ListItem(
      id: task.id,
      title: task.title,
      description: task.description,
      category: task.category,
      eloScore: task.eloScore,
      isCompleted: task.isCompleted,
      createdAt: task.createdAt,
      completedAt: task.completedAt,
      dueDate: task.dueDate,
      notes: null, // Les Task n'ont pas de notes
      listId: targetListId,
      lastChosenAt: task.lastChosenAt,
    );
  }

  /// Convertit une liste de ListItems en Tasks
  List<Task> convertListItemsToTasks(List<ListItem> listItems) {
    return listItems.map(convertListItemToTask).toList();
  }

  /// Convertit une liste de Tasks en ListItems
  List<ListItem> convertTasksToListItems(List<Task> tasks, {String? listId}) {
    return tasks.map((task) => convertTaskToListItem(task, listId: listId)).toList();
  }

  /// Extrait le listId des tags d'une Task
  /// 
  /// Cherche le premier tag qui commence par le préfixe de liste OU retourne le premier tag
  /// Si aucun tag trouvé, retourne 'default'
  String? _extractListIdFromTags(List<String> tags) {
    if (tags.isEmpty) return 'default';
    
    // Chercher d'abord un tag avec préfixe
    for (final tag in tags) {
      if (tag.startsWith(_listTagPrefix)) {
        return tag;
      }
    }
    
    // Si aucun tag de liste trouvé, prendre le premier tag (qui est souvent le listId)
    return tags.first;
  }
}