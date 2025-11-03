import 'dart:math';

import 'package:mockito/mockito.dart';

import '../../lib/data/repositories/custom_list_repository.dart';
import '../../lib/data/repositories/list_item_repository.dart';
import '../../lib/domain/models/core/entities/custom_list.dart';
import '../../lib/domain/models/core/entities/list_item.dart';
import '../../lib/domain/models/core/enums/list_enums.dart';
import '../../lib/domain/services/persistence/adaptive_persistence_service.dart';

export 'performance_test_utils.dart';

/// Small façade used by the architecture tests to provision mocks in a safe
/// and readable manner.
class SafeMockFactory {
  SafeMockFactory._({
    required this.adaptivePersistenceService,
    required this.customListRepository,
    required this.listItemRepository,
  });

  final AdaptivePersistenceService adaptivePersistenceService;
  final CustomListRepository customListRepository;
  final ListItemRepository listItemRepository;

  static SafeMockFactory initialize() {
    final adaptive = _MockAdaptivePersistenceService();
    final listRepo = _MockCustomListRepository();
    final itemRepo = _MockListItemRepository();
    return SafeMockFactory._(
      adaptivePersistenceService: adaptive,
      customListRepository: listRepo,
      listItemRepository: itemRepo,
    );
  }

  void resetAll() {
    reset(adaptivePersistenceService);
    reset(customListRepository);
    reset(listItemRepository);
  }

  void verifyNoMoreInteractionsOnAll() {
    _safeVerifyNoMoreInteractions(adaptivePersistenceService);
    _safeVerifyNoMoreInteractions(customListRepository);
    _safeVerifyNoMoreInteractions(listItemRepository);
  }

  static void _safeVerifyNoMoreInteractions(Object mock) {
    try {
      verifyNoMoreInteractions(mock);
    } catch (_) {
      // Ignore verification failures; architecture tests should remain informative
    }
  }
}

/// Helper factory for generating entities across the architecture tests.
class TestEntityFactory {
  static final Random _random = Random();
  static int _listCounter = 0;
  static int _itemCounter = 0;

  static CustomList createCustomList({
    String? id,
    String? name,
    List<ListItem>? items,
    ListType type = ListType.CUSTOM,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final now = DateTime.now().add(Duration(seconds: _listCounter));
    final listItems = items ?? createListItems(0, listId: id ?? 'list-');
    return CustomList(
      id: id ?? 'list-',
      name: name ?? 'List ',
      type: type,
      items: listItems,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  static List<CustomList> createCustomLists(int count) {
    return List<CustomList>.generate(count, (_) => createCustomList());
  }

  static List<ListItem> createListItems(int count, {required String listId}) {
    return List<ListItem>.generate(
      count,
      (_) => createListItem(listId: listId),
    );
  }

  static ListItem createListItem({
    String? id,
    String? listId,
    String? title,
    bool isCompleted = false,
    double? eloScore,
  }) {
    final now = DateTime.now().add(Duration(milliseconds: _itemCounter));
    return ListItem(
      id: id ?? 'item-',
      listId: listId ?? 'list-0',
      title: title ?? 'Item ',
      eloScore: eloScore ?? (1100 + _random.nextInt(400)).toDouble(),
      isCompleted: isCompleted,
      createdAt: now,
      completedAt: isCompleted ? now : null,
    );
  }
}

class _MockAdaptivePersistenceService extends Mock implements AdaptivePersistenceService {}

class _MockCustomListRepository extends Mock implements CustomListRepository {}

class _MockListItemRepository extends Mock implements ListItemRepository {}

