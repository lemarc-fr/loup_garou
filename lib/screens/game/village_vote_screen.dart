import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'sequential_vote_flow.dart';

class VillageVoteScreen extends StatelessWidget {
  const VillageVoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;

    return SequentialVoteFlow(
      title: 'Vote du village',
      instruction: 'Chaque joueur désigne le suspect à éliminer.',
      accent: AppColors.blood,
      voters: state.alivePlayers,
      initialCandidates: state.alivePlayers,
      onResolved: (eliminatedId) => gp.resolveVillageVote(eliminatedId),
    );
  }
}
