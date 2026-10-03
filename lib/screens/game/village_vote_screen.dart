import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
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
    final loc = AppLocalizations.of(context)!;

    return SequentialVoteFlow(
      title: loc.villageVoteTitle,
      instruction: loc.villageVoteInstruction,
      accent: AppColors.blood,
      voters: state.alivePlayers,
      initialCandidates: state.alivePlayers,
      onResolved: (eliminatedId) => gp.resolveVillageVote(eliminatedId),
    );
  }
}
