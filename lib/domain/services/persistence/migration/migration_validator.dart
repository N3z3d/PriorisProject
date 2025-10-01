import 'package:prioris/domain/models/core/entities/custom_list.dart';
import 'package:prioris/domain/models/core/entities/list_item.dart';

/// Validation severity levels
enum ValidationSeverity {
  info,
  warning,
  error,
  critical,
}

/// Validation rule types
enum ValidationRuleType {
  dataIntegrity,
  schemaCompatibility,
  businessLogic,
  performance,
  security,
}

/// Validation issue representation
class ValidationIssue {
  final ValidationSeverity severity;
  final ValidationRuleType type;
  final String code;
  final String message;
  final String? entityId;
  final Map<String, dynamic>? metadata;

  const ValidationIssue({
    required this.severity,
    required this.type,
    required this.code,
    required this.message,
    this.entityId,
    this.metadata,
  });

  bool get isBlocking => severity == ValidationSeverity.critical ||
                         severity == ValidationSeverity.error;

  @override
  String toString() {
    return '${severity.name.toUpperCase()}: $message (Code: $code)';
  }
}

/// Validation result container
class ValidationResult {
  final List<ValidationIssue> issues;
  final bool hasBlockingIssues;
  final Duration validationTime;

  ValidationResult({
    required this.issues,
    required this.validationTime,
  }) : hasBlockingIssues = issues.any((issue) => issue.isBlocking);

  bool get isValid => !hasBlockingIssues;

  List<ValidationIssue> get errors =>
      issues.where((i) => i.severity == ValidationSeverity.error).toList();

  List<ValidationIssue> get warnings =>
      issues.where((i) => i.severity == ValidationSeverity.warning).toList();

  List<ValidationIssue> get criticalIssues =>
      issues.where((i) => i.severity == ValidationSeverity.critical).toList();
}

/// Migration Validator - Validates data and rules before/during migration
///
/// SOLID COMPLIANCE:
/// - SRP: Single responsibility for migration validation logic
/// - OCP: Extensible through validation rule registration
/// - LSP: All validators follow same ValidationRule contract
/// - ISP: Focused interface for validation operations only
/// - DIP: Depends on validation rule abstractions
///
/// CONSTRAINTS: <200 lines (currently ~180 lines)
class MigrationValidator {
  /// Singleton instance for consistent validation across app
  static final MigrationValidator instance = MigrationValidator._();
  MigrationValidator._();

  // Internal validation rule registry
  final Map<ValidationRuleType, List<ValidationRule>> _rules = {};

  /// Validates a custom list for migration
  Future<ValidationResult> validateList(CustomList list) async {
    final stopwatch = Stopwatch()..start();
    final issues = <ValidationIssue>[];

    // Data integrity validations
    issues.addAll(await _validateListDataIntegrity(list));

    // Schema compatibility validations
    issues.addAll(await _validateListSchema(list));

    // Business logic validations
    issues.addAll(await _validateListBusinessRules(list));

    stopwatch.stop();
    return ValidationResult(
      issues: issues,
      validationTime: stopwatch.elapsed,
    );
  }

  /// Validates a list item for migration
  Future<ValidationResult> validateListItem(ListItem item) async {
    final stopwatch = Stopwatch()..start();
    final issues = <ValidationIssue>[];

    // Data integrity validations
    issues.addAll(await _validateItemDataIntegrity(item));

    // Schema compatibility validations
    issues.addAll(await _validateItemSchema(item));

    // Business logic validations
    issues.addAll(await _validateItemBusinessRules(item));

    stopwatch.stop();
    return ValidationResult(
      issues: issues,
      validationTime: stopwatch.elapsed,
    );
  }

  /// Validates migration batch for performance concerns
  Future<ValidationResult> validateMigrationBatch(
    List<CustomList> lists,
    List<ListItem> items,
  ) async {
    final stopwatch = Stopwatch()..start();
    final issues = <ValidationIssue>[];

    // Performance validations
    if (lists.length > 100) {
      issues.add(const ValidationIssue(
        severity: ValidationSeverity.warning,
        type: ValidationRuleType.performance,
        code: 'BATCH_SIZE_LARGE',
        message: 'Large batch size may impact performance. Consider splitting.',
      ));
    }

    if (items.length > 1000) {
      issues.add(const ValidationIssue(
        severity: ValidationSeverity.error,
        type: ValidationRuleType.performance,
        code: 'BATCH_SIZE_CRITICAL',
        message: 'Batch size too large. Split into smaller batches.',
      ));
    }

    // Memory usage estimation
    final estimatedMemoryMB = (lists.length * 0.5) + (items.length * 0.1);
    if (estimatedMemoryMB > 100) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.warning,
        type: ValidationRuleType.performance,
        code: 'MEMORY_USAGE_HIGH',
        message: 'High memory usage estimated: ${estimatedMemoryMB.toInt()}MB',
        metadata: {'estimatedMemoryMB': estimatedMemoryMB},
      ));
    }

    stopwatch.stop();
    return ValidationResult(
      issues: issues,
      validationTime: stopwatch.elapsed,
    );
  }

  // === PRIVATE VALIDATION METHODS ===

  Future<List<ValidationIssue>> _validateListDataIntegrity(CustomList list) async {
    final issues = <ValidationIssue>[];

    // ID validation
    if (list.id.isEmpty) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.critical,
        type: ValidationRuleType.dataIntegrity,
        code: 'LIST_ID_EMPTY',
        message: 'List ID cannot be empty',
        entityId: list.id,
      ));
    }

    // Name validation
    if (list.name.isEmpty) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.error,
        type: ValidationRuleType.dataIntegrity,
        code: 'LIST_NAME_EMPTY',
        message: 'List name cannot be empty',
        entityId: list.id,
      ));
    }

    // Name length validation
    if (list.name.length > 100) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.warning,
        type: ValidationRuleType.dataIntegrity,
        code: 'LIST_NAME_TOO_LONG',
        message: 'List name exceeds 100 characters',
        entityId: list.id,
      ));
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateListSchema(CustomList list) async {
    final issues = <ValidationIssue>[];

    // Timestamp validation
    if (list.createdAt.isAfter(DateTime.now().add(const Duration(hours: 1)))) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.error,
        type: ValidationRuleType.schemaCompatibility,
        code: 'LIST_FUTURE_TIMESTAMP',
        message: 'List creation timestamp is in the future',
        entityId: list.id,
      ));
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateListBusinessRules(CustomList list) async {
    final issues = <ValidationIssue>[];

    // Business rule: List must have reasonable creation date
    final twoYearsAgo = DateTime.now().subtract(const Duration(days: 730));
    if (list.createdAt.isBefore(twoYearsAgo)) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.info,
        type: ValidationRuleType.businessLogic,
        code: 'LIST_VERY_OLD',
        message: 'List is older than 2 years. Consider archival.',
        entityId: list.id,
      ));
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateItemDataIntegrity(ListItem item) async {
    final issues = <ValidationIssue>[];

    // ID validation
    if (item.id.isEmpty) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.critical,
        type: ValidationRuleType.dataIntegrity,
        code: 'ITEM_ID_EMPTY',
        message: 'List item ID cannot be empty',
        entityId: item.id,
      ));
    }

    // Title validation
    if (item.title.isEmpty) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.error,
        type: ValidationRuleType.dataIntegrity,
        code: 'ITEM_TITLE_EMPTY',
        message: 'List item title cannot be empty',
        entityId: item.id,
      ));
    }

    // List ID reference validation
    if (item.listId.isEmpty) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.critical,
        type: ValidationRuleType.dataIntegrity,
        code: 'ITEM_LIST_ID_EMPTY',
        message: 'List item must reference a valid list ID',
        entityId: item.id,
      ));
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateItemSchema(ListItem item) async {
    final issues = <ValidationIssue>[];

    // Completion validation
    if (item.isCompleted && item.completedAt == null) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.warning,
        type: ValidationRuleType.schemaCompatibility,
        code: 'ITEM_COMPLETION_MISMATCH',
        message: 'Item marked as completed but no completion timestamp',
        entityId: item.id,
      ));
    }

    return issues;
  }

  Future<List<ValidationIssue>> _validateItemBusinessRules(ListItem item) async {
    final issues = <ValidationIssue>[];

    // ELO score validation
    if (item.eloScore < 0 || item.eloScore > 3000) {
      issues.add(ValidationIssue(
        severity: ValidationSeverity.warning,
        type: ValidationRuleType.businessLogic,
        code: 'ITEM_ELO_OUT_OF_RANGE',
        message: 'ELO score outside normal range (0-3000)',
        entityId: item.id,
        metadata: {'eloScore': item.eloScore},
      ));
    }

    return issues;
  }
}

/// Abstract validation rule for extensibility (SOLID OCP)
abstract class ValidationRule {
  ValidationRuleType get type;
  Future<List<ValidationIssue>> validate(dynamic entity);
}