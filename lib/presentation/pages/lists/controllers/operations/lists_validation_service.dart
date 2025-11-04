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

  final ValidationRuleSet<CustomList> _listRuleSet = ValidationRuleSet([
    (list) => list.id.isEmpty ? 'empty list id' : null,
    (list) => list.name.trim().isEmpty ? 'empty list name' : null,
    (list) => list.name.length > maxListNameLength
        ? 'list name too long (max $maxListNameLength)'
        : null,
    (list) => list.description != null &&
            list.description!.length > maxListDescriptionLength
        ? 'description too long (max $maxListDescriptionLength)'
        : null,
    (list) =>
        list.items.length > maxItemsPerList ? 'too many items (max $maxItemsPerList)' : null,
  ]);

  final ValidationRuleSet<ListItem> _itemRuleSet = ValidationRuleSet([
    (item) => item.id.isEmpty ? 'empty item id' : null,
    (item) => item.title.trim().isEmpty ? 'empty item title' : null,
    (item) => item.title.length > maxItemTitleLength
        ? 'item title too long (max $maxItemTitleLength)'
        : null,
    (item) => item.description != null &&
            item.description!.length > maxItemDescriptionLength
        ? 'item description too long (max $maxItemDescriptionLength)'
        : null,
    (item) => item.listId.isEmpty ? 'empty parent list id' : null,
  ]);

  @override
  bool validateList(CustomList list) {
    return _validate(
      entity: list,
      context: 'list:${list.id}',
      errorProvider: getListValidationErrors,
    );
  }

  @override
  bool validateListItem(ListItem item) {
    return _validate(
      entity: item,
      context: 'item:${item.id}',
      errorProvider: getItemValidationErrors,
    );
  }

  @override
  bool validateState(ListsState state) {
    return _validate(
      entity: state,
      context: 'state',
      errorProvider: getStateValidationErrors,
    );
  }

  @override
  bool validateListsCollection(List<CustomList> lists) {
    for (final list in lists) {
      if (!validateList(list)) return false;
    }
    return checkReferentialIntegrity(lists);
  }

  @override
  List<String> getListValidationErrors(CustomList list) =>
      _listRuleSet.evaluate(list);

  @override
  List<String> getItemValidationErrors(ListItem item) =>
      _itemRuleSet.evaluate(item);

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
  List<CustomList> sanitizeLists(List<CustomList> lists) =>
      lists.where(validateList).toList();

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

  bool _validate<T>({
    required T entity,
    required String context,
    required List<String> Function(T) errorProvider,
  }) {
    _validationCount++;
    final errors = errorProvider(entity);
    if (errors.isNotEmpty) {
      _recordFailure(errors, context);
      return false;
    }
    return true;
  }

}

class ValidationRuleSet<T> {
  ValidationRuleSet(this._rules);

  final List<String? Function(T)> _rules;

  List<String> evaluate(T entity) {
    final errors = <String>[];
    for (final rule in _rules) {
      final result = rule(entity);
      if (result != null) {
        errors.add(result);
      }
    }
    return errors;
  }
}
