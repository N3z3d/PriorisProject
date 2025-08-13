import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

void main() {
  group('InMemoryListItemRepository', () {
    late InMemoryListItemRepository repo;
    late ListItem item1;
    late ListItem item2;

    setUp(() {
      repo = InMemoryListItemRepository();
      item1 = ListItem(
        id: '1',
        title: 'Test 1',
        createdAt: DateTime(2024, 1, 1),
      );
      item2 = ListItem(
        id: '2',
        title: 'Test 2',
        createdAt: DateTime(2024, 1, 2),
      );
    });

    test('ajout et récupération', () async {
      await repo.add(item1);
      await repo.add(item2);
      final all = await repo.getAll();
      expect(all, containsAll([item1, item2]));
    });

    test('getById retourne l\'item correct', () async {
      await repo.add(item1);
      final found = await repo.getById('1');
      expect(found, equals(item1));
      final notFound = await repo.getById('999');
      expect(notFound, isNull);
    });

    test('add lève une erreur si id déjà présent', () async {
      await repo.add(item1);
      expect(() => repo.add(item1), throwsA(isA<StateError>()));
    });

    test('update modifie l\'item existant', () async {
      await repo.add(item1);
      final updated = item1.copyWith(title: 'Modifié');
      final result = await repo.update(updated);
      expect(result.title, 'Modifié');
      final all = await repo.getAll();
      expect(all.first.title, 'Modifié');
    });

    test('update lève une erreur si id inconnu', () async {
      expect(() => repo.update(item1), throwsA(isA<StateError>()));
    });

    test('delete supprime l\'item', () async {
      await repo.add(item1);
      await repo.delete('1');
      final all = await repo.getAll();
      expect(all, isEmpty);
    });

    test('delete ne lève pas d\'erreur si id inconnu', () async {
      await repo.delete('inexistant');
      // Pas d'exception attendue
    });
  });
} 
