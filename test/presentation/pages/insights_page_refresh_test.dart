import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/habits_state_provider.dart';
import 'package:prioris/data/repositories/habit_repository.dart';
import 'package:prioris/domain/habit/repositories/habit_repository.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/insights_page.dart';

class _MockHabitRepository implements HabitRepository {
  int getAllHabitsCallCount = 0;
  List<Habit> habits;

  _MockHabitRepository({this.habits = const []});

  @override
  Future<List<Habit>> getAllHabits() async {
    getAllHabitsCallCount++;
    return List.from(habits);
  }

  @override
  Future<void> saveHabit(Habit habit) async {}
  @override
  Future<void> addHabit(Habit habit) async {}
  @override
  Future<void> updateHabit(Habit habit) async {}
  @override
  Future<void> deleteHabit(String habitId) async {}
  @override
  Future<List<Habit>> getHabitsByCategory(String category) async => [];
  @override
  Future<void> clearAllHabits() async {}
}

Widget _buildApp(ProviderContainer container) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: InsightsPage()),
    ),
  );
}

void _setTestViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  group('InsightsPage — rafraîchissement au changement d\'onglet', () {
    testWidgets(
      'T1 — naviguer vers Insights (index 3) déclenche loadHabits',
      (tester) async {
        _setTestViewport(tester);
        final mockRepo = _MockHabitRepository();
        final container = ProviderContainer(
          overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildApp(container));
        await tester.pump(); // let initState postFrameCallback complete

        final countAfterInit = mockRepo.getAllHabitsCallCount;
        expect(countAfterInit, greaterThanOrEqualTo(1),
            reason: 'initState doit appeler loadHabits au démarrage');

        // Simulate navigation to Insights tab (index 3)
        container.read(currentPageProvider.notifier).state = 3;
        await tester.pump();

        expect(
          mockRepo.getAllHabitsCallCount,
          greaterThan(countAfterInit),
          reason: 'Naviguer vers l\'onglet Insights doit déclencher loadHabits',
        );
      },
    );

    testWidgets(
      'T2 — habitsStateProvider mis à jour → InsightsPage rebuilt avec nouvelles données',
      (tester) async {
        _setTestViewport(tester);
        final mockRepo = _MockHabitRepository(); // empty habits
        final container = ProviderContainer(
          overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildApp(container));
        await tester.pump(); // complete initState

        // With empty habits, empty state title should be visible
        expect(find.text("Pas encore d'analyses"), findsWidgets);

        // Add a habit to state directly (bypassing loadHabits)
        final habit = Habit(id: 'h1', name: 'Méditer', type: HabitType.binary);
        container.read(habitsStateProvider.notifier).state =
            container.read(habitsStateProvider).copyWith(habits: [habit]);
        await tester.pump();

        // Empty state should no longer be shown
        expect(find.text("Pas encore d'analyses"), findsNothing);
      },
    );

    testWidgets(
      'T3 — naviguer hors d\'Insights puis revenir redéclenche loadHabits',
      (tester) async {
        _setTestViewport(tester);
        final mockRepo = _MockHabitRepository();
        final container = ProviderContainer(
          overrides: [habitRepositoryProvider.overrideWithValue(mockRepo)],
        );
        addTearDown(container.dispose);

        await tester.pumpWidget(_buildApp(container));
        await tester.pump(); // complete initState

        // First visit to Insights
        container.read(currentPageProvider.notifier).state = 3;
        await tester.pump();
        final countAfterFirstVisit = mockRepo.getAllHabitsCallCount;

        // Navigate away to another tab
        container.read(currentPageProvider.notifier).state = 1;
        await tester.pump();

        expect(mockRepo.getAllHabitsCallCount, equals(countAfterFirstVisit),
            reason: 'Naviguer hors d\'Insights ne doit pas déclencher loadHabits');

        // Navigate back to Insights
        container.read(currentPageProvider.notifier).state = 3;
        await tester.pump();

        expect(
          mockRepo.getAllHabitsCallCount,
          greaterThan(countAfterFirstVisit),
          reason: 'Revenir sur l\'onglet Insights doit déclencher un nouveau loadHabits',
        );
      },
    );
  });
}
