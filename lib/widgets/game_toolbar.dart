import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';

import '../screens/settings/game_settings_screen.dart';
import '../theme/app_theme.dart';
import 'game_progress_sheet.dart';
import 'game_roles_sheet.dart';

/// Barre d'outils affichée en haut à droite de chaque écran de partie (voir
/// GameMainScreen) : rôles de la partie, réglages, résumé.
///
/// Elle a sa propre bande en haut de l'écran ([height]) : les écrans de
/// partie sont décalés d'autant, pour qu'elle ne recouvre jamais leur
/// titre.
class GameToolbar extends StatelessWidget {
  const GameToolbar({super.key});

  /// Hauteur de la bande réservée à la barre, sous la barre d'état.
  static const height = 48.0;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: 6, right: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToolbarPill(
            tooltip: loc.gameRolesTooltip,
            onTap: () => showGameRolesSheet(context),
            child: const Icon(Icons.style, size: 20, color: AppColors.moonlight),
          ),
          const SizedBox(width: 6),
          ToolbarPill(
            tooltip: loc.gameSettingsTooltip,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const GameSettingsScreen(inGame: true))),
            child: const Icon(Icons.tune, size: 20, color: AppColors.moonlight),
          ),
          const SizedBox(width: 6),
          const GameProgressButton(),
        ],
      ),
    );
  }
}

/// Pastille "nuit" de la barre d'outils, lisible sur les deux thèmes.
class ToolbarPill extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final String? tooltip;

  const ToolbarPill(
      {super.key, required this.child, required this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final pill = Material(
      color: AppColors.nightAlt.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(20),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(widthFactor: 1, child: child),
          ),
        ),
      ),
    );
    return tooltip == null ? pill : Tooltip(message: tooltip, child: pill);
  }
}
