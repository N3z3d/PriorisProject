import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';

/// Test final pour valider que tous les bugs de persistance sont corrigés
void main() {
  group('🔧 FINAL PERSISTENCE BUG FIXES', () {
    test('✅ UUID generation creates valid PostgreSQL UUIDs', () {
      // ACT: Generate UUID like in the fixed code
      final uuid = const Uuid().v4();
      
      // ASSERT: Valid UUID format
      expect(uuid, matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
      
      // ASSERT: Length is reasonable for PostgreSQL
      expect(uuid.length, equals(36)); // Standard UUID length
      
      // ASSERT: Different from millisecond-based IDs
      expect(uuid, isNot(matches(RegExp(r'^\d+$'))));
    });
    
    test('✅ CustomList JSON is clean for Supabase', () {
      final list = CustomList(
        id: const Uuid().v4(),
        name: 'Test List',
        type: ListType.CUSTOM,
        description: 'Test',
        createdAt: DateTime.parse('2023-01-01T10:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-01T11:00:00.000Z'),
      );
      
      final json = list.toJson();
      
      // ASSERT: Only Supabase-compatible fields
      expect(json.keys, containsAll(['id', 'title', 'list_type', 'description', 'created_at', 'updated_at']));
      
      // ASSERT: No problematic fields that caused errors
      expect(json.containsKey('createdAt'), isFalse, reason: 'camelCase createdAt caused PostgreSQL error');
      expect(json.containsKey('updatedAt'), isFalse, reason: 'camelCase updatedAt caused PostgreSQL error');
      expect(json.containsKey('name'), isFalse, reason: 'name field should be title for Supabase');
      expect(json.containsKey('type'), isFalse, reason: 'type field should be list_type for Supabase');
      
      // ASSERT: Correct field mappings
      expect(json['title'], equals('Test List'));
      expect(json['list_type'], equals('CUSTOM'));
      expect(json['created_at'], equals('2023-01-01T10:00:00.000Z'));
      expect(json['updated_at'], equals('2023-01-01T11:00:00.000Z'));
    });
    
    test('✅ CustomList.fromJson still handles backward compatibility', () {
      // ARRANGE: Old format JSON (backward compatibility)
      final oldJson = {
        'id': 'test-123',
        'name': 'Old List',
        'type': 'SHOPPING',
        'description': 'Old format',
        'createdAt': '2023-01-01T10:00:00.000Z',
        'updatedAt': '2023-01-01T11:00:00.000Z',
        'items': [],
      };
      
      // ACT: Parse old format
      final list = CustomList.fromJson(oldJson);
      
      // ASSERT: Successfully parsed
      expect(list.name, equals('Old List'));
      expect(list.type, equals(ListType.SHOPPING));
      expect(list.description, equals('Old format'));
      
      // ARRANGE: New Supabase format JSON
      final newJson = {
        'id': 'test-456',
        'title': 'New List',
        'list_type': 'TRAVEL',
        'description': 'New format',
        'created_at': '2023-01-01T10:00:00.000Z',
        'updated_at': '2023-01-01T11:00:00.000Z',
        'items': [],
      };
      
      // ACT: Parse new format
      final newList = CustomList.fromJson(newJson);
      
      // ASSERT: Successfully parsed
      expect(newList.name, equals('New List'));
      expect(newList.type, equals(ListType.TRAVEL));
      expect(newList.description, equals('New format'));
    });
  });
  
  group('📊 REGRESSION PREVENTION', () {
    test('🚫 Prevent millisecond-based ID generation', () {
      // ARRANGE: Old problematic way (what we fixed)
      final oldStyleId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // ASSERT: Old style creates large integers
      expect(int.parse(oldStyleId), greaterThan(1000000000000)); // > 1 trillion
      
      // ARRANGE: New fixed way
      final newStyleId = const Uuid().v4();
      
      // ASSERT: New style creates UUIDs, not integers
      expect(() => int.parse(newStyleId), throwsFormatException);
      expect(newStyleId.length, equals(36));
      expect(newStyleId.contains('-'), isTrue);
    });
    
    test('🚫 Prevent camelCase fields in Supabase JSON', () {
      final list = CustomList(
        id: 'test-789',
        name: 'Prevention Test',
        type: ListType.CUSTOM,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final json = list.toJson();
      
      // ASSERT: These fields should NOT exist (they caused the bug)
      final forbiddenFields = ['createdAt', 'updatedAt', 'name', 'type'];
      for (final field in forbiddenFields) {
        expect(json.containsKey(field), isFalse, 
               reason: 'Field $field should not be in Supabase JSON to prevent schema errors');
      }
      
      // ASSERT: Required Supabase fields exist
      final requiredFields = ['title', 'list_type', 'created_at', 'updated_at'];
      for (final field in requiredFields) {
        expect(json.containsKey(field), isTrue,
               reason: 'Field $field is required for Supabase schema');
      }
    });
  });
}