import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/pages/statistics/widgets/smart/period_selector.dart';

void main() {
  testWidgets('PeriodSelector affiche les bonnes périodes et sélectionne correctement', (WidgetTester tester) async {
    String selected = '7_days';
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PeriodSelector(
            selectedPeriod: selected,
            onPeriodChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    // Vérifie la présence des labels
    expect(find.text('7 jours'), findsOneWidget);
    expect(find.text('30 jours'), findsOneWidget);
    expect(find.text('3 mois'), findsOneWidget);
    expect(find.text('1 an'), findsOneWidget);

    // Vérifie que le chip sélectionné est bien le premier
    final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip)).toList();
    expect(chips[0].selected, isTrue);
    expect(chips[1].selected, isFalse);

    // Simule un tap sur le chip "30 jours"
    await tester.tap(find.text('30 jours'));
    await tester.pumpAndSettle();
    // Le callback doit avoir changé la valeur
    expect(selected, equals('30_days'));
  });
} 
