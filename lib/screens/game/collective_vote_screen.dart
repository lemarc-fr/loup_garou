import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import '../../models/player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/player_grid_selector.dart';

/// Une information à rappeler à la table avant un vote collectif (voix
/// double du maire, malédiction du Corbeau...).
class CollectiveVoteNote {
  final IconData icon;
  final Color color;
  final String text;
  const CollectiveVoteNote(
      {required this.icon, required this.color, required this.text});
}

/// Vote collectif : toute la table vote en même temps (à voix haute, à
/// main levée...), puis le joueur qui tient le téléphone sélectionne le
/// résultat et le confirme. Pendant de [SequentialVoteFlow] (vote secret).
class CollectiveVoteScreen extends StatefulWidget {
  final String title;
  final String instruction;
  final List<Player> candidates;
  final List<CollectiveVoteNote> notes;
  final String Function(String name) confirmLabel;
  final void Function(String playerId) onConfirmed;

  /// La table déclare une égalité (règle d'égalité du vote du village).
  /// Null : pas de bouton, la table revote d'elle-même.
  final VoidCallback? onTie;

  const CollectiveVoteScreen({
    super.key,
    required this.title,
    required this.instruction,
    required this.candidates,
    required this.confirmLabel,
    required this.onConfirmed,
    this.notes = const [],
    this.onTie,
  });

  @override
  State<CollectiveVoteScreen> createState() => _CollectiveVoteScreenState();
}

class _CollectiveVoteScreenState extends State<CollectiveVoteScreen> {
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final selected =
        widget.candidates.where((p) => p.id == _selectedId).firstOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.instruction,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              for (final note in widget.notes) ...[
                const SizedBox(height: 10),
                VoteNoteBox(note: note),
              ],
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: widget.candidates,
                    selectedId: _selectedId,
                    onSelect: (id) => setState(
                        () => _selectedId = _selectedId == id ? null : id),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: selected == null
                    ? null
                    : () => widget.onConfirmed(selected.id),
                icon: const Icon(Icons.check),
                label: Text(selected == null
                    ? loc.collectiveVoteSelectPlayer
                    : widget.confirmLabel(selected.name)),
              ),
              if (widget.onTie != null) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: widget.onTie,
                  icon: const Icon(Icons.balance),
                  label: Text(loc.voteTieButton),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Encadré d'un rappel avant un vote (collectif ou secret).
class VoteNoteBox extends StatelessWidget {
  final CollectiveVoteNote note;
  const VoteNoteBox({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: note.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(note.icon, size: 20, color: context.readableIcon(note.color)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(note.text,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
