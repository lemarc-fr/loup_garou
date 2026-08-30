import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/player_grid_selector.dart';

/// Le maire vient de mourir, quelle qu'en soit la cause (nuit ou vote).
/// Avant de rendre son dernier souffle, il désigne son successeur — pas de
/// vote ici, c'est un choix unique.
///
/// Voir GameState.mayorSuccessionNeededFor et
/// GameEngine.resolveMayorSuccession.
class MayorSuccessionScreen extends StatelessWidget {
  const MayorSuccessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Succession du maire')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.emoji_events_outlined,
                  size: 56, color: AppColors.lantern),
              const SizedBox(height: 16),
              Text(
                'Le maire est mort. Avant de rendre son dernier souffle, '
                    'il désigne son successeur.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: state.alivePlayers,
                    onSelect: (id) => gp.resolveMayorSuccession(id),
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