import 'package:prioris/domain/models/core/entities/list_item.dart';

abstract class Prototype<T> {
  T clone();
}

int _prototypeIdCounter = 0;
String _generateId() =>
    'proto-${DateTime.now().microsecondsSinceEpoch}-${_prototypeIdCounter++}';

class PrototypeListItem implements Prototype<PrototypeListItem> {
  PrototypeListItem({
    String? id,
    required this.title,
    required this.description,
    required this.category,
    this.eloScore = 1200.0,
    DateTime? createdAt,
    bool isCompleted = false,
  })  : id = id ?? _generateId(),
        createdAt = createdAt ?? DateTime.now(),
        isCompleted = isCompleted;

  final String id;
  final String title;
  final String description;
  final String category;
  final double eloScore;
  final DateTime createdAt;
  final bool isCompleted;

  @override
  PrototypeListItem clone() {
    return PrototypeListItem(
      title: title,
      description: description,
      category: category,
      eloScore: eloScore,
      isCompleted: isCompleted,
    );
  }

  ListItem toListItem() {
    return ListItem(
      id: id,
      title: title,
      description: description,
      category: category,
      eloScore: eloScore,
      isCompleted: isCompleted,
      createdAt: createdAt,
    );
  }
}

class AdvancedPrototypeItem extends PrototypeListItem {
  AdvancedPrototypeItem({
    required super.id,
    required super.title,
    required super.description,
    required Map<String, dynamic> metadata,
    super.createdAt,
    super.isCompleted,
  })  : metadata = Map<String, dynamic>.from(metadata),
        super(category: metadata['category'] as String? ?? 'Advanced', eloScore: (metadata['eloScore'] as num?)?.toDouble() ?? 1200.0);

  Map<String, dynamic> metadata;

  @override
  AdvancedPrototypeItem clone() {
    return AdvancedPrototypeItem(
      id: _generateId(),
      title: title,
      description: description,
      metadata: Map<String, dynamic>.from(metadata),
      createdAt: DateTime.now(),
      isCompleted: isCompleted,
    );
  }
}

class PrototypeRegistry {
  PrototypeRegistry() {
    registerPrototype(
      'task',
      PrototypeListItem(
        title: 'Task Template',
        description: 'Standard task template',
        category: 'Task',
        eloScore: 1200.0,
      ),
    );
    registerPrototype(
      'habit',
      PrototypeListItem(
        title: 'Habit Template',
        description: 'Standard habit template',
        category: 'Habit',
        eloScore: 1250.0,
      ),
    );
    registerPrototype(
      'note',
      PrototypeListItem(
        title: 'Note Template',
        description: 'Standard note template',
        category: 'Note',
        eloScore: 1100.0,
      ),
    );
  }

  final Map<String, PrototypeListItem> _prototypes = {};

  PrototypeListItem getPrototype(String key) {
    final prototype = _prototypes[key];
    if (prototype == null) {
      throw ArgumentError('No prototype registered for key "$key".');
    }
    return prototype.clone();
  }

  void registerPrototype(String key, PrototypeListItem prototype) {
    _prototypes[key] = prototype;
  }
}

class PrototypeManager {
  PrototypeManager() {
    _registry.registerPrototype(
      'urgent',
      PrototypeListItem(
        title: 'Urgent Template',
        description: 'Template for urgent tasks',
        category: 'Urgent',
        eloScore: 1600.0,
      ),
    );
    _registry.registerPrototype(
      'routine',
      PrototypeListItem(
        title: 'Routine Habit',
        description: 'Template for routine habits',
        category: 'Routine',
        eloScore: 1250.0,
      ),
    );
    _registry.registerPrototype(
      'project',
      PrototypeListItem(
        title: 'Project Note',
        description: 'Template for project notes',
        category: 'Project',
        eloScore: 1300.0,
      ),
    );
  }

  final PrototypeRegistry _registry = PrototypeRegistry();

  PrototypeListItem createFromTemplate(
    String templateKey, {
    required String title,
    required String description,
  }) {
    final prototype = _registry.getPrototype(templateKey).clone();
    return PrototypeListItem(
      title: title,
      description: description,
      category: prototype.category,
      eloScore: prototype.eloScore,
    );
  }

  PrototypeListItem createVariation(
    PrototypeListItem base,
    Map<String, dynamic> modifications,
  ) {
    return PrototypeListItem(
      title: (modifications['title'] as String?) ?? base.title,
      description: (modifications['description'] as String?) ?? base.description,
      category: (modifications['category'] as String?) ?? base.category,
      eloScore: (modifications['eloScore'] as num?)?.toDouble() ?? base.eloScore,
      isCompleted: (modifications['isCompleted'] as bool?) ?? base.isCompleted,
    );
  }

  List<PrototypeListItem> batchCreate(
    String templateKey,
    List<Map<String, String>> data,
  ) {
    final template = _registry.getPrototype(templateKey);
    final List<PrototypeListItem> results = [];
    for (final item in data) {
      final cloned = template.clone();
      results.add(
        PrototypeListItem(
          title: item['title'] ?? cloned.title,
          description: item['description'] ?? cloned.description,
          category: cloned.category,
          eloScore: cloned.eloScore,
        ),
      );
    }
    return results;
  }

  void registerTemplate(String key, PrototypeListItem prototype) {
    _registry.registerPrototype(key, prototype);
  }
}
