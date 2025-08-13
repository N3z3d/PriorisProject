// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ListTypeAdapter extends TypeAdapter<ListType> {
  @override
  final int typeId = 2;

  @override
  ListType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ListType.TRAVEL;
      case 1:
        return ListType.SHOPPING;
      case 2:
        return ListType.MOVIES;
      case 3:
        return ListType.BOOKS;
      case 4:
        return ListType.RESTAURANTS;
      case 5:
        return ListType.PROJECTS;
      case 6:
        return ListType.CUSTOM;
      default:
        return ListType.TRAVEL;
    }
  }

  @override
  void write(BinaryWriter writer, ListType obj) {
    switch (obj) {
      case ListType.TRAVEL:
        writer.writeByte(0);
        break;
      case ListType.SHOPPING:
        writer.writeByte(1);
        break;
      case ListType.MOVIES:
        writer.writeByte(2);
        break;
      case ListType.BOOKS:
        writer.writeByte(3);
        break;
      case ListType.RESTAURANTS:
        writer.writeByte(4);
        break;
      case ListType.PROJECTS:
        writer.writeByte(5);
        break;
      case ListType.CUSTOM:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
