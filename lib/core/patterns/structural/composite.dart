import 'dart:collection';

typedef TaskJson = Map<String, dynamic>;

abstract class TaskComponent {
  String getId();
  String getName();
  String? getDescription();
  double getTotalScore();
  int getItemCount();
  bool isCompleted();
  double getCompletionPercentage();
  void setCompleted(bool completed);
  void accept(TaskVisitor visitor, int depth);
  TaskComponent? findChildById(String id);
  TaskJson toJson();
}

abstract class TaskVisitor {
  void visitTask(TaskLeaf task, int depth);
  void visitProject(ProjectComposite project, int depth);
}

class TaskLeaf implements TaskComponent {
  TaskLeaf({
    required this.id,
    required this.name,
    this.description,
    this.eloScore = 1200.0,
    bool isCompleted = false,
  })  : _isCompleted = isCompleted,
        createdAt = DateTime.now();

  final String id;
  final String name;
  final String? description;
  final double eloScore;
  final DateTime createdAt;
  bool _isCompleted;

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
  double getCompletionPercentage() => _isCompleted ? 1.0 : 0.0;

  @override
  void setCompleted(bool completed) {
    _isCompleted = completed;
  }

  @override
  void accept(TaskVisitor visitor, int depth) {
    visitor.visitTask(this, depth);
  }

  @override
  TaskComponent? findChildById(String id) => this.id == id ? this : null;

  @override
  TaskJson toJson() {
    return {
      'type': 'task',
      'id': id,
      'name': name,
      'description': description,
      'eloScore': eloScore,
      'completed': _isCompleted,
    };
  }
}

class ProjectComposite implements TaskComponent {
  ProjectComposite({
    required this.id,
    required this.name,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final List<TaskComponent> _children = [];

  @override
  String getId() => id;

  @override
  String getName() => name;

  @override
  String? getDescription() => description;

  List<TaskComponent> getChildren() =>
      List.unmodifiable(_children);

  void addChild(TaskComponent component) {
    _children.add(component);
  }

  void removeChild(TaskComponent component) {
    _children.remove(component);
  }

  @override
  double getTotalScore() {
    return _children.fold<double>(
      0.0,
      (sum, child) => sum + child.getTotalScore(),
    );
  }

  @override
  int getItemCount() {
    return _children.fold<int>(
      0,
      (count, child) => count + child.getItemCount(),
    );
  }

  @override
  bool isCompleted() {
    if (_children.isEmpty) return false;
    return _children.every((child) => child.isCompleted());
  }

  @override
  double getCompletionPercentage() {
    final totalItems = getItemCount();
    if (totalItems == 0) return 0.0;
    final completedCount = _children.fold<double>(
      0.0,
      (count, child) =>
          count + child.getCompletionPercentage() * child.getItemCount(),
    );
    return completedCount / totalItems;
  }

  @override
  void setCompleted(bool completed) {
    for (final child in _children) {
      child.setCompleted(completed);
    }
  }

  @override
  void accept(TaskVisitor visitor, int depth) {
    visitor.visitProject(this, depth);
    for (final child in _children) {
      child.accept(visitor, depth + 1);
    }
  }

  @override
  TaskComponent? findChildById(String searchId) {
    if (id == searchId) {
      return this;
    }
    for (final child in _children) {
      final found = child.findChildById(searchId);
      if (found != null) {
        return found;
      }
    }
    return null;
  }

  @override
  TaskJson toJson() {
    return {
      'type': 'composite',
      'id': id,
      'name': name,
      'description': description,
      'totalScore': getTotalScore(),
      'itemCount': getItemCount(),
      'completed': isCompleted(),
      'children': _children.map((child) => child.toJson()).toList(),
    };
  }
}

class TaskStatisticsVisitor implements TaskVisitor {
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _totalProjects = 0;
  double _totalScore = 0.0;

  @override
  void visitProject(ProjectComposite project, int depth) {
    _totalProjects += 1;
  }

  @override
  void visitTask(TaskLeaf task, int depth) {
    _totalTasks += 1;
    if (task.isCompleted()) {
      _completedTasks += 1;
    }
    _totalScore += task.getTotalScore();
  }

  Map<String, dynamic> getStatistics() {
    final completionRate =
        _totalTasks == 0 ? 0.0 : _completedTasks / _totalTasks;
    return {
      'total_tasks': _totalTasks,
      'completed_tasks': _completedTasks,
      'completion_rate': completionRate,
      'total_projects': _totalProjects,
      'total_score': _totalScore,
    };
  }
}

class TaskTreeRenderVisitor implements TaskVisitor {
  static const String _completedIcon = '�o"';
  static const String _pendingIcon = '�-<';

  final StringBuffer _buffer = StringBuffer();

  String getTreeString() => _buffer.toString();

  void _writeLine(int depth, String content) {
    final indent = '  ' * depth;
    _buffer.writeln('$indent$content');
  }

  @override
  void visitProject(ProjectComposite project, int depth) {
    _writeLine(depth, '📁 ${project.getName()}');
  }

  @override
  void visitTask(TaskLeaf task, int depth) {
    final icon = task.isCompleted() ? _completedIcon : _pendingIcon;
    _writeLine(depth, '$icon ${task.getName()}');
  }
}

class TaskHierarchyManager {
  TaskHierarchyManager({String rootName = 'Projects'})
      : _root = ProjectComposite(
          id: 'root-${DateTime.now().microsecondsSinceEpoch}',
          name: rootName,
        );

  final ProjectComposite _root;

  ProjectComposite createProject({required String name, String? description}) {
    return ProjectComposite(
      id: _generateId(),
      name: name,
      description: description,
    );
  }

  TaskLeaf createTask({
    required String name,
    String? description,
    double eloScore = 1200.0,
    bool isCompleted = false,
  }) {
    return TaskLeaf(
      id: _generateId(),
      name: name,
      description: description,
      eloScore: eloScore,
      isCompleted: isCompleted,
    );
  }

  void addProject(ProjectComposite project) {
    _root.addChild(project);
  }

  Map<String, dynamic> getStatistics() {
    final visitor = TaskStatisticsVisitor();
    _root.accept(visitor, 0);
    return visitor.getStatistics();
  }

  String renderTree() {
    final visitor = TaskTreeRenderVisitor();
    _root.accept(visitor, 0);
    return visitor.getTreeString();
  }

  List<TaskLeaf> getIncompleteTasks() {
    final List<TaskLeaf> results = [];
    void collect(TaskComponent component) {
      if (component is TaskLeaf && !component.isCompleted()) {
        results.add(component);
      } else if (component is ProjectComposite) {
        for (final child in component.getChildren()) {
          collect(child);
        }
      }
    }

    collect(_root);
    return results;
  }

  TaskJson exportToJson() => _root.toJson();

  ProjectComposite get root => _root;
}
