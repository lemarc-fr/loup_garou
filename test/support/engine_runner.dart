import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_progress.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/player.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

import 'game_decisions.dart';

/// Phases jouées la nuit (toutes les autres le sont le jour).
const nightPhases = {
  GamePhase.nightIntro,
  GamePhase.nightGoBackToSleep,
  GamePhase.nightVoleur,
  GamePhase.nightCupidon,
  GamePhase.nightLoversReveal,
  GamePhase.nightEnfantSauvage,
  GamePhase.nightEnfantSauvageMutation,
  GamePhase.nightInfectedReveal,
  GamePhase.nightSalvateur,
  GamePhase.nightVoyante,
  GamePhase.nightLoups,
  GamePhase.nightPetiteFille,
  GamePhase.nightLoupBlanc,
  GamePhase.nightGrandMechantLoup,
  GamePhase.nightEnfantSauvageCheck,
  GamePhase.nightInfectPereDesLoups,
  GamePhase.nightRenard,
  GamePhase.nightCorbeau,
  GamePhase.nightSorciere,
};

/// Suites d'une mort (voir GameEngine._resolveFollowUps).
const followUpPhases = {
  GamePhase.chasseurRevange,
  GamePhase.successionMaire,
  GamePhase.enfantsauvageReveal,
  GamePhase.villagePowerLoss,
  GamePhase.servanteDevouee,
  GamePhase.boucEmissaire,
  GamePhase.idiotduvillageCivicRightLoss,
};

/// Joue une partie via le moteur, en reproduisant exactement ce que ferait
/// chaque écran, et vérifie les invariants du jeu après chaque action.
class EngineRunner {
  final GameEngine engine;
  final GameState s;
  final GameDecisions decisions;

  /// Appelé avant chaque action, pour des vérifications propres au test.
  final void Function(GameState s)? beforeStep;

  /// Journal des actions, affiché quand un invariant casse.
  final List<String> log = [];
  int steps = 0;

  EngineRunner(this.engine, this.s, this.decisions, {this.beforeStep});

  GameDecisions get d => decisions;

  String _name(String? id) => s.tryById(id)?.name ?? '-';

  void playToEnd({int maxSteps = 4000}) {
    while (s.phase != GamePhase.endGame) {
      if (steps >= maxSteps) {
        fail('Partie sans fin après $steps actions '
            '(nuit ${s.night}, phase ${s.phase})\n${log.join('\n')}');
      }
      step();
    }
  }

  void step() {
    steps++;
    beforeStep?.call(s);
    final deadBefore = {for (final p in s.players) if (!p.alive) p.id};
    final phase = s.phase;
    expectPhasePreconditions(s, log);
    log.add('N${s.night}/J${s.day} $phase');

    switch (phase) {
      case GamePhase.nightIntro:
      case GamePhase.nightGoBackToSleep:
        engine.advance(s);
      case GamePhase.nightVoleur:
        final card = d.voleur(s);
        log.add('  voleur prend $card');
        engine.resolveVoleur(s, card);
      case GamePhase.nightCupidon:
        final (a, b) = d.cupidon(s);
        log.add('  amoureux ${_name(a)} + ${_name(b)}');
        engine.resolveCupidon(s, a, b);
      case GamePhase.nightLoversReveal:
        engine.confirmLoversReveal(s);
      case GamePhase.nightEnfantSauvage:
        engine.resolveEnfantSauvageMentor(s, d.enfantSauvageModel(s));
      case GamePhase.nightEnfantSauvageMutation:
        engine.confirmEnfantSauvageNightMutation(s);
      case GamePhase.nightInfectedReveal:
        engine.confirmInfectedReveal(s);
      case GamePhase.nightEnfantSauvageCheck:
        engine.confirmEnfantSauvageCheck(s);
      case GamePhase.nightSalvateur:
        final id = d.salvateur(s);
        _ensure(s.salvateurCanProtect(id),
            () => 'Salvateur : même protégé que la veille', s, log);
        engine.resolveSalvateur(s, id);
      case GamePhase.nightVoyante:
        d.voyante(s);
        engine.confirmVoyanteDone(s);
      case GamePhase.nightLoups:
        // Plus personne à dévorer : bouton « aucune victime possible ».
        final id =
            LegalChoices.loupsTargets(s).isEmpty ? null : d.loups(s);
        log.add('  loups -> ${_name(id)}');
        engine.setLoupsVictim(s, id);
      case GamePhase.nightPetiteFille:
        fail('La Petite Fille ne devrait jamais être appelée');
      case GamePhase.nightLoupBlanc:
        engine.resolveLoupBlanc(s, d.loupBlanc(s));
      case GamePhase.nightGrandMechantLoup:
        engine.resolveGrandMechantLoup(s, d.grandMechantLoup(s));
      case GamePhase.nightInfectPereDesLoups:
        engine.resolveInfectPereDesLoups(
            s, s.loupsVictimId != null && d.infect(s));
      case GamePhase.nightRenard:
        engine.resolveRenardCenter(s, d.renardCenter(s));
      case GamePhase.nightCorbeau:
        engine.resolveCorbeau(s, d.corbeau(s));
      case GamePhase.nightSorciere:
        final c = d.sorciere(s);
        engine.resolveSorciere(s, useVie: c.save, poisonTargetId: c.poison);
      case GamePhase.chasseurRevange:
        engine.resolveChasseurRevenge(s, d.chasseur(s));
      case GamePhase.successionMaire:
        engine.resolveMayorSuccession(s, d.mayorSuccessor(s));
      case GamePhase.enfantsauvageReveal:
        _confirm(() => engine.confirmEnfantSauvageReveal(s));
      case GamePhase.villagePowerLoss:
        _confirm(() => engine.confirmPowerLossReveal(s));
      case GamePhase.servanteDevouee:
        engine.resolveServanteDevouee(s, d.servanteTakesRole(s));
      case GamePhase.boucEmissaire:
        engine.resolveBoucEmissaireChoice(s, d.boucEmissaire(s));
      case GamePhase.idiotduvillageCivicRightLoss:
        engine.confirmIdiotDuVillageReveal(s);
      case GamePhase.dayReveal:
        _confirm(() => engine.confirmDayReveal(s),
            origin: FollowUpOrigin.nightDeaths);
      case GamePhase.mayorElectionExplain:
        engine.confirmMayorElectionExplain(
            s, d.voteMode(s, mayorElection: true));
      case GamePhase.mayorElection:
        engine.resolveMayorElection(s, _vote(mayorElection: true));
      case GamePhase.mayorReveal:
        engine.confirmMayorReveal(s);
      case GamePhase.debate:
        engine.confirmDebate(s, d.voteMode(s, mayorElection: false));
      case GamePhase.jugeBegueDecision:
        engine.resolveJugeBegueDecision(s, d.jugeBegue(s));
      case GamePhase.villageVote:
        _villageVote();
      case GamePhase.voteResult:
        _confirm(() => engine.confirmVoteResult(s),
            origin: FollowUpOrigin.voteDeaths);
      case GamePhase.setupPlayerCount:
      case GamePhase.setupRoles:
      case GamePhase.setupNames:
      case GamePhase.roleReveal:
      case GamePhase.endGame:
        fail('Rien à jouer en phase $phase');
    }

    expectInvariants(s, deadBefore: deadBefore, log: log);
  }

  /// Un écran de résolution annonce sur son bouton ce qui va suivre
  /// (UpcomingStep) : l'annonce doit correspondre à ce qui arrive.
  void _confirm(void Function() action, {FollowUpOrigin? origin}) {
    final announced = engine.upcomingStep(s, origin: origin);
    action();
    final ok = switch (announced) {
      UpcomingStep.gameOver => s.phase == GamePhase.endGame,
      UpcomingStep.followUp => followUpPhases.contains(s.phase),
      UpcomingStep.revote => s.phase == GamePhase.villageVote,
      UpcomingStep.nightFalls => s.phase == GamePhase.nightIntro,
      UpcomingStep.dayStarts => s.phase == GamePhase.mayorElectionExplain ||
          s.phase == GamePhase.debate,
    };
    _ensure(ok, () => 'Bouton annonçant $announced, arrivé sur ${s.phase}',
        s, log);
  }

  /// Vote du village, avec sa règle d'égalité (VillageVoteScreen).
  void _villageVote() {
    final rule = engine.villageVoteTieRule(s);
    if (s.voteMode == VoteMode.collective) {
      if (rule != VoteTieRule.runoff && d.collectiveTie(s)) {
        _resolveTie(rule, s.alivePlayers);
      } else {
        final id = d.collectiveVote(s, mayorElection: false);
        log.add('  village -> ${_name(id)}');
        engine.resolveVillageVote(s, id);
      }
      return;
    }
    final (winner, tied) = _secretVote(mayorElection: false, tieRule: rule);
    if (winner != null) {
      log.add('  village -> ${_name(winner)}');
      engine.resolveVillageVote(s, winner);
    } else {
      _resolveTie(rule, tied!);
    }
  }

  void _resolveTie(VoteTieRule rule, List<Player> tied) {
    log.add('  égalité ($rule) entre ${tied.map((p) => p.name).join(', ')}');
    if (rule == VoteTieRule.mayorDecides) {
      final choice = d.mayorTieBreak(s, tied);
      _ensure(tied.any((p) => p.id == choice),
          () => 'Le maire tranche hors des ex aequo', s, log);
      engine.resolveVillageVoteTie(s, mayorChoiceId: choice);
    } else {
      engine.resolveVillageVoteTie(s);
    }
  }

  /// Même déroulé que SequentialVoteFlow / CollectiveVoteScreen.
  String _vote({required bool mayorElection}) {
    if (s.voteMode == VoteMode.collective) {
      return d.collectiveVote(s, mayorElection: mayorElection);
    }
    final (winner, _) = _secretVote(mayorElection: mayorElection);
    return winner!;
  }

  /// Vote secret : (élu, null), ou (null, ex aequo) si l'égalité ne se
  /// règle pas par un second tour.
  (String?, List<Player>?) _secretVote(
      {required bool mayorElection, VoteTieRule tieRule = VoteTieRule.runoff}) {
    final voters = mayorElection ? s.alivePlayers : s.eligibleVoters;
    _ensure(voters.isNotEmpty, () => 'Vote sans votant', s, log);
    var candidates = s.alivePlayers;
    for (var round = 0; round < 60; round++) {
      final ids = candidates.map((c) => c.id).toSet();
      final votes = {
        for (final v in voters)
          v.id: d.secretVote(s, v, candidates, mayorElection: mayorElection),
      };
      _ensure(votes.values.every(ids.contains),
          () => 'Vote pour un non-candidat', s, log);
      final tally = engine.tallyVotes(s, votes, candidates: ids);
      if (tally.winner != null) {
        _ensure(ids.contains(tally.winner),
            () => 'Le vote désigne ${_name(tally.winner)}, non candidat', s, log);
        return (tally.winner!, null);
      }
      _ensure(tally.tiedCandidates.length > 1, () => 'Vote sans résultat', s,
          log);
      candidates = tally.tiedCandidates.map(s.byId).toList();
      if (tieRule != VoteTieRule.runoff) return (null, candidates);
    }
    fail('Égalités sans fin au vote\n${log.join('\n')}');
  }
}

/// Échoue avec [message] et le journal de la partie si [ok] est faux. Le
/// texte n'est construit qu'en cas d'échec : les vérifications tournent
/// après chaque action de centaines de parties.
void _ensure(bool ok, String Function() message, GameState s,
    List<String> log) {
  if (ok) return;
  fail('${message()}\n(nuit ${s.night}, jour ${s.day}, phase ${s.phase})\n'
      '${log.join('\n')}');
}

/// Ce dont chaque écran a besoin pour s'afficher sans planter.
void expectPhasePreconditions(GameState s, [List<String> log = const []]) {
  bool alive(RoleId role) => s.hasAliveRole(role);

  final ok = switch (s.phase) {
    GamePhase.nightVoleur => alive(RoleId.voleur),
    GamePhase.nightCupidon => alive(RoleId.cupidon),
    GamePhase.nightEnfantSauvage => alive(RoleId.enfantSauvage),
    GamePhase.nightEnfantSauvageCheck => alive(RoleId.enfantSauvage),
    GamePhase.nightEnfantSauvageMutation =>
      s.tryById(s.enfantSauvageNightMutationId)?.alive ?? false,
    GamePhase.nightInfectedReveal =>
      s.tryById(s.infectedRevealPendingId)?.alive ?? false,
    GamePhase.nightSalvateur => alive(RoleId.salvateur) &&
        s.alivePlayers.any((p) => s.salvateurCanProtect(p.id)),
    GamePhase.nightVoyante => alive(RoleId.voyante),
    GamePhase.nightLoups => s.wolfPackAwake,
    GamePhase.nightLoupBlanc => alive(RoleId.loupBlanc),
    GamePhase.nightGrandMechantLoup => alive(RoleId.grandMechantLoup),
    GamePhase.nightInfectPereDesLoups =>
      alive(RoleId.infectPereDesLoups) && !s.infectPereDesLoupsUsed,
    GamePhase.nightRenard => alive(RoleId.renard) && !s.renardPowerLost,
    GamePhase.nightCorbeau => alive(RoleId.corbeau),
    GamePhase.nightSorciere => alive(RoleId.sorciere),
    GamePhase.chasseurRevange =>
      s.chasseurRevengeTargetId != null && s.alivePlayers.isNotEmpty,
    GamePhase.successionMaire =>
      s.mayorSuccessionNeededFor != null && s.alivePlayers.isNotEmpty,
    GamePhase.enfantsauvageReveal =>
      s.tryById(s.enfantSauvageTransformedId)?.alive ?? false,
    GamePhase.villagePowerLoss => s.powerLossThisWave.isNotEmpty,
    GamePhase.servanteDevouee =>
      s.servanteDevoueeOfferId != null && alive(RoleId.servanteDevouee),
    GamePhase.boucEmissaire =>
      s.boucEmissaireChoiceNeededId != null && s.alivePlayers.isNotEmpty,
    GamePhase.idiotduvillageCivicRightLoss =>
      s.tryById(s.idiotDuVillageRevealId)?.alive ?? false,
    GamePhase.mayorElection => s.alivePlayers.isNotEmpty,
    GamePhase.mayorReveal => s.tryById(s.mayorId)?.alive ?? false,
    GamePhase.jugeBegueDecision => alive(RoleId.jugeBegue) && !s.jugeBegueUsed,
    GamePhase.villageVote =>
      s.alivePlayers.isNotEmpty && s.eligibleVoters.isNotEmpty,
    GamePhase.endGame => s.result != null,
    _ => true,
  };
  _ensure(ok, () => 'Précondition de l\'écran non remplie', s, log);
  final wave = nightPhases.contains(s.phase) ? 'night' : 'day';
  _ensure(s.currentWave == wave, () => 'Vague ${s.currentWave} incohérente',
      s, log);
}

/// Ce qui doit rester vrai à tout moment de la partie.
void expectInvariants(GameState s,
    {Set<String> deadBefore = const {}, List<String> log = const []}) {
  void ensure(bool ok, String Function() message) =>
      _ensure(ok, message, s, log);

  // Les morts restent morts, et seuls les morts ont une cause de décès.
  for (final id in deadBefore) {
    ensure(!s.byId(id).alive, () => 'Résurrection de ${s.byId(id).name}');
  }
  for (final p in s.players) {
    ensure((p.deathCause == null) == p.alive,
        () => '${p.name} : cause de décès incohérente');
  }

  // Les Amoureux vivent et meurent ensemble.
  final lovers = s.players.where((p) => p.isLover).toList();
  ensure(lovers.isEmpty || lovers.length == 2,
      () => '${lovers.length} Amoureux');
  for (final p in lovers) {
    final lover = s.byId(p.loverId!);
    ensure(lover.loverId == p.id, () => 'Amoureux non réciproques');
    ensure(lover.alive == p.alive,
        () => '${p.name} et ${lover.name} : un seul Amoureux mort');
  }

  // Un seul maire, celui désigné par mayorId, vivant.
  final mayors = s.players.where((p) => p.isMayor).toList();
  ensure(mayors.length <= 1, () => 'Deux maires');
  for (final m in mayors) {
    ensure(m.id == s.mayorId, () => 'isMayor ≠ mayorId');
    ensure(m.alive, () => 'Maire mort encore en poste');
  }
  final mayor = s.tryById(s.mayorId);
  if (mayor != null && mayor.alive) {
    ensure(mayor.isMayor, () => 'Maire ${mayor.name} sans écharpe');
  }

  // Les rôles uniques ne sont jamais tenus par deux vivants.
  for (final role in RoleId.values.where((r) => r.info.unique)) {
    ensure(s.alivePlayersWithRole(role).length <= 1,
        () => 'Deux $role vivants');
  }

  // Résumé live : au plus une étape « en cours », dans le dernier round.
  for (var i = 0; i < s.rounds.length; i++) {
    final current = s.rounds[i].steps
        .where((st) => st.status == StepStatus.current)
        .length;
    ensure(current <= (i == s.rounds.length - 1 ? 1 : 0),
        () => 'Résumé : $current étapes en cours au round $i');
  }

  if (s.phase == GamePhase.endGame) expectConsistentResult(s, log);
}

/// Le vainqueur annoncé correspond bien à la table.
void expectConsistentResult(GameState s, [List<String> log = const []]) {
  void ensure(bool ok, String Function() message) =>
      _ensure(ok, () => 'Résultat ${s.result?.winner} : ${message()}', s, log);

  final result = s.result!;
  final alive = s.alivePlayers;
  final aliveIds = alive.map((p) => p.id).toSet();
  final wolves = alive.where((p) => p.camp == Camp.loups).toList();
  final loupBlanc = alive.where((p) => p.role == RoleId.loupBlanc).toList();
  ensure(result.winningPlayerIds.every(aliveIds.contains),
      () => 'vainqueur mort');
  switch (result.winner) {
    case null:
      ensure(alive.isEmpty, () => 'des survivants');
    case Camp.village:
      ensure(wolves.isEmpty, () => 'des loups vivants');
      ensure(loupBlanc.isEmpty, () => 'Loup Blanc vivant');
      ensure(result.winningPlayerIds.toSet().length == aliveIds.length,
          () => 'vainqueurs ≠ survivants');
    case Camp.loups:
      final others = alive.length - wolves.length - loupBlanc.length;
      ensure(wolves.isNotEmpty && wolves.length >= others,
          () => 'loups minoritaires');
      ensure(
          result.winningPlayerIds.toSet().containsAll(wolves.map((w) => w.id)) &&
              result.winningPlayerIds.length == wolves.length,
          () => 'vainqueurs ≠ loups vivants');
    case Camp.amoureux:
      ensure(alive.length == 2 && alive.every((p) => p.isLover),
          () => 'pas deux Amoureux seuls');
      ensure(alive[0].camp != alive[1].camp, () => 'Amoureux du même camp');
    case Camp.seul:
      ensure(alive.length == 1 && alive.single.role == RoleId.loupBlanc,
          () => 'Loup Blanc pas seul');
  }
}
