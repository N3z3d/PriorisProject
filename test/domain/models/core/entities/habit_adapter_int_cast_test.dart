import 'package:flutter_test/flutter_test.dart';

/// Tests unitaires pour le pattern de cast num->double utilisé dans HabitAdapter
/// (lib/domain/models/core/entities/habit.g.dart, champ targetValue)
///
/// Vérifie que `(fields[5] as num?)?.toDouble()` gère correctement
/// les valeurs int retournées par Hive.
void main() {
  group('HabitAdapter - num cast pattern (story 8.9)', () {
    test('should convert int to double via num cast', () {
      final dynamic intValue = 8; // simule fields[5] stocké comme int
      final result = (intValue as num?)?.toDouble();
      expect(result, 8.0);
      expect(result, isA<double>());
    });

    test('should pass through double unchanged via num cast', () {
      final dynamic doubleValue = 8.0;
      final result = (doubleValue as num?)?.toDouble();
      expect(result, 8.0);
      expect(result, isA<double>());
    });

    test('should return null for null field', () {
      final dynamic nullValue = null;
      final result = (nullValue as num?)?.toDouble();
      expect(result, isNull);
    });

    test('should convert zero int to 0.0', () {
      final dynamic zeroInt = 0;
      final result = (zeroInt as num?)?.toDouble();
      expect(result, 0.0);
      expect(result, isA<double>());
    });

    test('old cast would throw CastError for int', () {
      final dynamic intValue = 8; // int, not double
      expect(
        () => intValue as double?,
        throwsA(isA<TypeError>()),
      );
    });
  });
}
