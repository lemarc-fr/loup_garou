import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/vote_mode_chooser.dart';

class MayorElectionExplainScreen extends StatefulWidget {
  const MayorElectionExplainScreen({super.key});

  @override
  State<MayorElectionExplainScreen> createState() => _MayorElectionExplainScreenState();
}

class _MayorElectionExplainScreenState extends State<MayorElectionExplainScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      color: AppColors.lantern,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/images/roles/mayor_insign.png',
                        width: 96, height: 96),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  loc.mayorElectionExplainText,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  loc.mayorElectionDoubleVoiceExplain,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Sous l'insigne : le choix du mode de vote lance l'élection.
                VoteModeChooser(onChosen: gp.confirmMayorElectionExplain),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
