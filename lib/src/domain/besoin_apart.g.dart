// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'besoin_apart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BesoinApartAdapter extends TypeAdapter<BesoinApart> {
  @override
  final int typeId = 3;

  @override
  BesoinApart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BesoinApart()
      ..titre = fields[0] as String
      ..description = fields[1] as String?
      ..prix = fields[2] as double
      ..dateCreated = fields[3] as DateTime
      ..category = fields[4] as Category?
      ..groupTitle = fields[5] as String
      ..isCompleted = fields[6] as bool
      ..hasBudget = fields[7] as bool
      ..budgetAmount = fields[8] as double?;
  }

  @override
  void write(BinaryWriter writer, BesoinApart obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.titre)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.prix)
      ..writeByte(3)
      ..write(obj.dateCreated)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.groupTitle)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.hasBudget)
      ..writeByte(8)
      ..write(obj.budgetAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BesoinApartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
