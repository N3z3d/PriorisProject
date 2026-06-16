import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/presentation/widgets/dialogs/list_selection_dialog.dart';
import 'package:prioris/domain/core/value_objects/list_prioritization_settings.dart';

void main() {
  group('ListSelectionDialog', () {
    testWidgets('doit afficher le titre du dialog', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'list1', 'title': 'Liste de travail'},
        {'id': 'list2', 'title': 'Liste de courses'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
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

      expect(find.text('Sélectionner les listes à prioriser'), findsOneWidget);
    });

    testWidgets('doit afficher toutes les listes disponibles', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'work-list', 'title': 'Tâches de travail'},
        {'id': 'shopping-list', 'title': 'Liste de courses'},
        {'id': 'personal-list', 'title': 'Tâches personnelles'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
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

      expect(find.text('Tâches de travail'), findsOneWidget);
      expect(find.text('Liste de courses'), findsOneWidget);
      expect(find.text('Tâches personnelles'), findsOneWidget);
    });

    testWidgets('doit afficher les checkboxes cochées par défaut', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
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

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsNWidgets(2));

      for (int i = 0; i < 2; i++) {
        final checkboxWidget = tester.widget<Checkbox>(checkboxes.at(i));
        expect(checkboxWidget.value, isTrue);
      }
    });

    testWidgets('doit permettre de taper sur un checkbox', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const availableLists = [
        {'id': 'work-list', 'title': 'Tâches de travail'},
        {'id': 'shopping-list', 'title': 'Liste de courses'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
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

      final checkboxes = find.byType(Checkbox);
      expect(checkboxes, findsAtLeastNWidgets(1));

      await tester.tap(checkboxes.first);
      await tester.pumpAndSettle();

      expect(find.byType(Checkbox), findsAtLeastNWidgets(1));
    });

    // AC1 — pas de recochage automatique
    testWidgets('AC1: décocher toutes les listes → pas de recochage automatique', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const lists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: lists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      final updatedCheckboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      for (final cb in updatedCheckboxes) {
        expect(cb.value, isFalse, reason: 'Aucun recochage automatique attendu');
      }
    });

    // AC2 — bouton Sauvegarder désactivé quand 0 liste
    testWidgets('AC2: 0 liste cochée → bouton Sauvegarder désactivé', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const lists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: lists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    // AC3 — message d'aide quand 0 liste
    testWidgets('AC3: 0 liste cochée → message d\'aide affiché', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const lists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: lists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      expect(
        find.text('Sélectionne au moins une liste pour pouvoir sauvegarder'),
        findsOneWidget,
      );
    });

    // AC4 — sauvegarder avec 1 liste → callback appelé avec enabledListIds = {'list1'}
    testWidgets('AC4: sauvegarder avec 1 liste → onSettingsChanged appelé correctement', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const lists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      ListPrioritizationSettings? captured;

      // InkRipple évite le shader ink_sparkle.frag qui échoue dans l'env de test
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: lists,
                onSettingsChanged: (s) => captured = s,
              ),
            ),
          ),
        ),
      );

      // Décocher list2 seulement
      final checkboxes = find.byType(Checkbox);
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.enabledListIds, equals({'list1'}));
    });

    // T3.1 — toutes les listes cochées → sauvegarder → defaultSettings()
    testWidgets('T3.1: sauvegarder toutes les listes cochées → defaultSettings() émis', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const lists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      ListPrioritizationSettings? captured;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            theme: ThemeData(splashFactory: InkRipple.splashFactory),
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: lists,
                onSettingsChanged: (s) => captured = s,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(captured, isNotNull);
      expect(captured!.isAllListsEnabled, isTrue);
      expect(captured!.enabledListIds, isEmpty);
    });

    // Edge case — décocher tout puis recocher une liste → bouton réactivé
    testWidgets('Edge case: recocher une liste après tout décoché → bouton réactivé', (tester) async {
      final settings = ListPrioritizationSettings.defaultSettings();
      const lists = [
        {'id': 'list1', 'title': 'Liste 1'},
        {'id': 'list2', 'title': 'Liste 2'},
      ];

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('fr'),
            home: Scaffold(
              body: ListSelectionDialog(
                currentSettings: settings,
                availableLists: lists,
                onSettingsChanged: (_) {},
              ),
            ),
          ),
        ),
      );

      final checkboxes = find.byType(Checkbox);

      // Tout décocher
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();
      await tester.tap(checkboxes.at(1));
      await tester.pumpAndSettle();

      // Bouton désactivé
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNull);

      // Recocher une liste
      await tester.tap(checkboxes.at(0));
      await tester.pumpAndSettle();

      // Bouton réactivé
      expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed, isNotNull);
    });
  });
}
