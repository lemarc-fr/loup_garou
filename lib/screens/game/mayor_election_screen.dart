import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'sequential_vote_flow.dart';

class MayorElectionScreen extends StatelessWidget {
  const MayorElectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;

    return SequentialVoteFlow(
      title: 'Élection du maire',
      instruction: 'Chaque joueur désigne le futur maire du village.',
      accent: AppColors.lantern,
      voters: state.alivePlayers,
      initialCandidates: state.alivePlayers,
      onResolved: (winnerId) => gp.resolveMayorElection(winnerId),
    );
  }
}
