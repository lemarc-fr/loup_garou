import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class SalvateurScreen extends StatelessWidget {
  const SalvateurScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.salvateur.info.name,
      subtitle: loc.salvateurSubtitle,
      accent: RoleId.salvateur.info.accent,
      contentBuilder: (_) => const _SalvateurContent(),
    );
  }
}

class _SalvateurContent extends StatelessWidget {
  const _SalvateurContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.salvateurTitle,
      accent: RoleId.salvateur.info.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.salvateurInstruction,
            accent: RoleId.salvateur.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setSalvateurTarget(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}