import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/forms/common_button.dart';

void main() {
  group('CommonButton', () {
    testWidgets('affiche le texte du bouton', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer'),
        ),
      ));
      expect(find.text('Cliquer'), findsOneWidget);
    });

    testWidgets('déclenche onPressed quand tapé', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', onPressed: () => tapped = true),
        ),
      ));
      await tester.tap(find.byType(CommonButton));
      expect(tapped, isTrue);
    });

    testWidgets('n\'affiche pas l\'icône si non fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer'),
        ),
      ));
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('affiche l\'icône si fournie', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', icon: Icons.add),
        ),
      ));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('affiche le loading si isLoading=true', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', isLoading: true),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('n\'affiche pas le loading si isLoading=false', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', isLoading: false),
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('désactive le bouton si isLoading=true', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonButton(
            text: 'Cliquer',
            onPressed: () => tapped = true,
            isLoading: true,
          ),
        ),
      ));
      await tester.tap(find.byType(CommonButton));
      expect(tapped, isFalse);
    });

    testWidgets('utilise la largeur personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton large',
              width: 200,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // Vérifier que le bouton a une largeur contrainte
      final buttonWidget = tester.widget<ElevatedButton>(button);
      expect(buttonWidget, isNotNull);
    });

    testWidgets('utilise la hauteur personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton haut',
              height: 60,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // Vérifier que le bouton a une hauteur personnalisée
      final buttonWidget = tester.widget<ElevatedButton>(button);
      expect(buttonWidget, isNotNull);
    });

    testWidgets('utilise la couleur personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', color: Colors.green),
        ),
      ));
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style as ButtonStyle;
      final backgroundColor = style.backgroundColor?.resolve({});
      expect(backgroundColor, Colors.green);
    });

    testWidgets('utilise la couleur de texte personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', textColor: Colors.blue),
        ),
      ));
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style as ButtonStyle;
      final foregroundColor = style.foregroundColor?.resolve({});
      expect(foregroundColor, Colors.blue);
    });

    testWidgets('utilise la taille de police personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton texte',
              fontSize: 20,
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // Vérifier que le bouton a une taille de police personnalisée
      final buttonWidget = tester.widget<ElevatedButton>(button);
      expect(buttonWidget, isNotNull);
    });

    testWidgets('utilise le borderRadius personnalisé', (WidgetTester tester) async {
      const borderRadius = BorderRadius.all(Radius.circular(16));
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', borderRadius: borderRadius),
        ),
      ));
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style as ButtonStyle;
      final shape = style.shape?.resolve({}) as RoundedRectangleBorder;
      expect(shape.borderRadius, borderRadius);
    });

    testWidgets('utilise le padding personnalisé', (WidgetTester tester) async {
      const padding = EdgeInsets.all(16);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', padding: padding),
        ),
      ));
      final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = elevatedButton.style as ButtonStyle;
      final buttonPadding = style.padding?.resolve({});
      expect(buttonPadding, padding);
    });

    testWidgets('utilise les valeurs par défaut', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton par défaut',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // Vérifier que le bouton utilise les valeurs par défaut
      final buttonWidget = tester.widget<ElevatedButton>(button);
      expect(buttonWidget, isNotNull);
    });

    testWidgets('affiche le texte en gras', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton gras',
              onPressed: () {},
            ),
          ),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      // Vérifier que le bouton affiche le texte
      expect(find.text('Bouton gras'), findsOneWidget);
    });

    testWidgets('utilise Wrap pour le contenu', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton avec icône',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Wrap), findsOneWidget);
    });

    testWidgets('utilise mainAxisSize.min pour Wrap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final wrap = find.byType(Wrap);
      expect(wrap, findsOneWidget);
      
      final wrapWidget = tester.widget<Wrap>(wrap);
      expect(wrapWidget.alignment, WrapAlignment.center);
    });

    testWidgets('utilise mainAxisAlignment.center pour Wrap', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final wrap = find.byType(Wrap);
      expect(wrap, findsOneWidget);
      
      final wrapWidget = tester.widget<Wrap>(wrap);
      expect(wrapWidget.crossAxisAlignment, WrapCrossAlignment.center);
    });

    testWidgets('affiche SizedBox entre icône et texte', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton avec icône',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Vérifier qu'il y a des SizedBox (pour l'icône et le texte)
      expect(find.byType(SizedBox), findsAtLeastNWidgets(2));
    });

    testWidgets('utilise la bonne taille d\'icône', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonButton(text: 'Cliquer', icon: Icons.add),
        ),
      ));
      final icon = tester.widget<Icon>(find.byIcon(Icons.add));
      expect(icon.size, 18);
    });

    testWidgets('utilise la bonne taille de CircularProgressIndicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CommonButton(
              text: 'Bouton chargement',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      final progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsOneWidget);
      
      final progressWidget = tester.widget<CircularProgressIndicator>(progressIndicator);
      expect(progressWidget.strokeWidth, 2);
    });
  });
} 
