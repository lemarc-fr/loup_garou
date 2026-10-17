import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:thiercelieux/l10n/upcoming_step_localizations.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/player.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/widgets/player_grid_selector.dart';

import 'app_harness.dart';
import 'engine_runner.dart';
import 'game_decisions.dart';

/// Joue une partie entière dans l'application, en tapant sur les écrans
/// comme le feraient les joueurs, d'après [decisions]. Les libellés sont lus
/// dans AppLocalizations : le pilote marche en français comme en anglais.
///
/// Vérifie au passage ce que chaque écran doit montrer (rôle vu par la
/// Voyante, morts annoncées, message des Amoureux...).
class UiGameDriver {
  final WidgetTester tester;
  final GameProvider gp;
  final GameDecisions decisions;

  /// Appelé avant chaque étape jouée, pour des vérifications propres au test.
  final void Function(GameState s)? beforeStep;

  /// Écrans de jeu traversés, dans l'ordre.
  final List<GamePhase> visited = [];

  UiGameDriver(this.tester, this.gp, this.decisions, {this.beforeStep});

  GameState get s => gp.state!;
  GameDecisions get d => decisions;

  /// Où l'on en est, pour les messages d'échec.
  String get _where => gp.state == null
      ? 'création, étape ${gp.setupStep.name}'
      : 'phase ${s.phase}, nuit ${s.night}, jour ${s.day}';

  AppLocalizations get loc =>
      AppLocalizations.of(tester.element(find.byType(Scaffold).first))!;

  // -------------------------------------------------------------------------
  // Gestes de base
  // -------------------------------------------------------------------------

  Future<void> tap(Finder finder, {String? what}) async {
    expect(finder, findsWidgets,
        reason: 'Introuvable : ${what ?? finder} ($_where)');
    await tester.ensureVisible(finder.first);
    await tester.pump();
    await tester.tap(finder.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapText(String text) => tap(find.text(text), what: '« $text »');

  /// Tape un bouton en vérifiant qu'il est actif : un tap sur un bouton
  /// désactivé ne fait rien et bloquerait la partie sans explication.
  Future<void> tapButton(String label) async {
    final button = find.ancestor(
        of: find.text(label), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));
    expect(button, findsWidgets, reason: 'Bouton « $label » introuvable');
    expect(tester.widget<ButtonStyleButton>(button.first).enabled, isTrue,
        reason: 'Bouton « $label » désactivé ($_where)');
    await tap(button, what: 'bouton « $label »');
  }

  Future<void> tapPlayer(String id) => tap(
      find.descendant(
          of: find.byType(PlayerGridSelector),
          matching: find.text(s.byId(id).name)),
      what: 'joueur ${s.byId(id).name}');

  /// Écran « passe le téléphone à... » : vérifie le destinataire et
  /// confirme.
  Future<void> passTo(String name) async {
    expect(find.text(name), findsWidgets,
        reason: 'Le téléphone devrait passer à $name');
    await tapButton(loc.passDeviceConfirmButton);
  }

  void expectShown(String text) =>
      expect(find.text(text), findsWidgets, reason: '« $text » attendu');

  // -------------------------------------------------------------------------
  // Création de la partie
  // -------------------------------------------------------------------------

  /// Depuis l'accueil : nombre de joueurs, répartition des rôles, prénoms,
  /// puis découverte des rôles par chacun. [rig] peut imposer les cartes
  /// juste après la distribution (même composition que [roleCounts]).
  Future<void> createGame({
    required List<String> names,
    required Map<RoleId, int> roleCounts,
    bool randomLovers = false,
    void Function(GameState s)? rig,
  }) async {
    await tapOnHome(tester, loc.newGameButton);
    await tester.pumpAndSettle();

    // Nombre de joueurs (8 par défaut).
    final delta = names.length - gp.draftPlayerCount;
    for (var i = 0; i < delta.abs(); i++) {
      await tap(find.byIcon(delta > 0 ? Icons.add : Icons.remove));
    }
    expectShown('${names.length}');
    await tapButton(loc.continueButtonLabel);

    // Répartition : chaque rôle à pouvoir est réglé avec ses boutons -/+,
    // les Simples Villageois complètent tout seuls.
    final roleList = find.descendant(
        of: find.byType(ListView), matching: find.byType(Scrollable));
    for (final role in RoleId.values) {
      if (role == RoleId.simpleVillageois) continue;
      final target = roleCounts[role] ?? 0;
      var current = gp.draftConfig!.roleCounts[role] ?? 0;
      if (current == target) continue;
      final title = find.text(loc.roleName(role));
      // Retour en haut de la liste, puis on descend jusqu'au rôle.
      await tester.drag(roleList, const Offset(0, 20000));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(title, 120, scrollable: roleList);
      final card = find.ancestor(of: title, matching: find.byType(Card));
      while (current != target) {
        await tap(find.descendant(
            of: card,
            matching: find.byIcon(current < target ? Icons.add : Icons.remove)));
        current = gp.draftConfig!.roleCounts[role] ?? 0;
      }
    }
    expect(gp.draftConfig!.roleCounts[RoleId.simpleVillageois] ?? 0,
        roleCounts[RoleId.simpleVillageois] ?? 0);
    if (randomLovers) {
      // Case proposée en tête de liste quand le réglage « Amoureux tirés au
      // sort » est actif.
      await tester.drag(roleList, const Offset(0, 20000));
      await tester.pumpAndSettle();
      await tapText(loc.roleSelectionRandomLovers);
      expect(gp.draftConfig!.randomLovers, isTrue);
    }
    await tapButton(loc.continueButtonLabel);

    // Prénoms. (Chaque TextField a aussi son Scrollable : on prend celui de
    // la liste, le premier.)
    final list = find
        .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
        .first;
    for (var i = 0; i < names.length; i++) {
      final label = find.text(loc.playerNamesPlayerLabel(i + 1));
      await tester.scrollUntilVisible(label, 120, scrollable: list);
      await tester.enterText(
          find.ancestor(of: label, matching: find.byType(TextField)), names[i]);
    }
    await tester.pumpAndSettle();
    await tapButton(loc.dealRolesButton);
    expect(s.players.map((p) => p.name), names);
    rig?.call(s);

    // Chacun découvre son rôle (et son Amoureux en mode tiré au sort).
    for (final player in [...s.players]) {
      await passTo(player.name);
      await tapButton(loc.roleRevealRevealButton);
      expectShown(loc.roleName(player.role));
      final lover = s.tryById(player.loverId);
      if (lover != null) expectShown(loc.loverBondMessage(lover.name));
      await tapButton(loc.roleRevealHideButton);
    }
    expect(s.phase, GamePhase.nightIntro);
  }

  // -------------------------------------------------------------------------
  // Partie
  // -------------------------------------------------------------------------

  Future<void> playToEnd({int maxSteps = 2000}) async {
    var steps = 0;
    while (s.phase != GamePhase.endGame) {
      expect(++steps, lessThan(maxSteps), reason: 'Partie sans fin');
      await step();
    }
  }

  /// Joue l'écran courant jusqu'à ce que la partie avance.
  Future<void> step() async {
    beforeStep?.call(s);
    final phase = s.phase;
    final before = (phase, s.night, s.day, s.phaseIndex, s.deathsThisWave.length);
    visited.add(phase);
    expectPhasePreconditions(s);

    switch (phase) {
      case GamePhase.nightIntro:
        await tapButton(loc.nightIntroEveryoneAsleepButton);
      case GamePhase.nightGoBackToSleep:
        await tapButton(loc.continueButtonLabel);
      case GamePhase.nightVoleur:
        await passTo(loc.roleName(RoleId.voleur));
        final card = d.voleur(s);
        if (card == null) {
          await tapButton(loc.voleurKeepCurrentRoleButton);
        } else {
          await tapText(loc.roleName(card));
          await tapButton(loc.voleurExchangeRoleButton);
        }
      case GamePhase.nightCupidon:
        await passTo(loc.roleName(RoleId.cupidon));
        final (a, b) = d.cupidon(s);
        await tapPlayer(a);
        await tapPlayer(b);
        await tapButton(loc.cupidonConfirmButton);
      case GamePhase.nightLoversReveal:
        // Le téléphone passe chez tout le monde ; seuls les Amoureux ont un
        // message.
        for (final player in [...s.alivePlayers]) {
          await passTo(player.name);
          final lover = s.tryById(player.loverId);
          if (lover != null) {
            expectShown(loc.loverBondMessage(lover.name));
          } else {
            expectShown(loc.loversRevealNothingHeadline);
          }
          await tapButton(loc.loversRevealDoneButton);
        }
      case GamePhase.nightEnfantSauvage:
        await passTo(loc.enfantSauvagePassTo);
        await tapPlayer(d.enfantSauvageModel(s));
      case GamePhase.nightEnfantSauvageCheck:
        await passTo(loc.enfantSauvagePassTo);
        await tapButton(loc.goBackToSleepButton);
      case GamePhase.nightEnfantSauvageMutation:
        await passTo(s.byId(s.enfantSauvageNightMutationId!).name);
        await tapButton(loc.goBackToSleepButton);
      case GamePhase.nightInfectedReveal:
        await passTo(s.byId(s.infectedRevealPendingId!).name);
        expectShown(loc.infectedRevealInstruction);
        await tapButton(loc.goBackToSleepButton);
      case GamePhase.nightSalvateur:
        await passTo(loc.roleName(RoleId.salvateur));
        await tapPlayer(d.salvateur(s));
      case GamePhase.nightVoyante:
        await passTo(loc.roleName(RoleId.voyante));
        final target = s.byId(d.voyante(s));
        await tapPlayer(target.id);
        expectShown(loc.roleName(target.role));
        await tapButton(loc.voyanteDoneButton);
      case GamePhase.nightLoups:
        await passTo(loc.roleLoupGarouPlural);
        if (LegalChoices.loupsTargets(s).isEmpty) {
          await tapButton(loc.loupsNoPossibleVictimButton);
        } else {
          await tapPlayer(d.loups(s));
        }
      case GamePhase.nightLoupBlanc:
        await passTo(loc.roleName(RoleId.loupBlanc));
        await _playerOrSkip(d.loupBlanc(s));
      case GamePhase.nightGrandMechantLoup:
        await passTo(loc.roleName(RoleId.grandMechantLoup));
        await _playerOrSkip(d.grandMechantLoup(s));
      case GamePhase.nightInfectPereDesLoups:
        await passTo(loc.roleName(RoleId.infectPereDesLoups));
        await tapButton(s.loupsVictimId != null && d.infect(s)
            ? loc.infectPereDesLoupsInfectButton
            : loc.infectPereDesLoupsDoNotInfectButton);
      case GamePhase.nightRenard:
        await passTo(loc.roleName(RoleId.renard));
        final center = d.renardCenter(s);
        await tapPlayer(center);
        expectShown(s.renardTrioHasWolf(s.renardTrioAround(center))
            ? loc.renardResultWolfFound
            : loc.renardResultNoWolf);
        await tapButton(loc.goBackToSleepButton);
      case GamePhase.nightCorbeau:
        await passTo(loc.roleName(RoleId.corbeau));
        await _playerOrSkip(d.corbeau(s));
      case GamePhase.nightSorciere:
        await passTo(loc.roleName(RoleId.sorciere));
        final choice = d.sorciere(s);
        if (choice.save) {
          await tapText(loc.sorciereUseLifePotion(
              LegalChoices.sorciereVictim(s)!.name));
        }
        if (choice.poison != null) {
          await tapText(loc.sorciereUseDeathPotion);
          await tapPlayer(choice.poison!);
        }
        await tapButton(loc.confirmAndGoBackToSleepButton);
      case GamePhase.nightPetiteFille:
        fail('La Petite Fille ne devrait jamais être appelée');

      case GamePhase.dayReveal:
        for (final id in s.deathsThisWave) {
          expectShown(s.byId(id).name);
        }
        await tapButton(loc.upcomingStepButton(
            gp.upcomingStep(origin: FollowUpOrigin.nightDeaths)));
      case GamePhase.mayorElectionExplain:
        await _chooseVoteMode(d.voteMode(s, mayorElection: true));
      case GamePhase.mayorElection:
        await _vote(mayorElection: true);
      case GamePhase.mayorReveal:
        expectShown(s.byId(s.mayorId!).name);
        await tapButton(loc.mayorRevealContinueButton);
      case GamePhase.debate:
        await _chooseVoteMode(d.voteMode(s, mayorElection: false));
      case GamePhase.jugeBegueDecision:
        await passTo(loc.roleName(RoleId.jugeBegue));
        await tapButton(
            d.jugeBegue(s) ? loc.usePowerButton : loc.doNotUsePowerButton);
      case GamePhase.villageVote:
        await _vote(mayorElection: false);
      case GamePhase.voteResult:
        for (final id in s.deathsThisWave) {
          expectShown(s.byId(id).name);
        }
        await tapButton(loc.upcomingStepButton(
            gp.upcomingStep(origin: FollowUpOrigin.voteDeaths)));

      case GamePhase.chasseurRevange:
        await tapPlayer(d.chasseur(s));
      case GamePhase.successionMaire:
        await tapPlayer(d.mayorSuccessor(s));
      case GamePhase.enfantsauvageReveal:
        await tapButton(loc.upcomingStepButton(gp.upcomingStep()));
      case GamePhase.villagePowerLoss:
        final lost = {for (final e in s.powerLossThisWave) e.playerId: e.previousRole};
        for (final player in [...s.alivePlayers]) {
          await passTo(player.name);
          final role = lost[player.id];
          expectShown(role != null
              ? loc.powerLossReallyLostNotice
              : loc.powerLossFakeGiftNotice);
          await tapButton(loc.powerLossUnderstoodButton);
        }
        await tapButton(loc.upcomingStepButton(gp.upcomingStep()));
      case GamePhase.servanteDevouee:
        await passTo(loc.roleName(RoleId.servanteDevouee));
        await tapButton(d.servanteTakesRole(s)
            ? loc.servanteDevoueeTakeRoleButton
            : loc.servanteDevoueeKeepRoleButton);
      case GamePhase.boucEmissaire:
        // Tout le monde est coché au départ : il retire les exclus.
        final allowed = d.boucEmissaire(s);
        for (final p in [...s.alivePlayers]) {
          if (!allowed.contains(p.id)) await tapPlayer(p.id);
        }
        await tapButton(loc.boucEmissaireConfirmVoters(allowed.length));
      case GamePhase.idiotduvillageCivicRightLoss:
        expectShown(loc.idiotDuVillageRevealInstruction(
            s.byId(s.idiotDuVillageRevealId!).name));
        await tapButton(loc.continueButtonLabel);

      case GamePhase.setupPlayerCount:
      case GamePhase.setupRoles:
      case GamePhase.setupNames:
      case GamePhase.roleReveal:
      case GamePhase.endGame:
        fail('Rien à jouer en phase $phase');
    }

    final after = (s.phase, s.night, s.day, s.phaseIndex, s.deathsThisWave.length);
    expect(after, isNot(before), reason: 'Bloqué sur $phase');
  }

  Future<void> _playerOrSkip(String? id) => id == null
      ? tapButton(loc.skipPowerThisNightButton)
      : tapPlayer(id);

  Future<void> _chooseVoteMode(VoteMode mode) => tapText(
      mode == VoteMode.collective
          ? loc.voteModeCollectiveButton
          : loc.voteModeSecretButton);

  /// Même déroulé que EngineRunner._vote, mais en passant le téléphone.
  Future<void> _vote({required bool mayorElection}) async {
    final tieRule =
        mayorElection ? VoteTieRule.runoff : gp.villageVoteTieRule;
    if (s.voteMode == VoteMode.collective) {
      if (tieRule != VoteTieRule.runoff && d.collectiveTie(s)) {
        await tapText(loc.voteTieButton);
        if (tieRule == VoteTieRule.mayorDecides) {
          final choice = s.byId(d.mayorTieBreak(s, s.alivePlayers));
          await tapPlayer(choice.id);
          await tapButton(
              loc.collectiveVoteConfirmEliminationButton(choice.name));
        }
        return;
      }
      final target = s.byId(d.collectiveVote(s, mayorElection: mayorElection));
      await tapPlayer(target.id);
      await tapButton(mayorElection
          ? loc.collectiveVoteConfirmMayorButton(target.name)
          : loc.collectiveVoteConfirmEliminationButton(target.name));
      return;
    }
    final phase = s.phase;
    final voters = mayorElection ? s.alivePlayers : s.eligibleVoters;
    var candidates = s.alivePlayers;
    for (var round = 0; round < 30; round++) {
      final votes = <String, String>{};
      for (final Player voter in voters) {
        await passTo(voter.name);
        if (round > 0) expectShown(loc.voteRunoffTieNotice);
        final target = d.secretVote(s, voter, candidates,
            mayorElection: mayorElection);
        votes[voter.id] = target;
        await tapPlayer(target);
      }
      // Élu, ou égalité réglée par le Bouc ou « personne n'est éliminé ».
      if (s.phase != phase) return;
      final tally = gp.tallyVotes(votes,
          candidates: candidates.map((c) => c.id));
      expect(tally.isTie, isTrue, reason: 'Vote resté sans résultat');
      candidates = tally.tiedCandidates.map(s.byId).toList();
      if (tieRule == VoteTieRule.mayorDecides) {
        // Écran public : le maire désigne l'éliminé parmi les ex aequo.
        expectShown(loc.voteTieMayorInstruction(s.byId(s.mayorId!).name));
        await tapPlayer(d.mayorTieBreak(s, candidates));
        return;
      }
    }
    fail('Égalités sans fin au vote');
  }
}
