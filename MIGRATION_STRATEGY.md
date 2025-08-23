# 🚀 STRATÉGIE DE MIGRATION ARCHITECTURALE PRIORIS

## 📋 PLAN DE MIGRATION PROGRESSIVE - 12 SEMAINES

Cette migration transformera progressivement l'architecture actuelle vers une **Clean Hexagonal Architecture + DDD** sans arrêt de service.

---

## 🎯 PHASE 1: FONDATIONS (Semaines 1-2)

### **Semaine 1: Setup Infrastructure**

#### **Jour 1-2: Création des Bases**
```bash
# Créer les dossiers de la nouvelle architecture
mkdir -p lib/domain/{core,list_management,task_management,habit_tracking}/{aggregates,value_objects,events,services,ports}
mkdir -p lib/application/{common,list_management,task_management}/{commands,queries,handlers,dto}
mkdir -p lib/infrastructure/{persistence,events,di}

# Nouvelles dépendances
flutter pub add get_it injectable uuid equatable
flutter pub add --dev injectable_generator build_runner
```

#### **Jour 3-5: Implémentation des Buses**
- ✅ **CommandBus/QueryBus/EventBus** (déjà créé)
- ✅ **Middlewares** pour logging, validation, caching
- ✅ **Mediator pattern** pour simplification
- ✅ Tests unitaires complets

```dart
// Exemple d'utilisation nouvelle architecture
final mediator = GetIt.I<Mediator>();

// Command
await mediator.send(CreateListCommand(
  name: "Nouvelle Liste",
  type: ListType.todo,
));

// Query  
final lists = await mediator.query(GetAllListsQuery());

// Event
await mediator.publish(ListCreatedEvent(...));
```

### **Semaine 2: Value Objects & Domain Core**

#### **Jour 1-3: Value Objects Refactorisés**
- ✅ **ListId, TaskId, ListName** (déjà créés)
- ✅ **ListStatistics, ListPriority, ListTags** (déjà créés)
- ✅ **Validation robuste** intégrée
- ✅ **Immutabilité** garantie

#### **Jour 4-5: Enhanced Aggregate Root**
- ✅ **AggregateRootEnhanced** (déjà créé)
- ✅ **Domain Events** automatiques
- ✅ **Business Rules** validation
- ✅ **Concurrency Control** optimiste

---

## 🏗️ PHASE 2: DOMAIN LAYER (Semaines 3-4)

### **Semaine 3: Aggregates Migration**

#### **Jour 1-3: CustomListAggregate Refactorisé**
```dart
// Nouvelle implémentation avec business logic
class CustomListAggregate extends AggregateRootEnhanced<ListId> {
  // Business methods avec validation
  void addTask(TaskId taskId) {
    _validateCanAddTask(taskId);
    _tasks.add(taskId);
    _statistics = _statistics.incrementTotalTasks();
    
    addDomainEvent(TaskAddedToListEvent(
      aggregateId: id,
      taskId: taskId,
      occurredAt: DateTime.now(),
    ));
  }
  
  void completeTask(TaskId taskId) {
    _validateTaskExists(taskId);
    _statistics = _statistics.incrementCompletedTasks();
    
    addDomainEvent(TaskCompletedInListEvent(
      aggregateId: id,
      taskId: taskId,
      newCompletionRate: _statistics.completionRate,
      occurredAt: DateTime.now(),
    ));
    
    // Business rule: notify if list completed
    if (_statistics.isCompleted) {
      addDomainEvent(ListCompletedEvent(...));
    }
  }
}
```

#### **Jour 4-5: Domain Events & Specifications**
```dart
// Events avec data complète
class ListCompletedEvent extends DomainEvent {
  final ListId listId;
  final double completionTime;
  final int totalTasks;
  
  // Specifications pour règles complexes
  class ListCanBeDeletedSpec extends SpecificationEnhanced<CustomListAggregate> {
    @override
    bool isSatisfiedBy(CustomListAggregate list) {
      return list.statistics.isEmpty || list.canForceDelete;
    }
  }
}
```

### **Semaine 4: Domain Services & Ports**

#### **Jour 1-3: Repository Ports**
```dart
// Interfaces pures dans le domain
abstract class ListRepositoryPort {
  Future<CustomListAggregate?> findById(ListId id);
  Future<List<CustomListAggregate>> findAll();
  Future<void> save(CustomListAggregate aggregate);
  Future<void> delete(ListId id);
  Future<bool> existsByName(ListName name);
}

abstract class TaskRepositoryPort {
  Future<List<TaskAggregate>> findByListId(ListId listId);
  Future<void> save(TaskAggregate task);
  Future<void> saveAll(List<TaskAggregate> tasks);
}
```

#### **Jour 4-5: Domain Services**
```dart
class ListDomainService extends DomainServiceEnhanced {
  bool canDeleteList(CustomListAggregate list, List<TaskAggregate> tasks) {
    return ListCanBeDeletedSpec().isSatisfiedBy(list) ||
           tasks.every((task) => task.isCompleted);
  }
  
  ListStatistics calculateStatistics(List<TaskAggregate> tasks) {
    final completed = tasks.where((t) => t.isCompleted).length;
    return ListStatistics.create(
      totalTasks: tasks.length,
      completedTasks: completed,
    );
  }
}
```

---

## ⚡ PHASE 3: APPLICATION LAYER (Semaines 5-6)

### **Semaine 5: Commands & Handlers**

#### **Jour 1-3: Command Handlers**
```dart
class CreateListHandler implements CommandHandler<CreateListCommand> {
  final ListRepositoryPort _listRepository;
  final EventBus _eventBus;
  final ListDomainService _domainService;

  @override
  Future<void> handle(CreateListCommand command) async {
    // 1. Business validation
    await _validateUniqueListName(command.name);
    
    // 2. Create aggregate with business logic
    final list = CustomListAggregate.create(
      name: command.name,
      description: command.description,
      type: command.type,
    );
    
    // 3. Apply business rules
    _domainService.validateNewList(list);
    
    // 4. Persist
    await _listRepository.save(list);
    
    // 5. Publish domain events
    for (final event in list.domainEvents) {
      await _eventBus.publish(event);
    }
    
    list.clearDomainEvents();
  }
}
```

#### **Jour 4-5: Event Handlers pour Side Effects**
```dart
class ListCompletedEventHandler implements EventHandler<ListCompletedEvent> {
  final NotificationService _notificationService;
  final AnalyticsService _analyticsService;

  @override
  Future<void> handle(ListCompletedEvent event) async {
    // Side effect: Send notification
    await _notificationService.sendListCompletionNotification(event.listId);
    
    // Side effect: Track analytics
    await _analyticsService.trackListCompletion(
      listId: event.listId,
      completionTime: event.completionTime,
    );
  }
}
```

### **Semaine 6: Queries & DTOs**

#### **Jour 1-3: Query Handlers**
```dart
class GetAllListsHandler implements QueryHandler<GetAllListsQuery, List<ListDto>> {
  final ListRepositoryPort _repository;
  final ListDtoMapper _mapper;

  @override
  Future<List<ListDto>> handle(GetAllListsQuery query) async {
    var lists = await _repository.findAll();
    
    // Apply query filters
    lists = _applyFilters(lists, query);
    lists = _applySorting(lists, query);
    
    // Map to DTOs
    return lists.map(_mapper.toDto).toList();
  }
}

// DTO optimisé pour la présentation
class ListDto {
  final String id;
  final String name;
  final String? description;
  final String type;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Factory pour création depuis aggregate
  factory ListDto.fromAggregate(CustomListAggregate aggregate) {
    return ListDto(
      id: aggregate.id.value,
      name: aggregate.name,
      description: aggregate.description,
      type: aggregate.type.name,
      totalTasks: aggregate.statistics.totalTasks,
      completedTasks: aggregate.statistics.completedTasks,
      completionRate: aggregate.statistics.completionRate,
      tags: aggregate.tags.tags.map((t) => t.value).toList(),
      createdAt: aggregate.createdAt,
      updatedAt: aggregate.updatedAt,
    );
  }
}
```

#### **Jour 4-5: Application Services (Orchestration)**
```dart
class ListApplicationService {
  final Mediator _mediator;

  // Orchestration de plusieurs commands
  Future<String> createListWithTasks({
    required String listName,
    required List<String> taskTitles,
  }) async {
    // 1. Create list
    final createCommand = CreateListCommand(name: listName, type: ListType.todo);
    final listId = await _mediator.send(createCommand);
    
    // 2. Add all tasks
    for (final title in taskTitles) {
      await _mediator.send(AddTaskToListCommand(
        listId: listId,
        taskTitle: title,
      ));
    }
    
    return listId;
  }
}
```

---

## 🔧 PHASE 4: INFRASTRUCTURE LAYER (Semaines 7-8)

### **Semaine 7: Persistence Adapters**

#### **Jour 1-3: Repository Implementations**
```dart
class SupabaseListRepository implements ListRepositoryPort {
  final SupabaseClient _client;
  final ListAggregateMapper _mapper;
  final Logger _logger;

  @override
  Future<CustomListAggregate?> findById(ListId id) async {
    try {
      final response = await _client
          .from('custom_lists')
          .select('''
            *,
            list_items:list_items(*)
          ''')
          .eq('id', id.value)
          .maybeSingle();

      return response != null ? _mapper.toDomain(response) : null;
    } catch (e) {
      _logger.error('Failed to find list by id: ${id.value}', e);
      throw InfrastructureException('Database error', e);
    }
  }

  @override
  Future<void> save(CustomListAggregate aggregate) async {
    try {
      final data = _mapper.toInfrastructure(aggregate);
      
      await _client.from('custom_lists').upsert(data);
      
      _logger.info('List saved: ${aggregate.id.value}');
    } catch (e) {
      _logger.error('Failed to save list: ${aggregate.id.value}', e);
      throw InfrastructureException('Failed to save list', e);
    }
  }
}
```

#### **Jour 4-5: Mappers & Data Transfer**
```dart
class ListAggregateMapper {
  CustomListAggregate toDomain(Map<String, dynamic> data) {
    return CustomListAggregate.fromPersistence(
      id: ListId.fromString(data['id']),
      name: data['name'],
      description: data['description'],
      type: ListType.values.byName(data['type']),
      // ... autres mappings
    );
  }

  Map<String, dynamic> toInfrastructure(CustomListAggregate aggregate) {
    return {
      'id': aggregate.id.value,
      'name': aggregate.name,
      'description': aggregate.description,
      'type': aggregate.type.name,
      'total_tasks': aggregate.statistics.totalTasks,
      'completed_tasks': aggregate.statistics.completedTasks,
      'created_at': aggregate.createdAt.toIso8601String(),
      'updated_at': aggregate.updatedAt?.toIso8601String(),
      'version': aggregate.version,
    };
  }
}
```

### **Semaine 8: Event Infrastructure**

#### **Jour 1-3: Event Bus Implementation**
```dart
class InMemoryEventBus implements EventBus {
  final Map<Type, List<EventHandler>> _handlers = {};
  final Logger _logger;

  @override
  Future<void> publish<T>(T event) async {
    final handlers = _handlers[T] ?? [];
    
    _logger.info('Publishing event: ${T.toString()}');
    
    // Execute handlers concurrently with error isolation
    final futures = handlers.map((handler) async {
      try {
        await (handler as EventHandler<T>).handle(event);
      } catch (e) {
        _logger.error('Event handler failed for ${T.toString()}', e);
        // Don't rethrow - other handlers should continue
      }
    });
    
    await Future.wait(futures);
  }
}

// Pour production: RabbitMQ, Apache Kafka, etc.
class RabbitMQEventBus implements EventBus {
  // Implementation avec message queue externe
}
```

#### **Jour 4-5: Dependency Injection Configuration**
```dart
@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class InfrastructureModule {
  @singleton
  SupabaseClient supabaseClient() => SupabaseClient(url, key);

  @injectable
  ListRepositoryPort listRepository(
    SupabaseClient client,
    ListAggregateMapper mapper,
  ) => SupabaseListRepository(client, mapper);

  @singleton
  EventBus eventBus() => InMemoryEventBus();
  
  @singleton
  CommandBus commandBus(
    CreateListHandler createHandler,
    UpdateListHandler updateHandler,
    DeleteListHandler deleteHandler,
  ) {
    final bus = CommandBusImpl();
    bus.register<CreateListCommand>(createHandler);
    bus.register<UpdateListCommand>(updateHandler);
    bus.register<DeleteListCommand>(deleteHandler);
    bus.addMiddleware(LoggingCommandMiddleware());
    bus.addMiddleware(ValidationCommandMiddleware());
    return bus;
  }
}
```

---

## 🎨 PHASE 5: PRESENTATION REFACTORING (Semaines 9-10)

### **Semaine 9: Controllers Refactorés**

#### **Jour 1-3: Nouveaux Controllers basés sur Mediator**
```dart
class ListsPageController extends StateNotifier<ListsPageState> {
  final Mediator _mediator;

  ListsPageController(this._mediator) : super(ListsPageState.initial());

  Future<void> loadLists({
    String? searchTerm,
    ListType? filterType,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final query = GetAllListsQuery(
        searchTerm: searchTerm,
        filterType: filterType,
        sortOption: state.sortOption,
      );

      final lists = await _mediator.query<GetAllListsQuery, List<ListDto>>(query);

      state = state.copyWith(
        lists: lists,
        isLoading: false,
        searchTerm: searchTerm,
        filterType: filterType,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createList({
    required String name,
    String? description,
    required ListType type,
  }) async {
    state = state.copyWith(isProcessing: true);

    try {
      final command = CreateListCommand(
        name: name,
        description: description,
        type: type,
      );

      await _mediator.send(command);
      await loadLists(); // Refresh

      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }
}
```

#### **Jour 4-5: Riverpod Providers Refactorés**
```dart
// Provider pour le mediator
final mediatorProvider = Provider<Mediator>((ref) {
  return GetIt.I<Mediator>();
});

// Provider pour le controller
final listsPageControllerProvider = StateNotifierProvider<ListsPageController, ListsPageState>((ref) {
  final mediator = ref.watch(mediatorProvider);
  return ListsPageController(mediator);
});

// Providers dérivés pour l'UI
final filteredListsProvider = Provider<List<ListDto>>((ref) {
  return ref.watch(listsPageControllerProvider).lists;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(listsPageControllerProvider).isLoading;
});
```

### **Semaine 10: UI Integration**

#### **Jour 1-3: Pages Refactorées**
```dart
class ListsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(listsPageControllerProvider.notifier);
    final state = ref.watch(listsPageControllerProvider);

    // Auto-load on first render
    useEffect(() {
      controller.loadLists();
      return null;
    }, []);

    return Scaffold(
      body: state.isLoading
          ? LoadingWidget()
          : state.error != null
              ? ErrorWidget(state.error!)
              : ListsView(lists: state.lists),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateListDialog(context, controller),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, ListsPageController controller) {
    showDialog(
      context: context,
      builder: (context) => CreateListDialog(
        onSubmit: (name, description, type) async {
          await controller.createList(
            name: name,
            description: description,
            type: type,
          );
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
```

#### **Jour 4-5: Widget Components Optimisés**
```dart
class ListCard extends ConsumerWidget {
  final ListDto list;

  const ListCard({required this.list});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(listsPageControllerProvider.notifier);

    return Card(
      child: ListTile(
        title: Text(list.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (list.description != null) Text(list.description!),
            LinearProgressIndicator(
              value: list.completionRate,
              backgroundColor: Colors.grey[300],
            ),
            Text('${list.completedTasks}/${list.totalTasks} tasks completed'),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                _showEditDialog(context, controller, list);
                break;
              case 'delete':
                await controller.deleteList(list.id);
                break;
            }
          },
        ),
      ),
    );
  }
}
```

---

## 🔄 PHASE 6: MIGRATION & CLEANUP (Semaines 11-12)

### **Semaine 11: Data Migration**

#### **Jour 1-3: Migration Scripts**
```dart
class ArchitectureMigrationService {
  final LegacyListsController _legacyController;
  final Mediator _mediator;

  Future<void> migrateAllData() async {
    print('🚀 Starting architecture migration...');
    
    // 1. Export legacy data
    final legacyLists = await _legacyController.getAllLists();
    print('📦 Found ${legacyLists.length} legacy lists');
    
    // 2. Convert to new format
    for (final legacyList in legacyLists) {
      try {
        await _migrateSingleList(legacyList);
      } catch (e) {
        print('❌ Failed to migrate list ${legacyList.name}: $e');
      }
    }
    
    // 3. Verify migration
    final newLists = await _mediator.query(GetAllListsQuery());
    print('✅ Migration complete: ${newLists.length} lists migrated');
  }

  Future<void> _migrateSingleList(CustomList legacyList) async {
    // Create list with new architecture
    final command = CreateListCommand(
      name: legacyList.name,
      description: legacyList.description,
      type: legacyList.type,
    );
    
    await _mediator.send(command);
    
    // Migrate all tasks
    for (final task in legacyList.items) {
      final addTaskCommand = AddTaskToListCommand(
        listId: legacyList.id,
        taskTitle: task.title,
        taskDescription: task.description,
      );
      
      await _mediator.send(addTaskCommand);
      
      // If task was completed, complete it
      if (task.isCompleted) {
        await _mediator.send(CompleteTaskCommand(
          listId: legacyList.id,
          taskId: task.id,
          completedAt: task.completedAt,
        ));
      }
    }
  }
}
```

#### **Jour 4-5: Gradual Rollout**
```dart
// Feature flag pour migration progressive
class FeatureFlags {
  static bool get useNewArchitecture => 
      _getFlag('NEW_ARCHITECTURE') ?? false;
}

// Router qui utilise nouvelle ou ancienne architecture
class AdaptiveListsController {
  static StateNotifier get instance {
    if (FeatureFlags.useNewArchitecture) {
      return GetIt.I<ListsPageController>();
    } else {
      return GetIt.I<LegacyListsController>();
    }
  }
}
```

### **Semaine 12: Cleanup & Optimisation**

#### **Jour 1-3: Suppression du Code Legacy**
```bash
# Supprimer les anciens fichiers après validation
git rm lib/presentation/pages/lists/controllers/lists_controller.dart
git rm lib/domain/services/persistence/adaptive_persistence_service.dart
git rm lib/domain/services/persistence/data_migration_service.dart

# Nettoyer les dépendances obsolètes
flutter pub deps | grep unused
flutter pub remove old_dependency
```

#### **Jour 4-5: Documentation & Formation**
- ✅ **ADRs** (Architecture Decision Records)
- ✅ **Diagrammes** d'architecture mis à jour
- ✅ **Guide développeur** nouvelle architecture
- ✅ **Tests** de régression complets
- ✅ **Formation équipe** sur DDD/Clean Architecture

---

## 📈 RÉSULTATS ATTENDUS

### **MÉTRIQUES DE QUALITÉ**

| Métrique | Avant | Après | Amélioration |
|----------|-------|-------|--------------|
| **Cyclomatic Complexity** | 15-25 | 5-10 | 50-60% ↓ |
| **Code Coverage** | 75% | 90%+ | 20% ↑ |
| **Coupling** | High | Low | 70% ↓ |
| **Cohesion** | Medium | High | 60% ↑ |
| **Technical Debt** | High | Low | 80% ↓ |

### **PERFORMANCE**

| Aspect | Amélioration |
|--------|-------------|
| **Temps de build** | 30% ↓ |
| **Temps de test** | 50% ↓ |
| **Memory usage** | 25% ↓ |
| **App startup** | 40% ↓ |

### **DÉVELOPPEUR EXPERIENCE**

- ✅ **Onboarding** nouveau dev : 2 jours → 4 heures
- ✅ **Temps debugging** : 60% ↓
- ✅ **Temps ajout feature** : 40% ↓
- ✅ **Confidence refactoring** : 80% ↑

---

## 🚦 POINTS DE CONTRÔLE

### **Validation de Phase**
Chaque phase doit passer ces critères avant de continuer :

1. ✅ **Tests passants** (unitaires + intégration)
2. ✅ **Code Review** approuvé par 2+ développeurs
3. ✅ **Performance** maintenue ou améliorée
4. ✅ **Documentation** mise à jour
5. ✅ **Déploiement** réussi en staging
6. ✅ **Feedback** équipe collecté et intégré

### **Rollback Plan**
- **Feature Flags** pour désactiver instantanément
- **Database migration** réversibles
- **Legacy code** conservé pendant 2 sprints
- **Monitoring** renforcé pendant transition

Cette migration transformera Prioris en une application **robuste**, **scalable** et **maintenable**, prête pour les défis futurs ! 🚀