import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class RenardScreen extends StatelessWidget {
  const RenardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.renard.info.name,
      subtitle: loc.renardSubtitle,
      accent: RoleId.renard.info.accent,
      contentBuilder: (_) => const _RenardContent(),
    );
  }
}

class _RenardContent extends StatefulWidget {
  const _RenardContent();
  @override
  State<_RenardContent> createState() => _RenardContentState();
}

class _RenardContentState extends State<_RenardContent> {
  String? centerId;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final accent = RoleId.renard.info.accent;

    // Étape 2 : résultat du flair, annoncé au Renard.
    if (centerId != null) {
      final trioIds = state.renardTrioAround(centerId!);
      final trio = trioIds.map(state.byId).toList();
      final foundWolf = state.renardTrioHasWolf(trioIds);

      return RoleScreenFrame(
        title: loc.renardTitle,
        accent: accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoleInstructionCard(
              text: foundWolf
                  ? loc.renardResultWolfFound
                  : loc.renardResultNoWolf,
              accent: foundWolf ? AppColors.blood : AppColors.forest,
            ),
            const SizedBox(height: 20),
            RoleSectionCard(
              child: Column(
                children: [
                  Text(loc.renardResultTrioLabel,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      for (final p in trio)
                        Chip(
                          label: Text(p.name),
                          side: BorderSide(
                              color: foundWolf
                                  ? AppColors.blood
                                  : AppColors.forest),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            ElevatedButton(
              // C'est ici que le moteur applique la conséquence (pouvoir
              // conservé ou perdu) et passe à la phase suivante.
              onPressed: () => gp.setRenardTarget(centerId!),
              child: Text(loc.goBackToSleepButton),
            ),
          ],
        ),
      );
    }

    // Étape 1 : choix du joueur central.
    return RoleScreenFrame(
      title: loc.renardTitle,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.renardInstructionCenter,
            accent: accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: state.alivePlayers,
                  onSelect: (id) => setState(() => centerId = id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}