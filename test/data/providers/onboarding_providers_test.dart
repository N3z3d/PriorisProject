import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/data/providers/lists_controller_provider.dart';
import 'package:prioris/data/providers/onboarding_providers.dart';
import 'package:prioris/data/providers/prioritization_providers.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/ports/onboarding_repository.dart';

class _FakeOnboardingRepository implements IOnboardingRepository {
  _FakeOnboardingRepository(this._completed);
  bool _completed;

  @override
  Future<bool> hasCompletedOnboarding() async => _completed;

  @override
  Future<void> markCompleted() async => _completed = true;
}

CustomList _listWithItems(int count) {
  final now = DateTime.now();
  return CustomList(
    id: 'list-1',
    name: 'Liste',
    type: ListType.CUSTOM,
    createdAt: now,
    updatedAt: now,
    items: List.generate(
      count,
      (i) => ListItem(id: 'item-$i', title: 'Item $i', createdAt: now),
    ),
  );
}

ProviderContainer _container({
  required bool completed,
  required List<Task> classicTasks,
  List<CustomList> lists = const [],
}) {
  return ProviderContainer(
    overrides: [
      onboardingRepositoryProvider
          .overrideWithValue(_FakeOnboardingRepository(completed)),
      allPrioritizationTasksProvider.overrideWith((ref) async => classicTasks),
      listsProvider.overrideWithValue(lists),
    ],
  );
}

void main() {
  group('onboarding providers', () {
    test('shouldShowOnboarding=true : 0 tâche + non complété', () async {
      final c = _container(completed: false, classicTasks: const []);
      addTearDown(c.dispose);
      expect(await c.read(shouldShowOnboardingProvider.future), isTrue);
    });

    test('shouldShowOnboarding=false : au moins une tâche classique', () async {
      final c = _container(
        completed: false,
        classicTasks: [Task(title: 'A')],
      );
      addTearDown(c.dispose);
      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });

    test('shouldShowOnboarding=false : seulement des items de listes', () async {
      final c = _container(
        completed: false,
        classicTasks: const [],
        lists: [_listWithItems(2)],
      );
      addTearDown(c.dispose);
      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });

    test('shouldShowOnboarding=false : complété même si 0 tâche', () async {
      final c = _container(completed: true, classicTasks: const []);
      addTearDown(c.dispose);
      expect(await c.read(shouldShowOnboardingProvider.future), isFalse);
    });

    test('totalTaskCount additionne tâches classiques et items', () async {
      final c = _container(
        completed: false,
        classicTasks: [Task(title: 'A'), Task(title: 'B')],
        lists: [_listWithItems(3)],
      );
      addTearDown(c.dispose);
      expect(await c.read(totalTaskCountProvider.future), 5);
    });
  });
}
