import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/confirm.dart';
import '../game_flow_screen.dart';
import '../settings/game_settings_screen.dart';
import '../stats/stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.nightlight_round, size: 84, color: AppColors.lantern),
              const SizedBox(height: 20),
              Text(loc.appTitle,
                  style: theme.textTheme.displayLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                loc.homeSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.moonlight.withValues(alpha: 0.7)),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              if (gameProvider.hasActiveGame) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameFlowScreen()),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(loc.resumeGameButton),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final ok = await confirmAction(
                        context,
                        title: loc.abandonGameDialogTitle,
                        message: loc.abandonGameDialogMessage,
                        confirmLabel: loc.abandonGameConfirmLabel,
                        destructive: true,
                      );
                      if (ok) {
                        gameProvider.abandonGame();
                        if (context.mounted) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const GameFlowScreen()),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text(loc.newGameButton),
                  ),
                ),
              ] else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameFlowScreen()),
                    ),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(loc.newGameButton),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const StatsScreen())),
                  icon: const Icon(Icons.bar_chart),
                  label: Text(loc.statsButton),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GameSettingsScreen())),
                  icon: const Icon(Icons.settings_outlined),
                  label: Text(loc.gameSettingsButton),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _showRulesSheet(context),
                icon: const Icon(Icons.menu_book, size: 18),
                label: Text(loc.gameRulesButton),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  void _showRulesSheet(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.nightAlt,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            Text(loc.gameRulesRolesTitle, style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 16),
            for (final role in RoleId.values) ...[
              Text(role.info.name,
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: role.info.accent)),
              const SizedBox(height: 4),
              Text(role.info.description,
                  style: Theme.of(ctx).textTheme.bodyMedium),
              const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}
