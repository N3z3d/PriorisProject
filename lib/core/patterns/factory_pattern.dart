/// Factory Pattern Implementation following SOLID principles
///
/// Single Responsibility: Each factory creates objects of one type
/// Open/Closed: Easy to add new factories without modifying existing code
/// Dependency Inversion: Depend on factory abstractions
/// Interface Segregation: Specific factory interfaces for different needs

import '../interfaces/application_interfaces.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ABSTRACT FACTORY PATTERN (OCP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base factory interface
abstract class BaseFactory<T> implements Factory<T> {
  final Map<Type, T Function()> _creators = {};

  /// Register a creator function for a type
  void register<TType extends T>(TType Function() creator) {
    _creators[TType] = creator;
  }

  /// Unregister a creator for a type
  void unregister<TType extends T>() {
    _creators.remove(TType);
  }

  @override
  bool canCreate(Type type) {
    return _creators.containsKey(type);
  }

  /// Create instance by type
  TType createByType<TType extends T>() {
    final creator = _creators[TType];
    if (creator == null) {
      throw ArgumentError('No creator registered for type ${TType.toString()}');
    }
    return creator() as TType;
  }

  /// Get all registered types
  List<Type> get registeredTypes => _creators.keys.toList();

  /// Clear all registrations
  void clearRegistrations() {
    _creators.clear();
  }
}

/// Named factory for creating objects by string identifier
abstract class NamedFactory<T> extends BaseFactory<T> {
  final Map<String, T Function()> _namedCreators = {};

  /// Register a creator function with a name
  void registerNamed(String name, T Function() creator) {
    _namedCreators[name] = creator;
  }

  /// Unregister a named creator
  void unregisterNamed(String name) {
    _namedCreators.remove(name);
  }

  /// Create instance by name
  T createByName(String name) {
    final creator = _namedCreators[name];
    if (creator == null) {
      throw ArgumentError('No creator registered for name: $name');
    }
    return creator();
  }

  /// Check if a name is registered
  bool hasName(String name) => _namedCreators.containsKey(name);

  /// Get all registered names
  List<String> get registeredNames => _namedCreators.keys.toList();
}

/// Configurable factory that creates objects based on configuration
abstract class ConfigurableFactory<T> extends NamedFactory<T> {
  final Map<String, Map<String, dynamic>> _configurations = {};

  /// Register a configuration-based creator
  void registerWithConfig(
    String name,
    T Function(Map<String, dynamic>) creator,
    Map<String, dynamic> defaultConfig,
  ) {
    _configurations[name] = defaultConfig;
    registerNamed(name, () => creator(defaultConfig));
  }

  /// Create with custom configuration
  T createWithConfig(String name, Map<String, dynamic> config) {
    if (!hasName(name)) {
      throw ArgumentError('No creator registered for name: $name');
    }

    final mergedConfig = {..._configurations[name] ?? {}, ...config};
    return createConfigured(name, mergedConfig);
  }

  /// Override this method to handle configured creation
  T createConfigured(String name, Map<String, dynamic> config);
}

// ═══════════════════════════════════════════════════════════════════════════
// REPOSITORY FACTORY (SRP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Factory for creating repository instances
class RepositoryFactory extends ConfigurableFactory<dynamic> {
  static final RepositoryFactory _instance = RepositoryFactory._();
  static RepositoryFactory get instance => _instance;

  RepositoryFactory._();

  @override
  dynamic createConfigured(String name, Map<String, dynamic> config) {
    // This would be implemented based on specific repository types
    throw UnimplementedError('Repository creation not implemented');
  }

  /// Create repository with default configuration
  T createRepository<T>(String name) {
    return createByName(name) as T;
  }

  /// Register a repository creator
  void registerRepository<T>(String name, T Function() creator) {
    registerNamed(name, creator);
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SERVICE FACTORY (SRP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Factory for creating service instances
class ServiceFactory extends ConfigurableFactory<dynamic> {
  static final ServiceFactory _instance = ServiceFactory._();
  static ServiceFactory get instance => _instance;

  ServiceFactory._();

  @override
  dynamic createConfigured(String name, Map<String, dynamic> config) {
    switch (name) {
      case 'cache':
        return _createCacheService(config);
      case 'logger':
        return _createLoggerService(config);
      case 'validator':
        return _createValidatorService(config);
      default:
        throw ArgumentError('Unknown service type: $name');
    }
  }

  /// Create cache service with configuration
  dynamic _createCacheService(Map<String, dynamic> config) {
    final maxSize = config['maxSize'] as int? ?? 1000;
    final ttl = Duration(minutes: config['ttlMinutes'] as int? ?? 30);
    // Return actual cache service instance
    return null; // Placeholder
  }

  /// Create logger service with configuration
  dynamic _createLoggerService(Map<String, dynamic> config) {
    final level = config['level'] as String? ?? 'info';
    final format = config['format'] as String? ?? 'json';
    // Return actual logger service instance
    return null; // Placeholder
  }

  /// Create validator service with configuration
  dynamic _createValidatorService(Map<String, dynamic> config) {
    final strict = config['strict'] as bool? ?? false;
    // Return actual validator service instance
    return null; // Placeholder
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// BUILDER PATTERN IMPLEMENTATION (SRP)
// ═══════════════════════════════════════════════════════════════════════════

/// Base builder implementation
abstract class BaseBuilder<T> implements Builder<T> {
  bool _isBuilt = false;

  @override
  Builder<T> reset() {
    _isBuilt = false;
    resetInternal();
    return this;
  }

  @override
  T build() {
    if (_isBuilt) {
      throw StateError('Builder has already been used. Call reset() first.');
    }

    final result = buildInternal();
    _isBuilt = true;
    return result;
  }

  /// Reset internal state - to be implemented by concrete builders
  void resetInternal();

  /// Build the object - to be implemented by concrete builders
  T buildInternal();

  /// Check if builder is in a valid state to build
  bool get canBuild => !_isBuilt;
}

/// Fluent builder with method chaining
abstract class FluentBuilder<T> extends BaseBuilder<T> {
  /// Get a type-safe reference to this builder for method chaining
  TBuilder self<TBuilder extends FluentBuilder<T>>() => this as TBuilder;
}

// ═══════════════════════════════════════════════════════════════════════════
// EXAMPLE: CUSTOM LIST BUILDER (SRP Example)
// ═══════════════════════════════════════════════════════════════════════════

/// Builder for creating CustomList entities
class CustomListBuilder extends FluentBuilder<Map<String, dynamic>> {
  String? _id;
  String? _name;
  String? _description;
  String? _type;
  List<String> _tags = [];
  Map<String, dynamic> _metadata = {};
  DateTime? _createdAt;

  CustomListBuilder withId(String id) {
    _id = id;
    return this;
  }

  CustomListBuilder withName(String name) {
    _name = name;
    return this;
  }

  CustomListBuilder withDescription(String description) {
    _description = description;
    return this;
  }

  CustomListBuilder withType(String type) {
    _type = type;
    return this;
  }

  CustomListBuilder addTag(String tag) {
    _tags.add(tag);
    return this;
  }

  CustomListBuilder addTags(List<String> tags) {
    _tags.addAll(tags);
    return this;
  }

  CustomListBuilder addMetadata(String key, dynamic value) {
    _metadata[key] = value;
    return this;
  }

  CustomListBuilder withCreatedAt(DateTime createdAt) {
    _createdAt = createdAt;
    return this;
  }

  @override
  void resetInternal() {
    _id = null;
    _name = null;
    _description = null;
    _type = null;
    _tags = [];
    _metadata = {};
    _createdAt = null;
  }

  @override
  Map<String, dynamic> buildInternal() {
    if (_name == null) {
      throw StateError('Name is required');
    }

    return {
      'id': _id ?? _generateId(),
      'name': _name!,
      'description': _description,
      'type': _type ?? 'default',
      'tags': List.unmodifiable(_tags),
      'metadata': Map.unmodifiable(_metadata),
      'createdAt': _createdAt ?? DateTime.now(),
    };
  }

  String _generateId() {
    return 'list_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ABSTRACT FACTORY FOR DOMAIN OBJECTS (OCP + DIP)
// ═══════════════════════════════════════════════════════════════════════════

/// Abstract factory for creating domain objects
abstract class DomainObjectFactory {
  /// Create a custom list
  Map<String, dynamic> createCustomList({required String name, String? description});

  /// Create a list item
  Map<String, dynamic> createListItem({required String title, String? description});

  /// Create a task
  Map<String, dynamic> createTask({required String title, DateTime? dueDate});

  /// Create a habit
  Map<String, dynamic> createHabit({required String name, required String frequency});
}

/// Concrete factory for production domain objects
class ProductionDomainObjectFactory implements DomainObjectFactory {
  @override
  Map<String, dynamic> createCustomList({required String name, String? description}) {
    return CustomListBuilder()
        .withName(name)
        .withDescription(description ?? '')
        .withType('user_created')
        .build();
  }

  @override
  Map<String, dynamic> createListItem({required String title, String? description}) {
    return {
      'id': _generateId(),
      'title': title,
      'description': description ?? '',
      'priority': 0.5,
      'completed': false,
      'createdAt': DateTime.now(),
    };
  }

  @override
  Map<String, dynamic> createTask({required String title, DateTime? dueDate}) {
    return {
      'id': _generateId(),
      'title': title,
      'dueDate': dueDate,
      'status': 'pending',
      'priority': 'medium',
      'createdAt': DateTime.now(),
    };
  }

  @override
  Map<String, dynamic> createHabit({required String name, required String frequency}) {
    return {
      'id': _generateId(),
      'name': name,
      'frequency': frequency,
      'streak': 0,
      'active': true,
      'createdAt': DateTime.now(),
    };
  }

  String _generateId() {
    return 'obj_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }
}

/// Factory for test domain objects (different behavior for testing)
class TestDomainObjectFactory implements DomainObjectFactory {
  @override
  Map<String, dynamic> createCustomList({required String name, String? description}) {
    return {
      'id': 'test_list_${name.toLowerCase()}',
      'name': 'TEST: $name',
      'description': description ?? 'Test description',
      'type': 'test',
      'createdAt': DateTime(2023, 1, 1), // Fixed date for tests
    };
  }

  @override
  Map<String, dynamic> createListItem({required String title, String? description}) {
    return {
      'id': 'test_item_${title.toLowerCase()}',
      'title': 'TEST: $title',
      'description': description ?? 'Test description',
      'priority': 1.0,
      'completed': false,
      'createdAt': DateTime(2023, 1, 1), // Fixed date for tests
    };
  }

  @override
  Map<String, dynamic> createTask({required String title, DateTime? dueDate}) {
    return {
      'id': 'test_task_${title.toLowerCase()}',
      'title': 'TEST: $title',
      'dueDate': dueDate ?? DateTime(2023, 12, 31),
      'status': 'test',
      'priority': 'test',
      'createdAt': DateTime(2023, 1, 1), // Fixed date for tests
    };
  }

  @override
  Map<String, dynamic> createHabit({required String name, required String frequency}) {
    return {
      'id': 'test_habit_${name.toLowerCase()}',
      'name': 'TEST: $name',
      'frequency': frequency,
      'streak': 0,
      'active': false, // Inactive for tests
      'createdAt': DateTime(2023, 1, 1), // Fixed date for tests
    };
  }
}