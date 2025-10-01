import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Composite Pattern Implementation
///
/// Purpose: Compose objects into tree structures to represent part-whole
/// hierarchies. Composite lets clients treat individual objects and
/// compositions of objects uniformly.
///
/// This implementation creates hierarchical task/project structures.

/// Component interface for the composite pattern
abstract class TaskComponent {
  String getId();
  String getName();
  String? getDescription();
  double getTotalScore();
  int getItemCount();
  bool isCompleted();
  void setCompleted(bool completed);
  double getCompletionPercentage();
  List<TaskComponent> getChildren();
  void accept(TaskVisitor visitor);
  Map<String, dynamic> toJson();
}

/// Leaf component - individual task
class TaskLeaf implements TaskComponent {
  final String id;
  final String name;
  final String? description;
  final double eloScore;
  bool _isCompleted;

  TaskLeaf({
    required this.id,
    required this.name,
    this.description,
    this.eloScore = 1200.0,
    bool isCompleted = false,
  }) : _isCompleted = isCompleted;

  @override
  String getId() => id;

  @override
  String getName() => name;

  @override
  String? getDescription() => description;

  @override
  double getTotalScore() => eloScore;

  @override
  int getItemCount() => 1;

  @override
  bool isCompleted() => _isCompleted;

  @override
  void setCompleted(bool completed) {
    _isCompleted = completed;
  }

  @override
  double getCompletionPercentage() => _isCompleted ? 1.0 : 0.0;

  @override
  List<TaskComponent> getChildren() => [];

  @override
  void accept(TaskVisitor visitor) {
    visitor.visitLeaf(this);
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'leaf',
      'id': id,
      'name': name,
      'description': description,
      'eloScore': eloScore,
      'isCompleted': _isCompleted,
      'totalScore': getTotalScore(),
      'itemCount': getItemCount(),
      'completionPercentage': getCompletionPercentage(),
    };
  }

  @override
  String toString() => 'Task: $name (${_isCompleted ? "✓" : "○"})';
}

/// Composite component - project or group
class ProjectComposite implements TaskComponent {
  final String id;
  final String name;
  final String? description;
  final List<TaskComponent> _children = [];

  ProjectComposite({
    required this.id,
    required this.name,
    this.description,
  });

  @override
  String getId() => id;

  @override
  String getName() => name;

  @override
  String? getDescription() => description;

  @override
  double getTotalScore() {
    return _children.fold(0.0, (sum, child) => sum + child.getTotalScore());
  }

  @override
  int getItemCount() {
    return _children.fold(0, (sum, child) => sum + child.getItemCount());
  }

  @override
  bool isCompleted() {
    if (_children.isEmpty) return false;
    return _children.every((child) => child.isCompleted());
  }

  @override
  void setCompleted(bool completed) {
    for (final child in _children) {
      child.setCompleted(completed);
    }
  }

  @override
  double getCompletionPercentage() {
    if (_children.isEmpty) return 0.0;

    final totalPercentage = _children.fold(
      0.0,
      (sum, child) => sum + child.getCompletionPercentage(),
    );

    return totalPercentage / _children.length;
  }

  @override
  List<TaskComponent> getChildren() => List.unmodifiable(_children);

  // Composite-specific methods
  void addChild(TaskComponent child) {
    _children.add(child);
  }

  void removeChild(TaskComponent child) {
    _children.remove(child);
  }

  void removeChildById(String id) {
    _children.removeWhere((child) => child.getId() == id);
  }

  TaskComponent? findChildById(String id) {
    // Search direct children
    for (final child in _children) {
      if (child.getId() == id) return child;

      // Search recursively in composite children
      if (child is ProjectComposite) {
        final found = child.findChildById(id);
        if (found != null) return found;
      }
    }
    return null;
  }

  @override
  void accept(TaskVisitor visitor) {
    visitor.visitComposite(this);
    for (final child in _children) {
      child.accept(visitor);
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'composite',
      'id': id,
      'name': name,
      'description': description,
      'totalScore': getTotalScore(),
      'itemCount': getItemCount(),
      'isCompleted': isCompleted(),
      'completionPercentage': getCompletionPercentage(),
      'children': _children.map((child) => child.toJson()).toList(),
    };
  }

  @override
  String toString() {
    final completion = (getCompletionPercentage() * 100).toStringAsFixed(1);
    return 'Project: $name ($completion% complete, ${getItemCount()} items)';
  }
}

/// Visitor interface for traversing the composite structure
abstract class TaskVisitor {
  void visitLeaf(TaskLeaf leaf);
  void visitComposite(ProjectComposite composite);
}

/// Concrete visitor for calculating statistics
class TaskStatisticsVisitor implements TaskVisitor {
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalProjects = 0;
  double _totalScore = 0.0;

  @override
  void visitLeaf(TaskLeaf leaf) {
    _totalTasks++;
    if (leaf.isCompleted()) _completedTasks++;
    _totalScore += leaf.getTotalScore();
  }

  @override
  void visitComposite(ProjectComposite composite) {
    _totalProjects++;
  }

  Map<String, dynamic> getStatistics() {
    return {
      'total_tasks': _totalTasks,
      'completed_tasks': _completedTasks,
      'completion_rate': _totalTasks > 0 ? _completedTasks / _totalTasks : 0.0,
      'total_projects': _totalProjects,
      'total_score': _totalScore,
      'average_score': _totalTasks > 0 ? _totalScore / _totalTasks : 0.0,
    };
  }

  void reset() {
    _totalTasks = 0;
    _completedTasks = 0;
    _totalProjects = 0;
    _totalScore = 0.0;
  }
}

/// Concrete visitor for rendering the tree structure
class TaskTreeRenderVisitor implements TaskVisitor {
  final List<String> _lines = [];
  int _currentDepth = 0;

  @override
  void visitLeaf(TaskLeaf leaf) {
    final indent = '  ' * _currentDepth;
    final status = leaf.isCompleted() ? '✓' : '○';
    _lines.add('$indent$status ${leaf.getName()} (${leaf.getTotalScore()})');
  }

  @override
  void visitComposite(ProjectComposite composite) {
    final indent = '  ' * _currentDepth;
    final completion = (composite.getCompletionPercentage() * 100).toStringAsFixed(0);
    _lines.add('$indent📁 ${composite.getName()} ($completion%)');
    _currentDepth++;
  }

  String getTreeString() {
    return _lines.join('\n');
  }

  List<String> getLines() => List.unmodifiable(_lines);

  void reset() {
    _lines.clear();
    _currentDepth = 0;
  }
}

/// Task hierarchy manager
class TaskHierarchyManager {
  final ProjectComposite _root;
  final TaskStatisticsVisitor _statsVisitor = TaskStatisticsVisitor();
  final TaskTreeRenderVisitor _renderVisitor = TaskTreeRenderVisitor();

  TaskHierarchyManager({String rootName = 'Root Project'})
      : _root = ProjectComposite(
          id: 'root',
          name: rootName,
          description: 'Root project container',
        );

  /// Get root project
  ProjectComposite getRoot() => _root;

  /// Add project to root
  void addProject(ProjectComposite project) {
    _root.addChild(project);
  }

  /// Add task to root
  void addTask(TaskLeaf task) {
    _root.addChild(task);
  }

  /// Find any component by ID
  TaskComponent? findById(String id) {
    if (_root.getId() == id) return _root;
    return _root.findChildById(id);
  }

  /// Create a project with tasks
  ProjectComposite createProject({
    required String name,
    String? description,
    List<TaskLeaf>? tasks,
  }) {
    final project = ProjectComposite(
      id: 'proj_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
    );

    if (tasks != null) {
      for (final task in tasks) {
        project.addChild(task);
      }
    }

    return project;
  }

  /// Create a task
  TaskLeaf createTask({
    required String name,
    String? description,
    double eloScore = 1200.0,
    bool isCompleted = false,
  }) {
    return TaskLeaf(
      id: 'task_${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      eloScore: eloScore,
      isCompleted: isCompleted,
    );
  }

  /// Get statistics for the entire hierarchy
  Map<String, dynamic> getStatistics() {
    _statsVisitor.reset();
    _root.accept(_statsVisitor);
    return _statsVisitor.getStatistics();
  }

  /// Get tree visualization
  String renderTree() {
    _renderVisitor.reset();
    _root.accept(_renderVisitor);
    return _renderVisitor.getTreeString();
  }

  /// Export entire hierarchy to JSON
  Map<String, dynamic> exportToJson() {
    return _root.toJson();
  }

  /// Import hierarchy from JSON
  static TaskHierarchyManager importFromJson(Map<String, dynamic> json) {
    final manager = TaskHierarchyManager(rootName: json['name']);
    // Implementation would recursively build the hierarchy
    return manager;
  }

  /// Get all incomplete tasks (flattened)
  List<TaskLeaf> getIncompleteTasks() {
    final incompleteTasks = <TaskLeaf>[];
    _collectIncompleteTasks(_root, incompleteTasks);
    return incompleteTasks;
  }

  void _collectIncompleteTasks(TaskComponent component, List<TaskLeaf> result) {
    if (component is TaskLeaf && !component.isCompleted()) {
      result.add(component);
    } else if (component is ProjectComposite) {
      for (final child in component.getChildren()) {
        _collectIncompleteTasks(child, result);
      }
    }
  }

  /// Get projects by completion status
  List<ProjectComposite> getProjectsByCompletion({required bool completed}) {
    final projects = <ProjectComposite>[];
    _collectProjectsByCompletion(_root, projects, completed);
    return projects;
  }

  void _collectProjectsByCompletion(
    TaskComponent component,
    List<ProjectComposite> result,
    bool targetCompleted,
  ) {
    if (component is ProjectComposite && component != _root) {
      if (component.isCompleted() == targetCompleted) {
        result.add(component);
      }
      // Continue searching children regardless
      for (final child in component.getChildren()) {
        _collectProjectsByCompletion(child, result, targetCompleted);
      }
    } else if (component is ProjectComposite) {
      // For root, just search children
      for (final child in component.getChildren()) {
        _collectProjectsByCompletion(child, result, targetCompleted);
      }
    }
  }
}