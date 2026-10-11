import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import '../models/game_state.dart' show VoteMode;
import '../theme/app_theme.dart';

/// Choix du mode de vote, affiché juste avant un vote (élection du maire,
/// vote du village) : vote collectif (tout le monde vote en même temps, le
/// résultat est saisi une fois) ou vote secret (le téléphone passe de main
/// en main).
class VoteModeChooser extends StatelessWidget {
  final ValueChanged<VoteMode> onChosen;

  const VoteModeChooser({super.key, required this.onChosen});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.voteModeQuestion,
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _VoteModeCard(
                  icon: Icons.groups,
                  label: loc.voteModeCollectiveButton,
                  hint: loc.voteModeCollectiveHint,
                  onTap: () => onChosen(VoteMode.collective),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _VoteModeCard(
                  icon: Icons.lock_outline,
                  label: loc.voteModeSecretButton,
                  hint: loc.voteModeSecretHint,
                  onTap: () => onChosen(VoteMode.secret),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VoteModeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String hint;
  final VoidCallback onTap;

  const _VoteModeCard({
    required this.icon,
    required this.label,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: primary.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: primary.withValues(alpha: 0.6)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 36, color: context.readableIcon(primary)),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                hint,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
