import 'game_state.dart';

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

  RoundRecord({required this.wave, required this.number});
}