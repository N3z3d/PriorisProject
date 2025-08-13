import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/forms/common_dialog.dart';

void main() {
  group('CommonDialog', () {
    testWidgets('affiche le titre', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CommonDialog(title: 'Titre', content: Text('Contenu')),
      ));
      expect(find.text('Titre'), findsOneWidget);
    });

    testWidgets('affiche le contenu', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CommonDialog(title: 'Titre', content: Text('Contenu')),
      ));
      expect(find.text('Contenu'), findsOneWidget);
    });

    testWidgets('affiche les actions si fournies', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CommonDialog(
          title: 'Titre',
          content: const Text('Contenu'),
          actions: [TextButton(onPressed: () {}, child: const Text('OK'))],
        ),
      ));
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('n\'affiche pas d\'actions si non fournies', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CommonDialog(title: 'Titre', content: Text('Contenu')),
      ));
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('utilise le shape arrondi', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: CommonDialog(title: 'Titre', content: Text('Contenu')),
      ));
      final alertDialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
      expect(alertDialog.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('show() affiche le dialogue', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      CommonDialog.show(
        context: tester.element(find.byType(SizedBox)),
        title: 'Titre',
        content: const Text('Contenu'),
      );
      await tester.pump();
      expect(find.text('Titre'), findsOneWidget);
      expect(find.text('Contenu'), findsOneWidget);
    });

    testWidgets('show() affiche les actions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      CommonDialog.show(
        context: tester.element(find.byType(SizedBox)),
        title: 'Titre',
        content: const Text('Contenu'),
        actions: [TextButton(onPressed: () {}, child: const Text('OK'))],
      );
      await tester.pump();
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('show() accepte actions personnalisées', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      CommonDialog.show(
        context: tester.element(find.byType(SizedBox)),
        title: 'Titre',
        content: const Text('Contenu'),
        actions: [TextButton(onPressed: () {}, child: const Text('Fermer'))],
      );
      await tester.pump();
      expect(find.text('Fermer'), findsOneWidget);
    });

    testWidgets('show() accepte plusieurs actions', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      CommonDialog.show(
        context: tester.element(find.byType(SizedBox)),
        title: 'Titre',
        content: const Text('Contenu'),
        actions: [
          TextButton(onPressed: () {}, child: const Text('Oui')),
          TextButton(onPressed: () {}, child: const Text('Non')),
        ],
      );
      await tester.pump();
      expect(find.text('Oui'), findsOneWidget);
      expect(find.text('Non'), findsOneWidget);
    });

    testWidgets('show() peut être appelé plusieurs fois', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
      CommonDialog.show(
        context: tester.element(find.byType(SizedBox)),
        title: 'Titre1',
        content: const Text('Contenu1'),
      );
      await tester.pump();
      CommonDialog.show(
        context: tester.element(find.byType(SizedBox)),
        title: 'Titre2',
        content: const Text('Contenu2'),
      );
      await tester.pump();
      expect(find.text('Titre2'), findsOneWidget);
      expect(find.text('Contenu2'), findsOneWidget);
    });
  });
} 
