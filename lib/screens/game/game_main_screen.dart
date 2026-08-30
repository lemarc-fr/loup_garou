import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/screens/game/role_screens/enfant_sauvage_check_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/enfant_sauvage_reveal_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/grand_mechant_loup_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/idiot_du_village_reveal_screen.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'day_reveal_screen.dart';
import 'debate_screen.dart';
import 'end_game_screen.dart';
import 'mayor_election_explain.dart';
import 'mayor_election_screen.dart';
import 'mayor_reveal_screen.dart';
import 'mayor_succession_screen.dart';
import 'night_intro_screen.dart';
import 'role_screens/bouc_emissaire_screen.dart';
import 'role_screens/chasseur_screen.dart';
import 'role_screens/corbeau_screen.dart';
import 'role_screens/cupidon_screen.dart';
import 'role_screens/enfant_sauvage_screen.dart';
import 'role_screens/infect_pere_des_loups_screen.dart';
import 'role_screens/juge_begue_screen.dart';
import 'role_screens/loup_blanc_screen.dart';
import 'role_screens/loups_screen.dart';
import 'role_screens/petite_fille_screen.dart';
import 'role_screens/renard_screen.dart';
import 'role_screens/salvateur_screen.dart';
import 'role_screens/servante_devouee_screen.dart';
import 'role_screens/sorciere_screen.dart';
import 'role_screens/voleur_screen.dart';
import 'role_screens/voyante_screen.dart';
import 'village_power_loss_screen.dart';
import 'village_vote_screen.dart';
import 'vote_result_screen.dart';

/// Point d'entrée de la partie une fois la distribution des rôles terminée.
/// Regarde `GameState.phase` et affiche l'écran correspondant.
///
/// Le thème (nuit sombre vs jour parchemin) suit désormais directement
/// `GameState.currentWave` plutôt qu'une liste figée de phases : les suites
/// déclenchées par une mort (succession du maire, riposte du Chasseur,
/// Servante Dévouée, Bouc Émissaire...) peuvent survenir aussi bien de nuit
/// que de jour, une liste statique de phases "de jour" ne suffit plus à les
/// classer correctement.
class GameMainScreen extends StatelessWidget {
  const GameMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final phase = state.phase;

    final screen = switch (phase) {
      GamePhase.nightIntro => const NightIntroScreen(),
      GamePhase.nightVoleur => const VoleurScreen(),
      GamePhase.nightCupidon => const CupidonScreen(),
      GamePhase.nightEnfantSauvage => const EnfantSauvageScreen(),
      GamePhase.nightSalvateur => const SalvateurScreen(),
      GamePhase.nightVoyante => const VoyanteScreen(),
      GamePhase.nightLoups => const LoupsScreen(),
      GamePhase.nightPetiteFille => const PetiteFilleScreen(),
      GamePhase.nightLoupBlanc => const LoupBlancScreen(),
      GamePhase.nightInfectPereDesLoups => const InfectPereDesLoupsScreen(),
      GamePhase.nightRenard => const RenardScreen(),
      GamePhase.nightCorbeau => const CorbeauScreen(),
      GamePhase.nightSorciere => const SorciereScreen(),
      GamePhase.chasseurRevange => const ChasseurScreen(),
      GamePhase.successionMaire => const MayorSuccessionScreen(),
      GamePhase.servanteDevouee => const ServanteDevoueeScreen(),
      GamePhase.boucEmissaire => const BoucEmissaireScreen(),
      GamePhase.dayReveal => const DayRevealScreen(),
      GamePhase.mayorElectionExplain => const MayorElectionExplainScreen(),
      GamePhase.mayorElection => const MayorElectionScreen(),
      GamePhase.mayorReveal => const MayorRevealScreen(),
      GamePhase.debate => const DebateScreen(),
      GamePhase.jugeBegueDecision => const JugeBegueScreen(),
      GamePhase.villageVote => const VillageVoteScreen(),
      GamePhase.voteResult => const VoteResultScreen(),
      GamePhase.villagePowerLoss => const VillagePowerLossScreen(),
      GamePhase.endGame => const EndGameScreen(),
      GamePhase.nightGrandMechantLoup => const GrandMechantLoupScreen(),
      GamePhase.nightEnfantSauvageCheck => const EnfantSauvageCheckScreen(),
      GamePhase.enfantsauvageReveal => const EnfantSauvageRevealScreen(),
      GamePhase.idiotduvillageCivicRightLoss => const IdiotDuVillageRevealScreen(),
    // GamePhase.nightGrandMechantLoup, GamePhase.enfantsauvageReveal et
    // GamePhase.idiotduvillageCivicRightLoss n'ont pas encore d'écran :
    // les rôles correspondants restent désactivés dans
    // RoleSelectionScreen tant que ces écrans ne sont pas écrits.
    // Les phases de setup (avant distribution) ne passent jamais par ici :
    // GameFlowScreen les intercepte plus haut. Filet de sécurité :
      _ => const SizedBox.shrink(),
    };

    if (state.currentWave == 'day') {
      return Theme(data: AppTheme.day, child: screen);
    }
    return screen;
  }
}