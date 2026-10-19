import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';

import '../../../models/game_state.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/countdown_button.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

/// « Faux tour » (voir GameState.isFakeTurn) : un rôle qui n'a plus rien à
/// faire est quand même appelé, comme le ferait un vrai meneur. Le
/// téléphone lui est passé exactement comme d'habitude (même écran « passe
/// le téléphone à... »), puis il garde les yeux ouverts quelques secondes
/// avant que la nuit continue toute seule : vu de la table, rien ne le
/// distingue d'un vrai tour.
class FakeTurnScreen extends StatelessWidget {
  final GamePhase phase;

  const FakeTurnScreen({super.key, required this.phase});

  /// Durée d'un faux tour, tirée au hasard pour ne pas sonner faux.
  static const minDuration = Duration(seconds: 5);
  static const maxDuration = Duration(seconds: 9);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final role = _role(phase);
    // Mêmes textes et mêmes couleurs que l'écran du vrai tour.
    final (subtitle, accent) = switch (phase) {
      GamePhase.nightSorciere => (loc.sorciereSubtitle, role.info.accent),
      GamePhase.nightRenard => (loc.renardSubtitle, role.info.accent),
      GamePhase.nightInfectPereDesLoups =>
        (loc.infectPereDesLoupsSubtitle, role.info.accent),
      GamePhase.nightGrandMechantLoup =>
        (loc.grandMechantLoupSubtitle, AppColors.blood),
      _ => (null, role.info.accent),
    };
    return PassDeviceGate(
      toName: loc.roleName(role),
      subtitle: subtitle,
      accent: accent,
      contentBuilder: (_) => _FakeTurnContent(phase: phase, role: role),
    );
  }

  static RoleId _role(GamePhase phase) => switch (phase) {
        GamePhase.nightSorciere => RoleId.sorciere,
        GamePhase.nightRenard => RoleId.renard,
        GamePhase.nightInfectPereDesLoups => RoleId.infectPereDesLoups,
        GamePhase.nightGrandMechantLoup => RoleId.grandMechantLoup,
        _ => throw ArgumentError('Pas de faux tour pour $phase'),
      };
}

class _FakeTurnContent extends StatefulWidget {
  final GamePhase phase;
  final RoleId role;

  const _FakeTurnContent({required this.phase, required this.role});

  @override
  State<_FakeTurnContent> createState() => _FakeTurnContentState();
}

class _FakeTurnContentState extends State<_FakeTurnContent> {
  late final Duration _duration = Duration(
      milliseconds: FakeTurnScreen.minDuration.inMilliseconds +
          Random().nextInt(FakeTurnScreen.maxDuration.inMilliseconds -
              FakeTurnScreen.minDuration.inMilliseconds));

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final accent = widget.role.info.accent;

    final reason = switch (widget.phase) {
      GamePhase.nightSorciere => state.sorciereVieUsed && state.sorciereMortUsed
          ? loc.fakeTurnSorciereNoPotion
          : loc.fakeTurnSorciereCannotPlay,
      GamePhase.nightRenard => loc.fakeTurnRenard,
      GamePhase.nightInfectPereDesLoups => loc.fakeTurnInfectPereDesLoups,
      _ => loc.fakeTurnGrandMechantLoup,
    };

    return RoleScreenFrame(
      title: loc.roleName(widget.role),
      accent: accent,
      child: Column(
        children: [
          const Spacer(),
          RoleImage(role: widget.role, size: 120),
          const SizedBox(height: 24),
          Text(reason,
              style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          RoleInstructionCard(text: loc.fakeTurnInstruction, accent: accent),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: CountdownButton(
              label: loc.fakeTurnWaitButton,
              duration: _duration,
              waitForEnd: true,
              onPressed: gp.confirmFakeTurn,
            ),
          ),
        ],
      ),
    );
  }
}
