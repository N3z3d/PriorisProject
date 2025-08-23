# ARCHITECTURAL REFACTORING PROPOSAL - PRIORIS PROJECT

## 🎯 ARCHITECTURE CIBLE : CLEAN HEXAGONAL + DDD

### **PORTS (INTERFACES) - DOMAIN LAYER**

```dart
// lib/domain/ports/repositories/list_repository_port.dart
abstract class ListRepositoryPort {
  Future<List<CustomListAggregate>> findAll();
  Future<CustomListAggregate?> findById(ListId id);
  Future<void> save(CustomListAggregate aggregate);
  Future<void> delete(ListId id);
}

// lib/domain/ports/repositories/task_repository_port.dart  
abstract class TaskRepositoryPort {
  Future<List<TaskAggregate>> findByListId(ListId listId);
  Future<TaskAggregate?> findById(TaskId id);
  Future<void> save(TaskAggregate aggregate);
  Future<void> delete(TaskId id);
}

// lib/domain/ports/services/persistence_strategy_port.dart
abstract class PersistenceStrategyPort {
  Future<void> persist<T>(T aggregate, String context);
  Future<T?> retrieve<T>(String id, String context);
  Future<void> migrate(MigrationContext context);
}

// lib/domain/ports/events/event_bus_port.dart
abstract class EventBusPort {
  Future<void> publish(DomainEvent event);
  void subscribe<T extends DomainEvent>(EventHandler<T> handler);
}
```

### **BOUNDED CONTEXTS RESTRUCTURÉS**

```dart
// lib/domain/list_management/aggregates/custom_list_aggregate.dart
class CustomListAggregate extends AggregateRoot<ListId> {
  final ListName _name;
  final ListDescription? _description;
  final ListType _type;
  final List<TaskId> _taskIds;
  final ListStatistics _statistics;
  
  CustomListAggregate._({
    required ListId id,
    required ListName name,
    ListDescription? description,
    required ListType type,
    List<TaskId>? taskIds,
    ListStatistics? statistics,
  }) : _name = name,
       _description = description,
       _type = type,
       _taskIds = taskIds ?? [],
       _statistics = statistics ?? ListStatistics.empty(),
       super(id);

  // Factory methods
  factory CustomListAggregate.create({
    required String name,
    String? description,
    required ListType type,
  }) {
    final id = ListId.generate();
    final listName = ListName(name);
    final listDescription = description != null ? ListDescription(description) : null;
    
    final aggregate = CustomListAggregate._(
      id: id,
      name: listName,
      description: listDescription,
      type: type,
    );
    
    aggregate.addDomainEvent(ListCreatedEvent(
      aggregateId: id,
      name: name,
      type: type,
      occurredAt: DateTime.now(),
    ));
    
    return aggregate;
  }

  // Business methods
  void addTask(TaskId taskId) {
    if (_taskIds.contains(taskId)) {
      throw DomainException('Task already exists in list');
    }
    
    _taskIds.add(taskId);
    _statistics.incrementTotalTasks();
    
    addDomainEvent(TaskAddedToListEvent(
      aggregateId: id,
      taskId: taskId,
      occurredAt: DateTime.now(),
    ));
  }

  void completeTask(TaskId taskId) {
    if (!_taskIds.contains(taskId)) {
      throw DomainException('Task not found in list');
    }
    
    _statistics.incrementCompletedTasks();
    
    addDomainEvent(TaskCompletedInListEvent(
      aggregateId: id,
      taskId: taskId,
      completionRate: _statistics.completionRate,
      occurredAt: DateTime.now(),
    ));
  }

  // Getters
  String get name => _name.value;
  String? get description => _description?.value;
  ListType get type => _type;
  List<TaskId> get taskIds => List.unmodifiable(_taskIds);
  double get completionRate => _statistics.completionRate;
}

// lib/domain/list_management/value_objects/list_id.dart
class ListId extends ValueObject {
  final String _value;
  
  ListId._(this._value) {
    if (_value.isEmpty) {
      throw DomainException('ListId cannot be empty');
    }
  }
  
  factory ListId.fromString(String value) => ListId._(value);
  factory ListId.generate() => ListId._(Uuid().v4());
  
  String get value => _value;
  
  @override
  List<Object> get props => [_value];
}

// lib/domain/list_management/value_objects/list_name.dart
class ListName extends ValueObject {
  final String _value;
  
  ListName(this._value) {
    if (_value.isEmpty || _value.length > 100) {
      throw DomainException('List name must be between 1 and 100 characters');
    }
  }
  
  String get value => _value;
  
  @override
  List<Object> get props => [_value];
}
```

### **APPLICATION LAYER - USE CASES**

```dart
// lib/application/list_management/commands/create_list_command.dart
class CreateListCommand implements Command {
  final String name;
  final String? description;
  final ListType type;
  
  const CreateListCommand({
    required this.name,
    this.description,
    required this.type,
  });
}

// lib/application/list_management/handlers/create_list_handler.dart
class CreateListHandler implements CommandHandler<CreateListCommand> {
  final ListRepositoryPort _listRepository;
  final EventBusPort _eventBus;
  
  CreateListHandler(this._listRepository, this._eventBus);
  
  @override
  Future<void> handle(CreateListCommand command) async {
    // Business validation
    await _validateListNameUniqueness(command.name);
    
    // Create aggregate
    final list = CustomListAggregate.create(
      name: command.name,
      description: command.description,
      type: command.type,
    );
    
    // Persist
    await _listRepository.save(list);
    
    // Publish events
    for (final event in list.domainEvents) {
      await _eventBus.publish(event);
    }
    
    list.clearDomainEvents();
  }
  
  Future<void> _validateListNameUniqueness(String name) async {
    final existingLists = await _listRepository.findAll();
    final nameExists = existingLists.any((list) => list.name == name);
    
    if (nameExists) {
      throw DomainException('A list with this name already exists');
    }
  }
}

// lib/application/list_management/queries/get_all_lists_query.dart
class GetAllListsQuery implements Query<List<ListDto>> {
  final String? searchTerm;
  final ListType? filterType;
  final SortOption sortOption;
  
  const GetAllListsQuery({
    this.searchTerm,
    this.filterType,
    this.sortOption = SortOption.NAME_ASC,
  });
}

// lib/application/list_management/handlers/get_all_lists_handler.dart
class GetAllListsHandler implements QueryHandler<GetAllListsQuery, List<ListDto>> {
  final ListRepositoryPort _listRepository;
  
  GetAllListsHandler(this._listRepository);
  
  @override
  Future<List<ListDto>> handle(GetAllListsQuery query) async {
    var lists = await _listRepository.findAll();
    
    // Apply filters
    if (query.searchTerm != null) {
      lists = lists.where((list) => 
        list.name.toLowerCase().contains(query.searchTerm!.toLowerCase())
      ).toList();
    }
    
    if (query.filterType != null) {
      lists = lists.where((list) => list.type == query.filterType).toList();
    }
    
    // Apply sorting
    lists.sort((a, b) {
      switch (query.sortOption) {
        case SortOption.NAME_ASC:
          return a.name.compareTo(b.name);
        case SortOption.NAME_DESC:
          return b.name.compareTo(a.name);
        case SortOption.COMPLETION_ASC:
          return a.completionRate.compareTo(b.completionRate);
        case SortOption.COMPLETION_DESC:
          return b.completionRate.compareTo(a.completionRate);
      }
    });
    
    // Map to DTOs
    return lists.map((list) => ListDto.fromAggregate(list)).toList();
  }
}
```

### **INFRASTRUCTURE LAYER - ADAPTERS**

```dart
// lib/infrastructure/persistence/supabase/supabase_list_repository.dart
class SupabaseListRepository implements ListRepositoryPort {
  final SupabaseClient _client;
  final ListMapper _mapper;
  
  SupabaseListRepository(this._client, this._mapper);
  
  @override
  Future<List<CustomListAggregate>> findAll() async {
    try {
      final response = await _client
          .from('custom_lists')
          .select()
          .order('created_at', ascending: false);
      
      return response
          .map((data) => _mapper.toDomain(data))
          .toList();
    } catch (e) {
      throw InfrastructureException('Failed to fetch lists: $e');
    }
  }
  
  @override
  Future<CustomListAggregate?> findById(ListId id) async {
    try {
      final response = await _client
          .from('custom_lists')
          .select()
          .eq('id', id.value)
          .maybeSingle();
      
      return response != null ? _mapper.toDomain(response) : null;
    } catch (e) {
      throw InfrastructureException('Failed to fetch list: $e');
    }
  }
  
  @override
  Future<void> save(CustomListAggregate aggregate) async {
    try {
      final data = _mapper.toInfrastructure(aggregate);
      
      await _client
          .from('custom_lists')
          .upsert(data);
    } catch (e) {
      throw InfrastructureException('Failed to save list: $e');
    }
  }
  
  @override
  Future<void> delete(ListId id) async {
    try {
      await _client
          .from('custom_lists')
          .delete()
          .eq('id', id.value);
    } catch (e) {
      throw InfrastructureException('Failed to delete list: $e');
    }
  }
}

// lib/infrastructure/persistence/mappers/list_mapper.dart
class ListMapper {
  CustomListAggregate toDomain(Map<String, dynamic> data) {
    return CustomListAggregate.fromPersistence(
      id: ListId.fromString(data['id']),
      name: data['name'],
      description: data['description'],
      type: ListType.values.firstWhere((t) => t.name == data['type']),
      taskIds: (data['task_ids'] as List<dynamic>?)
          ?.map((id) => TaskId.fromString(id))
          .toList() ?? [],
      statistics: ListStatistics(
        totalTasks: data['total_tasks'] ?? 0,
        completedTasks: data['completed_tasks'] ?? 0,
      ),
      createdAt: DateTime.parse(data['created_at']),
      updatedAt: data['updated_at'] != null 
          ? DateTime.parse(data['updated_at']) 
          : null,
    );
  }
  
  Map<String, dynamic> toInfrastructure(CustomListAggregate aggregate) {
    return {
      'id': aggregate.id.value,
      'name': aggregate.name,
      'description': aggregate.description,
      'type': aggregate.type.name,
      'task_ids': aggregate.taskIds.map((id) => id.value).toList(),
      'total_tasks': aggregate.totalTasks,
      'completed_tasks': aggregate.completedTasks,
      'created_at': aggregate.createdAt.toIso8601String(),
      'updated_at': aggregate.updatedAt?.toIso8601String(),
    };
  }
}
```

### **PRESENTATION LAYER - REFACTORISÉ**

```dart
// lib/presentation/pages/lists/lists_page_controller.dart
class ListsPageController extends StateNotifier<ListsPageState> {
  final CommandBus _commandBus;
  final QueryBus _queryBus;
  
  ListsPageController(this._commandBus, this._queryBus) 
    : super(const ListsPageState());
  
  Future<void> loadLists({
    String? searchTerm,
    ListType? filterType,
    SortOption sortOption = SortOption.NAME_ASC,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final query = GetAllListsQuery(
        searchTerm: searchTerm,
        filterType: filterType,
        sortOption: sortOption,
      );
      
      final lists = await _queryBus.execute(query);
      
      state = state.copyWith(
        lists: lists,
        isLoading: false,
        searchTerm: searchTerm,
        filterType: filterType,
        sortOption: sortOption,
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
      
      await _commandBus.execute(command);
      await loadLists(); // Refresh list
      
      state = state.copyWith(isProcessing: false);
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }
}

// lib/presentation/pages/lists/lists_page_state.dart
class ListsPageState {
  final List<ListDto> lists;
  final bool isLoading;
  final bool isProcessing;
  final String? error;
  final String? searchTerm;
  final ListType? filterType;
  final SortOption sortOption;
  
  const ListsPageState({
    this.lists = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.error,
    this.searchTerm,
    this.filterType,
    this.sortOption = SortOption.NAME_ASC,
  });
  
  ListsPageState copyWith({
    List<ListDto>? lists,
    bool? isLoading,
    bool? isProcessing,
    String? error,
    String? searchTerm,
    ListType? filterType,
    SortOption? sortOption,
  }) {
    return ListsPageState(
      lists: lists ?? this.lists,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      error: error,
      searchTerm: searchTerm ?? this.searchTerm,
      filterType: filterType ?? this.filterType,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}
```

### **BUSES ET MEDIATOR PATTERN**

```dart
// lib/application/common/command_bus.dart
abstract class CommandBus {
  Future<void> execute<T extends Command>(T command);
}

class CommandBusImpl implements CommandBus {
  final Map<Type, CommandHandler> _handlers = {};
  
  void register<T extends Command>(CommandHandler<T> handler) {
    _handlers[T] = handler;
  }
  
  @override
  Future<void> execute<T extends Command>(T command) async {
    final handler = _handlers[T] as CommandHandler<T>?;
    if (handler == null) {
      throw ApplicationException('No handler registered for ${T.toString()}');
    }
    
    await handler.handle(command);
  }
}

// lib/application/common/query_bus.dart
abstract class QueryBus {
  Future<R> execute<T extends Query<R>, R>(T query);
}

class QueryBusImpl implements QueryBus {
  final Map<Type, QueryHandler> _handlers = {};
  
  void register<T extends Query<R>, R>(QueryHandler<T, R> handler) {
    _handlers[T] = handler;
  }
  
  @override
  Future<R> execute<T extends Query<R>, R>(T query) async {
    final handler = _handlers[T] as QueryHandler<T, R>?;
    if (handler == null) {
      throw ApplicationException('No handler registered for ${T.toString()}');
    }
    
    return await handler.handle(query);
  }
}
```

### **DEPENDENCY INJECTION REFACTORISÉ**

```dart
// lib/infrastructure/di/dependency_injection.dart
class DependencyInjection {
  static void configure() {
    // Ports implementations
    GetIt.I.registerLazySingleton<ListRepositoryPort>(
      () => SupabaseListRepository(
        GetIt.I<SupabaseClient>(),
        ListMapper(),
      ),
    );
    
    GetIt.I.registerLazySingleton<TaskRepositoryPort>(
      () => SupabaseTaskRepository(
        GetIt.I<SupabaseClient>(),
        TaskMapper(),
      ),
    );
    
    GetIt.I.registerLazySingleton<EventBusPort>(
      () => InMemoryEventBus(),
    );
    
    // Command handlers
    GetIt.I.registerLazySingleton<CreateListHandler>(
      () => CreateListHandler(
        GetIt.I<ListRepositoryPort>(),
        GetIt.I<EventBusPort>(),
      ),
    );
    
    // Query handlers
    GetIt.I.registerLazySingleton<GetAllListsHandler>(
      () => GetAllListsHandler(GetIt.I<ListRepositoryPort>()),
    );
    
    // Buses
    GetIt.I.registerLazySingleton<CommandBus>(() {
      final bus = CommandBusImpl();
      bus.register<CreateListCommand>(GetIt.I<CreateListHandler>());
      return bus;
    });
    
    GetIt.I.registerLazySingleton<QueryBus>(() {
      final bus = QueryBusImpl();
      bus.register<GetAllListsQuery, List<ListDto>>(GetIt.I<GetAllListsHandler>());
      return bus;
    });
  }
}
```

## 🔄 STRATÉGIE DE MIGRATION PROGRESSIVE

### **Phase 1: Foundation (Semaine 1-2)**
1. ✅ Créer les interfaces ports dans `domain/ports/`
2. ✅ Implémenter les value objects et entities refactorisés
3. ✅ Mettre en place les buses (Command/Query/Event)
4. ✅ Configuration DI de base

### **Phase 2: Domain Layer (Semaine 3-4)**
1. ✅ Migrer les aggregates existants
2. ✅ Implémenter les événements de domaine
3. ✅ Refactoriser les spécifications et services domaine
4. ✅ Tests unitaires exhaustifs du domain

### **Phase 3: Application Layer (Semaine 5-6)**
1. ✅ Créer les commands/queries/handlers
2. ✅ Migrer la logique métier des controllers actuels
3. ✅ Implémentation des DTOs et mappers
4. ✅ Tests d'intégration application

### **Phase 4: Infrastructure (Semaine 7-8)**
1. ✅ Adaptateurs de persistance (Supabase/Hive)
2. ✅ Adaptateurs d'événements
3. ✅ Migration des repositories existants
4. ✅ Tests d'infrastructure

### **Phase 5: Presentation Refactoring (Semaine 9-10)**
1. ✅ Nouveaux controllers basés sur buses
2. ✅ Mise à jour des providers Riverpod
3. ✅ Migration des pages existantes
4. ✅ Tests UI et intégration

### **Phase 6: Migration & Cleanup (Semaine 11-12)**
1. ✅ Migration des données existantes
2. ✅ Suppression du code legacy
3. ✅ Optimisations performance
4. ✅ Documentation et formation équipe

## 📊 AVANTAGES DE LA NOUVELLE ARCHITECTURE

### **🎯 SCALABILITÉ**
- **Bounded Contexts** indépendants → Évolution parallèle possible
- **Microservices Ready** → Migration future facilitée
- **Plugin Architecture** → Extensions sans modification core

### **🧪 TESTABILITÉ**
- **Dependency Injection** → Mocking facilité
- **Ports/Adapters** → Tests unitaires isolés
- **Event Sourcing Ready** → Reproductibilité des bugs

### **🔧 MAINTENABILITÉ** 
- **Single Responsibility** → Modules cohérents
- **Interface Segregation** → Couplage minimal
- **Open/Closed** → Extensions sans modification

### **⚡ PERFORMANCE**
- **CQRS** → Optimisation lecture/écriture séparée
- **Event-Driven** → Processing asynchrone
- **Caching Layers** → Performance optimisée

### **🚀 ÉVOLUTIVITÉ**
- **Domain Events** → Intégration système externe facile
- **Anti-Corruption Layers** → Migration progressive
- **Backward Compatibility** → Zero downtime deployment

## 💡 BONNES PRATIQUES ÉTABLIES

1. **Domain First** → Business logic pure sans dépendances
2. **Explicit Architecture** → Intentions claires et documentées
3. **Fail Fast** → Validation early, exceptions explicites
4. **Immutable by Default** → Value objects et aggregates immutables
5. **Event-Driven Design** → Communication découplée
6. **Testing Strategy** → AAA pattern, Given-When-Then
7. **Documentation as Code** → ADRs, diagrammes automatiques

Cette architecture transformera Prioris en une application robuste, scalable et maintenable, prête pour l'avenir et l'équipe de développement.