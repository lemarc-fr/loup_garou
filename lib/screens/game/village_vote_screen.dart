import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'collective_vote_screen.dart';
import 'sequential_vote_flow.dart';

class VillageVoteScreen extends StatelessWidget {
  const VillageVoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final loc = AppLocalizations.of(context)!;

    // Mode choisi à la fin du débat (voir DebateScreen).
    if (state.voteMode == VoteMode.collective) {
      return CollectiveVoteScreen(
        title: loc.villageVoteTitle,
        instruction: loc.collectiveVoteVillageInstruction,
        candidates: state.alivePlayers,
        notes: _collectiveNotes(state, loc),
        confirmLabel: loc.collectiveVoteConfirmEliminationButton,
        onConfirmed: gp.resolveVillageVote,
      );
    }

    return SequentialVoteFlow(
      title: loc.villageVoteTitle,
      instruction: loc.villageVoteInstruction,
      accent: AppColors.blood,
      // L'Idiot du Village démasqué a perdu son droit de vote.
      voters: state.eligibleVoters,
      initialCandidates: state.alivePlayers,
      // Les deux voix du Corbeau sont ajoutées au décompte : chaque votant
      // doit le savoir.
      notes: [
        if (_corbeauNote(state, loc) case final note?) note,
      ],
      onResolved: (eliminatedId) => gp.resolveVillageVote(eliminatedId),
    );
  }

  static CollectiveVoteNote? _corbeauNote(
      GameState state, AppLocalizations loc) {
    final cursed = state.tryById(state.corbeauCursedId);
    if (cursed == null || !cursed.alive) return null;
    return CollectiveVoteNote(
      icon: Icons.campaign,
      color: AppColors.blood,
      text: loc.collectiveVoteCorbeauCurse(cursed.name),
    );
  }

  /// En vote collectif, c'est la table qui compte les voix : on lui
  /// rappelle tout ce que le décompte automatique du vote secret
  /// (GameEngine.tallyVotes) prendrait en compte.
  List<CollectiveVoteNote> _collectiveNotes(
      GameState state, AppLocalizations loc) {
    final mayor = state.tryById(state.mayorId);
    return [
      if (mayor != null && mayor.alive)
        CollectiveVoteNote(
          icon: Icons.emoji_events,
          color: AppColors.lantern,
          text: loc.collectiveVoteMayorDoubleVoice(mayor.name),
        ),
      if (_corbeauNote(state, loc) case final note?) note,
      for (final id in state.disenfranchisedPlayerIds)
        if (state.tryById(id)?.alive ?? false)
          CollectiveVoteNote(
            icon: Icons.block,
            color: AppColors.blood,
            text: loc.collectiveVoteCannotVote(state.byId(id).name),
          ),
    ];
  }
}
