import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';
import 'package:prioris/domain/models/core/entities/task.dart';
import 'package:prioris/domain/models/core/enums/list_enums.dart';
import 'package:prioris/domain/task/services/list_item_task_converter.dart';
import 'package:prioris/presentation/pages/duel/services/duel_service.dart';
import 'package:prioris/presentation/pages/lists/controllers/refactored/lists_controller_slim.dart';
import 'package:uuid/uuid.dart';

/// Mode de l'onboarding, décidé **une seule fois** à l'entrée du flux.
///
/// - [real] : l'utilisateur n'a aucune donnée. Ce qu'il saisit est réellement
///   créé et ses duels comptent — pour lui, ce n'est pas un tutoriel, c'est
///   l'app qui fonctionne pour la première fois.
/// - [sandbox] : l'utilisateur possède déjà des données. Le flux devient une
///   démonstration du geste : **aucune écriture** ne doit atteindre ses
///   données (hors flag « onboarding fait »).
enum OnboardingMode { real, sandbox }

/// Les seules écritures de listes dont l'onboarding a besoin (ISP).
///
/// Port étroit plutôt que le contrôleur de listes complet : il rend le mode
/// réel testable sans monter toute la chaîne d'init des listes.
abstract class OnboardingListsWriter {
  Future<void> createList(CustomList list);
  Future<void> addMultipleItems(String listId, List<ListItem> items);
  Future<void> updateListItem(String listId, ListItem item);
}

/// Persistance du flux d'onboarding.
///
/// Deux implémentations (réelle / no-op) choisies selon [OnboardingMode], au
/// lieu de disperser un `if (isSandbox)` dans les quatre méthodes du
/// contrôleur : la garantie « zéro écriture » devient structurelle, donc
/// prouvable par un test (AC6), et non dépendante d'une condition oubliée.
abstract class OnboardingPersistence {
  /// Matérialise les tâches saisies. Retourne les tâches sur lesquelles le
  /// flux va duelliser — l'unique source de vérité de l'onboarding.
  Future<List<Task>> captureTasks(
    List<String> titles, {
    required String listName,
  });

  /// Persiste l'issue d'un duel (le calcul ELO d'état reste au contrôleur, il
  /// doit avoir lieu dans les deux modes).
  Future<void> recordDuel(Task winner, Task loser);

  /// Marque la tâche révélée comme faite.
  Future<void> markTaskDone(Task task);
}

/// Mode réel : tout est réellement créé, et **visible**.
class RealOnboardingPersistence implements OnboardingPersistence {
  final OnboardingListsWriter _listsWriter;
  final DuelFlowService _duelService;
  final ListItemTaskConverter _converter;
  final String Function() _newId;

  RealOnboardingPersistence({
    required OnboardingListsWriter listsWriter,
    required DuelFlowService duelService,
    ListItemTaskConverter? converter,
    String Function()? idFactory,
  })  : _listsWriter = listsWriter,
        _duelService = duelService,
        _converter = converter ?? ListItemTaskConverter(),
        _newId = idFactory ?? _uuidV4;

  static String _uuidV4() => const Uuid().v4();

  /// Crée une **liste dédiée** plutôt que des `Task` classiques : aucune
  /// surface de l'app n'affiche les `Task` (tasks_page n'est montée par aucune
  /// route), l'utilisateur ne retrouverait donc jamais ce qu'il vient de
  /// saisir. Une liste est visible dans ListsPage — et c'est déjà la monnaie du
  /// moteur de duel.
  @override
  Future<List<Task>> captureTasks(
    List<String> titles, {
    required String listName,
  }) async {
    final now = DateTime.now();
    final listId = _newId();

    await _listsWriter.createList(CustomList(
      id: listId,
      name: listName,
      type: ListType.CUSTOM,
      createdAt: now,
      updatedAt: now,
    ));

    final items = [
      for (var i = 0; i < titles.length; i++)
        ListItem(
          id: _newId(),
          title: titles[i],
          // Décale les dates de création : l'ordre de saisie reste lisible.
          createdAt: now.add(Duration(microseconds: i)),
          listId: listId,
        ),
    ];
    await _listsWriter.addMultipleItems(listId, items);

    // La conversion pose `tags = [listId]`, la convention qui permet au
    // DuelService de persister l'ELO dans la liste.
    return _converter.convertListItemsToTasks(items);
  }

  @override
  Future<void> recordDuel(Task winner, Task loser) =>
      _duelService.processWinner(winner, loser);

  @override
  Future<void> markTaskDone(Task task) async {
    final listId = _listIdOf(task);
    final completed = task.copyWith(isCompleted: true);

    // Une tâche list-backed n'existe pas dans le TaskRepository : y écrire
    // serait un no-op silencieux (l'item resterait décoché dans la liste).
    if (listId == null) {
      await _duelService.updateTask(completed);
      return;
    }
    await _listsWriter.updateListItem(
      listId,
      _converter.convertTaskToListItem(completed, listId: listId),
    );
  }

  String? _listIdOf(Task task) => task.tags.isEmpty ? null : task.tags.first;
}

/// Mode sandbox : le flux tourne entièrement en mémoire.
///
/// Ne détient **aucune** dépendance d'écriture — « zéro écriture » n'est donc
/// pas une promesse à tenir, c'est une propriété du type.
class SandboxOnboardingPersistence implements OnboardingPersistence {
  const SandboxOnboardingPersistence();

  @override
  Future<List<Task>> captureTasks(
    List<String> titles, {
    required String listName,
  }) async =>
      [for (final title in titles) Task(title: title)];

  @override
  Future<void> recordDuel(Task winner, Task loser) async {}

  @override
  Future<void> markTaskDone(Task task) async {}
}

/// Adapte le contrôleur de listes au port étroit [OnboardingListsWriter].
///
/// Le contrôleur est résolu **à chaque écriture** (et non capturé une fois) :
/// `listsControllerProvider` est reconstruit quand ses managers sont
/// réinvalidés (changement d'auth), et une référence figée écrirait alors dans
/// un contrôleur mort. Même précaution que `DuelService._persistEloToLists`.
class ListsControllerWriter implements OnboardingListsWriter {
  final ListsControllerSlim Function() _controllerOf;

  const ListsControllerWriter(this._controllerOf);

  @override
  Future<void> createList(CustomList list) => _controllerOf().createList(list);

  @override
  Future<void> addMultipleItems(String listId, List<ListItem> items) =>
      _controllerOf().addMultipleItems(listId, items);

  @override
  Future<void> updateListItem(String listId, ListItem item) =>
      _controllerOf().updateListItem(listId, item);
}
