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

    setUp(() {
      customRepository = InMemoryCustomListRepository();
      listItemRepository = InMemoryListItemRepository();
      container = ProviderContainer(overrides: [
        customListRepositoryProvider.overrideWithValue(customRepository),
        listItemRepositoryProvider.overrideWithValue(listItemRepository),
      ]);
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
  });
}
