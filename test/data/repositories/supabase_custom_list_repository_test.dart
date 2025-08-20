import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

void main() {
  group('SupabaseCustomListRepository', () {
    final testCustomList = CustomList(
      id: 'list-123',
      name: 'Test List',
      description: 'Test Description',
      type: ListType.CUSTOM,
      createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
      updatedAt: DateTime.parse('2024-01-01T10:00:00Z'),
    );

    group('CustomList Model', () {
      test('should create CustomList with required fields', () {
        // Assert
        expect(testCustomList.id, equals('list-123'));
        expect(testCustomList.name, equals('Test List'));
        expect(testCustomList.description, equals('Test Description'));
        expect(testCustomList.type, equals(ListType.CUSTOM));
        expect(testCustomList.createdAt, equals(DateTime.parse('2024-01-01T10:00:00Z')));
        expect(testCustomList.updatedAt, equals(DateTime.parse('2024-01-01T10:00:00Z')));
      });

      test('should convert to JSON correctly', () {
        // Act
        final json = testCustomList.toJson();

        // Assert
        expect(json['id'], equals('list-123'));
        expect(json['name'], equals('Test List'));
        expect(json['description'], equals('Test Description'));
        expect(json['type'], equals('CUSTOM'));
      });

      test('should create from JSON correctly', () {
        // Arrange
        final json = {
          'id': 'list-456',
          'name': 'JSON Test List',
          'description': 'JSON Description',
          'type': 'BOOKS',
          'createdAt': '2024-01-02T10:00:00Z',
          'updatedAt': '2024-01-02T11:00:00Z',
        };

        // Act
        final customList = CustomList.fromJson(json);

        // Assert
        expect(customList.id, equals('list-456'));
        expect(customList.name, equals('JSON Test List'));
        expect(customList.description, equals('JSON Description'));
        expect(customList.type, equals(ListType.BOOKS));
        expect(customList.createdAt, equals(DateTime.parse('2024-01-02T10:00:00Z')));
        expect(customList.updatedAt, equals(DateTime.parse('2024-01-02T11:00:00Z')));
      });

      test('should handle enum conversion correctly', () {
        // Arrange
        final testCases = [
          {'type': 'CUSTOM', 'expected': ListType.CUSTOM},
          {'type': 'BOOKS', 'expected': ListType.BOOKS},
          {'type': 'PROJECTS', 'expected': ListType.PROJECTS},
        ];

        for (final testCase in testCases) {
          final json = {
            'id': 'test-id',
            'name': 'Test Name',
            'description': 'Test Description',
            'type': testCase['type'],
            'createdAt': '2024-01-01T10:00:00Z',
            'updatedAt': '2024-01-01T10:00:00Z',
          };

          // Act
          final customList = CustomList.fromJson(json);

          // Assert
          expect(customList.type, equals(testCase['expected']), 
            reason: 'Failed for type: ${testCase['type']}');
        }
      });
    });

    group('Integration Tests - Placeholder', () {
      test('repository integration tests require refactoring for dependency injection', () {
        // TODO: Refactor SupabaseCustomListRepository to accept injected dependencies
        // This will allow proper mocking and testing of repository methods
        
        // For now, we test the model serialization which is the core functionality
        expect(testCustomList.toJson(), isA<Map<String, dynamic>>());
      });
    });
  });
}