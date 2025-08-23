import 'package:prioris/domain/core/base/aggregate_root_enhanced.dart';
import 'package:uuid/uuid.dart';

/// Value objects for List Management bounded context
/// 
/// Following DDD principles:
/// - Immutable by design
/// - Self-validating
/// - Rich domain models
/// - Explicit constraints

// ========== IDENTIFIERS ==========

class ListId extends ValueObjectEnhanced {
  final String _value;

  ListId._(this._value) {
    if (_value.isEmpty) {
      throw BusinessRuleException('ListId cannot be empty');
    }
    if (_value.length < 36) {
      throw BusinessRuleException('ListId must be a valid UUID');
    }
  }

  /// Create from existing string value
  factory ListId.fromString(String value) => ListId._(value);

  /// Generate new unique ID
  factory ListId.generate() => ListId._(const Uuid().v4());

  String get value => _value;

  @override
  List<Object?> get props => [_value];
}

class TaskId extends ValueObjectEnhanced {
  final String _value;

  TaskId._(this._value) {
    if (_value.isEmpty) {
      throw BusinessRuleException('TaskId cannot be empty');
    }
  }

  factory TaskId.fromString(String value) => TaskId._(value);
  factory TaskId.generate() => TaskId._(const Uuid().v4());

  String get value => _value;

  @override
  List<Object?> get props => [_value];
}

// ========== LIST PROPERTIES ==========

class ListName extends ValueObjectEnhanced {
  final String _value;

  ListName(this._value) {
    if (_value.isEmpty) {
      throw BusinessRuleException('List name cannot be empty');
    }
    if (_value.length > 100) {
      throw BusinessRuleException('List name cannot exceed 100 characters');
    }
    if (_value.trim() != _value) {
      throw BusinessRuleException('List name cannot have leading or trailing spaces');
    }
  }

  String get value => _value;
  String get displayValue => _value;

  @override
  List<Object?> get props => [_value];
}

class ListDescription extends ValueObjectEnhanced {
  final String _value;

  ListDescription(this._value) {
    if (_value.length > 500) {
      throw BusinessRuleException('List description cannot exceed 500 characters');
    }
  }

  String get value => _value;
  String get displayValue => _value;
  bool get isEmpty => _value.isEmpty;
  bool get isNotEmpty => _value.isNotEmpty;

  @override
  List<Object?> get props => [_value];
}

// ========== LIST METRICS ==========

class ListStatistics extends ValueObjectEnhanced {
  final int _totalTasks;
  final int _completedTasks;
  final int _activeTasks;
  final DateTime _lastUpdated;

  ListStatistics._({
    required int totalTasks,
    required int completedTasks,
    required int activeTasks,
    required DateTime lastUpdated,
  }) : _totalTasks = totalTasks,
       _completedTasks = completedTasks,
       _activeTasks = activeTasks,
       _lastUpdated = lastUpdated {
    // Business invariants
    if (_totalTasks < 0) {
      throw BusinessRuleException('Total tasks cannot be negative');
    }
    if (_completedTasks < 0) {
      throw BusinessRuleException('Completed tasks cannot be negative');
    }
    if (_activeTasks < 0) {
      throw BusinessRuleException('Active tasks cannot be negative');
    }
    if (_completedTasks > _totalTasks) {
      throw BusinessRuleException('Completed tasks cannot exceed total tasks');
    }
    if (_activeTasks > _totalTasks) {
      throw BusinessRuleException('Active tasks cannot exceed total tasks');
    }
    if (_completedTasks + _activeTasks != _totalTasks) {
      throw BusinessRuleException('Completed + Active tasks must equal total tasks');
    }
  }

  /// Create empty statistics
  factory ListStatistics.empty() => ListStatistics._(
    totalTasks: 0,
    completedTasks: 0,
    activeTasks: 0,
    lastUpdated: DateTime.now(),
  );

  /// Create with specific values
  factory ListStatistics.create({
    required int totalTasks,
    required int completedTasks,
    DateTime? lastUpdated,
  }) => ListStatistics._(
    totalTasks: totalTasks,
    completedTasks: completedTasks,
    activeTasks: totalTasks - completedTasks,
    lastUpdated: lastUpdated ?? DateTime.now(),
  );

  // Getters
  int get totalTasks => _totalTasks;
  int get completedTasks => _completedTasks;
  int get activeTasks => _activeTasks;
  DateTime get lastUpdated => _lastUpdated;

  /// Calculate completion percentage (0.0 to 1.0)
  double get completionRate {
    if (_totalTasks == 0) return 0.0;
    return _completedTasks / _totalTasks;
  }

  /// Calculate completion percentage (0 to 100)
  int get completionPercentage => (completionRate * 100).round();

  /// Check if list is completed
  bool get isCompleted => _totalTasks > 0 && _completedTasks == _totalTasks;

  /// Check if list is empty
  bool get isEmpty => _totalTasks == 0;

  /// Business operations that return new instances
  ListStatistics incrementTotalTasks() => ListStatistics._(
    totalTasks: _totalTasks + 1,
    completedTasks: _completedTasks,
    activeTasks: _activeTasks + 1,
    lastUpdated: DateTime.now(),
  );

  ListStatistics incrementCompletedTasks() {
    if (_completedTasks >= _totalTasks) {
      throw BusinessRuleException('Cannot complete more tasks than total');
    }
    
    return ListStatistics._(
      totalTasks: _totalTasks,
      completedTasks: _completedTasks + 1,
      activeTasks: _activeTasks - 1,
      lastUpdated: DateTime.now(),
    );
  }

  ListStatistics decrementTotalTasks() {
    if (_totalTasks <= 0) {
      throw BusinessRuleException('Cannot have negative total tasks');
    }
    
    // Prioritize removing active tasks over completed ones
    final newActiveTasks = _activeTasks > 0 ? _activeTasks - 1 : _activeTasks;
    final newCompletedTasks = _activeTasks > 0 ? _completedTasks : _completedTasks - 1;
    
    return ListStatistics._(
      totalTasks: _totalTasks - 1,
      completedTasks: newCompletedTasks,
      activeTasks: newActiveTasks,
      lastUpdated: DateTime.now(),
    );
  }

  ListStatistics uncompleteTask() {
    if (_completedTasks <= 0) {
      throw BusinessRuleException('No completed tasks to uncomplete');
    }
    
    return ListStatistics._(
      totalTasks: _totalTasks,
      completedTasks: _completedTasks - 1,
      activeTasks: _activeTasks + 1,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [_totalTasks, _completedTasks, _activeTasks, _lastUpdated];
}

// ========== LIST PRIORITIZATION ==========

class ListPriority extends ValueObjectEnhanced {
  final int _value;

  ListPriority._(this._value) {
    if (_value < 0 || _value > 10) {
      throw BusinessRuleException('List priority must be between 0 and 10');
    }
  }

  factory ListPriority.low() => ListPriority._(1);
  factory ListPriority.medium() => ListPriority._(5);
  factory ListPriority.high() => ListPriority._(8);
  factory ListPriority.critical() => ListPriority._(10);
  factory ListPriority.fromValue(int value) => ListPriority._(value);

  int get value => _value;
  
  String get displayName {
    if (_value <= 2) return 'Low';
    if (_value <= 5) return 'Medium';
    if (_value <= 8) return 'High';
    return 'Critical';
  }

  bool get isLow => _value <= 2;
  bool get isMedium => _value > 2 && _value <= 5;
  bool get isHigh => _value > 5 && _value <= 8;
  bool get isCritical => _value > 8;

  ListPriority increase() {
    final newValue = (_value + 1).clamp(0, 10);
    return ListPriority._(newValue);
  }

  ListPriority decrease() {
    final newValue = (_value - 1).clamp(0, 10);
    return ListPriority._(newValue);
  }

  @override
  List<Object?> get props => [_value];
}

// ========== LIST TAGS ==========

class ListTag extends ValueObjectEnhanced {
  final String _value;
  final String _color;

  ListTag._(this._value, this._color) {
    if (_value.isEmpty) {
      throw BusinessRuleException('Tag value cannot be empty');
    }
    if (_value.length > 30) {
      throw BusinessRuleException('Tag value cannot exceed 30 characters');
    }
    if (!_isValidColor(_color)) {
      throw BusinessRuleException('Tag color must be a valid hex color');
    }
  }

  factory ListTag.create(String value, {String color = '#007AFF'}) =>
      ListTag._(value.trim(), color);

  String get value => _value;
  String get color => _color;
  String get displayValue => _value;

  bool _isValidColor(String color) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color);
  }

  ListTag withColor(String newColor) => ListTag._(_value, newColor);

  @override
  List<Object?> get props => [_value, _color];
}

class ListTags extends ValueObjectEnhanced {
  final List<ListTag> _tags;

  ListTags._(this._tags) {
    if (_tags.length > 10) {
      throw BusinessRuleException('A list cannot have more than 10 tags');
    }
    
    // Check for duplicates
    final tagValues = _tags.map((tag) => tag.value).toSet();
    if (tagValues.length != _tags.length) {
      throw BusinessRuleException('Duplicate tags are not allowed');
    }
  }

  factory ListTags.empty() => ListTags._([]);
  factory ListTags.fromList(List<ListTag> tags) => ListTags._(List.from(tags));

  List<ListTag> get tags => List.unmodifiable(_tags);
  int get count => _tags.length;
  bool get isEmpty => _tags.isEmpty;
  bool get isNotEmpty => _tags.isNotEmpty;

  bool contains(String tagValue) =>
      _tags.any((tag) => tag.value.toLowerCase() == tagValue.toLowerCase());

  ListTags add(ListTag tag) {
    if (contains(tag.value)) {
      throw BusinessRuleException('Tag already exists: ${tag.value}');
    }
    
    return ListTags._([..._tags, tag]);
  }

  ListTags remove(String tagValue) {
    final newTags = _tags.where((tag) => tag.value != tagValue).toList();
    return ListTags._(newTags);
  }

  @override
  List<Object?> get props => [_tags];
}

// ========== DATE RANGES ==========

class ListDateRange extends ValueObjectEnhanced {
  final DateTime? _startDate;
  final DateTime? _endDate;

  ListDateRange._(this._startDate, this._endDate) {
    if (_startDate != null && _endDate != null && _startDate!.isAfter(_endDate!)) {
      throw BusinessRuleException('Start date cannot be after end date');
    }
  }

  factory ListDateRange.open() => ListDateRange._(null, null);
  factory ListDateRange.startingFrom(DateTime startDate) => ListDateRange._(startDate, null);
  factory ListDateRange.endingAt(DateTime endDate) => ListDateRange._(null, endDate);
  factory ListDateRange.between(DateTime startDate, DateTime endDate) =>
      ListDateRange._(startDate, endDate);

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  bool get isOpen => _startDate == null && _endDate == null;
  bool get hasStartDate => _startDate != null;
  bool get hasEndDate => _endDate != null;
  bool get isClosed => _startDate != null && _endDate != null;

  bool isActive([DateTime? now]) {
    now ??= DateTime.now();
    
    if (_startDate != null && now.isBefore(_startDate!)) return false;
    if (_endDate != null && now.isAfter(_endDate!)) return false;
    
    return true;
  }

  Duration? get duration {
    if (_startDate == null || _endDate == null) return null;
    return _endDate!.difference(_startDate!);
  }

  @override
  List<Object?> get props => [_startDate, _endDate];
}