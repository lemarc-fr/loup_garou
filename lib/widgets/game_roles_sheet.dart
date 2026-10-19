import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';

import '../models/role.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import 'role_image.dart';

/// Ouvre la liste des rôles de la partie en cours, avec leur description et
/// le nombre de cartes de chacun encore en jeu (voir
/// GameState.remainingRoleCounts). Fond "nuit", comme le résumé.
void showGameRolesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightAlt,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => Theme(data: AppTheme.night, child: const GameRolesSheet()),
  );
}

class GameRolesSheet extends StatelessWidget {
  const GameRolesSheet({super.key});

  static const _campOrder = [
    Camp.loups,
    Camp.seul,
    Camp.village,
    Camp.amoureux
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameProvider>().state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final totals = {
      for (final e in state.config.roleCounts.entries)
        if (e.value > 0) e.key: e.value,
    };
    final remaining = state.remainingRoleCounts;
    // Loups d'abord, puis solitaires, puis village ; ordre du catalogue
    // dans chaque camp.
    final roles = totals.keys.toList()
      ..sort((a, b) {
        final byCamp = _campOrder
            .indexOf(a.info.camp)
            .compareTo(_campOrder.indexOf(b.info.camp));
        return byCamp != 0 ? byCamp : a.index.compareTo(b.index);
      });

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        children: [
          Row(
            children: [
              const Icon(Icons.style, color: AppColors.lantern),
              const SizedBox(width: 10),
              Expanded(
                child: Text(loc.gameRolesSheetTitle,
                    style: theme.textTheme.titleLarge),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(loc.gameRolesSheetIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          for (final role in roles)
            _RoleTile(
              role: role,
              remaining: remaining[role] ?? 0,
              total: totals[role]!,
            ),
        ],
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final RoleId role;
  final int remaining;
  final int total;

  const _RoleTile(
      {required this.role, required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final out = remaining == 0;
    // Lisible sur la carte, posée sur le fond (plus clair) de la feuille.
    final accent = AppColors.readableOn(role.info.accent, AppColors.nightAlt);
    final image = RoleImage(role: role, size: 52);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.night.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.nightLine),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte sortie du jeu : seule l'illustration s'estompe, le
          // texte reste lisible.
          out ? Opacity(opacity: 0.45, child: image) : image,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(loc.roleName(role),
                        style: theme.textTheme.titleMedium?.copyWith(
                            color: accent, fontWeight: FontWeight.w600)),
                    _CountChip(
                      label: out
                          ? loc.gameRolesNoneLeft
                          : loc.gameRolesRemaining(remaining, total),
                      highlighted: !out,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(loc.roleDescription(role),
                    style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final bool highlighted;

  const _CountChip({required this.label, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted
            ? AppColors.lantern.withValues(alpha: 0.18)
            : AppColors.nightLine,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: highlighted ? AppColors.lantern : AppColors.moonlight),
      ),
    );
  }
}
