import 'game_state.dart';
import 'role.dart';

/// État d'une étape dans le résumé "live" de la partie (voir GameProgressSheet).
/// - pending : encore à venir, pas encore atteinte.
/// - current : en train de se jouer maintenant.
/// - done    : terminée normalement.
/// - skipped : dans la file mais jamais jouée (ex. Sorcière bloquée par une option).
enum StepStatus { pending, current, done, skipped }

/// Une étape (un tour de rôle, un vote, ...) au sein d'une nuit ou d'un jour.
class StepRecord {
  final GamePhase phase;
  StepStatus status;
  StepRecord(this.phase, this.status);
}

/// Une nuit ou un jour complet, avec la liste chronologique de ses étapes —
/// y compris celles encore "à venir", pré-remplies dès le début du round à
/// partir de buildNightQueue/buildDayQueue (donc déjà filtrées selon les
/// rôles présents/vivants). Alimenté par GameEngine (_seedRoundSteps,
/// _goToPhase, _logSkippedPhase) pour le résumé "live" (GameProgressSheet).
class RoundRecord {
  final String wave; // 'night' ou 'day'
  final int number;
  final List<StepRecord> steps = [];

  /// Ce que tout le village a appris pendant ce round (morts, élections,
  /// résultat des votes), dans l'ordre : le "compte rendu" du résumé.
  /// Rien de secret n'y figure (infection, Ancien qui survit...).
  final List<RoundEvent> events = [];

  RoundRecord({required this.wave, required this.number});
}

enum RoundEventKind {
  /// Un joueur est mort ([RoundEvent.playerId], [RoundEvent.role],
  /// [RoundEvent.cause]).
  death,

  /// Le village a élu son maire ([RoundEvent.votes] : décompte d'un vote
  /// secret).
  mayorElected,

  /// Le maire mourant a désigné son successeur.
  mayorSuccession,

  /// Le vote du village a désigné [RoundEvent.playerId] (sa mort suit, s'il
  /// meurt). [RoundEvent.tieRule] : comment une égalité a été réglée.
  villageVote,

  /// Le vote du village n'a éliminé personne (égalité).
  nobodyEliminated,

  /// L'Idiot du Village, désigné par le vote, révèle son rôle et survit.
  idiotSpared,
}

/// Un événement public d'une nuit ou d'un jour (voir [RoundRecord.events]).
class RoundEvent {
  final RoundEventKind kind;
  final String? playerId;

  /// Rôle du joueur au moment de l'événement (sa carte, à sa mort).
  final RoleId? role;
  final DeathCause? cause;
  final VoteTieRule? tieRule;

  /// Voix reçues par chaque candidat (vote secret), du plus au moins voté.
  /// Null pour un vote collectif, dont seul le résultat est saisi.
  final Map<String, int>? votes;

  const RoundEvent(
    this.kind, {
    this.playerId,
    this.role,
    this.cause,
    this.tieRule,
    this.votes,
  });
}
