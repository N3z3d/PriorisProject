import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:prioris/domain/models/core/entities/habit.dart';

/// Tests the num→double cast pattern used in HabitAdapter
/// (lib/domain/models/core/entities/habit.g.dart, field targetValue at index 5).
///
/// Two test groups:
/// - Pattern isolation: verifies the cast expression directly (fast, independent of adapter code)
/// - Via HabitAdapter.read(): exercises the actual adapter code path so a build_runner
///   regeneration that reverts the fix would be caught at test time.
class _FakeBinaryReader extends BinaryReader {
  final List<int> _bytes;
  final List<dynamic> _values;
  int _bytePos = 0;
  int _valuePos = 0;

  _FakeBinaryReader({required List<int> bytes, required List<dynamic> values})
      : _bytes = bytes,
        _values = values;

  @override
  int readByte() => _bytes[_bytePos++];

  @override
  dynamic read([int? typeId]) => _values[_valuePos++];

  @override
  int get availableBytes => throw UnimplementedError();
  @override
  int get usedBytes => throw UnimplementedError();
  @override
  void skip(int bytes) => throw UnimplementedError();
  @override
  Uint8List viewBytes(int bytes) => throw UnimplementedError();
  @override
  Uint8List peekBytes(int bytes) => throw UnimplementedError();
  @override
  bool readBool() => throw UnimplementedError();
  @override
  List<bool> readBoolList([int? length]) => throw UnimplementedError();
  @override
  Uint8List readByteList([int? byteCount]) => throw UnimplementedError();
  @override
  DateTime readDateTime() => throw UnimplementedError();
  @override
  double readDouble() => throw UnimplementedError();
  @override
  List<double> readDoubleList([int? length]) => throw UnimplementedError();
  @override
  HiveList readHiveList([int? length]) => throw UnimplementedError();
  @override
  int readInt() => throw UnimplementedError();
  @override
  int readInt32() => throw UnimplementedError();
  @override
  List<int> readIntList([int? length]) => throw UnimplementedError();
  @override
  List readList([int? length]) => throw UnimplementedError();
  @override
  Map readMap([int? length]) => throw UnimplementedError();
  @override
  String readString([
    int? byteCount,
    Converter<List<int>, String>? encoder,
  ]) =>
      throw UnimplementedError();
  @override
  List<String> readStringList([
    int? length,
    Converter<List<int>, String>? encoder,
  ]) =>
      throw UnimplementedError();
  @override
  int readUint32() => throw UnimplementedError();
  @override
  int readWord() => throw UnimplementedError();
}

/// Builds a [_FakeBinaryReader] matching the HabitAdapter.read() field layout.
/// Override [targetValueOverride] to control the value of fields[5].
_FakeBinaryReader _buildHabitReader({required dynamic targetValueOverride}) {
  // HabitAdapter reads: readByte() → numOfFields, then 29× (readByte() → key, read() → value)
  const numFields = 29;
  final bytes = [numFields, ...List.generate(numFields, (i) => i)];
  final values = <dynamic>[
    null,                    // fields[0]: id
    'Test Habit',            // fields[1]: name (required String)
    null,                    // fields[2]: description
    HabitType.quantitative,  // fields[3]: type (required HabitType)
    null,                    // fields[4]: category
    targetValueOverride,     // fields[5]: targetValue — the tested field
    null,                    // fields[6]: unit
    null,                    // fields[7]: createdAt
    null,                    // fields[8]: completions
    null,                    // fields[9]: recurrenceType
    null,                    // fields[10]: intervalDays
    null,                    // fields[11]: weekdays
    null,                    // fields[12]: timesTarget
    null,                    // fields[13]: monthlyDay
    null,                    // fields[14]: quarterMonth
    null,                    // fields[15]: yearlyMonth
    null,                    // fields[16]: yearlyDay
    null,                    // fields[17]: hourlyInterval
    null,                    // fields[18]: color
    null,                    // fields[19]: icon
    null,                    // fields[20]: currentStreak
    null,                    // fields[21]: userId
    null,                    // fields[22]: userEmail
    null,                    // fields[23]: daysActive
    null,                    // fields[24]: daysCycle
    null,                    // fields[25]: cycleStartDate
    null,                    // fields[26]: specificWeekdays
    null,                    // fields[27]: specificDate
    false,                   // fields[28]: repeatEveryYear (non-nullable bool)
  ];
  return _FakeBinaryReader(bytes: bytes, values: values);
}

void main() {
  group('HabitAdapter - num cast pattern (story 8.9)', () {
    test('should convert int to double via num cast', () {
      final dynamic intValue = 8;
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
      final dynamic intValue = 8;
      expect(
        () => intValue as double?,
        throwsA(isA<TypeError>()),
      );
    });
  });

  group('HabitAdapter.read() - int targetValue via actual adapter (story 8.9)', () {
    final adapter = HabitAdapter();

    test('should deserialise int targetValue to double without CastError', () {
      final reader = _buildHabitReader(targetValueOverride: 8); // int
      final habit = adapter.read(reader);
      expect(habit.targetValue, 8.0);
      expect(habit.targetValue, isA<double>());
    });

    test('should deserialise double targetValue unchanged', () {
      final reader = _buildHabitReader(targetValueOverride: 8.0); // double
      final habit = adapter.read(reader);
      expect(habit.targetValue, 8.0);
      expect(habit.targetValue, isA<double>());
    });

    test('should deserialise null targetValue as null', () {
      final reader = _buildHabitReader(targetValueOverride: null);
      final habit = adapter.read(reader);
      expect(habit.targetValue, isNull);
    });

    test('should deserialise zero int targetValue to 0.0', () {
      final reader = _buildHabitReader(targetValueOverride: 0); // int zero
      final habit = adapter.read(reader);
      expect(habit.targetValue, 0.0);
      expect(habit.targetValue, isA<double>());
    });
  });
}
