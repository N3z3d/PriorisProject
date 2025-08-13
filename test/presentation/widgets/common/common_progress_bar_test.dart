import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/displays/common_progress_bar.dart';

void main() {
  group('CommonProgressBar', () {
    testWidgets('affiche le label si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50, label: 'Progression'),
        ),
      ));
      expect(find.text('Progression'), findsOneWidget);
    });

    testWidgets('n\'affiche pas de label si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50),
        ),
      ));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('affiche le pourcentage si showPercentage=true', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 25, maxValue: 100, showPercentage: true),
        ),
      ));
      expect(find.text('25%'), findsOneWidget);
    });

    testWidgets('n\'affiche pas le pourcentage si showPercentage=false', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 25, maxValue: 100, showPercentage: false),
        ),
      ));
      expect(find.text('25%'), findsNothing);
    });

    testWidgets('utilise la couleur personnalisée si fournie', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50, color: Colors.red),
        ),
      ));
      final fractionallyBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      final container = (fractionallyBox.child as Container);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.color, Colors.red);
    });

    testWidgets('utilise la hauteur personnalisée si fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50, height: 24),
        ),
      ));
      final containerFinder = find.byType(Container).at(1);
      final renderBox = tester.renderObject<RenderBox>(containerFinder);
      expect(renderBox.size.height, 24);
    });

    testWidgets('utilise la valeur maxValue si fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 30, maxValue: 60, showPercentage: true),
        ),
      ));
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('gère value > maxValue (clamp à 100%)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 150, maxValue: 100, showPercentage: true),
        ),
      ));
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('gère value < 0 (clamp à 0%)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: -10, maxValue: 100, showPercentage: true),
        ),
      ));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('gère maxValue = 0 (affiche 0%)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 10, maxValue: 0, showPercentage: true),
        ),
      ));
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('utilise le borderRadius personnalisé si fourni', (WidgetTester tester) async {
      const borderRadius = BorderRadius.all(Radius.circular(20));
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50, borderRadius: borderRadius),
        ),
      ));
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, borderRadius);
    });

    testWidgets('utilise le padding personnalisé si fourni', (WidgetTester tester) async {
      const padding = EdgeInsets.all(32);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50, padding: padding),
        ),
      ));
      final paddingWidget = tester.widget<Padding>(find.byType(Padding).first);
      expect(paddingWidget.padding, padding);
    });

    testWidgets('affiche la barre de fond grise', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50),
        ),
      ));
      final containers = tester.widgetList<Container>(find.byType(Container));
      final hasGreyBackground = containers.any((c) => (c.decoration as BoxDecoration?)?.color == Colors.grey[200]);
      expect(hasGreyBackground, isTrue);
    });

    testWidgets('affiche la barre de progression colorée', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50),
        ),
      ));
      final fractionallyBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      final container = (fractionallyBox.child as Container);
      final boxDecoration = container.decoration as BoxDecoration;
      expect(boxDecoration.color, isNot(Colors.grey[200]));
    });

    testWidgets('affiche la bonne largeur de barre (50%)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 50, maxValue: 100),
        ),
      ));
      final fractionallyBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fractionallyBox.widthFactor, 0.5);
    });

    testWidgets('affiche la bonne largeur de barre (0%)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 0, maxValue: 100),
        ),
      ));
      final fractionallyBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fractionallyBox.widthFactor, 0.0);
    });

    testWidgets('affiche la bonne largeur de barre (100%)', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 100, maxValue: 100),
        ),
      ));
      final fractionallyBox = tester.widget<FractionallySizedBox>(find.byType(FractionallySizedBox));
      expect(fractionallyBox.widthFactor, 1.0);
    });

    testWidgets('supporte les valeurs décimales', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 33.3, maxValue: 100, showPercentage: true),
        ),
      ));
      expect(find.text('33%'), findsOneWidget);
    });

    testWidgets('supporte les très grandes valeurs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonProgressBar(value: 100000, maxValue: 100000, showPercentage: true),
        ),
      ));
      expect(find.text('100%'), findsOneWidget);
    });
  });
} 
