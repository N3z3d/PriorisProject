import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_error_display.dart';

void main() {
  group('SampleDataErrorDisplay', () {
    const testErrorMessage = 'Une erreur est survenue lors de l\'import';

    testWidgets('should display error message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataErrorDisplay(errorMessage: testErrorMessage),
          ),
        ),
      );

      // Vérifier que le message d'erreur est affiché
      expect(find.text(testErrorMessage), findsOneWidget);
      
      // Vérifier que l'icône d'erreur est présente
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataErrorDisplay(errorMessage: testErrorMessage),
          ),
        ),
      );

      // Vérifier la structure Container avec Row
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(SizedBox), findsAtLeastNWidgets(1));
    });

    testWidgets('should have correct styling with red theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataErrorDisplay(errorMessage: testErrorMessage),
          ),
        ),
      );

      // Vérifier que l'icône est rouge
      final icon = tester.widget<Icon>(find.byIcon(Icons.error));
      expect(icon.color, Colors.red);
    });

    testWidgets('should handle long error messages', (WidgetTester tester) async {
      const longErrorMessage = 'Une erreur très longue qui pourrait déborder sur plusieurs lignes et nécessiter un widget Expanded pour être correctement affichée dans l\'interface utilisateur';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataErrorDisplay(errorMessage: longErrorMessage),
          ),
        ),
      );

      // Vérifier que le message long est affiché
      expect(find.text(longErrorMessage), findsOneWidget);
      
      // Vérifier que le Text est dans un Expanded
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded, isNotNull);
    });

    testWidgets('should handle empty error message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SampleDataErrorDisplay(errorMessage: ''),
          ),
        ),
      );

      // Vérifier que le widget se rend correctement même avec un message vide
      expect(find.byType(Container), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });
  });
} 
