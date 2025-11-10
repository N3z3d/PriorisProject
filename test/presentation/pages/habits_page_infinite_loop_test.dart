import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/habits_page.dart';

/// TDD-RED: Tests proving infinite loop in HabitsPage
/// These tests MUST fail initially, then pass after fix
void main() {
  group('HabitsPage - Infinite Loop Prevention (TDD-RED)', () {
    testWidgets(
      'RED: should NOT call loadHabits() during build when habits are empty',
      (tester) async {
        // ARRANGE - Track fetch calls
        int fetchCallCount = 0;

        final testNotifier = _TestHabitsNotifier(
          onLoadHabits: () => fetchCallCount++,
          initialHabits: [],
        );

        final container = ProviderContainer(
          overrides: [
            habitsStateProvider.overrideWith((ref) => testNotifier),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: HabitsPage(),
            ),
          ),
        );

        // ACT - Let UI settle (multiple frames to catch build() loops)
        await tester.pumpAndSettle();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // ASSERT - Fetch should be called at most ONCE (in initState)
        // NOT repeatedly in build()
        expect(
          fetchCallCount,
          lessThanOrEqualTo(1),
          reason: 'BUG: loadHabits() called $fetchCallCount times! '
              'Fetch is being triggered in build() causing infinite loop',
        );
      },
    );

    testWidgets(
      'RED: should NOT rebuild infinitely when habits list is empty',
      (tester) async {
        // ARRANGE - Track rebuild count
        int buildCount = 0;

        final testNotifier = _TestHabitsNotifier(
          onBuild: () => buildCount++,
          initialHabits: [],
        );

        final container = ProviderContainer(
          overrides: [
            habitsStateProvider.overrideWith((ref) => testNotifier),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: HabitsPage(),
            ),
          ),
        );

        // ACT - Initial render
        await tester.pumpAndSettle();
        final initialBuildCount = buildCount;

        // Wait for potential loops
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        // ASSERT - Build count should be stable (max 2-3 for initial layout)
        expect(
          buildCount,
          lessThan(initialBuildCount + 5),
          reason: 'BUG: Page rebuilt $buildCount times! '
              'Empty list triggers infinite rebuild loop',
        );
      },
    );

    testWidgets(
      'RED: providers should use memoization to prevent unnecessary rebuilds',
      (tester) async {
        // ARRANGE - Track provider notifications
        int habitsProviderNotifications = 0;
        int loadingProviderNotifications = 0;

        final container = ProviderContainer();

        // Listen to providers
        container.listen(
          reactiveHabitsProvider,
          (previous, next) => habitsProviderNotifications++,
        );
        container.listen(
          habitsLoadingProvider,
          (previous, next) => loadingProviderNotifications++,
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: HabitsPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Reset counters after initial build
        habitsProviderNotifications = 0;
        loadingProviderNotifications = 0;

        // ACT - Trigger state change that doesn't affect habits list
        container.read(habitsStateProvider.notifier).clearError();
        await tester.pump();

        // ASSERT - habitsProviderNotifications should NOT increase
        // (because habits list itself didn't change)
        expect(
          habitsProviderNotifications,
          equals(0),
          reason: 'BUG: reactiveHabitsProvider notified despite habits list unchanged! '
              'Missing .select() memoization causes unnecessary rebuilds',
        );
      },
    );
  });

  group('HabitsPage - Empty List Handling (TDD-RED)', () {
    testWidgets(
      'RED: empty habits list should NOT trigger automatic retry',
      (tester) async {
        // ARRANGE
        int fetchCallCount = 0;

        final testNotifier = _TestHabitsNotifier(
          onLoadHabits: () => fetchCallCount++,
          initialHabits: [],
        );

        final container = ProviderContainer(
          overrides: [
            habitsStateProvider.overrideWith((ref) => testNotifier),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: HabitsPage(),
            ),
          ),
        );

        // ACT - Let everything settle
        await tester.pumpAndSettle();
        final fetchCountAfterInit = fetchCallCount;

        // Wait to see if retry is triggered
        await tester.pump(const Duration(seconds: 2));
        await tester.pumpAndSettle();

        // ASSERT - No additional fetches should occur
        expect(
          fetchCallCount,
          equals(fetchCountAfterInit),
          reason: 'BUG: Empty list triggered retry! '
              'Empty list is VALID state, not an error requiring retry',
        );
      },
    );

    testWidgets(
      'RED: should display empty state UI, not loading spinner indefinitely',
      (tester) async {
        // ARRANGE
        final testNotifier = _TestHabitsNotifier(
          initialHabits: [],
          initialLoading: false,
        );

        final container = ProviderContainer(
          overrides: [
            habitsStateProvider.overrideWith((ref) => testNotifier),
          ],
        );

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: HabitsPage(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // ASSERT - Should show empty state, not loading indicator
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(
          find.textContaining('No habits'),
          findsAtLeastNWidgets(1),
          reason: 'BUG: Empty state UI not shown! '
              'Users see infinite spinner instead of empty state',
        );
      },
    );
  });
}

/// Test implementation of HabitsNotifier
class _TestHabitsNotifier extends HabitsNotifier {
  final VoidCallback? onBuild;
  final VoidCallback? onLoadHabits;
  final List<Habit> initialHabits;
  final bool initialLoading;

  _TestHabitsNotifier({
    this.onBuild,
    this.onLoadHabits,
    this.initialHabits = const [],
    this.initialLoading = false,
  }) : super(_DummyRef()) {
    onBuild?.call();

    // Set initial state
    state = HabitsState(
      habits: initialHabits,
      isLoading: initialLoading,
      error: null,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  Future<void> loadHabits() async {
    onLoadHabits?.call();

    // Simulate loading behavior
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 10));
    state = state.copyWith(
      habits: initialHabits,
      isLoading: false,
      lastUpdated: DateTime.now(),
    );
  }
}

/// Dummy Ref for testing
class _DummyRef implements Ref {
  @override
  T read<T>(ProviderListenable<T> provider) => throw UnimplementedError();

  @override
  ProviderSubscription<T> listen<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) => throw UnimplementedError();

  @override
  T watch<T>(ProviderListenable<T> provider) => throw UnimplementedError();

  @override
  void invalidate(ProviderOrFamily provider) => throw UnimplementedError();

  @override
  void onDispose(void Function() cb) {}

  @override
  State get context => throw UnimplementedError();

  @override
  bool exists(ProviderBase<Object?> provider) => throw UnimplementedError();

  @override
  ProviderContainer get container => throw UnimplementedError();

  @override
  ProviderSubscription<T> listenManual<T>(
    ProviderListenable<T> provider,
    void Function(T? previous, T next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
    bool fireImmediately = false,
  }) => throw UnimplementedError();

  @override
  T refresh<T>(Refreshable<T> provider) => throw UnimplementedError();

  @override
  void invalidateSelf() => throw UnimplementedError();

  @override
  KeepAliveLink keepAlive() => throw UnimplementedError();

  @override
  void listenSelf(
    void Function(Object? previous, Object? next) listener, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) => throw UnimplementedError();

  @override
  void notifyListeners() => throw UnimplementedError();

  @override
  void onAddListener(void Function() cb) => throw UnimplementedError();

  @override
  void onCancel(void Function() cb) => throw UnimplementedError();

  @override
  void onRemoveListener(void Function() cb) => throw UnimplementedError();

  @override
  void onResume(void Function() cb) => throw UnimplementedError();
}
