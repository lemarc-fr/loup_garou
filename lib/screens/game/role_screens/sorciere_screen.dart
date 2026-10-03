import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

class SorciereScreen extends StatelessWidget {
  const SorciereScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return PassDeviceGate(
      toName: RoleId.sorciere.info.name,
      subtitle: loc.sorciereSubtitle,
      accent: RoleId.sorciere.info.accent,
      contentBuilder: (_) => const _SorciereContent(),
    );
  }
}

class _SorciereContent extends StatefulWidget {
  const _SorciereContent();
  @override
  State<_SorciereContent> createState() => _SorciereContentState();
}

class _SorciereContentState extends State<_SorciereContent> {
  bool saveVictim = false;
  bool poisoning = false;
  String? poisonTargetId;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    final sorciereId = state.alivePlayersWithRole(RoleId.sorciere).first.id;
    final victim = state.tryById(state.finalNightVictimId);
    final victimIsSorciere = victim?.id == sorciereId;
    final selfSaveBlocked =
        victimIsSorciere && !state.settings.allowWitchToSaveHerself;
    final canSave = !state.sorciereVieUsed && victim != null && !selfSaveBlocked;
    final canPoison = !state.sorciereMortUsed;
    final poisonTargets =
        state.alivePlayers.where((p) => p.id != sorciereId).toList();

    return RoleScreenFrame(
      title: loc.sorciereTitle,
      accent: RoleId.sorciere.info.accent,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoleInstructionCard(
              text: victim != null
                  ? loc.sorciereInstructionWithVictim(victim.name)
                  : loc.sorciereInstructionNoVictim,
              accent: RoleId.sorciere.info.accent,
            ),
            const SizedBox(height: 14),
            RoleSectionCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (canSave)
                    SwitchListTile(
                      value: saveVictim,
                      onChanged: (v) => setState(() => saveVictim = v),
                      title: Text(
                        loc.sorciereUseLifePotion(victim.name),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        state.sorciereVieUsed
                            ? loc.sorciereLifePotionAlreadyUsed
                            : selfSaveBlocked
                                ? loc.sorciereSelfSaveBlocked
                                : loc.sorciereNoVictimToSave,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const Divider(height: 28),
                  if (canPoison) ...[
                    SwitchListTile(
                      value: poisoning,
                      onChanged: (v) => setState(() {
                        poisoning = v;
                        if (!v) poisonTargetId = null;
                      }),
                      title: Text(loc.sorciereUseDeathPotion),
                    ),
                    if (poisoning) ...[
                      const SizedBox(height: 8),
                      Text(
                        loc.sorciereChooseDeathPotionTarget,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      PlayerGridSelector(
                        players: poisonTargets,
                        selectedId: poisonTargetId,
                        onSelect: (id) => setState(() => poisonTargetId = id),
                      ),
                    ],
                  ] else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        loc.sorciereDeathPotionAlreadyUsed,
                        style: theme.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => gp.resolveSorciere(
                useVie: saveVictim,
                poisonTargetId: poisoning ? poisonTargetId : null,
              ),
              child: Text(loc.confirmAndGoBackToSleepButton),
            ),
          ],
        ),
      ),
    );
  }
}
