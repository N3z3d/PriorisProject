import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../../models/lists_state.dart';
import '../../interfaces/lists_managers_interfaces.dart';

class ListsValidationService implements IListsValidationService {
  static const int maxListNameLength = 100;
  static const int maxListDescriptionLength = 500;
  static const int maxItemTitleLength = 200;
  static const int maxItemDescriptionLength = 1000;
  static const int maxItemsPerList = 1000;

  int _validationCount = 0;
  int _validationErrorCount = 0;
  final Map<String, int> _errorTypeCount = {};

  @override
  bool validateList(CustomList list) {
    _validationCount++;
    final errors = getListValidationErrors(list);
    if (errors.isNotEmpty) {
      _recordFailure(errors, 'list:${list.id}');
      return false;
    }
    return true;
  }

  @override
  bool validateListItem(ListItem item) {
    _validationCount++;
    final errors = getItemValidationErrors(item);
    if (errors.isNotEmpty) {
      _recordFailure(errors, 'item:${item.id}');
      return false;
    }
    return true;
  }

  @override
  bool validateState(ListsState state) {
    _validationCount++;
    final errors = getStateValidationErrors(state);
    if (errors.isNotEmpty) {
      _recordFailure(errors, 'state');
      return false;
    }
    return true;
  }

  @override
  bool validateListsCollection(List<CustomList> lists) {
    for (final list in lists) {
      if (!validateList(list)) return false;
    }
    return checkReferentialIntegrity(lists);
  }

  @override
  List<String> getListValidationErrors(CustomList list) {
    final errors = <String>[];

    if (list.id.isEmpty) errors.add('empty list id');
    if (list.name.trim().isEmpty) errors.add('empty list name');
    if (list.name.length > maxListNameLength) {
      errors.add('list name too long (max $maxListNameLength)');
    }
    if (list.description != null && list.description!.length > maxListDescriptionLength) {
      errors.add('description too long (max $maxListDescriptionLength)');
    }
    if (list.items.length > maxItemsPerList) {
      errors.add('too many items (max $maxItemsPerList)');
    }

    return errors;
  }

  @override
  List<String> getItemValidationErrors(ListItem item) {
    final errors = <String>[];

    if (item.id.isEmpty) errors.add('empty item id');
    if (item.title.trim().isEmpty) errors.add('empty item title');
    if (item.title.length > maxItemTitleLength) {
      errors.add('item title too long (max $maxItemTitleLength)');
    }
    final description = item.description;
    if (description != null && description.length > maxItemDescriptionLength) {
      errors.add('item description too long (max $maxItemDescriptionLength)');
    }
    if (item.listId.isEmpty) errors.add('empty parent list id');

    return errors;
  }

  @override
  List<String> getStateValidationErrors(ListsState state) {
    final errors = <String>[];

    if (state.filteredLists.length > state.lists.length) {
      errors.add('filtered lists exceed total lists');
    }
    if (!state.isValid) {
      errors.add('state invariant violated');
    }

    return errors;
  }

  @override
  List<CustomList> sanitizeLists(List<CustomList> lists) {
    return lists.where(validateList).toList();
  }

  @override
  bool checkReferentialIntegrity(List<CustomList> lists) {
    final listIds = lists.map((list) => list.id).toSet();
    for (final list in lists) {
      for (final item in list.items) {
        if (!listIds.contains(item.listId)) {
          return false;
        }
      }
    }
    return true;
  }

  void _recordFailure(List<String> errors, String context) {
    _validationErrorCount++;
    for (final error in errors) {
      final key = error.contains('empty') ? 'empty_fields' : 'other';
      _errorTypeCount[key] = (_errorTypeCount[key] ?? 0) + 1;
    }

    LoggerService.instance.warning(
      'Validation failed for $context: ${errors.join(', ')}',
      context: 'ListsValidationService',
    );
  }
}
