import 'package:prioris/domain/models/core/entities/list_item.dart';

class ListItemBuilder {
  ListItemBuilder();

  String? _title;
  String? _description;
  String? _category;
  double? _eloScore;
  DateTime? _dueDate;
  String? _notes;
  bool? _isCompleted;

  static ListItemBuilder fromExisting(ListItem item) {
    return ListItemBuilder()
      .._title = item.title
      .._description = item.description
      .._category = item.category
      .._eloScore = item.eloScore
      .._dueDate = item.dueDate
      .._notes = item.notes
      .._isCompleted = item.isCompleted;
  }

  ListItemBuilder setTitle(String title) {
    _title = title;
    return this;
  }

  ListItemBuilder setDescription(String description) {
    _description = description;
    return this;
  }

  ListItemBuilder setCategory(String? category) {
    _category = category;
    return this;
  }

  ListItemBuilder setEloScore(double eloScore) {
    _eloScore = eloScore;
    return this;
  }

  ListItemBuilder setDueDate(DateTime dueDate) {
    _dueDate = dueDate;
    return this;
  }

  ListItemBuilder setNotes(String? notes) {
    _notes = notes;
    return this;
  }

  ListItemBuilder setCompleted([bool completed = true]) {
    _isCompleted = completed;
    return this;
  }

  ListItem build() {
    if (_title == null || _title!.trim().isEmpty) {
      throw ArgumentError('Title is required to build a ListItem.');
    }

    final item = ListItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _title!,
      description: _description,
      category: _category,
      eloScore: _eloScore ?? 1200.0,
      createdAt: DateTime.now(),
      dueDate: _dueDate,
      notes: _notes,
      isCompleted: _isCompleted ?? false,
    );

    _reset();
    return item;
  }

  void _reset() {
    _title = null;
    _description = null;
    _category = null;
    _eloScore = null;
    _dueDate = null;
    _notes = null;
    _isCompleted = null;
  }
}

class ListItemBuilderDirector {
  final ListItemBuilder _builder;

  ListItemBuilderDirector() : _builder = ListItemBuilder();

  ListItem buildPersonalTask(String title, String description) {
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Personal')
        .setEloScore(1200.0)
        .build();
  }

  ListItem buildWorkTask(String title, String description) {
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Work')
        .setEloScore(1350.0)
        .build();
  }

  ListItem buildUrgentTask(String title, String description) {
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Urgent')
        .setEloScore(1600.0)
        .setDueDate(DateTime.now().add(const Duration(hours: 1)))
        .build();
  }

  Map<String, ListItem> buildProjectWorkflow(
    String projectTitle,
    String projectDescription,
  ) {
    final now = DateTime.now();
    return {
      'planning': _builder
          .setTitle('$projectTitle - Planning')
          .setDescription(projectDescription)
          .setCategory('Planning')
          .setEloScore(1250.0)
          .setDueDate(now.add(const Duration(days: 3)))
          .build(),
      'development': _builder
          .setTitle('$projectTitle - Development')
          .setDescription(projectDescription)
          .setCategory('Development')
          .setEloScore(1350.0)
          .setDueDate(now.add(const Duration(days: 14)))
          .build(),
      'testing': _builder
          .setTitle('$projectTitle - Testing')
          .setDescription('QA and regression testing')
          .setCategory('Quality Assurance')
          .setEloScore(1300.0)
          .setDueDate(now.add(const Duration(days: 20)))
          .build(),
      'deployment': _builder
          .setTitle('$projectTitle - Deployment')
          .setDescription('Release to production')
          .setCategory('DevOps')
          .setEloScore(1400.0)
          .setDueDate(now.add(const Duration(days: 25)))
          .build(),
    };
  }
}
