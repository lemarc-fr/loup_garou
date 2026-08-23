import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';

class PlayerCountScreen extends StatefulWidget {
  const PlayerCountScreen({super.key});

  @override
  State<PlayerCountScreen> createState() => _PlayerCountScreenState();
}

class _PlayerCountScreenState extends State<PlayerCountScreen> {
  late int _count;

  @override
  void initState() {
    super.initState();
    final gp = context.read<GameProvider>();
    _count = gp.draftPlayerCount;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gp = context.read<GameProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nouvelle partie')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text('Combien de joueurs ?',
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'De 5 à 24 joueurs autour de la table.',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.moonlight.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed:
                        _count > 5 ? () => setState(() => _count--) : null,
                    icon: const Icon(Icons.remove),
                    iconSize: 28,
                  ),
                  Container(
                    width: 110,
                    alignment: Alignment.center,
                    child: Text('$_count', style: theme.textTheme.displayLarge),
                  ),
                  IconButton.filledTonal(
                    onPressed:
                        _count < 24 ? () => setState(() => _count++) : null,
                    icon: const Icon(Icons.add),
                    iconSize: 28,
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    gp.setDraftPlayerCount(_count);
                    gp.goToRoleSelection();
                  },
                  child: const Text('Continuer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
