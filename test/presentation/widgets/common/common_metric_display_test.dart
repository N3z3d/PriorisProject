import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/common/displays/common_metric_display.dart';

void main() {
  group('CommonMetricDisplay', () {
    testWidgets('affiche la valeur et le label correctement', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
          ),
        ),
      ));

      expect(find.text('42'), findsOneWidget);
      expect(find.text('Points'), findsOneWidget);
    });

    testWidgets('affiche l\'icône si fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            icon: Icons.star,
          ),
        ),
      ));

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('n\'affiche pas l\'icône si non fournie', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
          ),
        ),
      ));

      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('utilise la couleur personnalisée pour l\'icône', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            icon: Icons.star,
            color: Colors.red,
          ),
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.color, Colors.red);
    });

    testWidgets('utilise la couleur personnalisée pour la valeur', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            color: Colors.red,
            isHighlighted: true,
          ),
        ),
      ));

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.color, Colors.red);
    });

    testWidgets('utilise la couleur personnalisée pour la valeur (non highlightée)', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            color: Colors.red,
            isHighlighted: false,
          ),
        ),
      ));

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.color, Colors.black87);
    });

    testWidgets('applique la mise en évidence avec isHighlighted=true', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            color: Colors.blue,
            isHighlighted: true,
          ),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.blue.withValues(alpha: 0.1));
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('n\'applique pas la mise en évidence avec isHighlighted=false', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            isHighlighted: false,
          ),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.decoration, isNull);
    });

    testWidgets('utilise la taille d\'icône personnalisée', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            icon: Icons.star,
            iconSize: 48.0,
          ),
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.star));
      expect(icon.size, 48.0);
    });

    testWidgets('utilise la taille de police personnalisée pour la valeur', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            valueFontSize: 32.0,
          ),
        ),
      ));

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.fontSize, 32.0);
    });

    testWidgets('utilise la taille de police personnalisée pour le label', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            labelFontSize: 18.0,
          ),
        ),
      ));

      final labelText = tester.widget<Text>(find.text('Points'));
      expect(labelText.style?.fontSize, 18.0);
    });

    testWidgets('utilise la couleur personnalisée pour le label', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            labelColor: Colors.orange,
          ),
        ),
      ));

      final labelText = tester.widget<Text>(find.text('Points'));
      expect(labelText.style?.color, Colors.orange);
    });

    testWidgets('utilise la couleur personnalisée valueColor', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            valueColor: Colors.green,
          ),
        ),
      ));

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.color, Colors.green);
    });

    testWidgets('utilise l\'espacement personnalisé', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            icon: Icons.star,
            spacing: 16.0,
          ),
        ),
      ));

      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(2));

      final spacingSizedBox = tester.widget<SizedBox>(sizedBoxes.at(1));
      expect(spacingSizedBox.height, 16.0);
    });

    testWidgets('utilise l\'alignement personnalisé', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('utilise le padding personnalisé', (WidgetTester tester) async {
      const padding = EdgeInsets.all(32);
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
            padding: padding,
          ),
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container));
      expect(container.padding, padding);
    });

    testWidgets('centre le texte par défaut', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
          ),
        ),
      ));

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.textAlign, TextAlign.center);

      final labelText = tester.widget<Text>(find.text('Points'));
      expect(labelText.textAlign, TextAlign.center);
    });

    testWidgets('utilise mainAxisSize.min pour la Column', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
          ),
        ),
      ));

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('affiche la valeur en gras par défaut', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
          ),
        ),
      ));

      final valueText = tester.widget<Text>(find.text('42'));
      expect(valueText.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('affiche le label avec fontWeight.w500 par défaut', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: CommonMetricDisplay(
            value: '42',
            label: 'Points',
          ),
        ),
      ));

      final labelText = tester.widget<Text>(find.text('Points'));
      expect(labelText.style?.fontWeight, FontWeight.w500);
    });
  });
} 
