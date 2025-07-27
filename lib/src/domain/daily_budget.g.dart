// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_budget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailyBudgetAdapter extends TypeAdapter<DailyBudget> {
  @override
  final int typeId = 1;

  @override
  DailyBudget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailyBudget()
      ..date = fields[0] as DateTime
      ..amount = fields[1] as double;
  }

  @override
  void write(BinaryWriter writer, DailyBudget obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.amount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyBudgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
