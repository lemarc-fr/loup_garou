import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

class InfectPereDesLoupsScreen extends StatelessWidget {
  const InfectPereDesLoupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.infectPereDesLoups.info.name,
      subtitle: loc.infectPereDesLoupsSubtitle,
      accent: RoleId.infectPereDesLoups.info.accent,
      contentBuilder: (_) => const _InfectPereDesLoupsContent(),
    );
  }
}

class _InfectPereDesLoupsContent extends StatelessWidget {
  const _InfectPereDesLoupsContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final victim = state.tryById(state.loupsVictimId);
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.infectPereDesLoupsTitle,
      accent: RoleId.infectPereDesLoups.info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: victim != null
                ? loc.infectPereDesLoupsInstructionWithVictim(victim.name)
                : loc.infectPereDesLoupsInstructionNoVictim,
            accent: RoleId.infectPereDesLoups.info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: victim == null
                        ? null
                        : () => gp.setInfectPereDesLoups(true),
                    child: Text(loc.infectPereDesLoupsInfectButton),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => gp.setInfectPereDesLoups(false),
                    child: Text(loc.infectPereDesLoupsDoNotInfectButton),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}