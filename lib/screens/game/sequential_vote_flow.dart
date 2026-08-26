import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/player.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

/// Fait voter chaque joueur vivant, un par un (téléphone passé de main en
/// main, vote secret), puis calcule le résultat. En cas d'égalité, relance
/// un tour restreint aux candidats à égalité — jusqu'à décision.
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


  const SequentialVoteFlow({
    super.key,
    required this.title,
    required this.instruction,
    required this.voters,
    required this.initialCandidates,
    required this.onResolved,
    this.accent = AppColors.lantern,
    this.allowSelfVote = true,
  });

  @override
  State<SequentialVoteFlow> createState() => _SequentialVoteFlowState();
}

class _SequentialVoteFlowState extends State<SequentialVoteFlow> {
  late List<Player> candidates;
  int voterIndex = 0;
  Map<String, String> votes = {};
  bool isRunoff = false;

  @override
  void initState() {
    super.initState();
    candidates = widget.initialCandidates;
  }

  void _castVote(String targetId) {
    final gp = context.read<GameProvider>();
    final newVotes = {...votes, widget.voters[voterIndex].id: targetId};

    if (voterIndex == widget.voters.length - 1) {
      final tally = gp.tallyVotes(newVotes);
      if (tally.winner != null) {
        widget.onResolved(tally.winner!);
        return;
      }
      setState(() {
        votes = {};
        voterIndex = 0;
        isRunoff = true;
        candidates =
            tally.tiedCandidates.map((id) => gp.state!.byId(id)).toList();
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
    final voter = widget.voters[voterIndex];
    final theme = Theme.of(context);
    final selectable = widget.allowSelfVote ? [...candidates] : candidates.where((c) => c.id != voter.id).toList();

    return PassDeviceGate(
      key: ValueKey('vote-${voter.id}-$isRunoff-${candidates.length}'),
      toName: voter.name,
      subtitle: 'Vote secret : les autres joueurs ne doivent pas regarder.',
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
                      'Égalité au tour précédent — on revote entre les candidats à égalité.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                Text(widget.instruction,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center),
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
