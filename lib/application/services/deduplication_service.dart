/// Deduplication Service
/// Single Responsibility: Handle data deduplication and conflict resolution

import '../../domain/models/core/entities/custom_list.dart';
import '../../domain/models/core/entities/list_item.dart';
import '../../infrastructure/services/logger_service.dart';
import '../ports/persistence_interfaces.dart';

/// SOLID implementation of data deduplication
/// Follows Single Responsibility Principle - only handles deduplication
class DeduplicationService implements IDeduplicationService {
  @override
  List<CustomList> deduplicateLists(List<CustomList> lists) {
    LoggerService.instance.debug(
      'Starting deduplication of ${lists.length} lists',
      context: 'DeduplicationService',
    );

    final Map<String, CustomList> uniqueLists = {};
    int duplicatesFound = 0;

    for (final list in lists) {
      final existingList = uniqueLists[list.id];

      if (existingList == null) {
        // First occurrence of this ID
        uniqueLists[list.id] = list;
      } else {
        // Conflict detected, resolve by keeping the most recent
        duplicatesFound++;
        final resolved = _resolveListConflict(existingList, list);
        uniqueLists[list.id] = resolved;

        LoggerService.instance.debug(
          'Duplicate resolved for list "${resolved.name}" (${list.id})',
          context: 'DeduplicationService',
        );
      }
    }

    final deduplicatedLists = uniqueLists.values.toList();

    if (duplicatesFound > 0) {
      LoggerService.instance.info(
        'Deduplication completed: ${lists.length} → ${deduplicatedLists.length} lists ($duplicatesFound duplicates removed)',
        context: 'DeduplicationService',
      );
    }

    return deduplicatedLists;
  }

  @override
  Future<void> saveListWithDeduplication(
    CustomList list,
    Future<void> Function(CustomList) saveOperation,
    Future<CustomList?> Function(String) getExistingOperation,
    Future<void> Function(CustomList) updateOperation,
  ) async {
    try {
      // Try normal save operation first
      await saveOperation(list);
    } catch (e) {
      if (_isIdConflictError(e)) {
        LoggerService.instance.info(
          'ID conflict detected for list ${list.id}, applying deduplication strategy',
          context: 'DeduplicationService',
        );

        // Get existing list to resolve conflict
        final existingList = await getExistingOperation(list.id);

        if (existingList != null) {
          // Resolve conflict and update
          final mergedList = _resolveListConflict(existingList, list);
          await updateOperation(mergedList);

          LoggerService.instance.info(
            'Conflict resolved: merged list "${mergedList.name}"',
            context: 'DeduplicationService',
          );
        } else {
          // If existing list is null, retry the save
          await saveOperation(list);
        }
      } else {
        // Re-throw non-conflict errors
        rethrow;
      }
    }
  }

  @override
  Future<void> saveItemWithDeduplication(
    ListItem item,
    Future<void> Function(ListItem) addOperation,
    Future<ListItem?> Function(String) getByIdOperation,
    Future<void> Function(ListItem) updateOperation,
  ) async {
    try {
      // Try normal add operation first
      await addOperation(item);
    } catch (e) {
      if (_isItemIdConflictError(e)) {
        LoggerService.instance.info(
          'Item ID conflict detected for ${item.id}, applying deduplication strategy',
          context: 'DeduplicationService',
        );

        // Get existing item to resolve conflict
        final existingItem = await getByIdOperation(item.id);

        if (existingItem != null) {
          // Resolve conflict and update
          final mergedItem = _resolveItemConflict(existingItem, item);
          await updateOperation(mergedItem);

          LoggerService.instance.info(
            'Item conflict resolved: merged item "${mergedItem.title}"',
            context: 'DeduplicationService',
          );
        } else {
          // If existing item is null, retry the add
          await addOperation(item);
        }
      } else {
        // Re-throw non-conflict errors
        rethrow;
      }
    }
  }

  /// Resolve conflicts between two lists
  CustomList _resolveListConflict(CustomList existing, CustomList incoming) {
    // Use the list with the most recent update timestamp
    if (existing.updatedAt != null && incoming.updatedAt != null) {
      if (existing.updatedAt!.isAfter(incoming.updatedAt!)) {
        LoggerService.instance.debug('Keeping existing list version (more recent)', context: 'DeduplicationService');
        return existing;
      } else if (incoming.updatedAt!.isAfter(existing.updatedAt!)) {
        LoggerService.instance.debug('Adopting incoming list version (more recent)', context: 'DeduplicationService');
        return incoming;
      }
    }

    // If timestamps are equal or missing, prefer incoming (default behavior)
    LoggerService.instance.debug('Default resolution: adopting incoming list version', context: 'DeduplicationService');
    return incoming;
  }

  /// Resolve conflicts between two items
  ListItem _resolveItemConflict(ListItem existing, ListItem incoming) {
    // Use the item with the most recent creation date
    if (existing.createdAt.isAfter(incoming.createdAt)) {
      LoggerService.instance.debug('Keeping existing item version (more recent)', context: 'DeduplicationService');
      return existing;
    } else if (incoming.createdAt.isAfter(existing.createdAt)) {
      LoggerService.instance.debug('Adopting incoming item version (more recent)', context: 'DeduplicationService');
      return incoming;
    } else {
      // If creation dates are equal, prefer incoming
      LoggerService.instance.debug('Default resolution: adopting incoming item version', context: 'DeduplicationService');
      return incoming;
    }
  }

  /// Check if error is an ID conflict error
  bool _isIdConflictError(dynamic error) {
    final errorString = error.toString();
    return errorString.contains('Une liste avec cet ID existe déjà') ||
           errorString.contains('duplicate key') ||
           errorString.contains('unique constraint') ||
           errorString.contains('UNIQUE constraint failed');
  }

  /// Check if error is an item ID conflict error
  bool _isItemIdConflictError(dynamic error) {
    final errorString = error.toString();
    return errorString.contains('Un item avec cet id existe déjà') ||
           errorString.contains('duplicate key') ||
           errorString.contains('unique constraint') ||
           errorString.contains('UNIQUE constraint failed');
  }

  /// Get deduplication statistics for a list of items
  Map<String, dynamic> getDeduplicationStats(List<dynamic> items) {
    final Map<String, int> idCounts = {};
    int totalItems = items.length;

    for (final item in items) {
      String id = '';
      if (item is CustomList) {
        id = item.id;
      } else if (item is ListItem) {
        id = item.id;
      } else {
        continue;
      }

      idCounts[id] = (idCounts[id] ?? 0) + 1;
    }

    final duplicateIds = idCounts.entries.where((entry) => entry.value > 1).toList();
    final uniqueItems = idCounts.length;
    final duplicateCount = totalItems - uniqueItems;

    return {
      'totalItems': totalItems,
      'uniqueItems': uniqueItems,
      'duplicateCount': duplicateCount,
      'duplicateRate': totalItems > 0 ? (duplicateCount / totalItems * 100).toStringAsFixed(1) : '0.0',
      'duplicateIds': duplicateIds.map((entry) => {
        'id': entry.key,
        'count': entry.value,
      }).toList(),
    };
  }

  /// Validate data consistency after deduplication
  bool validateDeduplication(List<dynamic> originalItems, List<dynamic> deduplicatedItems) {
    final originalStats = getDeduplicationStats(originalItems);
    final deduplicatedStats = getDeduplicationStats(deduplicatedItems);

    // After deduplication, there should be no duplicates
    final isValid = deduplicatedStats['duplicateCount'] == 0 &&
                   deduplicatedStats['uniqueItems'] == deduplicatedItems.length;

    if (!isValid) {
      LoggerService.instance.error(
        'Deduplication validation failed',
        context: 'DeduplicationService',
        error: {
          'original': originalStats,
          'deduplicated': deduplicatedStats,
        },
      );
    } else {
      LoggerService.instance.debug(
        'Deduplication validation passed',
        context: 'DeduplicationService',
      );
    }

    return isValid;
  }

  /// Merge two lists of items, removing duplicates
  List<T> mergeAndDeduplicate<T>(
    List<T> list1,
    List<T> list2,
    String Function(T) getId,
    T Function(T, T) conflictResolver,
  ) {
    final Map<String, T> mergedItems = {};

    // Process first list
    for (final item in list1) {
      final id = getId(item);
      mergedItems[id] = item;
    }

    // Process second list, resolving conflicts
    for (final item in list2) {
      final id = getId(item);
      final existing = mergedItems[id];

      if (existing != null) {
        // Resolve conflict
        mergedItems[id] = conflictResolver(existing, item);
      } else {
        mergedItems[id] = item;
      }
    }

    return mergedItems.values.toList();
  }
}