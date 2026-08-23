import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pass_device_gate.dart';
import '../../widgets/role_image.dart';

class RoleRevealScreen extends StatelessWidget {
  const RoleRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final player = state.players[gp.revealIndex];

    return PassDeviceGate(
      key: ValueKey('reveal-${player.id}'),
      toName: player.name,
      subtitle:
          'Ton rôle va s\'afficher. Assure-toi que personne d\'autre ne regarde l\'écran.',
      contentBuilder: (_) => _RevealContent(
        playerIndex: gp.revealIndex,
        totalPlayers: state.players.length,
      ),
    );
  }
}

class _RevealContent extends StatelessWidget {
  final int playerIndex;
  final int totalPlayers;
  const _RevealContent({required this.playerIndex, required this.totalPlayers});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final player = gp.state!.players[playerIndex];
    final theme = Theme.of(context);
    final info = player.role;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (playerIndex + 1) / totalPlayers,
                backgroundColor: AppColors.nightAlt,
              ),
              const SizedBox(height: 8),
              Text('Joueur ${playerIndex + 1} / $totalPlayers',
                  style: theme.textTheme.bodyMedium),
              const Spacer(),
              if (!gp.revealCardVisible) ...[
                Text(player.name,
                    style: theme.textTheme.displayMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                const Icon(Icons.touch_app, size: 56, color: AppColors.lantern),
                const SizedBox(height: 16),
                Text('Appuie pour découvrir ton rôle',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center),
                const SizedBox(height: 32),
                ElevatedButton(
                    onPressed: gp.showRevealCard,
                    child: const Text('Révéler mon rôle')),
              ] else ...[
                RoleImage(role: player.role, size: 140),
                const SizedBox(height: 20),
                Text(info.name,
                    style: theme.textTheme.displayMedium
                        ?.copyWith(color: info.accent),
                    textAlign: TextAlign.center),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: info.accent.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info.camp.name == 'loups'
                        ? 'Camp des Loups-Garous'
                        : 'Camp des Villageois',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: info.accent),
                  ),
                ),
                const SizedBox(height: 20),
                Text(info.description,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center),
              ],
              const Spacer(),
              if (gp.revealCardVisible)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: gp.confirmRevealSeen,
                    icon: const Icon(Icons.visibility_off),
                    label: const Text("J'ai vu, masquer mon rôle"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
