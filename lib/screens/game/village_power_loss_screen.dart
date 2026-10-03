import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pass_device_gate.dart';
import '../../widgets/role_image.dart';

/// Le village a fait pendre l'Ancien par erreur : tous les villageois à
/// pouvoir perdent leur don pour le reste de la partie.
///
/// Cette information doit rester SECRÈTE : dans la partie physique,
/// personne d'autre que le joueur concerné n'apprend qu'il a perdu son
/// pouvoir, ni lequel c'était.
///
/// Un premier correctif avait fait défiler le téléphone en privé
/// uniquement vers les joueurs réellement touchés (`powerLossThisWave`).
/// Mais ça fuit quand même : le simple fait que le téléphone ne passe
/// QUE chez certains joueurs — en sautant les autres — suffit à toute la
/// table pour deviner qui a un pouvoir et qui n'en a jamais eu, sans même
/// avoir besoin de regarder l'écran. Pour que la procédure ne révèle
/// rien, TOUS les joueurs vivants doivent passer par le même rituel
/// (même écran, même bouton, même déroulé) : ceux qui perdent vraiment un
/// pouvoir voient leur ancien rôle, les autres reçoivent un don fictif et
/// totalement inutile — mais personne à l'extérieur ne peut faire la
/// différence entre les deux passages.
class VillagePowerLossScreen extends StatefulWidget {
  const VillagePowerLossScreen({super.key});

  @override
  State<VillagePowerLossScreen> createState() =>
      _VillagePowerLossScreenState();
}

class _VillagePowerLossScreenState extends State<VillagePowerLossScreen> {
  // Index dans la liste de TOUS les joueurs vivants (pas seulement ceux
  // qui ont réellement perdu un pouvoir) du prochain joueur à faire
  // passer en privé.
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final players = state.alivePlayers;
    final loc = AppLocalizations.of(context)!;

    // Rôle perdu pour ce joueur, si (et seulement si) il fait
    // effectivement partie des victimes de la perte de pouvoirs.
    final lostRoleByPlayerId = <String, RoleId>{
      for (final e in state.powerLossThisWave) e.playerId: e.previousRole,
    };

    if (_index < players.length) {
      final player = players[_index];
      final lostRole = lostRoleByPlayerId[player.id];

      return PassDeviceGate(
        // Une clé différente à chaque joueur : force une nouvelle
        // confirmation "c'est moi qui ai le téléphone" à chaque tour.
        key: ValueKey('power-loss-${player.id}'),
        toName: player.name,
        subtitle: loc.powerLossPrivatePassSubtitle,
        accent: AppColors.blood,
        contentBuilder: (_) => _PowerLossPrivateScreen(
          index: _index,
          total: players.length,
          lostRole: lostRole,
          onContinue: () => setState(() => _index++),
        ),
      );
    }

    // Tout le monde est passé par le même rituel : on peut informer la
    // table, sans citer aucun nom ni aucun rôle.
    return _PublicPowerLossAnnouncement(
      onContinue: gp.confirmPowerLossReveal,
    );
  }
}

/// Écran privé montré à UN SEUL joueur à la fois. [lostRole] non-null
/// signifie que ce joueur a réellement perdu ce pouvoir ; null signifie
/// qu'il ne se passe rien pour lui, mais on lui montre quand même un
/// "don" — fictif et inutile — pour que la structure de l'écran (titre,
/// image, texte, bouton) soit rigoureusement identique dans les deux cas.
class _PowerLossPrivateScreen extends StatelessWidget {
  final int index;
  final int total;
  final RoleId? lostRole;
  final VoidCallback onContinue;

  const _PowerLossPrivateScreen({
    required this.index,
    required this.total,
    required this.lostRole,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reallyLost = lostRole != null;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.powerLossTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (index + 1) / total,
                backgroundColor: AppColors.nightAlt,
              ),
              const SizedBox(height: 8),
              Text(loc.powerLossPlayerCount(index + 1, total),
                  style: theme.textTheme.bodyMedium),
              const Spacer(),
              const Icon(Icons.auto_awesome_outlined,
                  size: 56, color: AppColors.blood),
              const SizedBox(height: 16),
              Text(
                loc.powerLossAncienHangedHeadline,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (reallyLost) ...[
                Text(
                  loc.powerLossReallyLostNotice,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                RoleImage(role: lostRole!, size: 96),
                const SizedBox(height: 12),
                Text(
                  lostRole!.info.name,
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: lostRole!.info.accent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.powerLossNowSimpleVillageois,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  loc.powerLossFakeGiftNotice,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Icon(Icons.bedtime,
                    size: 96, color: AppColors.moonlight.withValues(alpha: 0.6)),
                const SizedBox(height: 12),
                Text(
                  loc.powerLossFakeGiftName,
                  style: theme.textTheme.displayMedium
                      ?.copyWith(color: AppColors.moonlight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  loc.powerLossFakeGiftUseless,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.blood.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  loc.powerLossKeepSecretWarning,
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: Text(loc.powerLossUnderstoodButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vu par toute la table : volontairement neutre, aucun nom ni rôle n'y
/// figure.
class _PublicPowerLossAnnouncement extends StatelessWidget {
  final VoidCallback onContinue;
  const _PublicPowerLossAnnouncement({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.powerLossTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 64, color: AppColors.blood),
              const SizedBox(height: 20),
              Text(
                loc.powerLossAncienHangedHeadline,
                style: theme.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                loc.powerLossPublicExplanation,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onContinue,
                  child: Text(loc.powerLossNightFallsAgainButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}