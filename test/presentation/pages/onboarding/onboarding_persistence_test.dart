import 'package:flutter_test/flutter_test.dart';
import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/onboarding/services/onboarding_persistence.dart';

/// Compte chaque écriture de liste : sert à prouver l'AC1/AC6 (0 écriture en
/// sandbox) autant que l'AC2 (la liste dédiée est bien créée en mode réel).
class _SpyListsWriter implements OnboardingListsWriter {
  final List<CustomList> createdLists = [];
  final List<ListItem> addedItems = [];
  final List<ListItem> updatedItems = [];

  @override
  Future<void> createList(CustomList list) async => createdLists.add(list);

  @override
  Future<void> addMultipleItems(String listId, List<ListItem> items) async =>
      addedItems.addAll(items);

  @override
  Future<void> updateListItem(String listId, ListItem item) async =>
      updatedItems.add(item);
}

class _SpyDuelService implements DuelFlowService {
  int processWinnerCalls = 0;
  int updateTaskCalls = 0;

  @override
  Future<void> processWinner(Task winner, Task loser) async {
    processWinnerCalls++;
  }

  @override
  Future<void> updateTask(Task task) async {
    updateTaskCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  late _SpyListsWriter writer;
  late _SpyDuelService duel;

  setUp(() {
    writer = _SpyListsWriter();
    duel = _SpyDuelService();
  });

  group('RealOnboardingPersistence', () {
    RealOnboardingPersistence subject() => RealOnboardingPersistence(
          listsWriter: writer,
          duelService: duel,
        );

    test('capture : crée une liste dédiée nommée par la clé i18n (AC2)',
        () async {
      await subject().captureTasks(['Sport', 'Courses'], listName: 'Mes priorités');

      expect(writer.createdLists, hasLength(1));
      expect(writer.createdLists.single.name, 'Mes priorités');
    });

    test('capture : dépose les tâches saisies comme items de la liste (AC2)',
        () async {
      await subject()
          .captureTasks(['Sport', 'Courses', 'Appeler'], listName: 'L');

      expect(writer.addedItems.map((i) => i.title),
          ['Sport', 'Courses', 'Appeler']);
      final listId = writer.createdLists.single.id;
      expect(writer.addedItems.every((i) => i.listId == listId), isTrue);
    });

    test('capture : retourne des tâches list-backed (tags = [listId])', () async {
      final tasks =
          await subject().captureTasks(['Sport', 'Courses'], listName: 'L');
      final listId = writer.createdLists.single.id;

      // La convention `task.tags = [listId]` est ce qui permet au DuelService de
      // persister l'ELO dans la liste (cf. DuelService._persistEloToLists).
      expect(tasks.every((t) => t.tags.single == listId), isTrue);
      expect(tasks.map((t) => t.title), ['Sport', 'Courses']);
    });

    test('duel : délègue la persistance ELO au DuelService', () async {
      await subject().recordDuel(Task(title: 'A'), Task(title: 'B'));

      expect(duel.processWinnerCalls, 1);
    });

    test('markDone : écrit dans la liste, pas dans le repository de tâches',
        () async {
      final tasks = await subject().captureTasks(['Sport'], listName: 'L');

      await subject().markTaskDone(tasks.single);

      // Une tâche list-backed n'existe pas dans le TaskRepository : passer par
      // duelService.updateTask serait un no-op silencieux (la tâche resterait
      // non cochée).
      expect(duel.updateTaskCalls, 0);
      expect(writer.updatedItems, hasLength(1));
      expect(writer.updatedItems.single.isCompleted, isTrue);
    });
  });

  group('SandboxOnboardingPersistence', () {
    const subject = SandboxOnboardingPersistence();

    test('capture : retourne des tâches en mémoire, sans aucune écriture (AC1)',
        () async {
      final tasks =
          await subject.captureTasks(['Sport', 'Courses'], listName: 'L');

      expect(tasks.map((t) => t.title), ['Sport', 'Courses']);
      expect(writer.createdLists, isEmpty);
      expect(writer.addedItems, isEmpty);
    });

    test('duel : aucune persistance ELO (AC1)', () async {
      await subject.recordDuel(Task(title: 'A'), Task(title: 'B'));

      expect(duel.processWinnerCalls, 0);
    });

    test('markDone : aucune écriture (AC1)', () async {
      await subject.markTaskDone(Task(title: 'A'));

      expect(duel.updateTaskCalls, 0);
      expect(writer.updatedItems, isEmpty);
    });
  });
}
