import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/data/providers/list_providers.dart';
import 'package:prioris/data/providers/clean_repository_providers.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart' show CustomListRepository, InMemoryCustomListRepository;
import 'package:prioris/data/repositories/list_item_repository.dart' show ListItemRepository, InMemoryListItemRepository;
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('List Providers', () {
    late ProviderContainer container;
    late InMemoryCustomListRepository customRepository;
    late InMemoryListItemRepository listItemRepository;
    late DateTime now;

    ProviderContainer _createContainer({
      InMemoryCustomListRepository? customRepo,
      InMemoryListItemRepository? itemRepo,
    }) {
      customRepository = customRepo ?? InMemoryCustomListRepository();
      listItemRepository = itemRepo ?? InMemoryListItemRepository();
      return ProviderContainer(overrides: [
        customListRepositoryProvider.overrideWithValue(customRepository),
        listItemRepositoryProvider.overrideWithValue(listItemRepository),
      ]);
    }

    setUp(() {
      container = _createContainer();
      now = DateTime(2024, 1, 1, 12, 0, 0);
    });

    tearDown(() {
      container.dispose();
    });

    group('Repository Providers', () {
      test('should provide CustomListRepository', () {
        final repository = container.read(customListRepositoryProvider);
        expect(repository, same(customRepository));
      });

      test('should provide ListItemRepository', () {
        final repository = container.read(listItemRepositoryProvider);
        expect(repository, same(listItemRepository));
      });
    });

    group('Consolidated Providers', () {
      test('should provide consolidated lists provider', () {
        final state = container.read(consolidatedListsProvider);
        expect(state, isA<ConsolidatedListsState>());
        expect(state.rawLists, isEmpty);
        expect(state.processedLists, isEmpty);
        expect(state.isLoading, false);
      });

      test('should provide processed lists', () {
        final lists = container.read(processedListsProvider);
        expect(lists, isA<List<CustomList>>());
        expect(lists, isEmpty);
      });

      test('should provide statistics', () {
        final stats = container.read(listsStatisticsProvider);
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['global'], isNotNull);
      });

      test('should expose stable default stats structure', () {
        final stats = container.read(listsStatisticsProvider);
        expect(stats, {
          'global': {
            'totalLists': 0,
            'totalItems': 0,
            'completedItems': 0,
            'averageProgress': 0.0,
            'trend': 'stable',
          },
          'byType': <String, dynamic>{},
        });
      });

      test('should provide configuration', () {
        final config = container.read(listsConfigProvider);
        expect(config, isA<ListsConfig>());
        expect(config.searchQuery, isEmpty);
        expect(config.showCompleted, true);
      });
    });

    group('Legacy Providers (Deprecated)', () {
      test('should provide all custom lists (deprecated)', () {
        final lists = container.read(allCustomListsProvider);
        expect(lists, isA<List<CustomList>>());
        expect(lists, isEmpty);
      });

      test('should filter by type (deprecated)', () {
        final shoppingLists = container.read(customListsByTypeProvider(ListType.SHOPPING));
        expect(shoppingLists, isA<List<CustomList>>());
        expect(shoppingLists, isEmpty);
      });

      test('should provide stats (deprecated)', () {
        final stats = container.read(customListsStatsProvider);
        expect(stats, isA<Map<String, dynamic>>());
      });

      test('should search lists (deprecated)', () {
        final results = container.read(customListsSearchProvider('test'));
        expect(results, isA<List<CustomList>>());
        expect(results, isEmpty);
      });
    });

    group('Integration Tests', () {
      test('should work with consolidated provider', () async {
        // Test avec données réelles
        final repository = container.read(customListRepositoryProvider);
        final list = CustomList(
          id: 'test-list',
          name: 'Test List',
          type: ListType.SHOPPING,
          createdAt: now,
          updatedAt: now,
        );

        await repository.saveList(list);

        // Forcer le rechargement du provider consolidé
        await container.read(consolidatedListsProvider.notifier).loadLists();

        final state = container.read(consolidatedListsProvider);
        expect(state.rawLists.length, 1);
        expect(state.processedLists.length, 1);
        expect(state.rawLists.first.name, 'Test List');
      });
    });

    // --- 8.9 int cast tests ---

    group('Advanced Filters - int cast (story 8.9)', () {
      test('should apply minProgress filter with int value without CastError and include matching list', () async {
        final c = _createContainer();
        final repo = c.read(customListRepositoryProvider);
        final list = CustomList(
          id: 'int-filter-list',
          name: 'Int Filter List',
          type: ListType.SHOPPING,
          createdAt: now,
          updatedAt: now,
        );
        await repo.saveList(list);
        await c.read(consolidatedListsProvider.notifier).loadLists();

        final config = c.read(listsConfigProvider);
        // Before fix: (value as double) throws CastError for int
        // After fix: (value as num).toDouble() works — 0.0 >= 0.0 is true
        c.read(consolidatedListsProvider.notifier).updateConfig(
          config.copyWith(advancedFilters: {'minProgress': 0}), // int, pas 0.0
        );

        final stateAfter = c.read(consolidatedListsProvider);
        // List with getProgress() == 0.0 satisfies minProgress: 0 (0.0 >= 0.0)
        expect(stateAfter.processedLists.length, 1);
        c.dispose();
      });

      test('should apply maxProgress filter with int value without CastError and include matching list', () async {
        final c = _createContainer();
        final repo = c.read(customListRepositoryProvider);
        final list = CustomList(
          id: 'int-filter-list-max',
          name: 'Int Filter List Max',
          type: ListType.SHOPPING,
          createdAt: now,
          updatedAt: now,
        );
        await repo.saveList(list);
        await c.read(consolidatedListsProvider.notifier).loadLists();

        final config = c.read(listsConfigProvider);
        // Before fix: (value as double) throws CastError for int
        // After fix: (value as num).toDouble() works — 0.0 <= 100.0 is true
        c.read(consolidatedListsProvider.notifier).updateConfig(
          config.copyWith(advancedFilters: {'maxProgress': 100}), // int, pas 100.0
        );

        final stateAfter = c.read(consolidatedListsProvider);
        // List with getProgress() == 0.0 satisfies maxProgress: 100 (0.0 <= 100.0)
        expect(stateAfter.processedLists.length, 1);
        c.dispose();
      });

      test('should exclude list when int minProgress filter exceeds list progress', () async {
        final c = _createContainer();
        final repo = c.read(customListRepositoryProvider);
        final list = CustomList(
          id: 'int-filter-list-exclude',
          name: 'Int Filter List Exclude',
          type: ListType.SHOPPING,
          createdAt: now,
          updatedAt: now,
        );
        await repo.saveList(list);
        await c.read(consolidatedListsProvider.notifier).loadLists();

        final config = c.read(listsConfigProvider);
        c.read(consolidatedListsProvider.notifier).updateConfig(
          config.copyWith(advancedFilters: {'minProgress': 50}), // int — empty list has 0% progress
        );

        final stateAfter = c.read(consolidatedListsProvider);
        // List with getProgress() == 0.0 does NOT satisfy minProgress: 50 (0.0 >= 50.0 is false)
        expect(stateAfter.processedLists.length, 0);
        c.dispose();
      });
    });
  });
}
