import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/role_image.dart';

class EnfantSauvageRevealScreen extends StatefulWidget {
  const EnfantSauvageRevealScreen({super.key});

  @override
  State<EnfantSauvageRevealScreen> createState() =>
      _EnfantSauvageRevealScreenState();
}

class _EnfantSauvageRevealScreenState extends State<EnfantSauvageRevealScreen>
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

    return Scaffold(
      appBar: AppBar(title: const Text('Mutation')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Son modèle est mort : L\'enfant sauvage n\'est plus un enfant, '
                    'il/elle devient...',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ScaleTransition(
                scale: _scale,
                child: const RoleImage(role: RoleId.loupGarou, size: 120),
              ),
              const SizedBox(height: 16),
              Text(
                RoleId.loupGarou.info.name,
                style: theme.textTheme.displayMedium
                    ?.copyWith(color: AppColors.blood),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmEnfantSauvageReveal,
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