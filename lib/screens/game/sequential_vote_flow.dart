import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/game_state.dart' show VoteTieRule;
import '../../../models/player.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'collective_vote_screen.dart';

/// Fait voter chaque joueur vivant, un par un (téléphone passé de main en
/// main, vote secret), puis calcule le résultat. Une égalité se règle selon
/// [tieRule] : second tour restreint aux ex aequo (jusqu'à décision), ou
/// [onTie], après que le maire a tranché s'il le doit.
///
/// Utilisé à la fois pour l'élection du maire et pour le vote du village :
/// c'est la même mécanique, seuls le titre et le texte changent.
class SequentialVoteFlow extends StatefulWidget {
  final String title;
  final String instruction;
  final Color accent;
  final List<Player> voters;
  final List<Player> initialCandidates;
  final void Function(String winnerId) onResolved;
  final bool allowSelfVote;

  /// Rappels montrés à chaque votant (voix du Corbeau...).
  final List<CollectiveVoteNote> notes;

  /// Règle d'égalité (vote du village) ; l'élection du maire se rejoue.
  final VoteTieRule tieRule;

  /// Égalité réglée sans second tour. [mayorChoiceId] : l'ex aequo désigné
  /// par le maire, quand c'est lui qui tranche.
  final void Function({String? mayorChoiceId})? onTie;

  const SequentialVoteFlow({
    super.key,
    required this.title,
    required this.instruction,
    required this.voters,
    required this.initialCandidates,
    required this.onResolved,
    this.accent = AppColors.lantern,
    this.allowSelfVote = true,
    this.notes = const [],
    this.tieRule = VoteTieRule.runoff,
    this.onTie,
  });

  @override
  State<SequentialVoteFlow> createState() => _SequentialVoteFlowState();
}

class _SequentialVoteFlowState extends State<SequentialVoteFlow> {
  late List<Player> candidates;
  int voterIndex = 0;
  Map<String, String> votes = {};
  bool isRunoff = false;

  /// Ex aequo entre lesquels le maire doit trancher (règle mayorDecides).
  List<Player>? mayorTie;

  @override
  void initState() {
    super.initState();
    candidates = widget.initialCandidates;
  }

  void _castVote(String targetId) {
    final gp = context.read<GameProvider>();
    final newVotes = {...votes, widget.voters[voterIndex].id: targetId};

    if (voterIndex == widget.voters.length - 1) {
      final tally =
          gp.tallyVotes(newVotes, candidates: candidates.map((c) => c.id));
      if (tally.winner != null) {
        widget.onResolved(tally.winner!);
        return;
      }
      final tied =
          tally.tiedCandidates.map((id) => gp.state!.byId(id)).toList();
      switch (widget.tieRule) {
        case VoteTieRule.boucEmissaire:
        case VoteTieRule.nobodyEliminated:
          widget.onTie!();
          return;
        case VoteTieRule.mayorDecides:
          setState(() => mayorTie = tied);
          return;
        case VoteTieRule.runoff:
          break;
      }
      setState(() {
        votes = {};
        voterIndex = 0;
        isRunoff = true;
        candidates = tied;
      });
    } else {
      setState(() {
        votes = newVotes;
        voterIndex++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tie = mayorTie;
    if (tie != null) {
      return _MayorTieBreak(
          tied: tie, onChosen: (id) => widget.onTie!(mayorChoiceId: id));
    }

    final voter = widget.voters[voterIndex];
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final selectable = widget.allowSelfVote ? [...candidates] : candidates.where((c) => c.id != voter.id).toList();

    return PassDeviceGate(
      key: ValueKey('vote-${voter.id}-$isRunoff-${candidates.length}'),
      toName: voter.name,
      subtitle: loc.voteSecretSubtitle,
      accent: widget.accent,
      contentBuilder: (_) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isRunoff)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.blood.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      loc.voteRunoffTieNotice,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                Text(widget.instruction,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center),
                for (final note in widget.notes) ...[
                  const SizedBox(height: 10),
                  VoteNoteBox(note: note),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: PlayerGridSelector(
                        players: selectable, onSelect: _castVote),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Égalité au vote secret : écran public où le maire désigne l'éliminé
/// parmi les ex aequo.
class _MayorTieBreak extends StatelessWidget {
  final List<Player> tied;
  final ValueChanged<String> onChosen;

  const _MayorTieBreak({required this.tied, required this.onChosen});

  @override
  Widget build(BuildContext context) {
    final state = context.read<GameProvider>().state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final mayor = state.byId(state.mayorId!);

    return Scaffold(
      appBar: AppBar(title: Text(loc.voteTieMayorTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.emoji_events,
                  size: 48, color: context.readableIcon(AppColors.lantern)),
              const SizedBox(height: 12),
              Text(loc.voteTieMayorInstruction(mayor.name),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(players: tied, onSelect: onChosen),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
