// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final int typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Player(
      fields[0] as String,
      goalMinutes: (fields[1] as List?)?.cast<int>(),
      hasYellowCard: fields[2] as bool,
      hasRedCard: fields[3] as bool,
      substitutedMinute: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Player obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.goalMinutes)
      ..writeByte(2)
      ..write(obj.hasYellowCard)
      ..writeByte(3)
      ..write(obj.hasRedCard)
      ..writeByte(4)
      ..write(obj.substitutedMinute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
