import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'day_reveal_screen.dart';
import 'debate_screen.dart';
import 'end_game_screen.dart';
import 'mayor_election_screen.dart';
import 'night_intro_screen.dart';
import 'pending_action_screen.dart';
import 'role_screens/cupidon_screen.dart';
import 'role_screens/loups_screen.dart';
import 'role_screens/petite_fille_screen.dart';
import 'role_screens/sorciere_screen.dart';
import 'role_screens/voleur_screen.dart';
import 'role_screens/voyante_screen.dart';
import 'village_vote_screen.dart';
import 'vote_result_screen.dart';
import 'village_power_loss_screen.dart';
import 'mayor_reveal_screen.dart';

/// Point d'entrée de la partie une fois la distribution des rôles terminée.
/// Regarde `GameState.phase` et affiche l'écran correspondant — c'est la
/// pièce manquante que [GameFlowScreen] attend déjà (`GameMainScreen`).
///
/// Les phases de jour basculent sur le thème "parchemin" défini dans
/// [AppTheme.day] ; les phases de nuit gardent le thème sombre appliqué
/// globalement dans main.dart.
class GameMainScreen extends StatelessWidget {
  const GameMainScreen({super.key});

  static const _dayPhases = {
    GamePhase.dayReveal,
    GamePhase.mayorElection,
    GamePhase.mayorReveal,
    GamePhase.debate,
    GamePhase.villageVote,
    GamePhase.voteResult,
    GamePhase.villagePowerLoss,
  };

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final phase = gp.state!.phase;

    final screen = switch (phase) {
      GamePhase.nightIntro => const NightIntroScreen(),
      GamePhase.nightVoleur => const VoleurScreen(),
      GamePhase.nightCupidon => const CupidonScreen(),
      GamePhase.nightVoyante => const VoyanteScreen(),
      GamePhase.nightLoups => const LoupsScreen(),
      GamePhase.nightPetiteFille => const PetiteFilleScreen(),
      GamePhase.nightSorciere => const SorciereScreen(),
      GamePhase.pendingAction => const PendingActionScreen(),
      GamePhase.dayReveal => const DayRevealScreen(),
      GamePhase.mayorElection => const MayorElectionScreen(),
      GamePhase.mayorReveal => const MayorRevealScreen(),
      GamePhase.debate => const DebateScreen(),
      GamePhase.villageVote => const VillageVoteScreen(),
      GamePhase.voteResult => const VoteResultScreen(),
      GamePhase.endGame => const EndGameScreen(),
      GamePhase.villagePowerLoss => const VillagePowerLossScreen(),
      // Les phases de setup (avant distribution) ne passent jamais par ici :
      // GameFlowScreen les intercepte plus haut. Filet de sécurité :
      _ => const SizedBox.shrink(),
    };

    if (_dayPhases.contains(phase)) {
      return Theme(data: AppTheme.day, child: screen);
    }
    return screen;
  }
}
