import 'role.dart';

class Player {
  final String id;
  String name;
  RoleId role;
  bool alive;
  bool isMayor;
  String? loverId; // id de l'autre Amoureux, si Cupidon est passé
  String? mentorOf; // id de l'Enfant Sauvage dont il est le mentor, si Enfant Sauvage est passé
  DeathCause? deathCause;
  int? deathAtNight; // numéro de nuit du décès (null si mort le jour ou vivant)
  int? deathAtDay; // numéro de jour du décès (null si mort la nuit ou vivant)

  Player({
    required this.id,
    required this.name,
    required this.role,
  })  : alive = true,
        isMayor = false;

  Camp get camp => role.info.camp;
  bool get isLover => loverId != null;

  Player copy() => Player(id: id, name: name, role: role)
    ..alive = alive
    ..isMayor = isMayor
    ..loverId = loverId
    ..deathCause = deathCause
    ..deathAtNight = deathAtNight
    ..deathAtDay = deathAtDay;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'alive': alive,
        'isMayor': isMayor,
        'loverId': loverId,
        'deathCause': deathCause?.name,
        'deathAtNight': deathAtNight,
        'deathAtDay': deathAtDay,
      };

  static Player fromJson(Map<String, dynamic> json) {
    final p = Player(
      id: json['id'] as String,
      name: json['name'] as String,
      role: RoleId.values.byName(json['role'] as String),
    );
    p.alive = json['alive'] as bool;
    p.isMayor = json['isMayor'] as bool;
    p.loverId = json['loverId'] as String?;
    final dc = json['deathCause'] as String?;
    p.deathCause = dc == null ? null : DeathCause.values.byName(dc);
    p.deathAtNight = json['deathAtNight'] as int?;
    p.deathAtDay = json['deathAtDay'] as int?;
    return p;
  }
}
