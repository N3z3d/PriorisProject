import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/layouts/common_list_tile.dart';

void main() {
  group('CommonListTile', () {
    testWidgets('affiche le titre', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre'),
        ),
      ));
      expect(find.text('Titre'), findsOneWidget);
    });

    testWidgets('affiche le sous-titre si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', subtitle: 'Sous-titre'),
        ),
      ));
      expect(find.text('Sous-titre'), findsOneWidget);
    });

    testWidgets('n\'affiche pas le sous-titre si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre'),
        ),
      ));
      expect(find.text('Sous-titre'), findsNothing);
    });

    testWidgets('affiche le leading si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', leading: const Icon(Icons.star)),
        ),
      ));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('affiche le trailing si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', trailing: const Icon(Icons.arrow_forward)),
        ),
      ));
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('n\'affiche pas le leading si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre'),
        ),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('n\'affiche pas le trailing si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre'),
        ),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('déclenche onTap quand tapé', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', onTap: () => tapped = true),
        ),
      ));
      await tester.tap(find.byType(CommonListTile));
      expect(tapped, isTrue);
    });

    testWidgets('affiche la couleur de fond si sélectionné', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', isSelected: true, selectedColor: Colors.red),
        ),
      ));
      final materialFinder = find.byWidgetPredicate((w) =>
        w is Material && w.child is InkWell
      );
      final material = tester.widget<Material>(materialFinder);
      expect(material.color, Colors.red);
    });

    testWidgets('n\'affiche pas de couleur de fond si non sélectionné', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', isSelected: false),
        ),
      ));
      final materialFinder = find.byWidgetPredicate((w) =>
        w is Material && w.child is InkWell
      );
      final material = tester.widget<Material>(materialFinder);
      expect(material.color, Colors.transparent);
    });

    testWidgets('utilise la couleur de titre personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', titleColor: Colors.green),
        ),
      ));
      final titleText = tester.widget<Text>(find.text('Titre'));
      expect(titleText.style?.color, Colors.green);
    });

    testWidgets('utilise la couleur de sous-titre personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', subtitle: 'Sous-titre', subtitleColor: Colors.orange),
        ),
      ));
      final subtitleText = tester.widget<Text>(find.text('Sous-titre'));
      expect(subtitleText.style?.color, Colors.orange);
    });

    testWidgets('utilise le padding personnalisé', (WidgetTester tester) async {
      const padding = EdgeInsets.all(32);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', padding: padding),
        ),
      ));
      final paddingWidget = tester.widget<Padding>(find.byType(Padding));
      expect(paddingWidget.padding, padding);
    });

    testWidgets('texte du titre en gras', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre'),
        ),
      ));
      final titleText = tester.widget<Text>(find.text('Titre'));
      expect(titleText.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('texte du sous-titre en fontWeight normal', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonListTile(title: 'Titre', subtitle: 'Sous-titre'),
        ),
      ));
      final subtitleText = tester.widget<Text>(find.text('Sous-titre'));
      expect(subtitleText.style?.fontWeight, isNot(FontWeight.w600));
    });
  });
} 
