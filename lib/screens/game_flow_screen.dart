import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'game/game_main_screen.dart';
import 'setup/player_count_screen.dart';
import 'setup/player_names_screen.dart';
import 'setup/role_reveal_screen.dart';
import 'setup/role_selection_screen.dart';

/// Point d'entrée unique de tout le déroulé "création + partie". Regarde
/// l'état du [GameProvider] et affiche l'écran correspondant — pas de
/// pile de navigation complexe, la machine à états fait déjà tout le travail.
class GameFlowScreen extends StatelessWidget {
  const GameFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();

    if (gp.state == null) {
      switch (gp.setupStep) {
        case SetupStep.playerCount:
          return const PlayerCountScreen();
        case SetupStep.roles:
          return const RoleSelectionScreen();
        case SetupStep.names:
          return const PlayerNamesScreen();
        case SetupStep.reveal:
        case SetupStep.done:
          return const PlayerCountScreen();
      }
    }

    if (gp.setupStep == SetupStep.reveal) {
      return const RoleRevealScreen();
    }

    return const GameMainScreen();
  }
}
