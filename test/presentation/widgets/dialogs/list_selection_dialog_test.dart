import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/widgets/dialogs/list_selection_dialog.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';

/// Tests TDD pour le dialog de sélection des listes
/// Red -> Green -> Refactor
void main() {
  group('ListSelectionDialog', () {
    testWidgets('doit afficher le titre du dialog', (tester) async {
      // Arrange
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'list1', 'title': 'Liste de travail'},
        {'id': 'list2', 'title': 'Liste de courses'},
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: availableLists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Sélectionner les listes à prioriser'), findsOneWidget);
    });

    testWidgets('doit afficher toutes les listes disponibles', (tester) async {
      // Arrange
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'work-list', 'title': 'Tâches de travail'},
        {'id': 'shopping-list', 'title': 'Liste de courses'},
        {'id': 'personal-list', 'title': 'Tâches personnelles'},
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: availableLists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Tâches de travail'), findsOneWidget);
      expect(find.text('Liste de courses'), findsOneWidget);
      expect(find.text('Tâches personnelles'), findsOneWidget);
    });

    testWidgets('doit afficher les switches en état activé par défaut', (tester) async {
      // Arrange
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: availableLists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Assert - tous les checkboxes doivent être cochés (mode par défaut)
      // Widget uses Checkbox now, not Switch
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(2));

      for (int i = 0; i < 2; i++) {
        final checkboxWidget = tester.widget<Checkbox>(checkboxes.at(i));
        expect(checkboxWidget.value, isTrue);
      }
    });

    testWidgets('doit permettre de taper sur un switch', (tester) async {
      // Arrange
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'work-list', 'title': 'Tâches de travail'},
        {'id': 'shopping-list', 'title': 'Liste de courses'},
      ];

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: availableLists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      // Trouver et taper sur un checkbox
      // Widget uses Checkbox now, not Switch
      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsAtLeastNWidgets(1));

      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      // Assert - l'UI doit répondre sans erreur
      expect(find.byType(Checkbox), findsAtLeastNWidgets(1));
    });
  });
}