import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pass_device_gate.dart';
import '../../widgets/role_image.dart';
import '../../models/role.dart';

class RoleRevealScreen extends StatelessWidget {
  const RoleRevealScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final player = state.players[gp.revealIndex];
    final loc = AppLocalizations.of(context)!;

    return PassDeviceGate(
      key: ValueKey('reveal-${player.id}'),
      toName: player.name,
      subtitle: loc.roleRevealSubtitle,
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
    final info = player.role.info;
    final loc = AppLocalizations.of(context)!;
    final lover = gp.state!.tryById(player.loverId);

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
              Text(loc.roleRevealPlayerProgress(playerIndex + 1, totalPlayers),
                  style: theme.textTheme.bodyMedium),
              // Défilable : avec la bannière des Amoureux, la carte peut
              // dépasser la hauteur des petits écrans.
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!gp.revealCardVisible) ...[
                          Text(player.name,
                              style: theme.textTheme.displayMedium,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 24),
                          const Icon(Icons.touch_app, size: 56, color: AppColors.lantern),
                          const SizedBox(height: 16),
                          Text(loc.roleRevealTapToDiscover,
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 32),
                          ElevatedButton(
                              onPressed: gp.showRevealCard,
                              child: Text(loc.roleRevealRevealButton)),
                        ] else ...[
                          RoleImage(role: player.role, size: 140),
                          const SizedBox(height: 20),
                          Text(loc.roleName(player.role),
                              style: theme.textTheme.displayMedium
                                  ?.copyWith(color: context.readable(info.accent)),
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
                              loc.campLabel(info.camp),
                              style: theme.textTheme.labelLarge
                                  ?.copyWith(color: context.readable(info.accent)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(loc.roleDescription(player.role),
                              style: theme.textTheme.bodyLarge,
                              textAlign: TextAlign.center),
                          // Amoureux tirés au sort : ils l'apprennent ici.
                          if (lover != null) ...[
                            const SizedBox(height: 20),
                            _LoverBanner(loverName: lover.name),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (gp.revealCardVisible)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: gp.confirmRevealSeen,
                    icon: const Icon(Icons.visibility_off),
                    label: Text(loc.roleRevealHideButton),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoverBanner extends StatelessWidget {
  final String loverName;
  const _LoverBanner({required this.loverName});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final accent = RoleId.cupidon.info.accent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.readableIcon(accent)),
      ),
      child: Column(
        children: [
          Icon(Icons.favorite, color: context.readableIcon(accent)),
          const SizedBox(height: 8),
          Text(loc.loverBondMessage(loverName),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(loc.loverBondRule,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
