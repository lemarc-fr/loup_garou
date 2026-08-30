import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

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

    return RoleScreenFrame(
      title: 'Mutation',
      accent: AppColors.blood,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const RoleInstructionCard(
            text:
                'Son modèle est mort : l’Enfant Sauvage rejoint désormais la meute.',
            accent: AppColors.blood,
          ),
          const SizedBox(height: 20),
          RoleSectionCard(
            child: Column(
              children: [
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
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: gp.confirmEnfantSauvageReveal,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}