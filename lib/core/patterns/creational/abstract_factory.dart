import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Abstract Factory Pattern Implementation
///
/// Purpose: Provide an interface for creating families of related or dependent
/// objects without specifying their concrete classes.
///
/// This implementation creates different types of productivity items
/// (tasks, habits, notes) for different workflow contexts (personal, business).

/// Abstract Factory Interface
abstract class ProductivityAbstractFactory {
  /// Create a task item
  ListItem createTask(String title, String description);

  /// Create a habit item
  ListItem createHabit(String title, String description);

  /// Create a note item
  ListItem createNote(String title, String content);
}

/// Concrete Factory for Personal Productivity
class PersonalProductivityFactory implements ProductivityAbstractFactory {
  @override
  ListItem createTask(String title, String description) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: 'Personal',
      eloScore: 1200.0, // Standard priority for personal tasks
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createHabit(String title, String description) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: 'Health',
      eloScore: 1300.0, // Slightly higher for personal habits
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createNote(String title, String content) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: content,
      category: 'Notes',
      eloScore: 1100.0, // Lower priority for notes
      createdAt: DateTime.now(),
    );
  }
}

/// Concrete Factory for Business Productivity
class BusinessWorkflowFactory implements ProductivityAbstractFactory {
  @override
  ListItem createTask(String title, String description) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: 'Business',
      eloScore: 1400.0, // Higher priority for business tasks
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createHabit(String title, String description) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: 'Professional',
      eloScore: 1350.0, // Professional habits priority
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createNote(String title, String content) {
    return ListItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: content,
      category: 'Business Documentation',
      eloScore: 1250.0, // Business documentation priority
      createdAt: DateTime.now(),
    );
  }
}

/// Workflow types enumeration
enum WorkflowType {
  personal,
  business,
  custom,
  unknown,
}

/// Factory Provider - manages different abstract factories
class ProductivityFactoryProvider {
  final Map<WorkflowType, ProductivityAbstractFactory> _factories = {};

  ProductivityFactoryProvider() {
    // Register default factories
    _factories[WorkflowType.personal] = PersonalProductivityFactory();
    _factories[WorkflowType.business] = BusinessWorkflowFactory();
  }

  /// Get factory for specific workflow type
  ProductivityAbstractFactory getFactory(WorkflowType type) {
    final factory = _factories[type];
    if (factory == null) {
      throw UnsupportedError('No factory registered for workflow type: $type');
    }
    return factory;
  }

  /// Register a custom factory
  void registerFactory(WorkflowType type, ProductivityAbstractFactory factory) {
    _factories[type] = factory;
  }

  /// Get available workflow types
  List<WorkflowType> getAvailableTypes() {
    return _factories.keys.toList();
  }

  /// Remove a factory
  void unregisterFactory(WorkflowType type) {
    _factories.remove(type);
  }

  /// Check if factory exists
  bool hasFactory(WorkflowType type) {
    return _factories.containsKey(type);
  }
}

/// High-level productivity service using Abstract Factory
class ProductivityService {
  final ProductivityFactoryProvider _factoryProvider = ProductivityFactoryProvider();

  /// Create a complete personal workflow setup
  Map<String, ListItem> createPersonalWorkflow({
    required String taskTitle,
    required String habitTitle,
    required String noteTitle,
  }) {
    final factory = _factoryProvider.getFactory(WorkflowType.personal);

    return {
      'task': factory.createTask(taskTitle, 'Personal task'),
      'habit': factory.createHabit(habitTitle, 'Personal habit'),
      'note': factory.createNote(noteTitle, 'Personal note'),
    };
  }

  /// Create a complete business workflow setup
  Map<String, ListItem> createBusinessWorkflow({
    required String taskTitle,
    required String habitTitle,
    required String noteTitle,
  }) {
    final factory = _factoryProvider.getFactory(WorkflowType.business);

    return {
      'task': factory.createTask(taskTitle, 'Business task'),
      'habit': factory.createHabit(habitTitle, 'Business habit'),
      'note': factory.createNote(noteTitle, 'Business documentation'),
    };
  }

  /// Create items using specified workflow type
  Map<String, ListItem> createWorkflow(
    WorkflowType type, {
    required String taskTitle,
    required String habitTitle,
    required String noteTitle,
  }) {
    final factory = _factoryProvider.getFactory(type);

    return {
      'task': factory.createTask(taskTitle, 'Generated task'),
      'habit': factory.createHabit(habitTitle, 'Generated habit'),
      'note': factory.createNote(noteTitle, 'Generated note'),
    };
  }

  /// Get service statistics
  Map<String, dynamic> getServiceStats() {
    return {
      'available_workflows': _factoryProvider.getAvailableTypes().length,
      'registered_types': _factoryProvider.getAvailableTypes().map((t) => t.toString()).toList(),
    };
  }

  /// Register custom workflow factory
  void registerCustomWorkflow(WorkflowType type, ProductivityAbstractFactory factory) {
    _factoryProvider.registerFactory(type, factory);
  }
}