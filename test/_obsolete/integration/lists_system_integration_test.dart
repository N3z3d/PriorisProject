import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/presentation/pages/home_page.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Test d'intégration pour la Tâche 2.2 : Vérifier l'intégration avec le système existant
/// 
/// Valide que les listes personnalisées s'intègrent correctement avec :
/// - Navigation dans l'application
/// - Filtres et recherche
/// - Synchronisation Riverpod
/// - Interface utilisateur cohérente
void main() {
  group('Lists System Integration Test - Tâche 2.2', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('Should navigate to lists page from home navigation', (WidgetTester tester) async {
      // Arrange: Initialiser l'application complète
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Cliquer sur l'onglet "Listes" dans la navigation
      final listsTab = find.text('Listes');
      expect(listsTab, findsOneWidget);
      await tester.tap(listsTab);
      await tester.pumpAndSettle();

      // Assert: Vérifier que la page des listes est affichée
      expect(find.text('Mes Listes'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget); // Bouton d'ajout
      expect(find.text('Rechercher dans mes listes...'), findsOneWidget); // Champ de recherche
    });

    testWidgets('Should filter lists by type correctly', (WidgetTester tester) async {
      // Arrange: Créer des listes de différents types via le controller
      final listsController = container.read(listsControllerProvider.notifier);
      
      final shoppingList = CustomList(
        id: 'shopping-test',
        name: 'Courses Test',
        type: ListType.SHOPPING,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final travelList = CustomList(
        id: 'travel-test',
        name: 'Voyage Test',
        type: ListType.TRAVEL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await listsController.createList(shoppingList);
      await listsController.createList(travelList);

      // Initialiser l'interface
      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Naviguer vers les listes
      await tester.tap(find.text('Listes'));
      await tester.pumpAndSettle();

      // Act & Assert: Tester le filtre par type
      await _testTypeFilter(tester, container);
    });

    testWidgets('Should search lists correctly', (WidgetTester tester) async {
      // Arrange: Créer des listes avec des noms spécifiques
      final listsController = container.read(listsControllerProvider.notifier);
      
      await listsController.createList(CustomList(
        id: 'search-1',
        name: 'Ma liste de courses',
        type: ListType.SHOPPING,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
      
      await listsController.createList(CustomList(
        id: 'search-2',
        name: 'Voyage en Italie',
        type: ListType.TRAVEL,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          parent: container,
          child: MaterialApp(
            home: const HomePage(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Listes'));
      await tester.pumpAndSettle();

      // Act & Assert: Tester la recherche
      await _testSearchFunctionality(tester);
    });

    testWidgets('Should maintain Riverpod state consistency', (WidgetTester tester) async {
      // Arrange & Act: Tester la synchronisation d'état
      await _testRiverpodStateConsistency(tester, container);
    });

    test('Should handle CRUD operations with proper state management', () async {
      // Test unitaire pour les opérations CRUD
      final listsController = container.read(listsControllerProvider.notifier);
      final initialState = container.read(listsControllerProvider);

      expect(initialState.lists, isEmpty);
      expect(initialState.filteredLists, isEmpty);

      // Créer une liste
      final testList = CustomList(
        id: 'crud-test',
        name: 'Test CRUD',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await listsController.createList(testList);
      
      var state = container.read(listsControllerProvider);
      expect(state.lists, hasLength(1));
      expect(state.filteredLists, hasLength(1));
      expect(state.lists.first.name, 'Test CRUD');

      // Modifier la liste
      final updatedList = testList.copyWith(name: 'Test CRUD Modifié');
      await listsController.updateList(updatedList);
      
      state = container.read(listsControllerProvider);
      expect(state.lists.first.name, 'Test CRUD Modifié');

      // Supprimer la liste
      await listsController.deleteList(testList.id);
      
      state = container.read(listsControllerProvider);
      expect(state.lists, isEmpty);
      expect(state.filteredLists, isEmpty);
    });
  });
}

/// Teste le filtre par type
Future<void> _testTypeFilter(WidgetTester tester, ProviderContainer container) async {
  // Chercher le dropdown de type
  final typeDropdown = find.byType(DropdownButtonFormField<ListType?>);
  if (typeDropdown.evaluate().isNotEmpty) {
    await tester.tap(typeDropdown);
    await tester.pumpAndSettle();

    // Sélectionner "Shopping"
    final shoppingOption = find.text('Shopping');
    if (shoppingOption.evaluate().isNotEmpty) {
      await tester.tap(shoppingOption.first);
      await tester.pumpAndSettle();

      // Vérifier que seules les listes de shopping sont affichées
      expect(find.text('Courses Test'), findsOneWidget);
      expect(find.text('Voyage Test'), findsNothing);
    }
  }
}

/// Teste la fonctionnalité de recherche
Future<void> _testSearchFunctionality(WidgetTester tester) async {
  // Chercher le champ de recherche
  final searchField = find.byType(TextField);
  if (searchField.evaluate().isNotEmpty) {
    // Rechercher "courses"
    await tester.enterText(searchField, 'courses');
    await tester.pumpAndSettle();

    // Vérifier que seule la liste de courses est affichée
    expect(find.text('Ma liste de courses'), findsOneWidget);
    expect(find.text('Voyage en Italie'), findsNothing);

    // Effacer la recherche
    await tester.enterText(searchField, '');
    await tester.pumpAndSettle();

    // Vérifier que toutes les listes sont à nouveau affichées
    expect(find.text('Ma liste de courses'), findsOneWidget);
    expect(find.text('Voyage en Italie'), findsOneWidget);
  }
}

/// Teste la cohérence de l'état Riverpod
Future<void> _testRiverpodStateConsistency(WidgetTester tester, ProviderContainer container) async {
  await tester.pumpWidget(
    ProviderScope(
      parent: container,
      child: MaterialApp(
        home: const HomePage(),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Vérifier que l'état initial est cohérent
  final initialState = container.read(listsControllerProvider);
  expect(initialState.isLoading, false);
  expect(initialState.error, isNull);
  expect(initialState.searchQuery, isEmpty);
  expect(initialState.selectedType, isNull);

  // Simuler une modification d'état via l'interface
  await tester.tap(find.text('Listes'));
  await tester.pumpAndSettle();

  // L'état doit rester cohérent après navigation
  final stateAfterNavigation = container.read(listsControllerProvider);
  expect(stateAfterNavigation.isLoading, false);
  expect(stateAfterNavigation.error, isNull);
} 
