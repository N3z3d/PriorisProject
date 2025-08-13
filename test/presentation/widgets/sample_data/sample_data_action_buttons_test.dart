import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/presentation/widgets/sample_data/sample_data_action_buttons.dart';

void main() {
  group('SampleDataActionButtons', () {
    bool cancelPressed = false;
    bool importPressed = false;

    void resetCallbacks() {
      cancelPressed = false;
      importPressed = false;
    }

    void onCancel() {
      cancelPressed = true;
    }

    void onImport() {
      importPressed = true;
    }

    setUp(() {
      resetCallbacks();
    });

    testWidgets('should display both buttons when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: false,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Vérifier que les deux boutons sont présents
      expect(find.text('Annuler'), findsOneWidget);
      expect(find.text('Importer'), findsOneWidget);
      
      // Vérifier qu'il n'y a pas d'indicateur de chargement
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should show loading indicator when isLoading is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: true,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Vérifier que l'indicateur de chargement est présent
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Vérifier que le texte "Importer" n'est pas affiché
      expect(find.text('Importer'), findsNothing);
    });

    testWidgets('should disable buttons when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: true,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Vérifier que les boutons sont désactivés
      final cancelButton = tester.widget<TextButton>(find.byType(TextButton));
      final importButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      
      expect(cancelButton.onPressed, isNull);
      expect(importButton.onPressed, isNull);
    });

    testWidgets('should enable buttons when not loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: false,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Vérifier que les boutons sont activés
      final cancelButton = tester.widget<TextButton>(find.byType(TextButton));
      final importButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      
      expect(cancelButton.onPressed, isNotNull);
      expect(importButton.onPressed, isNotNull);
    });

    testWidgets('should call onCancel when cancel button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: false,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Appuyer sur le bouton Annuler
      await tester.tap(find.text('Annuler'));
      await tester.pump();

      // Vérifier que le callback a été appelé
      expect(cancelPressed, isTrue);
      expect(importPressed, isFalse);
    });

    testWidgets('should call onImport when import button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: false,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Appuyer sur le bouton Importer
      await tester.tap(find.text('Importer'));
      await tester.pump();

      // Vérifier que le callback a été appelé
      expect(importPressed, isTrue);
      expect(cancelPressed, isFalse);
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: false,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Vérifier la structure Row
      expect(find.byType(Row), findsOneWidget);
      
      // Vérifier les types de boutons
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should have correct alignment', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SampleDataActionButtons(
              isLoading: false,
              onCancel: onCancel,
              onImport: onImport,
            ),
          ),
        ),
      );

      // Vérifier que le Row a l'alignement correct
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.end);
    });
  });
} 
