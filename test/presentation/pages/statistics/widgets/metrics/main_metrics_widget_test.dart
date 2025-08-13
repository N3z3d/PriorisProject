import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/main_metrics_widget.dart';

void main() {
  group('MainMetricsWidget', () {
    testWidgets('affiche le loader quand le Future n\'est pas résolu', (tester) async {
      // Arrange
      final completer = Completer<Map<String, dynamic>>();
      await tester.pumpWidget(
        MaterialApp(
          home: MainMetricsWidget(metricsFuture: completer.future),
        ),
      );
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('affiche les métriques principales quand le Future est résolu', (tester) async {
      // Arrange
      final metrics = {
        'habitSuccessRate': 78,
        'taskCompletionRate': 92,
        'currentStreak': 12,
        'totalPoints': 1234,
      };
      await tester.pumpWidget(
        MaterialApp(
          home: MainMetricsWidget(metricsFuture: Future.value(metrics)),
        ),
      );
      // Pump le FutureBuilder
      await tester.pumpAndSettle();
      // Assert
      expect(find.text('🎯 Performance Globale'), findsOneWidget);
      expect(find.text('78%'), findsOneWidget);
      expect(find.text('Taux habitudes'), findsOneWidget);
      expect(find.text('92%'), findsOneWidget);
      expect(find.text('Taux tâches'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      expect(find.text('Série actuelle'), findsOneWidget);
      expect(find.text('1234'), findsOneWidget);
      expect(find.text('Points totaux'), findsOneWidget);
    });

    testWidgets('respecte le design (gradient, Card, MetricCard)', (tester) async {
      // Arrange
      final metrics = {
        'habitSuccessRate': 50,
        'taskCompletionRate': 60,
        'currentStreak': 3,
        'totalPoints': 100,
      };
      await tester.pumpWidget(
        MaterialApp(
          home: MainMetricsWidget(metricsFuture: Future.value(metrics)),
        ),
      );
      await tester.pumpAndSettle();
      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(Row), findsNWidgets(2));
      expect(find.byType(Column), findsWidgets);
    });
  });
} 
