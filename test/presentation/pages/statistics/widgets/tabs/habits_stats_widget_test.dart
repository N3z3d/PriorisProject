import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/habits_stats_widget.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/stat_item.dart';

void main() {
  group('HabitsStatsWidget', () {
    testWidgets('affiche les statistiques des habitudes', (tester) async {
      final habits = [
        Habit(name: 'Test 1', type: HabitType.binary, category: 'Santé'),
        Habit(name: 'Test 2', type: HabitType.binary, category: 'Sport'),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: HabitsStatsWidget(habits: habits),
        ),
      );
      expect(find.text('🎯 Statistiques des Habitudes'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Habitudes actives
      expect(find.text('Habitudes actives'), findsOneWidget);
      expect(find.text('Taux moyen'), findsOneWidget);
      expect(find.text('Série la plus longue'), findsOneWidget);
      expect(find.text('Moyenne/jour'), findsOneWidget);
    });

    testWidgets('supporte une liste vide sans crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: HabitsStatsWidget(habits: const []),
        ),
      );
      expect(find.text('🎯 Statistiques des Habitudes'), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // Habitudes actives
    });

    testWidgets('affiche les StatItem avec les bonnes icônes', (tester) async {
      final habits = [Habit(name: 'Test', type: HabitType.binary, category: 'Santé')];
      await tester.pumpWidget(
        MaterialApp(
          home: HabitsStatsWidget(habits: habits),
        ),
      );
      expect(find.byType(StatItem), findsNWidgets(4));
    });
  });
} 

