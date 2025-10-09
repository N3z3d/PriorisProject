import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/charts/progress_chart_widget.dart';
import 'package:prioris/presentation/widgets/charts/premium_progress_chart.dart';

void main() {
  group('ProgressChartWidget', () {
    testWidgets('affiche le titre et le graphique', (tester) async {
      final data = [
        const ChartDataPoint(label: 'Lun', value: 65),
        const ChartDataPoint(label: 'Mar', value: 70),
        const ChartDataPoint(label: 'Mer', value: 68),
        const ChartDataPoint(label: 'Jeu', value: 75),
        const ChartDataPoint(label: 'Ven', value: 80),
        const ChartDataPoint(label: 'Sam', value: 85),
        const ChartDataPoint(label: 'Dim', value: 88),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressChartWidget(
              data: data,
              period: '7_days',
            ),
          ),
        ),
      );

      expect(find.text('�Y"^ �%volution des Performances'), findsOneWidget);
      expect(find.byType(PremiumProgressChart), findsOneWidget);

      final chart = tester.widget<PremiumProgressChart>(
        find.byType(PremiumProgressChart),
      );
      expect(chart.data.length, equals(7));
    });

    testWidgets('expose les labels fournis via les data points', (tester) async {
      final data = [
        const ChartDataPoint(label: 'A', value: 10),
        const ChartDataPoint(label: 'B', value: 20),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProgressChartWidget(
              data: data,
              period: 'custom',
            ),
          ),
        ),
      );

      final chart = tester.widget<PremiumProgressChart>(
        find.byType(PremiumProgressChart),
      );
      expect(chart.data.map((point) => point.label), equals(['A', 'B']));
    });

    testWidgets('génère des données de secours lorsque la liste est vide', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProgressChartWidget(data: []),
          ),
        ),
      );

      final chart = tester.widget<PremiumProgressChart>(
        find.byType(PremiumProgressChart),
      );
      expect(chart.data, isNotEmpty);
    });
  });
}
