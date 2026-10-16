import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/services/game_engine.dart';

/// L'assistant de création de partie (nombre, rôles, prénoms, découverte).
void main() {
  late GameProvider gp;
  late int notifications;

  setUp(() {
    gp = GameProvider(engine: GameEngine(random: Random(1)));
    notifications = 0;
    gp.addListener(() => notifications++);
  });

  int sum(Map<RoleId, int> counts) => counts.values.fold(0, (a, b) => a + b);

  group('Nombre de joueurs et rôles', () {
    test('une répartition suggérée et valide pour chaque taille de table', () {
      for (var n = 5; n <= 24; n++) {
        gp.setDraftPlayerCount(n);
        expect(gp.draftConfigValid, isTrue, reason: '$n joueurs');
        expect(gp.draftConfig!.roleCounts[RoleId.loupGarou],
            greaterThanOrEqualTo(1));
      }
    });

    test('revenir au même nombre garde les rôles ajustés', () {
      gp.setDraftPlayerCount(10);
      gp.goToRoleSelection();
      gp.incrementRole(RoleId.salvateur);
      gp.recomputeVillagers();
      gp.setDraftPlayerCount(10);
      expect(gp.draftConfig!.roleCounts[RoleId.salvateur], 1);
      gp.setDraftPlayerCount(11);
      expect(gp.draftConfig!.roleCounts[RoleId.salvateur], 0);
    });

    test('un rôle unique ne dépasse pas un exemplaire ; les villageois '
        'complètent', () {
      gp.setDraftPlayerCount(8);
      gp.goToRoleSelection();
      gp.incrementRole(RoleId.voyante, by: 3);
      gp.incrementRole(RoleId.loupGarou, by: 2);
      gp.recomputeVillagers();
      final counts = gp.draftConfig!.roleCounts;
      expect(counts[RoleId.voyante], 1);
      expect(sum(counts), 8);
      expect(gp.draftConfigValid, isTrue);
    });

    test('trop de rôles : la partie ne peut pas commencer', () {
      gp.setDraftPlayerCount(5);
      gp.goToRoleSelection();
      for (final role in [
        RoleId.sorciere,
        RoleId.chasseur,
        RoleId.salvateur,
        RoleId.corbeau,
        RoleId.renard,
      ]) {
        gp.incrementRole(role);
      }
      gp.recomputeVillagers();
      expect(gp.draftConfigValid, isFalse);
    });

    test('avec le Voleur, il faut deux cartes de plus que de joueurs', () {
      gp.setDraftPlayerCount(8);
      gp.goToRoleSelection();
      gp.incrementRole(RoleId.voleur);
      gp.recomputeVillagers();
      expect(sum(gp.draftConfig!.roleCounts), 10);
      expect(gp.draftConfig!.cardsForPlayers, 8);
      expect(gp.draftConfigValid, isTrue);
    });

    test('mode « Amoureux tirés au sort » : Cupidon est retiré', () {
      gp.setDraftPlayerCount(10); // la suggestion inclut Cupidon
      gp.goToRoleSelection();
      expect(gp.draftConfig!.roleCounts[RoleId.cupidon], 1);
      gp.applyLoversMode(randomLoversInsteadOfCupidon: true);
      expect(gp.draftConfig!.roleCounts[RoleId.cupidon], 0);
      expect(gp.draftConfigValid, isTrue);
      gp.setRandomLovers(true);
      gp.applyLoversMode(randomLoversInsteadOfCupidon: false);
      expect(gp.draftConfig!.randomLovers, isFalse);
    });
  });

  group('Prénoms et retour arrière', () {
    test('prénoms obligatoires et distincts (sans tenir compte de la casse)',
        () {
      gp.setDraftPlayerCount(5);
      gp.goToRoleSelection();
      gp.goToNames();
      expect(gp.namesValid, isFalse);
      for (final (i, name) in ['Ana', 'Bob', 'Cy', 'Dan', 'ana '].indexed) {
        gp.setPlayerName(i, name);
      }
      expect(gp.namesValid, isFalse, reason: 'Ana en double');
      gp.setPlayerName(4, 'Eve');
      expect(gp.namesValid, isTrue);
    });

    test('retour arrière : prénoms → rôles → nombre, en gardant la saisie',
        () {
      gp.setDraftPlayerCount(5);
      gp.goToRoleSelection();
      gp.goToNames();
      gp.setPlayerName(0, 'Ana');
      expect(gp.canGoBackInSetup, isTrue);

      expect(gp.backInSetup(), isTrue);
      expect(gp.setupStep, SetupStep.roles);
      expect(gp.backInSetup(), isTrue);
      expect(gp.setupStep, SetupStep.playerCount);
      expect(gp.backInSetup(), isFalse, reason: 'On quitte vers l\'accueil');

      gp.goToRoleSelection();
      gp.goToNames();
      expect(gp.draftNames.first, 'Ana');
    });
  });

  group('Distribution et découverte des rôles', () {
    test('chacun découvre son rôle, puis la première nuit commence', () {
      gp.setDraftPlayerCount(5);
      gp.goToRoleSelection();
      gp.goToNames();
      for (final (i, name) in [' Ana ', 'Bob', 'Cy', 'Dan', 'Eve'].indexed) {
        gp.setPlayerName(i, name);
      }
      gp.confirmNamesAndDeal(GameSettings());
      expect(gp.setupStep, SetupStep.reveal);
      expect(gp.state!.players.first.name, 'Ana', reason: 'Espaces retirés');

      for (var i = 0; i < 5; i++) {
        expect(gp.revealIndex, i);
        gp.showRevealCard();
        expect(gp.revealCardVisible, isTrue);
        gp.confirmRevealSeen();
        expect(gp.revealCardVisible, isFalse);
      }
      expect(gp.setupStep, SetupStep.done);
      expect(gp.state!.phase, GamePhase.nightIntro);
      expect(gp.canGoBackInSetup, isFalse);
    });

    test('nouvelle partie : tout est remis à zéro sauf le nombre de joueurs',
        () {
      gp.setDraftPlayerCount(6);
      gp.goToRoleSelection();
      gp.goToNames();
      gp.confirmNamesAndDeal(GameSettings());
      notifications = 0;
      gp.startNewSetup();
      expect(gp.state, isNull);
      expect(gp.setupStep, SetupStep.playerCount);
      expect(gp.draftConfig, isNull);
      expect(gp.draftNames, isEmpty);
      expect(gp.draftPlayerCount, 6);
      expect(notifications, 1);
    });
  });
}
