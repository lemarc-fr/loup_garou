import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

class VoyanteScreen extends StatelessWidget {
  const VoyanteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.voyante.info.name,
      subtitle: loc.voyanteSubtitle,
      accent: RoleId.voyante.info.accent,
      contentBuilder: (_) => const _VoyanteContent(),
    );
  }
}

class _VoyanteContent extends StatefulWidget {
  const _VoyanteContent();
  @override
  State<_VoyanteContent> createState() => _VoyanteContentState();
}

class _VoyanteContentState extends State<_VoyanteContent> {
  String? targetId;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    if (targetId != null) {
      final target = state.byId(targetId!);
      final info = target.role.info;
      return RoleScreenFrame(
        title: loc.voyanteTitle,
        accent: RoleId.voyante.info.accent,
        child: Column(
          children: [
            RoleInstructionCard(
              text: loc.voyanteObservedTargetInstruction(target.name),
              accent: RoleId.voyante.info.accent,
            ),
            const SizedBox(height: 20),
            RoleSectionCard(
              child: Column(
                children: [
                  RoleImage(role: target.role, size: 120),
                  const SizedBox(height: 16),
                  Text(
                    target.name,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    info.name,
                    style: theme.textTheme.displayMedium
                        ?.copyWith(color: info.accent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: gp.confirmVoyanteDone,
                child: Text(loc.voyanteDoneButton),
              ),
            ),
          ],
        ),
      );
    }

    return RoleScreenFrame(
      title: loc.voyanteTitle,
      accent: RoleId.voyante.info.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.voyanteChooseTargetInstruction,
            accent: RoleId.voyante.info.accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: state.alivePlayers,
                  onSelect: (id) => setState(() => targetId = id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
