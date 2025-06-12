// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionItemAdapter extends TypeAdapter<DetectionItem> {
  @override
  final int typeId = 2;

  @override
  DetectionItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DetectionItem(
      className: fields[0] as String,
      confidence: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DetectionItem obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.className)
      ..writeByte(1)
      ..write(obj.confidence);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
