import '../shared/lists_domain_dependencies.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../shared/validation_rule_set.dart';
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
    (list) => _requireValue(list.id, 'empty list id'),
    (list) => _requireValue(list.name, 'empty list name'),
    (list) => _limitLength(
          list.name,
          maxListNameLength,
          'list name too long (max $maxListNameLength)',
        ),
    (list) => _limitOptionalLength(
          list.description,
          maxListDescriptionLength,
          'description too long (max $maxListDescriptionLength)',
        ),
    (list) => _limitCount(
          list.items.length,
          maxItemsPerList,
          'too many items (max $maxItemsPerList)',
        ),
  ]);

  final ValidationRuleSet<ListItem> _itemRuleSet = ValidationRuleSet([
    (item) => _requireValue(item.id, 'empty item id'),
    (item) => _requireValue(item.title, 'empty item title'),
    (item) => _limitLength(
          item.title,
          maxItemTitleLength,
          'item title too long (max $maxItemTitleLength)',
        ),
    (item) => _limitOptionalLength(
          item.description,
          maxItemDescriptionLength,
          'item description too long (max $maxItemDescriptionLength)',
        ),
    (item) => _requireValue(item.listId, 'empty parent list id'),
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

  static String? _requireValue(String value, String error) =>
      value.trim().isEmpty ? error : null;

  static String? _limitLength(String value, int max, String error) =>
      value.length > max ? error : null;

  static String? _limitOptionalLength(String? value, int max, String error) =>
      value != null && value.length > max ? error : null;

  static String? _limitCount(int count, int max, String error) =>
      count > max ? error : null;
}
