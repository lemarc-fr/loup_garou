import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'collective_vote_screen.dart';
import 'sequential_vote_flow.dart';

class MayorElectionScreen extends StatelessWidget {
  const MayorElectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final loc = AppLocalizations.of(context)!;

    // Mode choisi sous l'insigne du maire (voir MayorElectionExplainScreen).
    if (state.voteMode == VoteMode.collective) {
      return CollectiveVoteScreen(
        title: loc.mayorElectionTitle,
        instruction: loc.collectiveVoteMayorInstruction,
        candidates: state.alivePlayers,
        confirmLabel: loc.collectiveVoteConfirmMayorButton,
        onConfirmed: gp.resolveMayorElection,
      );
    }

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
