import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/player.dart';
import 'package:thiercelieux/models/player_stats.dart';
import 'package:thiercelieux/models/role.dart';

void main() {
  group('GameConfig', () {
    test('suggestion : un loup pour quatre joueurs, total juste', () {
      for (var n = 5; n <= 24; n++) {
        final config = GameConfig(playerCount: n);
        expect(config.isValid, isTrue, reason: '$n joueurs');
        expect(config.roleCounts[RoleId.loupGarou], (n / 4).floor().clamp(1, 8));
      }
    });

    test('le Voleur ajoute deux cartes à distribuer sur la table', () {
      final config = GameConfig(playerCount: 6, roleCounts: {
        RoleId.loupGarou: 1,
        RoleId.voleur: 1,
        RoleId.simpleVillageois: 6,
      });
      expect(config.hasVoleur, isTrue);
      expect(config.expectedTotalCards, 8);
      expect(config.cardsForPlayers, 6);
      expect(config.isValid, isTrue);
    });
  });

  group('GameSettings', () {
    test('valeurs par défaut du catalogue', () {
      final settings = GameSettings();
      for (final d in kGameSettingDefinitions) {
        expect(settings.get(d.id), d.defaultValue, reason: d.id.name);
      }
    });

    test('aller-retour JSON ; une option inconnue reprend son défaut', () {
      final settings = GameSettings()
        ..set(SettingId.allowWitchToSaveHerself, false);
      final json = settings.toJson()
        ..remove(SettingId.randomLoversInsteadOfCupidon.name)
        ..['optionSupprimée'] = true;
      final restored = GameSettings.fromJson(json);
      expect(restored.allowWitchToSaveHerself, isFalse);
      expect(restored.randomLoversInsteadOfCupidon, isFalse);
      expect(restored.allowWerewolfToKillThemselves, isTrue);
    });
  });

  test('Player : aller-retour JSON', () {
    final player = Player(id: 'p1', name: 'Ana', role: RoleId.loupGarou)
      ..alive = false
      ..isMayor = true
      ..loverId = 'p2'
      ..formerRole = RoleId.enfantSauvage
      ..deathCause = DeathCause.vote
      ..deathAtDay = 3;
    final copy = Player.fromJson(player.toJson());
    expect(copy.toJson(), player.toJson());
    expect(player.copy().toJson(), player.toJson());
  });

  test('PlayerStats : bilan et aller-retour JSON', () {
    GameHistoryEntry entry(RoleId role, bool won) => GameHistoryEntry(
        date: DateTime(2026, 10, 1),
        role: role,
        won: won,
        playerCountInGame: 12);
    final stats = PlayerStats(name: 'Ana', history: [
      entry(RoleId.voyante, true),
      entry(RoleId.voyante, false),
      entry(RoleId.loupGarou, true),
    ]);
    expect(stats.gamesPlayed, 3);
    expect(stats.wins, 2);
    expect(stats.losses, 1);
    expect(stats.winRate, closeTo(2 / 3, 1e-9));
    expect(stats.favoriteRole, RoleId.voyante);

    final copy = PlayerStats.fromJson(stats.toJson());
    expect(copy.toJson(), stats.toJson());
    expect(PlayerStats(name: 'Nouveau').winRate, 0);
  });
}
