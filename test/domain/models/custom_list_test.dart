import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('CustomList', () {
    late DateTime testDate;
    late ListItem testItem1;
    late ListItem testItem2;
    late CustomList testList;

    setUp(() {
      testDate = DateTime(2024, 1, 1, 12, 0, 0);
      testItem1 = ListItem(
        id: 'item-1',
        title: 'Test Item 1',
        description: 'Description 1',
        category: 'Test Category',
        eloScore: 1500.0, // Score ELO élevé (équivalent HIGH priority)
        isCompleted: false,
        createdAt: testDate,
        completedAt: null,
      );
      testItem2 = ListItem(
        id: 'item-2',
        title: 'Test Item 2',
        description: 'Description 2',
        category: 'Test Category',
        eloScore: 1200.0, // Score ELO moyen (équivalent MEDIUM priority)
        isCompleted: true,
        createdAt: testDate,
        completedAt: DateTime(2024, 1, 2, 12, 0, 0),
      );
      testList = CustomList(
        id: 'test-list-id',
        name: 'Test List',
        type: ListType.SHOPPING,
        description: 'Test Description',
        items: [testItem1, testItem2],
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    group('Constructor', () {
      test('should create CustomList with all properties', () {
        expect(testList.id, 'test-list-id');
        expect(testList.name, 'Test List');
        expect(testList.type, ListType.SHOPPING);
        expect(testList.description, 'Test Description');
        expect(testList.items, [testItem1, testItem2]);
        expect(testList.createdAt, testDate);
        expect(testList.updatedAt, testDate);
      });

      test('should create CustomList with minimal properties', () {
        final minimalList = CustomList(
          id: 'minimal-id',
          name: 'Minimal List',
          type: ListType.CUSTOM,
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(minimalList.id, 'minimal-id');
        expect(minimalList.name, 'Minimal List');
        expect(minimalList.type, ListType.CUSTOM);
        expect(minimalList.description, null);
        expect(minimalList.items, isEmpty);
        expect(minimalList.createdAt, testDate);
        expect(minimalList.updatedAt, testDate);
      });
    });

    group('copyWith', () {
      test('should return same instance when no parameters provided', () {
        final copied = testList.copyWith();
        expect(copied, testList);
      });

      test('should copy with modified properties', () {
        final newDate = DateTime(2024, 1, 3, 12, 0, 0);
        final copied = testList.copyWith(
          name: 'Modified Name',
          description: 'Modified Description',
          type: ListType.TRAVEL,
          updatedAt: newDate,
        );

        expect(copied.id, testList.id);
        expect(copied.name, 'Modified Name');
        expect(copied.description, 'Modified Description');
        expect(copied.type, ListType.TRAVEL);
        expect(copied.items, testList.items);
        expect(copied.createdAt, testList.createdAt);
        expect(copied.updatedAt, newDate);
      });

      test('should copy with modified items', () {
        final newItem = ListItem(
          id: 'new-item',
          title: 'New Item',
          eloScore: 1000.0,
          createdAt: testDate,
        );
        final copied = testList.copyWith(items: [newItem]);

        expect(copied.items, [newItem]);
        expect(copied.id, testList.id);
        expect(copied.name, testList.name);
      });
    });

    group('addItem', () {
      test('should add new item to list', () {
        final newItem = ListItem(
          id: 'new-item',
          title: 'New Item',
          eloScore: 1000.0,
          createdAt: testDate,
        );
        final updatedList = testList.addItem(newItem);

        expect(updatedList.items.length, 3);
        expect(updatedList.items, contains(newItem));
        expect(updatedList.updatedAt.isAfter(testList.updatedAt), true);
      });

      test('should not add duplicate item', () {
        final duplicateItem = ListItem(
          id: 'item-1', // Même ID que testItem1
          title: 'Duplicate Item',
          eloScore: 1000.0,
          createdAt: testDate,
        );
        final updatedList = testList.addItem(duplicateItem);

        expect(updatedList.items.length, 2);
        expect(updatedList, equals(testList));
      });

      test('should not modify other properties when adding item', () {
        final newItem = ListItem(
          id: 'new-item',
          title: 'New Item',
          eloScore: 1000.0,
          createdAt: testDate,
        );
        final updatedList = testList.addItem(newItem);

        expect(updatedList.id, testList.id);
        expect(updatedList.name, testList.name);
        expect(updatedList.type, testList.type);
        expect(updatedList.description, testList.description);
        expect(updatedList.createdAt, testList.createdAt);
      });
    });

    group('removeItem', () {
      test('should remove existing item by id', () {
        final updatedList = testList.removeItem('item-1');

        expect(updatedList.items.length, 1);
        expect(updatedList.items, contains(testItem2));
        expect(updatedList.items, isNot(contains(testItem1)));
        expect(updatedList.updatedAt.isAfter(testList.updatedAt), true);
      });

      test('should not remove non-existent item', () {
        final updatedList = testList.removeItem('non-existent');

        expect(updatedList.items.length, 2);
        expect(updatedList, equals(testList));
      });

      test('should not modify other properties when removing item', () {
        final updatedList = testList.removeItem('item-1');

        expect(updatedList.id, testList.id);
        expect(updatedList.name, testList.name);
        expect(updatedList.type, testList.type);
        expect(updatedList.description, testList.description);
        expect(updatedList.createdAt, testList.createdAt);
      });
    });

    group('updateItem', () {
      test('should update existing item', () {
        final updatedItem = testItem1.copyWith(title: 'Updated Title');
        final updatedList = testList.updateItem(updatedItem);

        expect(updatedList.items.length, 2);
        expect(updatedList.items.first.title, 'Updated Title');
        expect(updatedList.updatedAt.isAfter(testList.updatedAt), true);
      });

      test('should not update non-existent item', () {
        final nonExistentItem = ListItem(
          id: 'non-existent',
          title: 'Non Existent',
          eloScore: 1000.0,
          createdAt: testDate,
        );
        final updatedList = testList.updateItem(nonExistentItem);

        expect(updatedList, equals(testList));
      });
    });

    group('getCompletedItems', () {
      test('should return only completed items', () {
        final completedItems = testList.getCompletedItems();

        expect(completedItems.length, 1);
        expect(completedItems.first, testItem2);
      });

      test('should return empty list when no completed items', () {
        final incompleteList = testList.copyWith(
          items: [testItem1], // Seulement testItem1 qui n'est pas complété
        );
        final completedItems = incompleteList.getCompletedItems();

        expect(completedItems, isEmpty);
      });
    });

    group('getIncompleteItems', () {
      test('should return only incomplete items', () {
        final incompleteItems = testList.getIncompleteItems();

        expect(incompleteItems.length, 1);
        expect(incompleteItems.first, testItem1);
      });

      test('should return empty list when all items are completed', () {
        final completedList = testList.copyWith(
          items: [testItem2], // Seulement testItem2 qui est complété
        );
        final incompleteItems = completedList.getIncompleteItems();

        expect(incompleteItems, isEmpty);
      });
    });

    group('getProgress', () {
      test('should return correct progress percentage', () {
        final progress = testList.getProgress();

        expect(progress, 0.5); // 1 item complété sur 2
      });

      test('should return 0.0 for empty list', () {
        final emptyList = testList.copyWith(items: []);
        final progress = emptyList.getProgress();

        expect(progress, 0.0);
      });

      test('should return 1.0 for fully completed list', () {
        final completedList = testList.copyWith(
          items: [testItem2], // Seulement testItem2 qui est complété
        );
        final progress = completedList.getProgress();

        expect(progress, 1.0);
      });
    });

    group('Computed properties', () {
      test('should return correct itemCount', () {
        expect(testList.itemCount, 2);
      });

      test('should return correct completedCount', () {
        expect(testList.completedCount, 1);
      });

      test('should return correct incompleteCount', () {
        expect(testList.incompleteCount, 1);
      });

      test('should return correct isEmpty', () {
        expect(testList.isEmpty, false);
        
        final emptyList = testList.copyWith(items: []);
        expect(emptyList.isEmpty, true);
      });

      test('should return correct isCompleted', () {
        expect(testList.isCompleted, false);
        
        final completedList = testList.copyWith(
          items: [testItem2], // Seulement testItem2 qui est complété
        );
        expect(completedList.isCompleted, true);
        
        final emptyList = testList.copyWith(items: []);
        expect(emptyList.isCompleted, false);
      });
    });

    group('Sorting methods', () {
      test('should sort items by ELO', () {
        final sortedItems = testList.getItemsSortedByElo();

        expect(sortedItems.first.eloScore, 1500.0);
        expect(sortedItems.last.eloScore, 1200.0);
      });

      test('should sort items by date', () {
        final oldItem = ListItem(
          id: 'old-item',
          title: 'Old Item',
          eloScore: 1000.0,
          createdAt: DateTime(2023, 12, 1, 12, 0, 0),
        );
        final listWithOldItem = testList.copyWith(
          items: [testItem1, testItem2, oldItem],
        );
        final sortedItems = listWithOldItem.getItemsSortedByDate();

        expect(sortedItems.last, oldItem);
      });
    });

    group('Filtering methods', () {
      test('should filter items by category', () {
        final itemsByCategory = testList.getItemsByCategory('Test Category');

        expect(itemsByCategory.length, 2);
        expect(itemsByCategory, containsAll([testItem1, testItem2]));
      });

      test('should filter items by ELO range', () {
        final highEloItems = testList.getItemsByEloRange('high');

        expect(highEloItems.length, 1);
        expect(highEloItems, contains(testItem1));
      });

      test('should return empty list for non-existent category', () {
        final itemsByCategory = testList.getItemsByCategory('Non-existent');

        expect(itemsByCategory, isEmpty);
      });

      test('should return correct items for medium ELO range', () {
        final mediumEloItems = testList.getItemsByEloRange('medium');

        expect(mediumEloItems.length, 1);
        expect(mediumEloItems, contains(testItem2));
      });
    });

    group('getCategories', () {
      test('should return all unique categories', () {
        final categories = testList.getCategories();

        expect(categories.length, 1);
        expect(categories, contains('Test Category'));
      });

      test('should return empty set when no categories', () {
        final itemWithoutCategory = ListItem(
          id: 'no-category',
          title: 'No Category',
          eloScore: 1000.0,
          createdAt: testDate,
        );
        final listWithoutCategories = testList.copyWith(
          items: [itemWithoutCategory],
        );
        final categories = listWithoutCategories.getCategories();

        expect(categories, isEmpty);
      });
    });

    group('toLocalJson', () {
      test('should convert CustomList to JSON with all properties', () {
        final json = testList.toLocalJson();

        expect(json['id'], 'test-list-id');
        expect(json['name'], 'Test List');
        expect(json['type'], 'SHOPPING');
        expect(json['description'], 'Test Description');
        expect(json['items'], isA<List>());
        expect(json['items'].length, 2);
        expect(json['createdAt'], testDate.toIso8601String());
        expect(json['updatedAt'], testDate.toIso8601String());
      });

      test('should convert empty list to JSON', () {
        final emptyList = testList.copyWith(items: []);
        final json = emptyList.toLocalJson();

        expect(json['items'], isEmpty);
      });
    });

    group('toJson (Supabase)', () {
      test('should surface supabase fields with defaults', () {
        final json = testList.toJson();

        expect(json['id'], 'test-list-id');
        expect(json['title'], 'Test List');
        expect(json['list_type'], 'SHOPPING');
        expect(json['description'], 'Test Description');
        expect(json['color'], greaterThan(0));
        expect(json['icon'], greaterThan(0));
        expect(json['is_deleted'], isFalse);
        expect(json['created_at'], testDate.toIso8601String());
        expect(json['updated_at'], testDate.toIso8601String());
        expect(json.containsKey('user_id'), isFalse);
        expect(json.containsKey('user_email'), isFalse);
      });

      test('should include optional metadata when provided', () {
        final list = testList.copyWith(
          isDeleted: true,
          color: 123,
          iconCodePoint: 456,
          userId: 'user-1',
          userEmail: 'user@example.com',
        );

        final json = list.toJson();
        expect(json['color'], 123);
        expect(json['icon'], 456);
        expect(json['is_deleted'], isTrue);
        expect(json['user_id'], 'user-1');
        expect(json['user_email'], 'user@example.com');
      });
    });

    group('fromJson', () {
      test('should create CustomList from Supabase JSON with all properties', () {
        final json = {
          'id': 'json-list-id',
          'title': 'JSON List',
          'list_type': 'TRAVEL',
          'description': 'JSON Description',
          'items': [
            {
              'id': 'json-item-1',
              'title': 'JSON Item 1',
              'eloScore': 1500.0,
              'created_at': testDate.toIso8601String(),
            }
          ],
          'color': 321,
          'icon': 654,
          'is_deleted': true,
          'user_id': 'user-42',
          'user_email': 'user@example.com',
          'created_at': testDate.toIso8601String(),
          'updated_at': testDate.toIso8601String(),
        };

        final list = CustomList.fromJson(json);

        expect(list.id, 'json-list-id');
        expect(list.name, 'JSON List');
        expect(list.type, ListType.TRAVEL);
        expect(list.description, 'JSON Description');
        expect(list.isDeleted, isTrue);
        expect(list.color, 321);
        expect(list.iconCodePoint, 654);
        expect(list.userId, 'user-42');
        expect(list.userEmail, 'user@example.com');
        expect(list.items.length, 1);
        expect(list.items.first.title, 'JSON Item 1');
        expect(list.createdAt, testDate);
        expect(list.updatedAt, testDate);
      });

      test('should create CustomList from legacy JSON with minimal properties', () {
        final json = {
          'id': 'minimal-json-id',
          'name': 'Minimal JSON List',
          'type': 'CUSTOM',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        final list = CustomList.fromJson(json);

        expect(list.id, 'minimal-json-id');
        expect(list.name, 'Minimal JSON List');
        expect(list.type, ListType.CUSTOM);
        expect(list.description, null);
        expect(list.items, isEmpty);
        expect(list.isDeleted, isFalse);
        expect(list.createdAt, testDate);
        expect(list.updatedAt, testDate);
      });

      test('should handle invalid type gracefully', () {
        final json = {
          'id': 'invalid-type-id',
          'name': 'Invalid Type List',
          'type': 'INVALID_TYPE',
          'createdAt': testDate.toIso8601String(),
          'updatedAt': testDate.toIso8601String(),
        };

        final list = CustomList.fromJson(json);

        expect(list.type, ListType.CUSTOM);
      });
    });

    group('Equality', () {
      test('should be equal to itself', () {
        expect(testList, equals(testList));
      });

      test('should be equal to identical list', () {
        final identicalList = CustomList(
          id: 'test-list-id',
          name: 'Test List',
          type: ListType.SHOPPING,
          description: 'Test Description',
          items: [testItem1, testItem2],
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(testList, equals(identicalList));
      });

      test('should not be equal to different list', () {
        final differentList = testList.copyWith(name: 'Different Name');
        expect(testList, isNot(equals(differentList)));
      });

      test('should not be equal to different type', () {
        expect(testList, isNot(equals('string')));
      });
    });

    group('toString', () {
      test('should return meaningful string representation', () {
        final string = testList.toString();

        expect(string, contains('CustomList'));
        expect(string, contains('test-list-id'));
        expect(string, contains('Test List'));
        expect(string, contains('SHOPPING'));
        expect(string, contains('2'));
        expect(string, contains('50.0%'));
      });
    });
  });

  group('ListType', () {
    group('values', () {
      test('should have correct number of values', () {
        expect(ListType.values.length, 9);
      });

      test('should contain all expected values', () {
        expect(ListType.values, contains(ListType.TRAVEL));
        expect(ListType.values, contains(ListType.SHOPPING));
        expect(ListType.values, contains(ListType.MOVIES));
        expect(ListType.values, contains(ListType.BOOKS));
        expect(ListType.values, contains(ListType.RESTAURANTS));
        expect(ListType.values, contains(ListType.PROJECTS));
        expect(ListType.values, contains(ListType.TODO));
        expect(ListType.values, contains(ListType.IDEAS));
        expect(ListType.values, contains(ListType.CUSTOM));
      });
    });
  });

  group('ListTypeExtension', () {
    group('displayName', () {
      test('should return correct display names', () {
        expect(ListType.TRAVEL.displayName, 'Voyages');
        expect(ListType.SHOPPING.displayName, 'Courses');
        expect(ListType.MOVIES.displayName, 'Films & Séries');
        expect(ListType.BOOKS.displayName, 'Livres');
        expect(ListType.RESTAURANTS.displayName, 'Restaurants');
        expect(ListType.PROJECTS.displayName, 'Projets');
        expect(ListType.TODO.displayName, 'Tâches');
        expect(ListType.IDEAS.displayName, 'Idées');
        expect(ListType.CUSTOM.displayName, 'Personnalisée');
      });
    });

    group('iconName', () {
      test('should return correct icon names', () {
        expect(ListType.TRAVEL.iconName, 'flight');
        expect(ListType.SHOPPING.iconName, 'shopping_cart');
        expect(ListType.MOVIES.iconName, 'movie');
        expect(ListType.BOOKS.iconName, 'book');
        expect(ListType.RESTAURANTS.iconName, 'restaurant');
        expect(ListType.PROJECTS.iconName, 'work');
        expect(ListType.TODO.iconName, 'check');
        expect(ListType.IDEAS.iconName, 'lightbulb');
        expect(ListType.CUSTOM.iconName, 'list');
      });
    });

    group('colorValue', () {
      test('should return correct color values', () {
        expect(ListType.TRAVEL.colorValue, 0xFF2196F3);
        expect(ListType.SHOPPING.colorValue, 0xFF4CAF50);
        expect(ListType.MOVIES.colorValue, 0xFF9C27B0);
        expect(ListType.BOOKS.colorValue, 0xFFFF9800);
        expect(ListType.RESTAURANTS.colorValue, 0xFFE91E63);
        expect(ListType.PROJECTS.colorValue, 0xFF607D8B);
        expect(ListType.TODO.colorValue, 0xFF3F51B5);
        expect(ListType.IDEAS.colorValue, 0xFFFFC107);
        expect(ListType.CUSTOM.colorValue, 0xFF795548);
      });
    });

    group('description', () {
      test('should return correct descriptions', () {
        expect(ListType.TRAVEL.description, 'Destinations à visiter et voyages à planifier');
        expect(ListType.SHOPPING.description, 'Articles à acheter et courses à faire');
        expect(ListType.MOVIES.description, 'Films et séries à regarder');
        expect(ListType.BOOKS.description, 'Livres à lire et à découvrir');
        expect(ListType.RESTAURANTS.description, 'Restaurants à tester et à recommander');
        expect(ListType.PROJECTS.description, 'Projets personnels et professionnels');
        expect(ListType.TODO.description, 'Tâches quotidiennes et priorités à suivre');
        expect(ListType.IDEAS.description, 'Idées, inspirations et notes rapides');
        expect(ListType.CUSTOM.description, 'Liste personnalisée selon vos besoins');
      });
    });
  });
} 
