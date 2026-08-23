import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../widgets/player_grid_selector.dart';

/// Traite les actions différées empilées par le moteur (vengeance du
/// Chasseur, succession du Maire) avant de pouvoir révéler publiquement
/// les morts de la vague en cours. Ces moments sont publics (le joueur
/// concerné vient de mourir) : pas de PassDeviceGate ici.
class PendingActionScreen extends StatelessWidget {
  const PendingActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final action = state.pendingActions.first;
    final theme = Theme.of(context);
    final deadPlayer = state.byId(action.playerId);
    final targets = state.alivePlayers;

    final title = action.isHunterRevenge
        ? 'Vengeance du Chasseur'
        : 'Succession du Maire';
    final instruction = action.isHunterRevenge
        ? '${deadPlayer.name} était le Chasseur ! Avant de mourir, il abat un dernier joueur.'
        : '${deadPlayer.name} était le Maire. Il désigne son successeur avant de rendre son dernier souffle.';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                instruction,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: targets,
                    onSelect: (id) => action.isHunterRevenge
                        ? gp.resolvePendingAction(hunterTargetId: id)
                        : gp.resolvePendingAction(mayorSuccessorId: id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
