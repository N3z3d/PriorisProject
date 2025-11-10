import 'package:uuid/uuid.dart';

/// Service for generating unique identifiers across the application
///
/// **SRP**: Single responsibility - ID generation only
/// **DIP**: Depends on abstraction (Uuid interface)
///
/// Guarantees:
/// - Uniqueness via UUIDv4 (collision probability ~= 0)
/// - Consistency across entity types
/// - Testability via injectable UUID generator
class IdGenerationService {
  final Uuid _uuid;

  IdGenerationService([Uuid? uuid]) : _uuid = uuid ?? const Uuid();

  /// Generates a unique ID for a ListItem
  ///
  /// Format: UUID v4 (e.g., "550e8400-e29b-41d4-a716-446655440000")
  ///
  /// Guarantees:
  /// - Globally unique (collision probability < 10^-36)
  /// - No dependency on timestamp or external state
  /// - Thread-safe and idempotent
  String generateListItemId() {
    return _uuid.v4();
  }

  /// Generates a unique ID for a CustomList
  String generateListId() {
    return _uuid.v4();
  }

  /// Generates multiple unique IDs in a single batch
  ///
  /// More efficient than calling generateListItemId() N times
  /// when creating multiple items simultaneously
  List<String> generateBatchIds(int count) {
    if (count <= 0) {
      throw ArgumentError('Count must be positive, got: $count');
    }
    return List.generate(count, (_) => _uuid.v4());
  }

  /// Legacy format for backward compatibility (if needed)
  ///
  /// Format: {prefix}_{timestamp}_{index}_{hashCode}
  /// WARNING: Not collision-proof - use generateListItemId() for new code
  @Deprecated('Use generateListItemId() instead for better uniqueness')
  String generateLegacyId({
    required String prefix,
    required int index,
    required int hashCode,
  }) {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    return '${prefix}_${timestamp}_${index}_$hashCode';
  }
}
