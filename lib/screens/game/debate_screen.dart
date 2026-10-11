import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/vote_mode_chooser.dart';

class DebateScreen extends StatelessWidget {
  const DebateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.debateTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.forum,
                    size: 72, color: context.readableIcon(AppColors.forest)),
                const SizedBox(height: 24),
                Text(
                  loc.debateVillageDebates,
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.debateInstruction,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Le débat se termine par le choix du mode de vote du village.
                VoteModeChooser(onChosen: gp.confirmDebate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
