import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/player_grid_selector.dart';
import 'role_screen_chrome.dart';

/// Le Bouc Émissaire vient d'être éliminé à la place des ex aequo (voir
/// GameEngine.resolveVillageVoteTie). Avant de mourir, il désigne
/// publiquement les seuls joueurs qui pourront voter le lendemain.
class BoucEmissaireScreen extends StatefulWidget {
  const BoucEmissaireScreen({super.key});

  @override
  State<BoucEmissaireScreen> createState() => _BoucEmissaireScreenState();
}

class _BoucEmissaireScreenState extends State<BoucEmissaireScreen> {
  /// Tout le monde peut voter, au départ : il retire ceux qu'il soupçonne.
  late final Set<String> _allowed = {
    for (final p in context.read<GameProvider>().state!.alivePlayers) p.id,
  };

  void _toggle(String id) => setState(() {
        if (!_allowed.remove(id)) _allowed.add(id);
      });

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final loc = AppLocalizations.of(context)!;
    final accent = RoleId.boucEmissaire.info.accent;

    return RoleScreenFrame(
      title: loc.boucEmissaireTitle,
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoleInstructionCard(
            text: loc.boucEmissaireVotersInstruction,
            accent: accent,
          ),
          const SizedBox(height: 14),
          Expanded(
            child: RoleSectionCard(
              child: SingleChildScrollView(
                child: PlayerGridSelector(
                  players: gp.state!.alivePlayers,
                  highlightedIds: _allowed,
                  onSelect: _toggle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            // Il faut au moins un votant pour le vote du lendemain.
            onPressed: _allowed.isEmpty
                ? null
                : () => gp.setBoucEmissaireVoters({..._allowed}),
            child: Text(loc.boucEmissaireConfirmVoters(_allowed.length)),
          ),
        ],
      ),
    );
  }
}
