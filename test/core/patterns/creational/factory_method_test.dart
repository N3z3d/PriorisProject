import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/core/patterns/creational/factory_method.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('Factory Method Pattern', () {
    test('should create list item factory correctly', () {
      // Arrange
      final factory = ListItemFactory();

      // Act
      final item = factory.createItem(
        title: 'Test Item',
        description: 'Test Description',
        category: 'Test Category',
      );

      // Assert
      expect(item, isA<ListItem>());
      expect(item.title, equals('Test Item'));
      expect(item.description, equals('Test Description'));
      expect(item.category, equals('Test Category'));
      expect(item.isCompleted, isFalse);
      expect(item.eloScore, equals(1200.0));
    });

    test('should create high priority items', () {
      // Arrange
      final factory = HighPriorityItemFactory();

      // Act
      final item = factory.createItem(
        title: 'Urgent Task',
        description: 'High priority task',
      );

      // Assert
      expect(item, isA<ListItem>());
      expect(item.title, equals('Urgent Task'));
      expect(item.eloScore, equals(1400.0)); // Higher initial score
    });

    test('should create items through factory manager', () {
      // Arrange
      final manager = ItemFactoryManager();

      // Act
      final standardItem = manager.createItem(ItemType.standard, 'Standard', 'Standard Desc');
      final urgentItem = manager.createItem(ItemType.urgent, 'Urgent', 'Urgent Desc');

      // Assert
      expect(standardItem, isA<ListItem>());
      expect(urgentItem, isA<ListItem>());
      expect(standardItem.title, equals('Standard'));
      expect(urgentItem.title, equals('Urgent'));
      expect(standardItem.eloScore, equals(1200.0));
      expect(urgentItem.eloScore, equals(1400.0));
    });

    test('should throw exception for unknown item type', () {
      // Arrange
      final manager = ItemFactoryManager();

      // Act & Assert
      expect(
        () => manager.createItem(ItemType.unknown, 'Title', 'Desc'),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test('should register custom factory', () {
      // Arrange
      final manager = ItemFactoryManager();
      final customFactory = CustomItemFactory();

      // Act
      manager.registerFactory(ItemType.custom, customFactory);
      final item = manager.createItem(ItemType.custom, 'Custom Title', 'Custom Desc');

      // Assert
      expect(item, isA<ListItem>());
      expect(item.title, equals('Custom Title'));
      expect(item.category, equals('Custom'));
    });

    test('should get available factory types', () {
      // Arrange
      final manager = ItemFactoryManager();

      // Act
      final types = manager.getAvailableTypes();

      // Assert
      expect(types, contains(ItemType.standard));
      expect(types, contains(ItemType.urgent));
      expect(types.length, equals(2));
    });
  });
}

// Test factory for custom items
class CustomItemFactory extends ItemFactory {
  @override
  ListItem createItem({
    required String title,
    String? description,
    String? category,
  }) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category ?? 'Custom',
      eloScore: 1300.0,
      createdAt: DateTime.now(),
    );
  }
}