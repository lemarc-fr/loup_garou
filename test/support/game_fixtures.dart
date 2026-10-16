import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/player.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';

/// Une place autour de la table : prénom et carte imposée.
typedef Seat = (String name, RoleId role);

/// Partie aux cartes imposées, dans l'ordre des places (l'ordre compte pour
/// le Renard et le Montreur d'Ours). [tableCards] : les deux cartes posées
/// sur la table quand il y a un Voleur.
GameState riggedGame(
  GameEngine engine,
  List<Seat> seats, {
  GameSettings? settings,
  List<RoleId> tableCards = const [],
}) {
  final counts = <RoleId, int>{};
  for (final role in [...seats.map((s) => s.$2), ...tableCards]) {
    counts[role] = (counts[role] ?? 0) + 1;
  }
  final config = GameConfig(playerCount: seats.length, roleCounts: counts);
  final state = engine.initGame(
    config,
    [for (final seat in seats) seat.$1],
    settings ?? GameSettings(),
  );
  rigRoles(state, [for (final seat in seats) seat.$2], tableCards: tableCards);
  return state;
}

/// Remplace la distribution aléatoire par [roles] (même ordre que les
/// joueurs).
void rigRoles(GameState state, List<RoleId> roles,
    {List<RoleId> tableCards = const []}) {
  assert(roles.length == state.players.length);
  for (var i = 0; i < roles.length; i++) {
    state.players[i].role = roles[i];
  }
  state.voleurTableCards = [...tableCards];
}

/// Partie déjà lancée (première nuit, intro affichée).
GameState startedGame(
  GameEngine engine,
  List<Seat> seats, {
  GameSettings? settings,
  List<RoleId> tableCards = const [],
}) {
  final state =
      riggedGame(engine, seats, settings: settings, tableCards: tableCards);
  engine.startFirstNight(state);
  return state;
}

GameSettings settingsWith(Map<SettingId, bool> values) {
  final settings = GameSettings();
  values.forEach(settings.set);
  return settings;
}

extension GameStateByName on GameState {
  Player named(String name) => players.firstWhere((p) => p.name == name);
  String idOf(String name) => named(name).id;
  List<String> namesOf(Iterable<String> ids) =>
      [for (final id in ids) byId(id).name];
  List<String> get aliveNames => [for (final p in alivePlayers) p.name];
  List<String> get deadNames =>
      [for (final p in players) if (!p.alive) p.name];
}

extension EngineShortcuts on GameEngine {
  /// Avance jusqu'à [phase] dans la nuit en cours, en validant les écrans
  /// sans choix (intro, « rendors-toi », révélation des Amoureux...).
  void skipTo(GameState s, GamePhase phase) {
    var guard = 0;
    while (s.phase != phase) {
      if (++guard > 50) throw StateError('$phase jamais atteinte');
      switch (s.phase) {
        case GamePhase.nightIntro:
        case GamePhase.nightGoBackToSleep:
          advance(s);
        case GamePhase.nightLoversReveal:
          confirmLoversReveal(s);
        case GamePhase.nightVoyante:
          confirmVoyanteDone(s);
        case GamePhase.nightEnfantSauvageCheck:
          confirmEnfantSauvageCheck(s);
        default:
          throw StateError('Bloqué sur ${s.phase} en allant vers $phase');
      }
    }
  }

  /// Joue la fin de la nuit en cours sans rien faire de plus (chaque rôle
  /// restant passe son tour), jusqu'au récapitulatif du matin.
  void finishNight(GameState s) {
    var guard = 0;
    while (s.currentWave == 'night') {
      if (++guard > 60) throw StateError('nuit sans fin');
      switch (s.phase) {
        case GamePhase.nightIntro:
        case GamePhase.nightGoBackToSleep:
          advance(s);
        case GamePhase.nightLoversReveal:
          confirmLoversReveal(s);
        case GamePhase.nightVoyante:
          confirmVoyanteDone(s);
        case GamePhase.nightEnfantSauvageCheck:
          confirmEnfantSauvageCheck(s);
        case GamePhase.nightEnfantSauvageMutation:
          confirmEnfantSauvageNightMutation(s);
        case GamePhase.nightLoupBlanc:
          resolveLoupBlanc(s, null);
        case GamePhase.nightGrandMechantLoup:
          resolveGrandMechantLoup(s, null);
        case GamePhase.nightInfectPereDesLoups:
          resolveInfectPereDesLoups(s, false);
        case GamePhase.nightSorciere:
          resolveSorciere(s);
        case GamePhase.nightVoleur:
          resolveVoleur(s, null);
        default:
          throw StateError('finishNight : choix requis pour ${s.phase}');
      }
    }
  }

  /// Valide le récapitulatif du matin et les élections/débat jusqu'au vote
  /// du village (secret), sans suite à jouer.
  void dayToVote(GameState s, {String? mayor}) {
    var guard = 0;
    while (s.phase != GamePhase.villageVote) {
      if (++guard > 20) throw StateError('vote jamais atteint');
      switch (s.phase) {
        case GamePhase.dayReveal:
          confirmDayReveal(s);
        case GamePhase.mayorElectionExplain:
          confirmMayorElectionExplain(s, VoteMode.secret);
        case GamePhase.mayorElection:
          resolveMayorElection(s, mayor ?? s.alivePlayers.first.id);
        case GamePhase.mayorReveal:
          confirmMayorReveal(s);
        case GamePhase.debate:
          confirmDebate(s, VoteMode.secret);
        case GamePhase.jugeBegueDecision:
          resolveJugeBegueDecision(s, false);
        default:
          throw StateError('dayToVote : bloqué sur ${s.phase}');
      }
    }
  }
}
