// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DetectionAdapter extends TypeAdapter<Detection> {
  @override
  final int typeId = 0;

  @override
  Detection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Detection(
      className: fields[0] as String,
      confidence: fields[1] as double,
      bbox: (fields[2] as List).cast<double>(),
      timestamp: fields[3] as DateTime,
      imagePath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Detection obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.className)
      ..writeByte(1)
      ..write(obj.confidence)
      ..writeByte(2)
      ..write(obj.bbox)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DetectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
