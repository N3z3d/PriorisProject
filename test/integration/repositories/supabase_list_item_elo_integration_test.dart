import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/supabase/supabase_list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/infrastructure/services/auth_service.dart';
import 'package:prioris/infrastructure/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

@Tags(['integration'])
void main() {
  group('SupabaseListItemRepository — persistance ELO après duel', () {
    late SupabaseListItemRepository repository;
    late String testItemId;

    setUpAll(() async {
      await SupabaseService.initialize();
      await AuthService.instance.signIn(
        email: 'test_1776892399910_958@example.com',
        password: 'TestPassword123!',
      );
      repository = SupabaseListItemRepository();
      testItemId = '';
    });

    tearDownAll(() async {
      if (testItemId.isNotEmpty) {
        await repository.delete(testItemId);
      }
      await AuthService.instance.signOut();
    });

    test('update persiste le nouveau elo_score dans Supabase', () async {
      final initialItem = ListItem(
        id: const Uuid().v4(),
        title: 'Test ELO 7.2',
        eloScore: 1200.0,
        createdAt: DateTime.now(),
        listId: 'test-list-7-2',
      );
      testItemId = initialItem.id;

      await repository.add(initialItem);

      final updatedItem = ListItem(
        id: initialItem.id,
        title: initialItem.title,
        eloScore: 1216.0,
        createdAt: initialItem.createdAt,
        listId: initialItem.listId,
      );

      await repository.update(updatedItem);

      final fetched = await repository.getById(initialItem.id);
      expect(fetched, isNotNull);
      expect(fetched!.eloScore, closeTo(1216.0, 0.01),
          reason: 'Le nouveau ELO doit être persisté dans Supabase');
    });

    test('update loser persiste le score réduit dans Supabase', () async {
      final loserItem = ListItem(
        id: const Uuid().v4(),
        title: 'Test ELO Loser 7.2',
        eloScore: 1200.0,
        createdAt: DateTime.now(),
        listId: 'test-list-7-2',
      );
      final loserId = loserItem.id;

      await repository.add(loserItem);

      final updatedLoser = ListItem(
        id: loserId,
        title: loserItem.title,
        eloScore: 1184.0,
        createdAt: loserItem.createdAt,
        listId: loserItem.listId,
      );

      await repository.update(updatedLoser);

      final fetched = await repository.getById(loserId);
      expect(fetched, isNotNull);
      expect(fetched!.eloScore, closeTo(1184.0, 0.01),
          reason: 'Le score du perdant doit être persisté dans Supabase');

      await repository.delete(loserId);
    });
  });
}
