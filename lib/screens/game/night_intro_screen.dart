import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';

class NightIntroScreen extends StatelessWidget {
  const NightIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final night = gp.state!.night;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.dark_mode, size: 72, color: AppColors.lantern),
              const SizedBox(height: 28),
              Text(
                night == 1
                    ? loc.nightIntroFirstNight
                    : loc.nightIntroOtherNights(night),
                style: theme.textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                loc.nightIntroSleepInstruction,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: gp.advanceGeneric,
                  child: Text(loc.nightIntroEveryoneAsleepButton)),
            ],
          ),
        ),
      ),
    );
  }
}
