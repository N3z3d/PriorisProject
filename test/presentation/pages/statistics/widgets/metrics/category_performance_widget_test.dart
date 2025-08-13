import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/analytics/category_performance_widget.dart';

void main() {
  group('CategoryPerformanceWidget', () {
    testWidgets('affiche les catégories avec leurs pourcentages', (tester) async {
      final categories = {
        'Bien-être': 85.0,
        'Travail': 72.0,
        'Sport': 80.0,
      };
      await tester.pumpWidget(
        MaterialApp(
          home: CategoryPerformanceWidget(categories: categories),
        ),
      );
      expect(find.text('📊 Performance par Catégorie'), findsOneWidget);
      expect(find.text('Bien-être'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
      expect(find.text('Travail'), findsOneWidget);
      expect(find.text('72%'), findsOneWidget);
      expect(find.text('Sport'), findsOneWidget);
      expect(find.text('80%'), findsOneWidget);
    });

    testWidgets('affiche les barres de progression', (tester) async {
      final categories = {'Test': 50.0};
      await tester.pumpWidget(
        MaterialApp(
          home: CategoryPerformanceWidget(categories: categories),
        ),
      );
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('supporte une map vide sans crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CategoryPerformanceWidget(categories: const {}),
        ),
      );
      expect(find.text('📊 Performance par Catégorie'), findsOneWidget);
    });
  });
} 
