import 'package:flutter/material.dart';
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

    return PassDeviceGate(
      toName: "La Sorcière",
      subtitle: 'C\'est le tour de la Sorcière. Réveille-toi.',
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
      title: 'La Sorcière',
      accent: RoleId.sorciere.info.accent,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoleInstructionCard(
              text: victim != null
                  ? 'Cette nuit, les Loups-Garous ont désigné ${victim.name}.'
                  : 'Cette nuit, les Loups-Garous n’ont désigné personne.',
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
                        'Utiliser la potion de vie pour sauver ${victim.name}',
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        state.sorciereVieUsed
                            ? 'Potion de vie déjà utilisée.'
                            : selfSaveBlocked
                                ? 'Vous êtes vous-même la victime désignée, mais vous ne pouvez pas vous sauver vous-même.'
                                : 'Aucune victime à sauver cette nuit.',
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
                      title: const Text('Utiliser la potion de mort'),
                    ),
                    if (poisoning) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Choisissez la victime de la potion :',
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
                        'Potion de mort déjà utilisée.',
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
              child: const Text('Confirmer et se rendormir'),
            ),
          ],
        ),
      ),
    );
  }
}
