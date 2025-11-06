import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Workflow categories supported by the abstract factory.
enum WorkflowType { personal, business, custom, unknown }

/// Contract for creating productivity items.
abstract class ProductivityAbstractFactory {
  ListItem createTask(String title, String description);
  ListItem createHabit(String title, String description);
  ListItem createNote(String title, String content);
}

String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

class PersonalProductivityFactory implements ProductivityAbstractFactory {
  @override
  ListItem createTask(String title, String description) {
    return ListItem(
      id: _generateId(),
      title: title,
      description: description,
      category: 'Personal',
      eloScore: 1200.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createHabit(String title, String description) {
    return ListItem(
      id: _generateId(),
      title: title,
      description: description,
      category: 'Health',
      eloScore: 1300.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createNote(String title, String content) {
    return ListItem(
      id: _generateId(),
      title: title,
      description: content,
      category: 'Notes',
      eloScore: 1100.0,
      createdAt: DateTime.now(),
    );
  }
}

class BusinessWorkflowFactory implements ProductivityAbstractFactory {
  @override
  ListItem createTask(String title, String description) {
    return ListItem(
      id: _generateId(),
      title: title,
      description: description,
      category: 'Business',
      eloScore: 1400.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createHabit(String title, String description) {
    return ListItem(
      id: _generateId(),
      title: title,
      description: description,
      category: 'Professional',
      eloScore: 1350.0,
      createdAt: DateTime.now(),
    );
  }

  @override
  ListItem createNote(String title, String content) {
    return ListItem(
      id: _generateId(),
      title: title,
      description: content,
      category: 'Business Documentation',
      eloScore: 1250.0,
      createdAt: DateTime.now(),
    );
  }
}

/// Registry/provider for productivity factories.
class ProductivityFactoryProvider {
  final Map<WorkflowType, ProductivityAbstractFactory> _factories = {
    WorkflowType.personal: PersonalProductivityFactory(),
    WorkflowType.business: BusinessWorkflowFactory(),
  };

  ProductivityAbstractFactory getFactory(WorkflowType type) {
    final factory = _factories[type];
    if (factory == null) {
      throw UnsupportedError('No factory registered for workflow type "$type".');
    }
    return factory;
  }

  void registerFactory(
    WorkflowType type,
    ProductivityAbstractFactory factory,
  ) {
    _factories[type] = factory;
  }

  List<WorkflowType> getAvailableTypes() {
    return List<WorkflowType>.unmodifiable(
      _factories.keys.where((type) => type != WorkflowType.custom),
    );
  }
}
