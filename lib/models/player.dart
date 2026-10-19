import 'role.dart';

class Player {
  final String id;
  String name;
  RoleId role;

  /// La carte reçue à la distribution (ou prise sur la table par le
  /// Voleur), révélée à sa mort quoi qu'il soit devenu depuis : sert à
  /// compter les rôles encore en jeu (voir GameState.remainingRoleCounts).
  RoleId card;
  bool alive;
  bool isMayor;
  String? loverId; // id de l'autre Amoureux, si Cupidon est passé
  String? mentorOf; // id de l'Enfant Sauvage dont il est le mentor, si Enfant Sauvage est passé
  /// Rôle d'origine si le joueur a muté en cours de partie (Enfant Sauvage
  /// devenu Loup-Garou), pour le rappeler à l'annonce de sa mort.
  RoleId? formerRole;
  /// Infecté par l'Infect Père en gardant son rôle (réglage
  /// infectedKeepsPower) : il est désormais du camp des Loups.
  bool infected = false;
  DeathCause? deathCause;
  int? deathAtNight; // numéro de nuit du décès (null si mort le jour ou vivant)
  int? deathAtDay; // numéro de jour du décès (null si mort la nuit ou vivant)

  Player({
    required this.id,
    required this.name,
    required this.role,
    RoleId? card,
  })  : card = card ?? role,
        alive = true,
        isMayor = false;

  Camp get camp => infected ? Camp.loups : role.info.camp;
  bool get isLover => loverId != null;

  Player copy() => Player(id: id, name: name, role: role, card: card)
    ..alive = alive
    ..isMayor = isMayor
    ..loverId = loverId
    ..formerRole = formerRole
    ..infected = infected
    ..deathCause = deathCause
    ..deathAtNight = deathAtNight
    ..deathAtDay = deathAtDay;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role.name,
        'card': card.name,
        'alive': alive,
        'isMayor': isMayor,
        'loverId': loverId,
        'formerRole': formerRole?.name,
        'infected': infected,
        'deathCause': deathCause?.name,
        'deathAtNight': deathAtNight,
        'deathAtDay': deathAtDay,
      };

  static Player fromJson(Map<String, dynamic> json) {
    final p = Player(
      id: json['id'] as String,
      name: json['name'] as String,
      role: RoleId.values.byName(json['role'] as String),
      card: json['card'] == null
          ? null
          : RoleId.values.byName(json['card'] as String),
    );
    p.alive = json['alive'] as bool;
    p.isMayor = json['isMayor'] as bool;
    p.loverId = json['loverId'] as String?;
    final fr = json['formerRole'] as String?;
    p.formerRole = fr == null ? null : RoleId.values.byName(fr);
    p.infected = json['infected'] as bool? ?? false;
    final dc = json['deathCause'] as String?;
    p.deathCause = dc == null ? null : DeathCause.values.byName(dc);
    p.deathAtNight = json['deathAtNight'] as int?;
    p.deathAtDay = json['deathAtDay'] as int?;
    return p;
  }
}
