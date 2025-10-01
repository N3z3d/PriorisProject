import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/logger_service.dart';
import '../models/lists_state.dart';
import '../interfaces/lists_managers_interfaces.dart';

/// **Validator Pattern** pour la validation des données
///
/// **Single Responsibility Principle (SRP)** : Se concentre uniquement sur la validation
/// **Open/Closed Principle (OCP)** : Extensible pour de nouvelles règles de validation
/// **Data integrity focused** : Garantit la cohérence et l'intégrité des données
class ListsValidationService implements IListsValidationService {
  // === Règles de validation configurables ===
  static const int maxListNameLength = 100;
  static const int maxListDescriptionLength = 500;
  static const int maxItemTitleLength = 200;
  static const int maxItemDescriptionLength = 1000;
  static const int maxItemsPerList = 1000;

  // === Statistiques de validation ===
  int _validationCount = 0;
  int _validationErrorCount = 0;
  final Map<String, int> _errorTypeCount = {};

  @override
  bool validateList(CustomList list) {
    _validationCount++;

    final errors = getListValidationErrors(list);

    if (errors.isNotEmpty) {
      _validationErrorCount++;
      _recordErrorTypes(errors);

      LoggerService.instance.warning(
        'Validation échouée pour la liste "${list.name}": ${errors.join(", ")}',
        context: 'ListsValidationService',
      );
      return false;
    }

    return true;
  }

  @override
  bool validateListItem(ListItem item) {
    _validationCount++;
    final errors = getItemValidationErrors(item);
    if (errors.isNotEmpty) {
      _validationErrorCount++;
      _recordErrorTypes(errors);
      return false;
    }
    return true;
  }

  @override
  bool validateState(ListsState state) {
    _validationCount++;
    final errors = getStateValidationErrors(state);
    if (errors.isNotEmpty) {
      _validationErrorCount++;
      _recordErrorTypes(errors);
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

    if (list.id.isEmpty) errors.add('ID de liste vide');
    if (list.name.trim().isEmpty) errors.add('Nom de liste vide');
    if (list.name.length > maxListNameLength) {
      errors.add('Nom trop long (max $maxListNameLength)');
    }

    return errors;
  }

  @override
  List<String> getItemValidationErrors(ListItem item) {
    final errors = <String>[];

    if (item.id.isEmpty) errors.add('ID vide');
    if (item.title.trim().isEmpty) errors.add('Titre vide');
    if (item.listId.isEmpty) errors.add('ID liste parent vide');

    return errors;
  }

  @override
  List<String> getStateValidationErrors(ListsState state) {
    final errors = <String>[];

    if (state.filteredLists.length > state.lists.length) {
      errors.add('Plus de listes filtrées que totales');
    }

    return errors;
  }

  @override
  List<CustomList> sanitizeLists(List<CustomList> lists) {
    return lists.where((list) => validateList(list)).toList();
  }

  @override
  bool checkReferentialIntegrity(List<CustomList> lists) {
    final listIds = lists.map((list) => list.id).toSet();

    for (final list in lists) {
      for (final item in list.items) {
        if (!listIds.contains(item.listId)) return false;
      }
    }

    return true;
  }

  void _recordErrorTypes(List<String> errors) {
    for (final error in errors) {
      final type = error.toLowerCase().contains('vide') ? 'champs_vides' : 'autres';
      _errorTypeCount[type] = (_errorTypeCount[type] ?? 0) + 1;
    }
  }
}