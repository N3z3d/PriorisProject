import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/presentation/theme/app_theme.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';

// Generate mocks with custom names to avoid conflicts
@GenerateMocks([], customMocks: [
  MockSpec<ListsController>(as: #MockListsControllerTest),
  MockSpec<CustomListRepository>(as: #MockCustomListRepositoryTest),
  MockSpec<ListItemRepository>(as: #MockListItemRepositoryTest),
  MockSpec<ListsFilterService>(as: #MockListsFilterServiceTest),
])
import 'test_providers.mocks.dart';

/// Mock controller for testing - uses generated mock
class MockListsController extends MockListsControllerTest {
  @override
  bool get isLoading => super.noSuchMethod(
    Invocation.getter(#isLoading),
    returnValue: false,
    returnValueForMissingStub: false,
  );

  @override
  Future<void> addMultipleItemsToList(String? listId, List<String>? itemTitles) {
    return super.noSuchMethod(
      Invocation.method(#addMultipleItemsToList, [listId, itemTitles]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value(),
    );
  }

  @override
  RemoveListener addListener(void Function(ListsState)? listener, {bool? fireImmediately = true}) {
    return super.noSuchMethod(
      Invocation.method(#addListener, [listener], {#fireImmediately: fireImmediately}),
      returnValue: () {},
      returnValueForMissingStub: () {},
    );
  }

  @override
  void removeListener(void Function(ListsState)? listener) {
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
      // Override repositories with in-memory versions for testing
      listsControllerProvider.overrideWith((ref) {
        final mockController = MockListsController();
        // Initialize with empty state
        when(mockController.state).thenReturn(const ListsState(
          lists: [],
          filteredLists: [],
          isLoading: false,
        ));
        return mockController;
      }),
    ],
  );
}