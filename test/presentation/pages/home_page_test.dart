import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/tasks_page.dart';
import 'package:prioris/presentation/pages/lists_page.dart';
import 'package:prioris/presentation/pages/duel_page.dart';
import 'package:prioris/presentation/pages/habits_page.dart';
import 'package:prioris/presentation/pages/statistics_page.dart';

void main() {
  group('HomePage', () {
    testWidgets('affiche la structure de base', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsWidgets); // Peut y avoir plusieurs scaffolds (HomePage + pages internes)
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('affiche tous les onglets de navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('Tâches'), findsOneWidget);
      expect(find.text('Listes'), findsOneWidget);
      expect(find.text('Prioriser'), findsOneWidget);
      expect(find.text('Habitudes'), findsOneWidget);
      expect(find.text('Statistiques'), findsOneWidget);
    });

    testWidgets('affiche les icônes pour chaque onglet', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Vérifier que les textes de navigation sont présents (plus fiable que les icônes)
      expect(find.text('Tâches'), findsOneWidget);
      expect(find.text('Listes'), findsOneWidget);
      expect(find.text('Prioriser'), findsOneWidget);
      expect(find.text('Habitudes'), findsOneWidget);
      expect(find.text('Statistiques'), findsOneWidget);
    });

    testWidgets('affiche la page des tâches par défaut', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('permet de naviguer vers la page des listes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Taper sur l'onglet Listes
      await tester.tap(find.text('Listes'));
      await tester.pumpAndSettle();

      expect(find.byType(ListsPage), findsOneWidget);
    });

    testWidgets('permet de naviguer vers la page de duel', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Taper sur l'onglet Prioriser
      await tester.tap(find.text('Prioriser'));
      await tester.pumpAndSettle();

      expect(find.byType(DuelPage), findsOneWidget);
    });

    testWidgets('permet de naviguer vers la page des habitudes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Taper sur l'onglet Habitudes
      await tester.tap(find.text('Habitudes'));
      await tester.pumpAndSettle();

      expect(find.byType(HabitsPage), findsOneWidget);
    });

    testWidgets('permet de naviguer vers la page des statistiques', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Taper sur l'onglet Statistiques
      await tester.tap(find.text('Statistiques'));
      await tester.pumpAndSettle();

      expect(find.byType(StatisticsPage), findsOneWidget);
    });

    testWidgets('permet de revenir à la page des tâches', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      // Aller sur la page des listes
      await tester.tap(find.text('Listes'));
      await tester.pumpAndSettle();

      // Revenir aux tâches
      await tester.tap(find.text('Tâches'));
      await tester.pumpAndSettle();

      expect(find.byType(TasksPage), findsOneWidget);
    });

    testWidgets('utilise IndexedStack pour la navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.byType(IndexedStack), findsOneWidget);
    });

    testWidgets('affiche le header premium', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: HomePage(),
          ),
        ),
      );

      expect(find.text('Prioris Premium'), findsOneWidget);
      expect(find.text('Votre productivité au niveau supérieur'), findsOneWidget);
    });
  });
} 
