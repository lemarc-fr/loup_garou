import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'collective_vote_screen.dart';
import 'sequential_vote_flow.dart';

class VillageVoteScreen extends StatefulWidget {
  const VillageVoteScreen({super.key});

  @override
  State<VillageVoteScreen> createState() => _VillageVoteScreenState();
}

class _VillageVoteScreenState extends State<VillageVoteScreen> {
  /// Vote collectif déclaré à égalité, que le maire doit trancher.
  bool _mayorBreaksCollectiveTie = false;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final loc = AppLocalizations.of(context)!;
    final tieRule = gp.villageVoteTieRule;

    // Mode choisi à la fin du débat (voir DebateScreen).
    if (state.voteMode == VoteMode.collective) {
      if (_mayorBreaksCollectiveTie) {
        // La table connaît les ex aequo : le maire en désigne un.
        return CollectiveVoteScreen(
          title: loc.voteTieMayorTitle,
          instruction:
              loc.voteTieMayorInstruction(state.byId(state.mayorId!).name),
          candidates: state.alivePlayers,
          confirmLabel: loc.collectiveVoteConfirmEliminationButton,
          onConfirmed: (id) => gp.resolveVillageVoteTie(mayorChoiceId: id),
        );
      }
      return CollectiveVoteScreen(
        title: loc.villageVoteTitle,
        instruction: loc.collectiveVoteVillageInstruction,
        candidates: state.alivePlayers,
        notes: _collectiveNotes(state, loc, tieRule),
        confirmLabel: loc.collectiveVoteConfirmEliminationButton,
        onConfirmed: gp.resolveVillageVote,
        // En cas de second tour, la table revote simplement.
        onTie: switch (tieRule) {
          VoteTieRule.runoff => null,
          VoteTieRule.mayorDecides => () =>
              setState(() => _mayorBreaksCollectiveTie = true),
          VoteTieRule.boucEmissaire ||
          VoteTieRule.nobodyEliminated =>
            () => gp.resolveVillageVoteTie(),
        },
      );
    }

    return SequentialVoteFlow(
      title: loc.villageVoteTitle,
      instruction: loc.villageVoteInstruction,
      accent: AppColors.blood,
      // L'Idiot du Village démasqué a perdu son droit de vote ; le Bouc
      // Émissaire a pu restreindre les votants.
      voters: state.eligibleVoters,
      initialCandidates: state.alivePlayers,
      // Les deux voix du Corbeau sont ajoutées au décompte : chaque votant
      // doit le savoir, comme la règle en cas d'égalité.
      notes: [
        if (_corbeauNote(state, loc) case final note?) note,
        if (_boucNote(state, loc) case final note?) note,
        _tieRuleNote(tieRule, loc),
      ],
      tieRule: tieRule,
      onTie: ({mayorChoiceId}) =>
          gp.resolveVillageVoteTie(mayorChoiceId: mayorChoiceId),
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

  static CollectiveVoteNote? _boucNote(GameState state, AppLocalizations loc) {
    if (!state.voteRestrictedByBouc) return null;
    return CollectiveVoteNote(
      icon: Icons.how_to_vote,
      color: AppColors.forest,
      text: loc.voteRestrictedByBouc(
          state.eligibleVoters.map((p) => p.name).join(', ')),
    );
  }

  static CollectiveVoteNote _tieRuleNote(
          VoteTieRule rule, AppLocalizations loc) =>
      CollectiveVoteNote(
        icon: Icons.balance,
        color: AppColors.lantern,
        text: switch (rule) {
          VoteTieRule.boucEmissaire => loc.voteTieRuleBouc,
          VoteTieRule.mayorDecides => loc.voteTieRuleMayor,
          VoteTieRule.nobodyEliminated => loc.voteTieRuleNobody,
          VoteTieRule.runoff => loc.voteTieRuleRunoff,
        },
      );

  /// En vote collectif, c'est la table qui compte les voix : on lui
  /// rappelle tout ce que le décompte automatique du vote secret
  /// (GameEngine.tallyVotes) prendrait en compte.
  List<CollectiveVoteNote> _collectiveNotes(
      GameState state, AppLocalizations loc, VoteTieRule tieRule) {
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
      if (_boucNote(state, loc) case final note?) note,
      _tieRuleNote(tieRule, loc),
    ];
  }
}
