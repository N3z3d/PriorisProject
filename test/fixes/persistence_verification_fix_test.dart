import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/presentation/pages/lists/controllers/lists_controller.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';
import 'package:prioris/domain/services/core/lists_filter_service.dart';

import 'persistence_verification_fix_test.mocks.dart';

@GenerateMocks([
  CustomListRepository,
  ListItemRepository,
  AdaptivePersistenceService,
  ListsFilterService,
])

/// Tests pour valider la correction du bug de vérification de persistance
/// 
/// BUG: "Liste non trouvée après sauvegarde - échec de persistance"
/// CAUSE 1: Vérification dans le cloud pendant que sync cloud est asynchrone
/// CAUSE 2: JSON serialization avec createdAt au lieu de created_at pour Supabase
/// FIX: Correction de la serialization JSON pour être compatible Supabase
void main() {
  
  group('📋 INTEGRATION VALIDATION', () {
    test('🌐 CustomList JSON serialization matches Supabase schema', () {
      final list = CustomList(
        id: 'test-456',
        name: 'Test List',
        type: ListType.SHOPPING,
        description: 'Test description',
        createdAt: DateTime.parse('2023-01-01T10:00:00.000Z'),
        updatedAt: DateTime.parse('2023-01-01T11:00:00.000Z'),
      );
      
      final json = list.toJson();
      
      // ASSERT: Contains ONLY Supabase format (backward compatibility removed)
      expect(json['title'], equals('Test List'));        // Supabase format
      expect(json['list_type'], equals('SHOPPING'));     // Supabase format  
      expect(json['created_at'], isNotNull);             // Supabase format
      expect(json['updated_at'], isNotNull);             // Supabase format
      
      // ASSERT: Backward compatibility fields are NOT present
      expect(json.containsKey('name'), isFalse);         // Should not exist
      expect(json.containsKey('type'), isFalse);         // Should not exist  
      expect(json.containsKey('createdAt'), isFalse);    // Should not exist
      expect(json.containsKey('updatedAt'), isFalse);    // Should not exist
    });
    
    test('🔄 CustomList.fromJson handles both formats', () {
      // ARRANGE: Supabase format JSON
      final supabaseJson = {
        'id': 'test-789',
        'title': 'Supabase List',
        'list_type': 'CUSTOM', 
        'description': 'From Supabase',
        'created_at': '2023-01-01T10:00:00.000Z',
        'updated_at': '2023-01-01T11:00:00.000Z',
        'items': [],
      };
      
      // ACT: Parse from Supabase format
      final list = CustomList.fromJson(supabaseJson);
      
      // ASSERT: Correctly parsed
      expect(list.name, equals('Supabase List'));
      expect(list.type, equals(ListType.CUSTOM));
      expect(list.description, equals('From Supabase'));
    });
  });
}