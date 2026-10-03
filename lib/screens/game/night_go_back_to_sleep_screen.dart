import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';

/// Écran de transition générique affiché après qu'un rôle (ou un petit
/// groupe de rôles liés, comme les Loups et leurs sous-phases) a terminé
/// son action de nuit.
///
/// Volontairement neutre : il ne mentionne ni nom ni rôle, pour ne rien
/// laisser filtrer à qui que ce soit qui regarderait par-dessus l'épaule.
/// Il donne juste un point de fermeture clair avant que le téléphone ne
/// parte vers le rôle suivant — lequel reste de toute façon protégé par
/// son propre [PassDeviceGate].
class NightGoBackToSleepScreen extends StatelessWidget {
  const NightGoBackToSleepScreen({super.key});

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
                child: ElevatedButton(
                  onPressed: gp.advanceGeneric,
                  child: Text(loc.continueButtonLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}