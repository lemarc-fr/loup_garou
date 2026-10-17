import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../services/narration_timing.dart';
import '../../theme/app_theme.dart';
import '../../widgets/countdown_button.dart';
import '../../widgets/narration_host.dart';

/// Écran de transition générique affiché après qu'un rôle (ou un petit
/// groupe de rôles liés, comme les Loups et leurs sous-phases) a terminé
/// son action de nuit.
///
/// Volontairement neutre : il ne mentionne ni nom ni rôle, pour ne rien
/// laisser filtrer à qui que ce soit qui regarderait par-dessus l'épaule.
/// Il donne juste un point de fermeture clair avant que le téléphone ne
/// parte vers le rôle suivant — lequel reste de toute façon protégé par
/// son propre [PassDeviceGate].
///
/// Le bouton se valide tout seul une fois la phrase du narrateur (« la
/// Voyante se rendort ») terminée : personne n'a besoin de rouvrir les yeux
/// pour passer au rôle suivant.
class NightGoBackToSleepScreen extends StatefulWidget {
  const NightGoBackToSleepScreen({super.key});

  /// Sans phrase à dire (deux écrans d'affilée, voix d'un rôle sans
  /// fichier...), on laisse quand même le temps de reposer le téléphone.
  static const minCountdown = Duration(milliseconds: 1500);

  @override
  State<NightGoBackToSleepScreen> createState() =>
      _NightGoBackToSleepScreenState();
}

class _NightGoBackToSleepScreenState extends State<NightGoBackToSleepScreen> {
  Duration? _countdown;
  bool _timing = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_timing) return;
    _timing = true;
    // La phrase annoncée pour cet écran, dans la langue de l'app.
    final actions = CurrentNarration.of(context) ?? const [];
    final language = AppLocalizations.of(context)!.localeName;
    NarrationTiming.of(actions, language).then((duration) {
      if (!mounted) return;
      setState(() => _countdown = duration < NightGoBackToSleepScreen.minCountdown
          ? NightGoBackToSleepScreen.minCountdown
          : duration);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bedtime, size: 72, color: AppColors.lantern),
              const SizedBox(height: 28),
              Text(
                loc.nightGoBackToSleepTitle,
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                loc.nightGoBackToSleepInstruction,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: CountdownButton(
                  label: loc.continueButtonLabel,
                  duration: _countdown,
                  onPressed: gp.advanceGeneric,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
