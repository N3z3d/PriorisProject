import 'package:prioris/domain/core/events/domain_event.dart';
import 'package:prioris/domain/core/value_objects/export.dart';

/// Enhanced Aggregate Root with proper domain event handling
/// 
/// Follows DDD principles:
/// - Encapsulates business invariants
/// - Publishes domain events for side effects
/// - Maintains consistency boundaries
abstract class AggregateRootEnhanced<TId> {
  final TId _id;
  final DateTime _createdAt;
  DateTime? _updatedAt;
  int _version;
  
  final List<DomainEvent> _domainEvents = [];

  AggregateRootEnhanced(
    this._id, {
    DateTime? createdAt,
    DateTime? updatedAt,
    int version = 1,
  }) : _createdAt = createdAt ?? DateTime.now(),
       _updatedAt = updatedAt,
       _version = version;

  // Getters
  TId get id => _id;
  DateTime get createdAt => _createdAt;
  DateTime? get updatedAt => _updatedAt;
  int get version => _version;
  List<DomainEvent> get domainEvents => List.unmodifiable(_domainEvents);

  // Domain event management
  void addDomainEvent(DomainEvent event) {
    _domainEvents.add(event);
  }

  void clearDomainEvents() {
    _domainEvents.clear();
  }

  // Aggregate lifecycle
  void markAsModified() {
    _updatedAt = DateTime.now();
    _version++;
  }

  // Equality based on ID
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AggregateRootEnhanced<TId> && other._id == _id;
  }

  @override
  int get hashCode => _id.hashCode;

  @override
  String toString() => '${runtimeType}(id: $_id, version: $_version)';

  /// Template method for business rule validation
  /// Subclasses should override to implement specific invariants
  void validate() {
    // Base validation - override in subclasses
  }

  /// Template method for optimistic concurrency control
  void checkVersion(int expectedVersion) {
    if (_version != expectedVersion) {
      throw ConcurrencyException(
        'Expected version $_version, but got $expectedVersion'
      );
    }
  }
}

/// Exception thrown when business rules are violated
class BusinessRuleException implements Exception {
  final String message;
  final String? ruleCode;

  const BusinessRuleException(this.message, {this.ruleCode});

  @override
  String toString() => 'Business Rule Violation: $message';
}

/// Exception thrown when concurrency conflicts occur
class ConcurrencyException implements Exception {
  final String message;

  const ConcurrencyException(this.message);

  @override
  String toString() => 'Concurrency Conflict: $message';
}

/// Base class for all value objects
abstract class ValueObjectEnhanced {
  const ValueObjectEnhanced();

  /// Subclasses must implement props for equality comparison
  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ValueObjectEnhanced) return false;
    if (runtimeType != other.runtimeType) return false;
    
    return _listEquals(props, other.props);
  }

  @override
  int get hashCode => _listHashCode(props);

  @override
  String toString() {
    return '$runtimeType(${props.join(', ')})';
  }

  // Helper methods for list comparison
  bool _listEquals(List<Object?> a, List<Object?> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  int _listHashCode(List<Object?> list) {
    if (list.isEmpty) return 0;
    
    int hash = 0;
    for (final item in list) {
      hash = hash ^ (item?.hashCode ?? 0);
    }
    return hash;
  }
}

/// Enhanced domain service base class
abstract class DomainServiceEnhanced {
  const DomainServiceEnhanced();
  
  /// Domain services should be stateless and focus on business logic
  /// that doesn't naturally fit within an aggregate
}

/// Specification pattern for complex business rules
abstract class SpecificationEnhanced<T> {
  const SpecificationEnhanced();

  bool isSatisfiedBy(T candidate);
  String get description;

  SpecificationEnhanced<T> and(SpecificationEnhanced<T> other) {
    return AndSpecification(this, other);
  }

  SpecificationEnhanced<T> or(SpecificationEnhanced<T> other) {
    return OrSpecification(this, other);
  }

  SpecificationEnhanced<T> not() {
    return NotSpecification(this);
  }
}

class AndSpecification<T> extends SpecificationEnhanced<T> {
  final SpecificationEnhanced<T> _left;
  final SpecificationEnhanced<T> _right;

  const AndSpecification(this._left, this._right);

  @override
  bool isSatisfiedBy(T candidate) {
    return _left.isSatisfiedBy(candidate) && _right.isSatisfiedBy(candidate);
  }

  @override
  String get description => '(${_left.description} AND ${_right.description})';
}

class OrSpecification<T> extends SpecificationEnhanced<T> {
  final SpecificationEnhanced<T> _left;
  final SpecificationEnhanced<T> _right;

  const OrSpecification(this._left, this._right);

  @override
  bool isSatisfiedBy(T candidate) {
    return _left.isSatisfiedBy(candidate) || _right.isSatisfiedBy(candidate);
  }

  @override
  String get description => '(${_left.description} OR ${_right.description})';
}

class NotSpecification<T> extends SpecificationEnhanced<T> {
  final SpecificationEnhanced<T> _specification;

  const NotSpecification(this._specification);

  @override
  bool isSatisfiedBy(T candidate) {
    return !_specification.isSatisfiedBy(candidate);
  }

  @override
  String get description => 'NOT (${_specification.description})';
}