import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        actions: [
          if (stats.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Réinitialiser les statistiques',
              onPressed: () async {
                final ok = await confirmAction(
                  context,
                  title: 'Réinitialiser les statistiques ?',
                  message:
                      'Tout l\'historique des parties sera définitivement supprimé.',
                  confirmLabel: 'Réinitialiser',
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
                        'Aucune partie enregistrée pour l\'instant.\n'
                        'Jouez une partie complète pour voir apparaître vos statistiques ici.',
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
                    '${stats.gamesPlayed} partie(s) · '
                    '${(stats.winRate * 100).round()}% de victoires'
                    '${favorite != null ? ' · ${favorite.info.nameShort} favori' : ''}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.moonlight.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${stats.wins} V',
                    style: theme.textTheme.bodyLarge
                        ?.copyWith(color: AppColors.forest)),
                Text('${stats.losses} D',
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
