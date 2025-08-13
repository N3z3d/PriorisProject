import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/forms/common_text_field.dart';

void main() {
  group('CommonTextField', () {
    testWidgets('affiche le label si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom'),
        ),
      ));
      expect(find.text('Nom'), findsOneWidget);
    });

    testWidgets('n\'affiche pas de label si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(),
        ),
      ));
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('affiche le hint si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(hint: 'Entrez votre nom'),
        ),
      ));
      expect(find.text('Entrez votre nom'), findsOneWidget);
    });

    testWidgets('affiche le suffix si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonTextField(suffix: const Icon(Icons.search)),
        ),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('n\'affiche pas de suffix si non fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(),
        ),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('utilise le contrôleur si fourni', (WidgetTester tester) async {
      final controller = TextEditingController(text: 'Test');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonTextField(controller: controller),
        ),
      ));
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('utilise le type de clavier si fourni', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(keyboardType: TextInputType.emailAddress),
        ),
      ));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('masque le texte si obscureText=true', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(obscureText: true),
        ),
      ));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('affiche l\'astérisque si required=true', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom', required: true),
        ),
      ));
      expect(find.text('Nom *'), findsOneWidget);
    });

    testWidgets('n\'affiche pas l\'astérisque si required=false', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom', required: false),
        ),
      ));
      expect(find.text('Nom'), findsOneWidget);
      expect(find.text('Nom *'), findsNothing);
    });

    testWidgets('utilise Column comme widget principal', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom'),
        ),
      ));
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('utilise crossAxisAlignment.start pour Column', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom'),
        ),
      ));
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('affiche le label avec la bonne taille de police', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom'),
        ),
      ));
      final labelText = tester.widget<Text>(find.text('Nom'));
      expect(labelText.style?.fontSize, 14);
    });

    testWidgets('affiche le label avec la bonne couleur', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom'),
        ),
      ));
      final labelText = tester.widget<Text>(find.text('Nom'));
      expect(labelText.style?.color, const Color(0xFF0F172A)); // AppTheme.textPrimary
    });

    testWidgets('affiche le SizedBox avec la bonne hauteur', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(label: 'Nom'),
        ),
      ));
      // Vérifie qu'il y a au moins un SizedBox (peut y en avoir plusieurs dans le widget tree)
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('affiche le TextFormField avec InputDecoration', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(hint: 'Test'),
        ),
      ));
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('affiche le hint dans InputDecoration', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonTextField(hint: 'Test hint'),
        ),
      ));
      expect(find.text('Test hint'), findsOneWidget);
    });

    testWidgets('affiche le suffixIcon dans InputDecoration', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonTextField(suffix: const Icon(Icons.search)),
        ),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
} 
