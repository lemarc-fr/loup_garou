import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/player_stats.dart';
import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirm.dart';
import '../../widgets/role_image.dart';
import '../../models/role.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsProvider = context.watch<StatsProvider>();
    final theme = Theme.of(context);
    final stats = statsProvider.stats;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.statsTitle),
        actions: [
          if (stats.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: loc.statsResetTooltip,
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: loc.statsResetDialogTitle,
                  message: loc.statsResetDialogMessage,
                  confirmLabel: loc.statsResetConfirmLabel,
                  destructive: true,
                );
                if (ok && context.mounted) {
                  await context.read<StatsProvider>().clearAll();
                }
              },
            ),
        ],
      ),
      body: SafeArea(
        child: !statsProvider.loaded
            ? const Center(child: CircularProgressIndicator())
            : stats.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        loc.statsEmptyMessage,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: stats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _PlayerStatsCard(stats: stats[index]),
                  ),
      ),
    );
  }
}

class _PlayerStatsCard extends StatelessWidget {
  final PlayerStats stats;
  const _PlayerStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final favorite = stats.favoriteRole;
    final loc = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            if (favorite != null)
              RoleImage(role: favorite, size: 48)
            else
              const CircleAvatar(radius: 24, child: Icon(Icons.person)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stats.name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${loc.statsCardSummary(stats.gamesPlayed, (stats.winRate * 100).round())}'
                    '${favorite != null ? loc.statsFavoriteSuffix(favorite.info.nameShort) : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.moonlight.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(loc.statsWinsAbbr(stats.wins),
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.forest)),
                Text(loc.statsLossesAbbr(stats.losses),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.blood)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
