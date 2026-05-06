// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealRecordAdapter extends TypeAdapter<MealRecord> {
  @override
  final int typeId = 1;

  @override
  MealRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealRecord(
      foodName: fields[0] as String,
      calories: fields[1] as double,
      carbs: fields[2] as double,
      protein: fields[3] as double,
      fat: fields[4] as double,
      imagePath: fields[5] as String,
      recordedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MealRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.foodName)
      ..writeByte(1)
      ..write(obj.calories)
      ..writeByte(2)
      ..write(obj.carbs)
      ..writeByte(3)
      ..write(obj.protein)
      ..writeByte(4)
      ..write(obj.fat)
      ..writeByte(5)
      ..write(obj.imagePath)
      ..writeByte(6)
      ..write(obj.recordedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
