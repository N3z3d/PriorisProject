// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 2;

  @override
  Habit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Habit(
      id: fields[0] as String?,
      name: fields[1] as String,
      description: fields[2] as String?,
      type: fields[3] as HabitType,
      category: fields[4] as String?,
      targetValue: fields[5] as double?,
      unit: fields[6] as String?,
      createdAt: fields[7] as DateTime?,
      completions: (fields[8] as Map?)?.cast<String, dynamic>(),
      recurrenceType: fields[9] as RecurrenceType?,
      intervalDays: fields[10] as int?,
      weekdays: (fields[11] as List?)?.cast<int>(),
      timesTarget: fields[12] as int?,
      monthlyDay: fields[13] as int?,
      quarterMonth: fields[14] as int?,
      yearlyMonth: fields[15] as int?,
      yearlyDay: fields[16] as int?,
      hourlyInterval: fields[17] as int?,
      color: fields[18] as int?,
      icon: fields[19] as int?,
      currentStreak: fields[20] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.completions)
      ..writeByte(9)
      ..write(obj.recurrenceType)
      ..writeByte(10)
      ..write(obj.intervalDays)
      ..writeByte(11)
      ..write(obj.weekdays)
      ..writeByte(12)
      ..write(obj.timesTarget)
      ..writeByte(13)
      ..write(obj.monthlyDay)
      ..writeByte(14)
      ..write(obj.quarterMonth)
      ..writeByte(15)
      ..write(obj.yearlyMonth)
      ..writeByte(16)
      ..write(obj.yearlyDay)
      ..writeByte(17)
      ..write(obj.hourlyInterval)
      ..writeByte(18)
      ..write(obj.color)
      ..writeByte(19)
      ..write(obj.icon)
      ..writeByte(20)
      ..write(obj.currentStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HabitTypeAdapter extends TypeAdapter<HabitType> {
  @override
  final int typeId = 1;

  @override
  HabitType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return HabitType.binary;
      case 1:
        return HabitType.quantitative;
      default:
        return HabitType.binary;
    }
  }

  @override
  void write(BinaryWriter writer, HabitType obj) {
    switch (obj) {
      case HabitType.binary:
        writer.writeByte(0);
        break;
      case HabitType.quantitative:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class RecurrenceTypeAdapter extends TypeAdapter<RecurrenceType> {
  @override
  final int typeId = 4;

  @override
  RecurrenceType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return RecurrenceType.dailyInterval;
      case 1:
        return RecurrenceType.weeklyDays;
      case 2:
        return RecurrenceType.timesPerWeek;
      case 3:
        return RecurrenceType.timesPerDay;
      case 4:
        return RecurrenceType.monthly;
      case 5:
        return RecurrenceType.monthlyDay;
      case 6:
        return RecurrenceType.quarterly;
      case 7:
        return RecurrenceType.yearly;
      case 8:
        return RecurrenceType.hourlyInterval;
      case 9:
        return RecurrenceType.timesPerHour;
      case 10:
        return RecurrenceType.weekends;
      case 11:
        return RecurrenceType.weekdays;
      default:
        return RecurrenceType.dailyInterval;
    }
  }

  @override
  void write(BinaryWriter writer, RecurrenceType obj) {
    switch (obj) {
      case RecurrenceType.dailyInterval:
        writer.writeByte(0);
        break;
      case RecurrenceType.weeklyDays:
        writer.writeByte(1);
        break;
      case RecurrenceType.timesPerWeek:
        writer.writeByte(2);
        break;
      case RecurrenceType.timesPerDay:
        writer.writeByte(3);
        break;
      case RecurrenceType.monthly:
        writer.writeByte(4);
        break;
      case RecurrenceType.monthlyDay:
        writer.writeByte(5);
        break;
      case RecurrenceType.quarterly:
        writer.writeByte(6);
        break;
      case RecurrenceType.yearly:
        writer.writeByte(7);
        break;
      case RecurrenceType.hourlyInterval:
        writer.writeByte(8);
        break;
      case RecurrenceType.timesPerHour:
        writer.writeByte(9);
        break;
      case RecurrenceType.weekends:
        writer.writeByte(10);
        break;
      case RecurrenceType.weekdays:
        writer.writeByte(11);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurrenceTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
