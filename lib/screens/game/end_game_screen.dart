import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/game_state.dart';
import '../../providers/game_provider.dart';
import '../../providers/stats_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_image.dart';
import '../stats/stats_screen.dart';
import '../../models/role.dart';

class EndGameScreen extends StatefulWidget {
  const EndGameScreen({super.key});

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  bool _recorded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Enregistre le résultat une seule fois, après la première frame, pour
    // éviter d'appeler notifyListeners() pendant un build.
    if (!_recorded) {
      _recorded = true;
      final gp = context.read<GameProvider>();
      final stats = context.read<StatsProvider>();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) stats.recordGameResult(gp.state!);
      });
    }
  }

  String _winnerLabel(WinnerType w) {
    switch (w) {
      case WinnerType.village:
        return 'Le Village l\'emporte !';
      case WinnerType.loups:
        return 'Les Loups-Garous l\'emportent !';
      case WinnerType.amoureux:
        return 'Les Amoureux l\'emportent !';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final result = state.result!;
    final theme = Theme.of(context);
    final winners = result.winningPlayerIds.map(state.byId).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Fin de la partie')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.emoji_events,
                  size: 72, color: AppColors.lantern),
              const SizedBox(height: 20),
              Text(
                _winnerLabel(result.winner),
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    for (final p in state.players)
                      Card(
                        child: ListTile(
                          leading: RoleImage(role: p.role, size: 44),
                          title: Text(p.name),
                          subtitle: Text(p.role.info.name),
                          trailing: winners.contains(p)
                              ? const Icon(Icons.star, color: AppColors.lantern)
                              : (p.alive
                                  ? const Icon(Icons.favorite,
                                      color: AppColors.forest)
                                  : const Icon(Icons.close,
                                      color: AppColors.blood)),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatsScreen()));
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('Voir les statistiques'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    gp.abandonGame();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.home),
                  label: const Text('Retour à l\'accueil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
