import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart' as domain;
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
/// Mock controller for widget tests that need fine-grained verifications.
class MockListsController extends Mock implements ListsController {
  @override
  bool get isLoading => super.noSuchMethod(
    Invocation.getter(#isLoading),
    returnValue: false,
    returnValueForMissingStub: false,
  );

  @override
  Future<void> addMultipleItemsToList(String listId, List<dynamic> entries) {
    return super.noSuchMethod(
      Invocation.method(#addMultipleItemsToList, [listId, entries]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  RemoveListener addListener(void Function(ListsState state) listener, {bool fireImmediately = true}) {
    return super.noSuchMethod(
      Invocation.method(#addListener, [listener], {#fireImmediately: fireImmediately}),
      returnValue: () {},
      returnValueForMissingStub: () {},
    );
  }

  @override
  void removeListener(void Function(ListsState state) listener) {
    return super.noSuchMethod(
      Invocation.method(#removeListener, [listener]),
      returnValue: null,
      returnValueForMissingStub: null,
    );
  }
}

/// Wrapper widget for testing with providers
class TestAppWrapper extends StatelessWidget {
  final Widget child;
  final List<Override> overrides;

  const TestAppWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: child,
      ),
    );
  }
}

/// Helper for creating test widgets with common setup
Widget createTestWidget(Widget child, {List<Override>? overrides}) {
  return TestAppWrapper(
    overrides: overrides ?? [],
    child: child,
  );
}

/// Creates a test provider container with mock repositories
ProviderContainer createTestProviderContainer() {
  return ProviderContainer(
    overrides: [
      listsControllerProvider.overrideWith((ref) {
        final customRepository = InMemoryCustomListRepository();
        final itemRepository = InMemoryListItemRepository();
        final adaptiveService = AdaptivePersistenceService(
          localRepository: customRepository,
          cloudRepository: customRepository,
          localItemRepository: itemRepository,
          cloudItemRepository: itemRepository,
        );
        return ListsController.adaptive(
          adaptiveService,
          domain.ListsFilterService(),
          itemRepository,
        );
      }),
    ],
  );
}
