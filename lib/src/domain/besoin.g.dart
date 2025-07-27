// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'besoin.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BesoinAdapter extends TypeAdapter<Besoin> {
  @override
  final int typeId = 0;

  @override
  Besoin read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Besoin()
      ..titre = fields[0] as String
      ..description = fields[1] as String?
      ..prix = fields[2] as double
      ..date = fields[3] as DateTime
      ..category = fields[4] as Category?;
  }

  @override
  void write(BinaryWriter writer, Besoin obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.titre)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.prix)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BesoinAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
