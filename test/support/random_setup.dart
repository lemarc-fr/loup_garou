import 'dart:math';

import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/role.dart';

/// Composition et réglages tirés au hasard (reproductibles avec la graine),
/// mais toujours de ceux que l'écran de répartition accepterait.
class RandomSetup {
  final GameConfig config;
  final GameSettings settings;
  final List<String> names;

  RandomSetup._(this.config, this.settings, this.names);

  /// Rôles à pouvoir proposés par l'écran de répartition (un exemplaire
  /// chacun).
  static const specials = [
    RoleId.loupBlanc,
    RoleId.infectPereDesLoups,
    RoleId.grandMechantLoup,
    RoleId.voyante,
    RoleId.sorciere,
    RoleId.chasseur,
    RoleId.salvateur,
    RoleId.corbeau,
    RoleId.renard,
    RoleId.jugeBegue,
    RoleId.servanteDevouee,
    RoleId.boucEmissaire,
    RoleId.ancien,
    RoleId.idiotDuVillage,
    RoleId.montreurDours,
    RoleId.cupidon,
    RoleId.petiteFille,
    RoleId.enfantSauvage,
    RoleId.voleur,
  ];

  factory RandomSetup(Random rng, {int minPlayers = 5, int maxPlayers = 24}) {
    final n = minPlayers + rng.nextInt(maxPlayers - minPlayers + 1);
    final settings = GameSettings();
    for (final id in SettingId.values) {
      settings.set(id, rng.nextBool());
    }

    final counts = <RoleId, int>{for (final r in RoleId.values) r: 0};
    final wolves = max(1, n ~/ 4 + rng.nextInt(3) - 1);
    counts[RoleId.loupGarou] = wolves;

    final pool = [...specials]..shuffle(rng);
    if (settings.randomLoversInsteadOfCupidon) pool.remove(RoleId.cupidon);
    final extra = rng.nextInt(min(pool.length, n - wolves) + 1);
    for (final role in pool.take(extra)) {
      counts[role] = 1;
    }
    final hasVoleur = counts[RoleId.voleur] == 1;
    final used = counts.values.fold(0, (a, b) => a + b);
    // Les deux cartes du Voleur en plus.
    counts[RoleId.simpleVillageois] = n + (hasVoleur ? 2 : 0) - used;

    final config = GameConfig(
      playerCount: n,
      roleCounts: counts,
      randomLovers: settings.randomLoversInsteadOfCupidon && rng.nextBool(),
    );
    assert(config.isValid, '$counts');
    return RandomSetup._(
        config, settings, [for (var i = 1; i <= n; i++) 'Joueur $i']);
  }
}
