import 'package:hive/hive.dart';

part 'player.g.dart';

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<int> goalMinutes;

  @HiveField(2)
  bool hasYellowCard;

  @HiveField(3)
  bool hasRedCard;

  @HiveField(4)
  int? substitutedMinute;

  Player(
    this.name, {
    List<int>? goalMinutes,
    this.hasYellowCard = false,
    this.hasRedCard = false,
    this.substitutedMinute,
  }) : goalMinutes = goalMinutes ?? [];

  int get goals => goalMinutes.length;

  // Métodos toJson y fromJson los puedes mantener para interoperabilidad
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'goalMinutes': goalMinutes,
      'hasYellowCard': hasYellowCard,
      'hasRedCard': hasRedCard,
      'substitutedMinute': substitutedMinute,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      json['name'] as String,
      goalMinutes: List<int>.from(json['goalMinutes'] ?? []),
      hasYellowCard: json['hasYellowCard'] ?? false,
      hasRedCard: json['hasRedCard'] ?? false,
      substitutedMinute: json['substitutedMinute'],
    );
  }
}
