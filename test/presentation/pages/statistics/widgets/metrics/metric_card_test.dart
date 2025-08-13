import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/summary/metric_card.dart';

void main() {
  testWidgets('MetricCard affiche la valeur, le label et l\'icône correctement', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetricCard(
            value: '42',
            label: 'Réussite',
            icon: Icons.star,
            color: Colors.blue,
          ),
        ),
      ),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('Réussite'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
} 
