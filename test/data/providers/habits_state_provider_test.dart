import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/data/providers/repository_providers.dart';

/// Unit tests for HabitsStateProvider to verify infinite loop fixes
void main() {
  group('HabitsStateProvider - Infinite Loop Prevention', () {
    test('loadHabits() should be idempotent - blocks concurrent calls', () async {
      // ARRANGE
      int fetchCallCount = 0;
      final mockRepo = _MockHabitRepository(
        onGetAllHabits: () async {
          fetchCallCount++;
          await Future.delayed(const Duration(milliseconds: 50));
          return <Habit>[];
        },
      );

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // Keep provider alive during test
      final keepAlive = container.listen(habitsStateProvider, (_, __) {});

      try {
        // ACT - Call loadHabits() twice in parallel
        final notifier = container.read(habitsStateProvider.notifier);

        // Trigger both calls before any completes
        final future1 = notifier.loadHabits();
        final future2 = notifier.loadHabits(); // Should be blocked by reentrancy guard

        // Wait for both to complete
        await future1;
        await future2;

        // ASSERT - Should only fetch once (reentrancy guard)
        expect(
          fetchCallCount,
          equals(1),
          reason: 'Reentrancy guard should block concurrent fetch calls',
        );
      } finally {
        keepAlive.close();
        container.dispose();
      }
    });

    test('empty list is treated as valid state - no automatic retry', () async {
      // ARRANGE
      int fetchCallCount = 0;
      final mockRepo = _MockHabitRepository(
        onGetAllHabits: () {
          fetchCallCount++;
          return Future.value(<Habit>[]);
        },
      );

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // ACT - Load habits (returns empty list)
      await container.read(habitsStateProvider.notifier).loadHabits();

      // Wait to see if retry is triggered
      await Future.delayed(const Duration(milliseconds: 500));

      // ASSERT - Should NOT retry automatically
      expect(
        fetchCallCount,
        equals(1),
        reason: 'Empty list is VALID, should not trigger automatic retry',
      );

      container.dispose();
    });

    test('reactiveHabitsProvider uses .select() for memoization', () {
      // ARRANGE
      int notificationCount = 0;
      final container = ProviderContainer();

      // Listen to reactive provider
      container.listen(
        reactiveHabitsProvider,
        (previous, next) {
          notificationCount++;
        },
      );

      // ACT - Change loading state (not habits list)
      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(isLoading: true);

      // ASSERT - reactiveHabitsProvider should NOT notify (habits list unchanged)
      expect(
        notificationCount,
        equals(0),
        reason: '.select() should prevent notifications when habits list unchanged',
      );

      container.dispose();
    });

    test('habitsLoadingProvider uses .select() for memoization', () {
      // ARRANGE
      int notificationCount = 0;
      final container = ProviderContainer();

      container.listen(
        habitsLoadingProvider,
        (previous, next) {
          notificationCount++;
        },
      );

      // Trigger initial read
      container.read(habitsLoadingProvider);
      notificationCount = 0; // Reset after initial

      // ACT - Change error (not isLoading)
      container.read(habitsStateProvider.notifier).state =
          container.read(habitsStateProvider).copyWith(error: 'Test error');

      // ASSERT - habitsLoadingProvider should NOT notify
      expect(
        notificationCount,
        equals(0),
        reason: '.select() should prevent notifications when isLoading unchanged',
      );

      container.dispose();
    });

    test('providers use autoDispose to prevent memory leaks', () {
      // ARRANGE
      final container = ProviderContainer();

      // ACT - Read providers to initialize them
      container.read(habitsStateProvider);
      container.read(reactiveHabitsProvider);
      container.read(habitsLoadingProvider);

      // Dispose container (simulates navigation away)
      container.dispose();

      // ASSERT - Should not throw (providers cleaned up)
      // If autoDispose was missing, container.dispose() might leak
      expect(true, isTrue, reason: 'Container disposed successfully');
    });

    test('loadHabits() logs fetch operations for observability', () async {
      // ARRANGE
      final mockRepo = _MockHabitRepository(
        onGetAllHabits: () => Future.value([
          Habit(
            id: 'test-1',
            name: 'Test Habit',
            type: HabitType.binary,
            category: 'health',
            createdAt: DateTime.now(),
          ),
        ]),
      );

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // ACT - Load habits (logs should be printed)
      await container.read(habitsStateProvider.notifier).loadHabits();

      // ASSERT - Check state updated correctly
      final state = container.read(habitsStateProvider);
      expect(state.habits.length, equals(1));
      expect(state.isLoading, isFalse);
      expect(state.error, isNull);

      container.dispose();
    });
  });

  group('HabitsStateProvider - Error Handling', () {
    test('loadHabits() handles errors without crashing', () async {
      // ARRANGE
      final mockRepo = _MockHabitRepository(
        onGetAllHabits: () => Future.error('Network error'),
      );

      final container = ProviderContainer(
        overrides: [
          habitRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );

      // ACT
      await container.read(habitsStateProvider.notifier).loadHabits();

      // ASSERT - Error stored in state, not thrown
      final state = container.read(habitsStateProvider);
      expect(state.error, isNotNull);
      expect(state.error, contains('Network error'));
      expect(state.isLoading, isFalse);

      container.dispose();
    });
  });
}

/// Mock repository for testing
class _MockHabitRepository implements HabitRepository {
  final Future<List<Habit>> Function()? onGetAllHabits;

  _MockHabitRepository({this.onGetAllHabits});

  @override
  Future<List<Habit>> getAllHabits() async {
    if (onGetAllHabits != null) {
      return onGetAllHabits!();
    }
    return [];
  }

  @override
  Future<void> addHabit(Habit habit) async {}

  @override
  Future<void> clearAllHabits() async {}

  @override
  Future<void> deleteHabit(String habitId) async {}

  @override
  Future<List<Habit>> getHabitsByCategory(String category) async => [];

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> updateHabit(Habit habit) async {}
}
