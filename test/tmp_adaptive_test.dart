import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:prioris/data/repositories/custom_list_repository.dart';
import 'package:prioris/data/repositories/list_item_repository.dart';
import 'package:prioris/domain/services/persistence/adaptive_persistence_service.dart';

class MockListRepo extends Mock implements CustomListRepository {
  @override
  Future<void> deleteList(String id) => super.noSuchMethod(
        Invocation.method(#deleteList, [id]),
        returnValue: Future.value(),
        returnValueForMissingStub: Future.value(),
      );
}

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

    await service.initialize(isAuthenticated: true);

    await service.deleteList('abc');

    verify(local.deleteList('abc')).called(1);
  });
}
