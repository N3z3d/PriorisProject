import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Builder Pattern Implementation
///
/// Purpose: Separate the construction of a complex object from its representation
/// so that the same construction process can create different representations.
///
/// This implementation provides a fluent interface for creating ListItem objects
/// with optional parameters and validation.

/// ListItem Builder class
class ListItemBuilder {
  String? _title;
  String? _description;
  String? _category;
  double _eloScore = 1200.0;
  bool _isCompleted = false;
  DateTime? _dueDate;
  String? _notes;
  String _listId = 'default';

  /// Set title (required)
  ListItemBuilder setTitle(String title) {
    _title = title;
    return this;
  }

  /// Set description (optional)
  ListItemBuilder setDescription(String description) {
    _description = description;
    return this;
  }

  /// Set category (optional)
  ListItemBuilder setCategory(String category) {
    _category = category;
    return this;
  }

  /// Set ELO score
  ListItemBuilder setEloScore(double score) {
    _eloScore = score;
    return this;
  }

  /// Set completion status
  ListItemBuilder setCompleted(bool completed) {
    _isCompleted = completed;
    return this;
  }

  /// Set due date
  ListItemBuilder setDueDate(DateTime dueDate) {
    _dueDate = dueDate;
    return this;
  }

  /// Set notes
  ListItemBuilder setNotes(String notes) {
    _notes = notes;
    return this;
  }

  /// Set list ID
  ListItemBuilder setListId(String listId) {
    _listId = listId;
    return this;
  }

  /// Build the ListItem
  ListItem build() {
    // Validate required fields
    if (_title == null || _title!.trim().isEmpty) {
      throw ArgumentError('Title is required and cannot be empty');
    }

    final now = DateTime.now();
    // Ensure unique ID by adding microseconds and a random element
    final uniqueId = '${now.microsecondsSinceEpoch}_${DateTime.now().millisecond}';

    final item = ListItem(
      id: uniqueId,
      title: _title!,
      description: _description,
      category: _category,
      eloScore: _eloScore,
      isCompleted: _isCompleted,
      createdAt: now,
      completedAt: _isCompleted ? now : null,
      dueDate: _dueDate,
      notes: _notes,
      listId: _listId,
    );

    // Reset builder for reuse
    _reset();

    return item;
  }

  /// Create builder from existing item (for cloning/modification)
  ListItemBuilder.fromExisting(ListItem item) {
    _title = item.title;
    _description = item.description;
    _category = item.category;
    _eloScore = item.eloScore;
    _isCompleted = item.isCompleted;
    _dueDate = item.dueDate;
    _notes = item.notes;
    _listId = item.listId;
  }

  /// Default constructor
  ListItemBuilder();

  /// Reset builder state
  void _reset() {
    _title = null;
    _description = null;
    _category = null;
    _eloScore = 1200.0;
    _isCompleted = false;
    _dueDate = null;
    _notes = null;
    _listId = 'default';
  }

  /// Validate current state
  bool isValid() {
    return _title != null && _title!.trim().isNotEmpty;
  }

  /// Get current configuration as map
  Map<String, dynamic> getCurrentConfiguration() {
    return {
      'title': _title,
      'description': _description,
      'category': _category,
      'eloScore': _eloScore,
      'isCompleted': _isCompleted,
      'dueDate': _dueDate?.toIso8601String(),
      'notes': _notes,
      'listId': _listId,
      'isValid': isValid(),
    };
  }
}

/// Builder Director - provides predefined construction processes
class ListItemBuilderDirector {
  final ListItemBuilder _builder = ListItemBuilder();

  /// Build a personal task with standard configuration
  ListItem buildPersonalTask(String title, String description) {
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Personal')
        .setEloScore(1200.0)
        .build();
  }

  /// Build a work task with elevated priority
  ListItem buildWorkTask(String title, String description) {
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Work')
        .setEloScore(1350.0)
        .build();
  }

  /// Build an urgent task with high priority
  ListItem buildUrgentTask(String title, String description) {
    final urgentDueDate = DateTime.now().add(const Duration(hours: 4));
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Urgent')
        .setEloScore(1600.0)
        .setDueDate(urgentDueDate)
        .build();
  }

  /// Build a shopping item with specific category
  ListItem buildShoppingItem(String item, {String? store}) {
    final description = store != null ? 'Buy at $store' : 'Purchase item';
    return _builder
        .setTitle(item)
        .setDescription(description)
        .setCategory('Shopping')
        .setEloScore(1100.0)
        .build();
  }

  /// Build a health-related task
  ListItem buildHealthTask(String title, String description, {DateTime? scheduledTime}) {
    final builder = _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Health')
        .setEloScore(1400.0);

    if (scheduledTime != null) {
      builder.setDueDate(scheduledTime);
    }

    return builder.build();
  }

  /// Build a complete project workflow (multiple related items)
  Map<String, ListItem> buildProjectWorkflow(String projectName, String projectDescription) {
    final workflow = <String, ListItem>{};

    // Planning phase
    workflow['planning'] = _builder
        .setTitle('$projectName - Planning')
        .setDescription('Plan and design phase for $projectDescription')
        .setCategory('Planning')
        .setEloScore(1300.0)
        .build();

    // Development phase
    workflow['development'] = _builder
        .setTitle('$projectName - Development')
        .setDescription('Implementation phase for $projectDescription')
        .setCategory('Development')
        .setEloScore(1450.0)
        .build();

    // Testing phase
    workflow['testing'] = _builder
        .setTitle('$projectName - Testing')
        .setDescription('Testing and QA phase for $projectDescription')
        .setCategory('QA')
        .setEloScore(1350.0)
        .build();

    // Deployment phase
    workflow['deployment'] = _builder
        .setTitle('$projectName - Deployment')
        .setDescription('Deployment and release phase for $projectDescription')
        .setCategory('DevOps')
        .setEloScore(1400.0)
        .build();

    return workflow;
  }

  /// Build recurring task template
  ListItem buildRecurringTaskTemplate(
    String title,
    String description,
    String category,
    Duration frequency,
  ) {
    final nextDue = DateTime.now().add(frequency);
    return _builder
        .setTitle('$title (Recurring)')
        .setDescription('$description - Repeats every ${frequency.inDays} days')
        .setCategory(category)
        .setEloScore(1250.0)
        .setDueDate(nextDue)
        .setNotes('Auto-generated recurring task')
        .build();
  }

  /// Build item with dependencies
  ListItem buildDependentTask(
    String title,
    String description,
    List<String> dependencies,
  ) {
    final dependencyNotes = 'Depends on: ${dependencies.join(', ')}';
    return _builder
        .setTitle(title)
        .setDescription(description)
        .setCategory('Dependent')
        .setEloScore(1300.0)
        .setNotes(dependencyNotes)
        .build();
  }
}

/// Specialized builder for complex scenarios
class AdvancedListItemBuilder extends ListItemBuilder {
  final List<String> _tags = [];
  int _estimatedHours = 0;
  String? _assignedTo;

  /// Add tag
  AdvancedListItemBuilder addTag(String tag) {
    if (!_tags.contains(tag)) {
      _tags.add(tag);
    }
    return this;
  }

  /// Set estimated hours
  AdvancedListItemBuilder setEstimatedHours(int hours) {
    _estimatedHours = hours;
    return this;
  }

  /// Assign to person
  AdvancedListItemBuilder assignTo(String person) {
    _assignedTo = person;
    return this;
  }

  /// Build with advanced properties
  @override
  ListItem build() {
    final basicItem = super.build();

    // Create enhanced notes with additional info
    final enhancedNotes = <String>[];
    if (basicItem.notes != null) enhancedNotes.add(basicItem.notes!);
    if (_tags.isNotEmpty) enhancedNotes.add('Tags: ${_tags.join(', ')}');
    if (_estimatedHours > 0) enhancedNotes.add('Estimated: ${_estimatedHours}h');
    if (_assignedTo != null) enhancedNotes.add('Assigned to: $_assignedTo');

    return basicItem.copyWith(
      notes: enhancedNotes.isNotEmpty ? enhancedNotes.join(' | ') : null,
    );
  }

  /// Reset advanced properties
  void resetAdvanced() {
    _tags.clear();
    _estimatedHours = 0;
    _assignedTo = null;
  }
}