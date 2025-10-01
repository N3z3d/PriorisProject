import 'dart:math';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Prototype Pattern Implementation
///
/// Purpose: Specify the kinds of objects to create using a prototypical instance,
/// and create new objects by copying this prototype.
///
/// This implementation allows cloning of ListItem objects and provides a
/// registry for managing prototype instances.

/// Abstract Prototype interface
abstract class Prototype<T> {
  /// Clone the current instance
  T clone();
}

/// Prototype implementation for ListItem
class PrototypeListItem implements Prototype<PrototypeListItem> {
  final String id;
  final String title;
  final String? description;
  final String? category;
  final double eloScore;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? dueDate;
  final String? notes;
  final String listId;

  PrototypeListItem({
    required this.id,
    required this.title,
    this.description,
    this.category,
    this.eloScore = 1200.0,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
    this.dueDate,
    this.notes,
    this.listId = 'default',
  });

  /// Create from ListItem
  factory PrototypeListItem.fromListItem(ListItem item) {
    return PrototypeListItem(
      id: item.id,
      title: item.title,
      description: item.description,
      category: item.category,
      eloScore: item.eloScore,
      isCompleted: item.isCompleted,
      createdAt: item.createdAt,
      completedAt: item.completedAt,
      dueDate: item.dueDate,
      notes: item.notes,
      listId: item.listId,
    );
  }

  @override
  PrototypeListItem clone() {
    return PrototypeListItem(
      id: _generateUniqueId(),
      title: title,
      description: description,
      category: category,
      eloScore: eloScore,
      isCompleted: isCompleted,
      createdAt: DateTime.now(), // New creation time
      completedAt: completedAt,
      dueDate: dueDate,
      notes: notes,
      listId: listId,
    );
  }

  /// Clone with modifications
  PrototypeListItem cloneWithModifications(Map<String, dynamic> modifications) {
    return PrototypeListItem(
      id: _generateUniqueId(),
      title: modifications['title'] ?? title,
      description: modifications['description'] ?? description,
      category: modifications['category'] ?? category,
      eloScore: modifications['eloScore'] ?? eloScore,
      isCompleted: modifications['isCompleted'] ?? isCompleted,
      createdAt: modifications['createdAt'] ?? DateTime.now(),
      completedAt: modifications['completedAt'] ?? completedAt,
      dueDate: modifications['dueDate'] ?? dueDate,
      notes: modifications['notes'] ?? notes,
      listId: modifications['listId'] ?? listId,
    );
  }

  /// Convert to ListItem
  ListItem toListItem() {
    return ListItem(
      id: id,
      title: title,
      description: description,
      category: category,
      eloScore: eloScore,
      isCompleted: isCompleted,
      createdAt: createdAt,
      completedAt: completedAt,
      dueDate: dueDate,
      notes: notes,
      listId: listId,
    );
  }

  String _generateUniqueId() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return '${now.microsecondsSinceEpoch}_$random';
  }

  @override
  String toString() {
    return 'PrototypeListItem(id: $id, title: $title, category: $category)';
  }
}

/// Advanced prototype with complex nested properties
class AdvancedPrototypeItem implements Prototype<AdvancedPrototypeItem> {
  final String id;
  final String title;
  final String? description;
  final Map<String, dynamic> metadata;
  final DateTime createdAt;

  AdvancedPrototypeItem({
    required this.id,
    required this.title,
    this.description,
    required this.metadata,
    required this.createdAt,
  });

  @override
  AdvancedPrototypeItem clone() {
    return AdvancedPrototypeItem(
      id: _generateUniqueId(),
      title: title,
      description: description,
      metadata: Map<String, dynamic>.from(metadata), // Deep copy
      createdAt: DateTime.now(),
    );
  }

  String _generateUniqueId() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return 'adv_${now.microsecondsSinceEpoch}_$random';
  }
}

/// Prototype Registry - manages prototype instances
class PrototypeRegistry {
  final Map<String, PrototypeListItem> _prototypes = {};

  PrototypeRegistry() {
    _initializeDefaultPrototypes();
  }

  /// Initialize default prototypes
  void _initializeDefaultPrototypes() {
    _prototypes['task'] = PrototypeListItem(
      id: 'task-prototype',
      title: 'Task Template',
      description: 'Standard task template',
      category: 'Task',
      eloScore: 1200.0,
      createdAt: DateTime.now(),
    );

    _prototypes['habit'] = PrototypeListItem(
      id: 'habit-prototype',
      title: 'Habit Template',
      description: 'Daily habit template',
      category: 'Habit',
      eloScore: 1300.0,
      createdAt: DateTime.now(),
    );

    _prototypes['note'] = PrototypeListItem(
      id: 'note-prototype',
      title: 'Note Template',
      description: 'Quick note template',
      category: 'Note',
      eloScore: 1100.0,
      createdAt: DateTime.now(),
    );
  }

  /// Get prototype by key and clone it
  PrototypeListItem getPrototype(String key) {
    final prototype = _prototypes[key];
    if (prototype == null) {
      throw ArgumentError('No prototype found for key: $key');
    }
    return prototype.clone();
  }

  /// Register new prototype
  void registerPrototype(String key, PrototypeListItem prototype) {
    _prototypes[key] = prototype;
  }

  /// Remove prototype
  void removePrototype(String key) {
    _prototypes.remove(key);
  }

  /// Get all available prototype keys
  List<String> getAvailableKeys() {
    return _prototypes.keys.toList();
  }

  /// Check if prototype exists
  bool hasPrototype(String key) {
    return _prototypes.containsKey(key);
  }

  /// Clone all prototypes
  Map<String, PrototypeListItem> cloneAll() {
    final clones = <String, PrototypeListItem>{};
    for (final entry in _prototypes.entries) {
      clones[entry.key] = entry.value.clone();
    }
    return clones;
  }
}

/// Prototype Manager - high-level prototype management
class PrototypeManager {
  final PrototypeRegistry _registry = PrototypeRegistry();

  PrototypeManager() {
    _initializeTemplates();
  }

  /// Initialize predefined templates
  void _initializeTemplates() {
    _registry.registerPrototype('urgent', PrototypeListItem(
      id: 'urgent-template',
      title: 'Urgent Template',
      description: 'High priority urgent task',
      category: 'Urgent',
      eloScore: 1600.0,
      createdAt: DateTime.now(),
    ));

    _registry.registerPrototype('routine', PrototypeListItem(
      id: 'routine-template',
      title: 'Routine Template',
      description: 'Regular routine task',
      category: 'Routine',
      eloScore: 1250.0,
      createdAt: DateTime.now(),
    ));

    _registry.registerPrototype('project', PrototypeListItem(
      id: 'project-template',
      title: 'Project Template',
      description: 'Project-related task',
      category: 'Project',
      eloScore: 1300.0,
      createdAt: DateTime.now(),
    ));
  }

  /// Create item from template with custom properties
  PrototypeListItem createFromTemplate(
    String templateKey, {
    required String title,
    required String description,
    String? category,
    double? eloScore,
  }) {
    final template = _registry.getPrototype(templateKey);
    return template.cloneWithModifications({
      'title': title,
      'description': description,
      if (category != null) 'category': category,
      if (eloScore != null) 'eloScore': eloScore,
    });
  }

  /// Create variation of existing item
  PrototypeListItem createVariation(
    PrototypeListItem baseItem,
    Map<String, dynamic> modifications,
  ) {
    return baseItem.cloneWithModifications(modifications);
  }

  /// Batch create items from template
  List<PrototypeListItem> batchCreate(
    String templateKey,
    List<Map<String, String>> itemInfos,
  ) {
    final items = <PrototypeListItem>[];
    for (final info in itemInfos) {
      final item = createFromTemplate(
        templateKey,
        title: info['title']!,
        description: info['description']!,
      );
      items.add(item);
    }
    return items;
  }

  /// Create series of related items
  List<PrototypeListItem> createSeries(
    String templateKey,
    String baseTitle,
    int count, {
    String? titleSuffix,
  }) {
    final items = <PrototypeListItem>[];
    for (int i = 1; i <= count; i++) {
      final title = titleSuffix != null
          ? '$baseTitle $i $titleSuffix'
          : '$baseTitle $i';

      final item = createFromTemplate(
        templateKey,
        title: title,
        description: 'Auto-generated item $i of $count',
      );
      items.add(item);
    }
    return items;
  }

  /// Get manager statistics
  Map<String, dynamic> getStats() {
    return {
      'available_templates': _registry.getAvailableKeys().length,
      'template_keys': _registry.getAvailableKeys(),
    };
  }

  /// Register custom template
  void registerTemplate(String key, PrototypeListItem template) {
    _registry.registerPrototype(key, template);
  }

  /// Import templates from configuration
  void importTemplates(Map<String, Map<String, dynamic>> templateConfigs) {
    for (final entry in templateConfigs.entries) {
      final config = entry.value;
      final template = PrototypeListItem(
        id: '${entry.key}-template',
        title: config['title'] ?? 'Template',
        description: config['description'],
        category: config['category'],
        eloScore: config['eloScore']?.toDouble() ?? 1200.0,
        createdAt: DateTime.now(),
      );
      _registry.registerPrototype(entry.key, template);
    }
  }
}