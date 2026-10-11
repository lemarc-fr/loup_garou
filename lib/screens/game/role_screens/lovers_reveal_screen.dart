import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/player.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

/// Révélation des Amoureux, juste après le tour de Cupidon.
///
/// Le téléphone passe chez TOUS les joueurs, un par un, appelés par leur
/// prénom : les deux Amoureux apprennent qui est leur moitié, les autres
/// reçoivent un écran sans message. Comme pour la perte des pouvoirs (voir
/// VillagePowerLossScreen), si le téléphone n'allait que chez les deux
/// Amoureux, toute la table saurait qui ils sont ; et les deux écrans ont
/// la même structure (même titre, même icône, même bouton) pour ne rien
/// laisser deviner par-dessus l'épaule.
class LoversRevealScreen extends StatefulWidget {
  const LoversRevealScreen({super.key});

  @override
  State<LoversRevealScreen> createState() => _LoversRevealScreenState();
}

class _LoversRevealScreenState extends State<LoversRevealScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final players = state.alivePlayers;
    final loc = AppLocalizations.of(context)!;

    // Filet de sécurité : ne devrait pas arriver, le moteur passe à la
    // phase suivante dès que le dernier joueur a validé.
    if (_index >= players.length) return const SizedBox.shrink();

    final player = players[_index];
    final isLast = _index == players.length - 1;

    return PassDeviceGate(
      // Une clé différente à chaque joueur : force une nouvelle
      // confirmation "c'est moi qui ai le téléphone" à chaque passage.
      key: ValueKey('lovers-${player.id}'),
      toName: player.name,
      subtitle: loc.loversRevealPassSubtitle,
      accent: RoleId.cupidon.info.accent,
      contentBuilder: (_) => _LoversRevealPrivateScreen(
        index: _index,
        total: players.length,
        lover: state.tryById(player.loverId),
        onContinue: () {
          if (isLast) {
            gp.confirmLoversReveal();
          } else {
            setState(() => _index++);
          }
        },
      ),
    );
  }
}

/// Écran privé montré à UN SEUL joueur. [lover] non-null : ce joueur est
/// Amoureux de [lover] ; null : rien à lui dire, mais la structure de
/// l'écran reste identique.
class _LoversRevealPrivateScreen extends StatelessWidget {
  final int index;
  final int total;
  final Player? lover;
  final VoidCallback onContinue;

  const _LoversRevealPrivateScreen({
    required this.index,
    required this.total,
    required this.lover,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final accent = RoleId.cupidon.info.accent;
    final lover = this.lover;

    return RoleScreenFrame(
      title: loc.loversRevealTitle,
      accent: accent,
      child: Column(
        children: [
          LinearProgressIndicator(value: (index + 1) / total),
          const SizedBox(height: 8),
          Text(loc.roleRevealPlayerProgress(index + 1, total),
              style: theme.textTheme.bodyMedium),
          const Spacer(),
          Icon(Icons.mark_email_unread_outlined,
              size: 72, color: context.readableIcon(accent)),
          const SizedBox(height: 20),
          RoleSectionCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  lover != null
                      ? loc.loversRevealLoverHeadline
                      : loc.loversRevealNothingHeadline,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                if (lover != null) ...[
                  Text(
                    loc.loverBondMessage(lover.name),
                    style: theme.textTheme.titleLarge
                        ?.copyWith(color: context.readable(accent)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.loverBondRule,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ] else
                  Text(
                    loc.loversRevealNothingBody,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              child: Text(loc.loversRevealDoneButton),
            ),
          ),
        ],
      ),
    );
  }
}
