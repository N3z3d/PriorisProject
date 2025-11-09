import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('CustomList Model - Tests Complets', () {
    late CustomList testList;
    late ListItem testItem1;
    late ListItem testItem2;

    setUp(() {
      testItem1 = ListItem(
        id: 'item1',
        title: 'Item 1',
        description: 'Description 1',
        eloScore: 1400.0, // Score ELO élevé (équivalent HIGH priority)
        isCompleted: true,
        createdAt: DateTime(2024, 1, 1),
      );

      testItem2 = ListItem(
        id: 'item2',
        title: 'Item 2',
        description: 'Description 2',
        eloScore: 1200.0, // Score ELO moyen (équivalent MEDIUM priority)
        isCompleted: false,
        createdAt: DateTime(2024, 1, 2),
      );

      testList = CustomList(
        id: 'test_list',
        name: 'Liste de test',
        description: 'Description de test',
        type: ListType.SHOPPING,
        items: [testItem1, testItem2],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );
    });

    group('Constructeur et propriétés', () {
      test('crée une liste avec toutes les propriétés', () {
        expect(testList.id, equals('test_list'));
        expect(testList.name, equals('Liste de test'));
        expect(testList.description, equals('Description de test'));
        expect(testList.type, equals(ListType.SHOPPING));
        expect(testList.items, hasLength(2));
        expect(testList.createdAt, equals(DateTime(2024, 1, 1)));
        expect(testList.updatedAt, equals(DateTime(2024, 1, 15)));
      });

      test('crée une liste avec des valeurs minimales', () {
        final minimalList = CustomList(
          id: 'minimal',
          name: 'Minimal',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(minimalList.id, equals('minimal'));
        expect(minimalList.name, equals('Minimal'));
        expect(minimalList.description, isNull);
        expect(minimalList.type, equals(ListType.CUSTOM));
        expect(minimalList.items, isEmpty);
      });

      test('gère les dates correctement', () {
        final now = DateTime.now();
        final list = CustomList(
          id: 'date_test',
          name: 'Date Test',
          type: ListType.PROJECTS,
          items: [],
          createdAt: now,
          updatedAt: now,
        );

        expect(list.createdAt, equals(now));
        expect(list.updatedAt, equals(now));
      });
    });

    group('Méthodes de calcul', () {
      test('calcule le nombre total d\'éléments', () {
        expect(testList.items.length, equals(2));
      });

      test('calcule le nombre d\'éléments terminés', () {
        final completedCount = testList.items.where((item) => item.isCompleted).length;
        expect(completedCount, equals(1));
      });

      test('calcule le nombre d\'éléments en cours', () {
        final inProgressCount = testList.items.where((item) => !item.isCompleted).length;
        expect(inProgressCount, equals(1));
      });

      test('calcule le pourcentage de progression', () {
        final progress = testList.items.where((item) => item.isCompleted).length / testList.items.length;
        expect(progress, equals(0.5));
      });

      test('gère la progression avec liste vide', () {
        final emptyList = CustomList(
          id: 'empty',
          name: 'Empty',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final progress = emptyList.items.isEmpty ? 0.0 : emptyList.items.where((item) => item.isCompleted).length / emptyList.items.length;
        expect(progress, equals(0.0));
      });
    });

    group('Méthodes de recherche et filtrage', () {
      test('trouve un élément par ID', () {
        final foundItem = testList.items.firstWhere((item) => item.id == 'item1');
        expect(foundItem, equals(testItem1));
      });

      test('filtre les éléments par score ELO élevé', () {
        final highScoreItems = testList.items.where((item) => item.eloScore > 1300);
        expect(highScoreItems.length, equals(1));
        expect(highScoreItems.first, equals(testItem1));
      });

      test('filtre les éléments par statut', () {
        final completedItems = testList.items.where((item) => item.isCompleted);
        final inProgressItems = testList.items.where((item) => !item.isCompleted);

        expect(completedItems.length, equals(1));
        expect(inProgressItems.length, equals(1));
      });

      test('recherche dans le titre des éléments', () {
        final matchingItems = testList.items.where((item) => 
            item.title.toLowerCase().contains('item'));
        expect(matchingItems.length, equals(2));
      });

      test('recherche dans la description des éléments', () {
        final matchingItems = testList.items.where((item) => 
            item.description?.toLowerCase().contains('description') == true);
        expect(matchingItems.length, equals(2));
      });
    });

    group('Méthodes de modification', () {
      test('ajoute un nouvel élément', () {
        final newItem = ListItem(
          id: 'item3',
          title: 'Item 3',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        final updatedList = testList.copyWith(
          items: [...testList.items, newItem],
          updatedAt: DateTime.now(),
        );

        expect(updatedList.items.length, equals(3));
        expect(updatedList.items.last, equals(newItem));
      });

      test('supprime un élément', () {
        final updatedItems = testList.items.where((item) => item.id != 'item1').toList();
        final updatedList = testList.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        expect(updatedList.items.length, equals(1));
        expect(updatedList.items.first.id, equals('item2'));
      });

      test('met à jour un élément', () {
        final updatedItem = testItem1.copyWith(title: 'Item 1 Updated');
        final updatedItems = testList.items.map((item) => 
            item.id == 'item1' ? updatedItem : item).toList();
        final updatedList = testList.copyWith(
          items: updatedItems,
          updatedAt: DateTime.now(),
        );

        expect(updatedList.items.first.title, equals('Item 1 Updated'));
      });

      test('change le type de liste', () {
        final updatedList = testList.copyWith(
          type: ListType.TRAVEL,
          updatedAt: DateTime.now(),
        );

        expect(updatedList.type, equals(ListType.TRAVEL));
      });

      test('met à jour la description', () {
        final updatedList = testList.copyWith(
          description: 'Nouvelle description',
          updatedAt: DateTime.now(),
        );

        expect(updatedList.description, equals('Nouvelle description'));
      });
    });

    group('Validation et intégrité', () {
      test('valide l\'ID non vide', () {
        expect(() => CustomList(
          id: '',
          name: 'Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ), throwsA(isA<ArgumentError>()));
      });

      test('valide le nom non vide', () {
        expect(() => CustomList(
          id: 'test',
          name: '',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ), throwsA(isA<ArgumentError>()));
      });

      test('valide les dates cohérentes', () {
        final createdAt = DateTime.now();
        final updatedAt = createdAt.subtract(const Duration(days: 1));

        expect(() => CustomList(
          id: 'test',
          name: 'Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: createdAt,
          updatedAt: updatedAt,
        ), throwsA(isA<ArgumentError>()));
      });

      test('valide les éléments uniques par ID', () {
        final duplicateItem = ListItem(
          id: 'item1', // Même ID que testItem1
          title: 'Duplicate',
          isCompleted: false,
          createdAt: DateTime.now(),
        );

        expect(() => CustomList(
          id: 'test',
          name: 'Test',
          type: ListType.CUSTOM,
          items: [testItem1, duplicateItem],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ), throwsA(isA<ArgumentError>()));
      });
    });

    group('Comparaison et égalité', () {
      test('compare deux listes identiques', () {
        final list1 = CustomList(
          id: 'same',
          name: 'Same',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        final list2 = CustomList(
          id: 'same',
          name: 'Same',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        );

        expect(list1, equals(list2));
        expect(list1.hashCode, equals(list2.hashCode));
      });

      test('compare deux listes différentes', () {
        final list1 = CustomList(
          id: 'list1',
          name: 'List 1',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final list2 = CustomList(
          id: 'list2',
          name: 'List 2',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(list1, isNot(equals(list2)));
        expect(list1.hashCode, isNot(equals(list2.hashCode)));
      });
    });

    group('Sérialisation et désérialisation', () {
      test('convertit en Map', () {
        final map = testList.toMap();
        
        expect(map['id'], equals('test_list'));
        expect(map['name'], equals('Liste de test'));
        expect(map['description'], equals('Description de test'));
        expect(map['type'], equals('SHOPPING'));
        expect(map['items'], isA<List>());
        expect(map['createdAt'], isA<String>());
        expect(map['updatedAt'], isA<String>());
      });

      test('crée depuis un Map', () {
        final map = testList.toMap();
        final recreatedList = CustomList.fromMap(map);

        expect(recreatedList.id, equals(testList.id));
        expect(recreatedList.name, equals(testList.name));
        expect(recreatedList.description, equals(testList.description));
        expect(recreatedList.type, equals(testList.type));
        expect(recreatedList.items.length, equals(testList.items.length));
      });

      test('gère les valeurs nulles dans la sérialisation', () {
        final listWithNulls = CustomList(
          id: 'null_test',
          name: 'Null Test',
          type: ListType.CUSTOM,
          items: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final map = listWithNulls.toMap();
        expect(map['description'], isNull);
      });
    });

    group('Performance et optimisation', () {
      test('gère efficacement de grandes listes d\'éléments', () {
        final largeItemsList = List.generate(1000, (index) => ListItem(
          id: 'item_$index',
          title: 'Item $index',
          isCompleted: index % 2 == 0,
          createdAt: DateTime.now(),
        ));

        final largeList = CustomList(
          id: 'large',
          name: 'Large List',
          type: ListType.CUSTOM,
          items: largeItemsList,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        expect(largeList.items.length, equals(1000));
        
        // Test de performance pour le filtrage
        final stopwatch = Stopwatch()..start();
        final completedItems = largeList.items.where((item) => item.isCompleted).length;
        stopwatch.stop();

        expect(completedItems, equals(500));
        expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Moins de 100ms
      });

      test('optimise les recherches fréquentes', () {
        final searchableList = CustomList(
          id: 'searchable',
          name: 'Searchable',
          type: ListType.CUSTOM,
          items: [
            ListItem(id: 'a', title: 'Apple', isCompleted: false, createdAt: DateTime.now()),
            ListItem(id: 'b', title: 'Banana', isCompleted: true, createdAt: DateTime.now()),
            ListItem(id: 'c', title: 'Cherry', isCompleted: false, createdAt: DateTime.now()),
          ],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Test de recherche multiple
        final stopwatch = Stopwatch()..start();
        for (int i = 0; i < 1000; i++) {
          searchableList.items.where((item) => item.title.contains('a')).length;
        }
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Moins de 50ms pour 1000 recherches
      });
    });
  });
} 
