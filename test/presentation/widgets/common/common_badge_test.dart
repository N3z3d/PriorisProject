import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/displays/common_badge.dart';

void main() {
  group('CommonBadge', () {
    testWidgets('affiche le texte du badge', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      expect(find.text('Badge'), findsOneWidget);
    });

    testWidgets('utilise la couleur de fond personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge', color: Colors.red),
        ),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });

    testWidgets('utilise la couleur de texte personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge', textColor: Colors.green),
        ),
      ));
      final text = tester.widget<Text>(find.text('Badge'));
      expect(text.style?.color, Colors.green);
    });

    testWidgets('utilise la taille de police personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge', fontSize: 20),
        ),
      ));
      final text = tester.widget<Text>(find.text('Badge'));
      expect(text.style?.fontSize, 20);
    });

    testWidgets('utilise le padding personnalisé', (WidgetTester tester) async {
      const padding = EdgeInsets.all(16);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge', padding: padding),
        ),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, padding);
    });

    testWidgets('utilise le borderRadius personnalisé', (WidgetTester tester) async {
      const borderRadius = BorderRadius.all(Radius.circular(8));
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge', borderRadius: borderRadius),
        ),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, borderRadius);
    });

    testWidgets('utilise la couleur de fond par défaut si non fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNotNull);
    });

    testWidgets('utilise la couleur de texte par défaut si non fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      final text = tester.widget<Text>(find.text('Badge'));
      expect(text.style?.color, isNotNull);
    });

    testWidgets('utilise la taille de police par défaut si non fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      final text = tester.widget<Text>(find.text('Badge'));
      expect(text.style?.fontSize, 13.0);
    });

    testWidgets('utilise le padding par défaut si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, const EdgeInsets.symmetric(horizontal: 12, vertical: 4));
    });

    testWidgets('utilise le borderRadius par défaut si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('texte centré et gras', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonBadge(text: 'Badge'),
        ),
      ));
      final text = tester.widget<Text>(find.text('Badge'));
      expect(text.textAlign, TextAlign.center);
      expect(text.style?.fontWeight, FontWeight.w600);
    });
  });
} 
