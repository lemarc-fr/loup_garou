import 'game_state.dart';

/// État d'une étape dans le résumé "live" de la partie (voir GameProgressSheet).
enum StepStatus { current, done, skipped }

/// Une étape (un tour de rôle, un vote, ...) au sein d'une nuit ou d'un jour.
class StepRecord {
  final GamePhase phase;
  StepStatus status;
  StepRecord(this.phase, this.status);
}

/// Une nuit ou un jour complet, avec la liste chronologique de ses étapes.
/// Alimenté au fil de la partie par GameEngine (voir _goToPhase / _startRound
/// / _logSkippedPhase), pour permettre au joueur de consulter à tout moment
/// un résumé de ce qui s'est passé depuis le début (GameProgressSheet).
class RoundRecord {
  final String wave; // 'night' ou 'day'
  final int number;
  final List<StepRecord> steps = [];

  RoundRecord({required this.wave, required this.number});
}