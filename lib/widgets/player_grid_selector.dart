import 'package:flutter/material.dart';
import '../models/player.dart';

/// Grille de tuiles-joueurs, utilisée partout où quelqu'un doit "pointer"
/// un joueur : cible de la voyante, victime des loups, vote, etc.
class PlayerGridSelector extends StatelessWidget {
  final List<Player> players;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final Set<String> disabledIds;
  final Set<String> highlightedIds; // ex : amoureux déjà choisis

  const PlayerGridSelector({
    super.key,
    required this.players,
    required this.onSelect,
    this.selectedId,
    this.disabledIds = const {},
    this.highlightedIds = const {},
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final p = players[index];
        final selected = p.id == selectedId;
        final disabled = disabledIds.contains(p.id);
        final highlighted = highlightedIds.contains(p.id);

        return Material(
          color: selected
              ? theme.colorScheme.primary
              : highlighted
                  ? theme.colorScheme.primary.withValues(alpha: 0.25)
                  : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: disabled ? null : () => onSelect(p.id),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      selected ? theme.colorScheme.primary : theme.dividerColor,
                  width: selected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Opacity(
                opacity: disabled ? 0.35 : 1,
                child: Text(
                  p.name,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? theme.colorScheme.onPrimary : null,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
