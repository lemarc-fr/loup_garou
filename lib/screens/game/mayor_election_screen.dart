import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;

    return SequentialVoteFlow(
      title: loc.mayorElectionTitle,
      instruction: loc.mayorElectionInstruction,
      accent: AppColors.lantern,
      voters: state.alivePlayers,
      initialCandidates: state.alivePlayers,
      onResolved: (winnerId) => gp.resolveMayorElection(winnerId),
    );
  }
}
