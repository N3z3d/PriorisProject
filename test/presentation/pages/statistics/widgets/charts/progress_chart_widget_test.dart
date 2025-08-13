import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/progress_chart_widget.dart';

void main() {
  group('ProgressChartWidget', () {
    testWidgets('affiche le titre et le graphique', (tester) async {
      // Arrange
      final data = [
        const FlSpot(0, 65),
        const FlSpot(1, 70),
        const FlSpot(2, 68),
        const FlSpot(3, 75),
        const FlSpot(4, 80),
        const FlSpot(5, 85),
        const FlSpot(6, 88),
      ];
      final labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
      await tester.pumpWidget(
        MaterialApp(
          home: ProgressChartWidget(data: data, periodLabels: labels),
        ),
      );
      // Assert
      expect(find.text('📈 Évolution des Performances'), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
    });

    testWidgets('affiche les labels d\'axe X', (tester) async {
      // Arrange
      final data = [const FlSpot(0, 10), const FlSpot(1, 20)];
      final labels = ['A', 'B'];
      await tester.pumpWidget(
        MaterialApp(
          home: ProgressChartWidget(data: data, periodLabels: labels),
        ),
      );
      // Assert
      expect(find.text('A'), findsWidgets);
      expect(find.text('B'), findsWidgets);
    });

    testWidgets('supporte une liste vide sans crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProgressChartWidget(data: const [], periodLabels: const []),
        ),
      );
      expect(find.byType(LineChart), findsOneWidget);
    });
  });
} 
