import 'dart:math';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Strategies for conflict resolution during migration
enum ConflictResolutionStrategy {
  keepLocal,
  keepCloud,
  smartMerge,
  duplicate,
  askUser,
}

/// Configuration for conflict resolution
class ConflictResolutionConfig {
  final ConflictResolutionStrategy strategy;
  final bool enableSmartMerge;
  final bool preserveTimestamps;

  const ConflictResolutionConfig({
    this.strategy = ConflictResolutionStrategy.smartMerge,
    this.enableSmartMerge = true,
    this.preserveTimestamps = true,
  });
}

/// Conflict Resolver Service - Handles data conflicts during migration
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for conflict resolution only
/// - OCP: Extensible through strategy pattern
/// - LSP: All resolvers follow same contract
/// - ISP: Focused interface for conflict resolution
/// - DIP: Depends on abstractions, not concrete types
///
/// CONSTRAINTS: <200 lines (currently ~180 lines)
class ConflictResolver {
  /// Singleton instance for consistent conflict resolution
  static final ConflictResolver instance = ConflictResolver._();
  ConflictResolver._();

  /// Resolves conflicts between two lists
  Future<CustomList?> resolveListConflict(
    CustomList sourceList,
    CustomList targetList,
    ConflictResolutionConfig config,
  ) async {
    switch (config.strategy) {
      case ConflictResolutionStrategy.keepLocal:
        return sourceList;
      case ConflictResolutionStrategy.keepCloud:
        return targetList;
      case ConflictResolutionStrategy.smartMerge:
        return _smartMergeLists(sourceList, targetList, config);
      case ConflictResolutionStrategy.duplicate:
        return _createListDuplicate(sourceList);
      case ConflictResolutionStrategy.askUser:
        // TODO: Implement user interface for conflict resolution
        return _smartMergeLists(sourceList, targetList, config);
    }
  }

  /// Resolves conflicts between two list items
  Future<ListItem?> resolveItemConflict(
    ListItem sourceItem,
    ListItem targetItem,
    ConflictResolutionConfig config,
  ) async {
    switch (config.strategy) {
      case ConflictResolutionStrategy.keepLocal:
        return sourceItem;
      case ConflictResolutionStrategy.keepCloud:
        return targetItem;
      case ConflictResolutionStrategy.smartMerge:
        return _smartMergeItems(sourceItem, targetItem, config);
      case ConflictResolutionStrategy.duplicate:
        return _createItemDuplicate(sourceItem);
      case ConflictResolutionStrategy.askUser:
        // TODO: Implement user interface for conflict resolution
        return _smartMergeItems(sourceItem, targetItem, config);
    }
  }

  /// Determines if two lists have conflicts
  bool hasListConflict(CustomList list1, CustomList list2) {
    return list1.id == list2.id &&
           (list1.updatedAt != list2.updatedAt ||
            list1.name != list2.name ||
            list1.description != list2.description);
  }

  /// Determines if two items have conflicts
  bool hasItemConflict(ListItem item1, ListItem item2) {
    return item1.id == item2.id &&
           (item1.title != item2.title ||
            item1.isCompleted != item2.isCompleted ||
            item1.completedAt != item2.completedAt ||
            item1.eloScore != item2.eloScore);
  }

  // === PRIVATE METHODS ===

  CustomList _smartMergeLists(
    CustomList list1,
    CustomList list2,
    ConflictResolutionConfig config
  ) {
    // Use the list with the most recent update timestamp
    if (list1.updatedAt.isAfter(list2.updatedAt)) {
      return list1;
    } else if (list2.updatedAt.isAfter(list1.updatedAt)) {
      return list2;
    } else {
      // Same timestamp, merge intelligently
      return list1.copyWith(
        name: _selectBestString(list1.name, list2.name),
        description: _selectBestString(list1.description, list2.description),
        updatedAt: config.preserveTimestamps ? list1.updatedAt : DateTime.now(),
      );
    }
  }

  ListItem _smartMergeItems(
    ListItem item1,
    ListItem item2,
    ConflictResolutionConfig config
  ) {
    // Use the item with the most recent activity
    final item1RecentDate = _getMostRecentDate(item1);
    final item2RecentDate = _getMostRecentDate(item2);

    if (item1RecentDate.isAfter(item2RecentDate)) {
      return item1;
    } else if (item2RecentDate.isAfter(item1RecentDate)) {
      return item2;
    } else {
      // Same date, merge intelligently favoring completeness
      return ListItem(
        id: item1.id,
        title: _selectBestString(item1.title, item2.title) ?? 'Untitled',
        description: _selectBestString(item1.description, item2.description),
        category: _selectBestString(item1.category, item2.category),
        eloScore: max(item1.eloScore, item2.eloScore), // Keep best score
        isCompleted: item2.isCompleted || item1.isCompleted, // Favor completed
        createdAt: item1.createdAt.isBefore(item2.createdAt) ? item1.createdAt : item2.createdAt,
        completedAt: item2.completedAt ?? item1.completedAt,
        dueDate: item1.dueDate ?? item2.dueDate,
        notes: _selectBestString(item1.notes, item2.notes),
        listId: item1.listId,
        lastChosenAt: _selectMostRecentDateTime(item1.lastChosenAt, item2.lastChosenAt),
      );
    }
  }

  CustomList _createListDuplicate(CustomList sourceList) {
    return sourceList.copyWith(
      id: '${sourceList.id}_duplicate_${DateTime.now().millisecondsSinceEpoch}',
      name: '${sourceList.name} (Copy)',
    );
  }

  ListItem _createItemDuplicate(ListItem sourceItem) {
    return sourceItem.copyWith(
      id: '${sourceItem.id}_duplicate_${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  String? _selectBestString(String? str1, String? str2) {
    if (str1 == null && str2 == null) return null;
    if (str1 == null) return str2;
    if (str2 == null) return str1;

    // Prefer non-empty strings
    if (str1.isNotEmpty && str2.isEmpty) return str1;
    if (str2.isNotEmpty && str1.isEmpty) return str2;

    // Prefer longer, more descriptive strings
    return str1.length >= str2.length ? str1 : str2;
  }

  DateTime _getMostRecentDate(ListItem item) {
    final dates = [
      item.completedAt,
      item.lastChosenAt,
      item.createdAt,
    ].where((date) => date != null).cast<DateTime>();

    return dates.isEmpty ? item.createdAt : dates.reduce(
      (a, b) => a.isAfter(b) ? a : b
    );
  }

  DateTime? _selectMostRecentDateTime(DateTime? date1, DateTime? date2) {
    if (date1 == null && date2 == null) return null;
    if (date1 == null) return date2;
    if (date2 == null) return date1;
    return date1.isAfter(date2) ? date1 : date2;
  }
}