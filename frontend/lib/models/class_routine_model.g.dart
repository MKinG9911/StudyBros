// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_routine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassRoutineAdapter extends TypeAdapter<ClassRoutine> {
  @override
  final int typeId = 5;

  @override
  ClassRoutine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassRoutine(
      id: fields[0] as String?,
      userId: fields[1] as String,
      imagePath: fields[2] as String,
      uploadedAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, ClassRoutine obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.uploadedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassRoutineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
