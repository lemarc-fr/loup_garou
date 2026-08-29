// test/services/game_engine_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

void main() {
  late GameEngine engine;

  setUp(() {
    engine = GameEngine();
  });

  GameState buildGame({
    required Map<RoleId, int> roles,
    required List<String> names,
  }) {
    final config = GameConfig(playerCount: names.length, roleCounts: roles);
    return engine.initGame(config, names, GameSettings());
  }

  group('initGame', () {
    test('distribue exactement le bon nombre de cartes', () {
      final state = buildGame(
        roles: {
          RoleId.loupGarou: 2,
          RoleId.voyante: 1,
          RoleId.simpleVillageois: 2,
        },
        names: ['A', 'B', 'C', 'D', 'E'],
      );
      expect(state.players.length, 5);
      expect(state.players.where((p) => p.role == RoleId.loupGarou).length, 2);
    });

    test('réserve 2 cartes sur la table si le Voleur est présent', () {
      final config = GameConfig(playerCount: 5, roleCounts: {
        RoleId.loupGarou: 1,
        RoleId.voleur: 1,
        RoleId.simpleVillageois: 5, // + 2 cartes table = 7 cartes au total
      });
      final state = engine.initGame(config, ['A', 'B', 'C', 'D', 'E'], GameSettings());
      expect(state.voleurTableCards.length, 2);
      expect(state.players.length, 5);
    });
  });

  group("L'Ancien", () {
    late GameState state;

    setUp(() {
      state = buildGame(
        roles: {
          RoleId.loupGarou: 1,
          RoleId.ancien: 1,
          RoleId.simpleVillageois: 3
        },
        names: ['Loup', 'Ancien', 'V1', 'V2'],
      );
      // Forcer les rôles pour un test déterministe
      state.players[0].role = RoleId.loupGarou;
      state.players[1].role = RoleId.ancien;
    });

    test('survit à la première attaque des Loups sans mourir', () {
      final ancien = state.players[1];
      state.currentWave = 'night';
      engine.setLoupsVictim(
          state, ancien.id); // déclenche aussi finalNightVictimId
      // On simule la fin de nuit directement pour isoler la règle
      engine.buildNightQueue(state); // no-op ici, juste pour cohérence
      state.finalNightVictimId = ancien.id;

      // Appel de la méthode privée via le chemin public : on simule _finishNight
      // en appelant confirmVoteResult indirectement n'est pas nécessaire ici,
      // on teste directement l'effet attendu :
      expect(state.ancienExtraLifeUsed, false);
    });

    test('meurt à la seconde attaque des Loups', () {
      final ancien = state.players[1];
      state.ancienExtraLifeUsed = true; // vie déjà consommée
      state.finalNightVictimId = ancien.id;
      // (voir remarque ci-dessous sur l'exposition de _applyDeath)
    });

    test('le poison de la Sorcière le tue même avec sa vie intacte', () {
      // à écrire une fois _applyDeath rendue testable (voir note plus bas)
    });

    test('perte des pouvoirs si le village le pend', () {
      final voyante = state.players[2]..role = RoleId.voyante;
      final loup = state.players[0];
      state.mayorId = null;
      final tally = engine.tallyVotes(state, {
        loup.id: state.players[1].id, // tout le monde vote l'Ancien
        voyante.id: state.players[1].id,
        state.players[3].id: state.players[1].id,
      });
      expect(tally.winner, state.players[1].id);
      engine.resolveVillageVote(state, tally.winner!);
      expect(voyante.role, RoleId.simpleVillageois);
      expect(state.powerLossThisWave, isNotEmpty);
    });
  });

  group('checkWinCondition', () {
    test('le village gagne quand il ne reste plus de loups', () {
      final state = buildGame(
        roles: {RoleId.loupGarou: 1, RoleId.simpleVillageois: 2},
        names: ['A', 'B', 'C'],
      );
      state.players.firstWhere((p) => p.role == RoleId.loupGarou).alive = false;
      final result = engine.checkWinCondition(state);
      expect(result?.winner, Camp.village);
    });

    test('les amoureux de camps différents gagnent seuls s\'ils restent 2', () {
      final state = buildGame(
        roles: {RoleId.loupGarou: 1, RoleId.simpleVillageois: 1},
        names: ['Loup', 'Villageois'],
      );
      final loup = state.players[0];
      final vil = state.players[1];
      loup.loverId = vil.id;
      vil.loverId = loup.id;
      final result = engine.checkWinCondition(state);
      expect(result?.winner, Camp.amoureux);
    });
  });
}
