import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class CorbeauScreen extends StatelessWidget {
  const CorbeauScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.corbeau.info.name,
      pluralToName: false,
      subtitle: loc.corbeauSubtitle,
      accent: AppColors.blood,
      contentBuilder: (_) => const _CorbeauContent(),
    );
  }
}

class _CorbeauContent extends StatelessWidget {
  const _CorbeauContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;

    return RoleScreenFrame(
      title: loc.corbeauTitle,
      accent: AppColors.blood,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.corbeauInstruction,
            accent: AppColors.blood,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  onSelect: (id) => gp.setCorbeauVictim(id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}