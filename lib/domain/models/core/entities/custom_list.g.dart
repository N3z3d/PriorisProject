// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'custom_list.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomListAdapter extends TypeAdapter<CustomList> {
  @override
  final int typeId = 0;

  @override
  CustomList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomList(
      id: fields[0] as String,
      name: fields[1] as String,
      type: fields[2] as ListType,
      description: fields[3] as String?,
      items: (fields[4] as List).cast<ListItem>(),
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomList obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
