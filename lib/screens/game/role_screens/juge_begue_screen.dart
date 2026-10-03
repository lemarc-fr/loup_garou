import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

/// Le Juge Bègue ne désigne jamais un joueur : une fois par partie, il
/// décide en secret que le vote du village qui va suivre sera rejoué
/// immédiatement une fois terminé (voir GameEngine.resolveJugeBegueDecision
/// et le flag GameState.voteReplayPending).
class JugeBegueScreen extends StatelessWidget {
  const JugeBegueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.jugeBegue.info.name,
      subtitle: loc.jugeBegueSubtitle,
      accent: RoleId.jugeBegue.info.accent,
      contentBuilder: (_) => const _JugeBegueContent(),
    );
  }
}

class _JugeBegueContent extends StatelessWidget {
  const _JugeBegueContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final info = RoleId.jugeBegue.info;
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.jugeBegueTitle,
      accent: info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: loc.jugeBegueInstruction,
            accent: info.accent,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
                Icon(info.fallbackIcon, size: 64, color: info.accent),
                const SizedBox(height: 12),
                Text(
                  loc.jugeBegueQuestion,
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => gp.resolveJugeBegueDecision(true),
              child: Text(loc.usePowerButton),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.resolveJugeBegueDecision(false),
              child: Text(loc.doNotUsePowerButton),
            ),
          ),
        ],
      ),
    );
  }
}