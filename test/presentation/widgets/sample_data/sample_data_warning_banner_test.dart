import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_warning_banner.dart';

void main() {
  group('SampleDataWarningBanner', () {
    testWidgets('should display warning message with correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataWarningBanner(),
          ),
        ),
      );

      // Vérifier que le message d'avertissement est affiché
      expect(find.text('Des données existent déjà. L\'import remplacera toutes les données actuelles.'), findsOneWidget);
      
      // Vérifier que l'icône d'avertissement est présente
      expect(find.byIcon(Icons.warning), findsOneWidget);
      
      // Vérifier que le widget est dans un Container avec le bon style
      final container = tester.widget<Container>(find.byType(Container));
      expect(container, isNotNull);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataWarningBanner(),
          ),
        ),
      );

      // Vérifier la structure Row avec Icon et Text
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('should have correct text styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataWarningBanner(),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontWeight, FontWeight.w500);
    });
  });
} 
