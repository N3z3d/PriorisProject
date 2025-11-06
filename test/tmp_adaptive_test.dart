import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';

class MockListRepo extends Mock implements CustomListRepository {}

class MockItemRepo extends Mock implements ListItemRepository {}

void main() {
  test('deleteList call count', () async {
    final local = MockListRepo();
    final cloud = MockListRepo();
    final localItems = MockItemRepo();
    final cloudItems = MockItemRepo();

    final service = AdaptivePersistenceService(
      localRepository: local,
      cloudRepository: cloud,
      localItemRepository: localItems,
      cloudItemRepository: cloudItems,
    );

    when(local.deleteList(any)).thenAnswer((_) async {});
    when(cloud.deleteList(any)).thenAnswer((_) async {});
    await service.initialize(isAuthenticated: true);

    await service.deleteList('abc');

    verify(local.deleteList('abc')).called(1);
  });
}
