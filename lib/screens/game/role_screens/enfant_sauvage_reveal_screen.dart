import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';
import 'package:thiercelieux/l10n/upcoming_step_localizations.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/role_image.dart';

/// Annonce PUBLIQUE de la mutation de l'Enfant Sauvage (option
/// "Mutation de l'Enfant Sauvage annoncée à tous") : son modèle vient de
/// mourir, il rejoint la meute. Toute la table regarde l'écran : on montre
/// la transformation (Enfant Sauvage → Loup-Garou) sans jamais nommer le
/// joueur concerné, dont l'identité reste secrète.
class EnfantSauvageRevealScreen extends StatefulWidget {
  const EnfantSauvageRevealScreen({super.key});

  @override
  State<EnfantSauvageRevealScreen> createState() =>
      _EnfantSauvageRevealScreenState();
}

class _EnfantSauvageRevealScreenState extends State<EnfantSauvageRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // L'Enfant Sauvage s'efface, puis la flèche et le Loup-Garou apparaissent.
  late final Animation<double> _childFade;
  late final Animation<double> _arrow;
  late final Animation<double> _wolfScale;
  late final Animation<double> _text;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _childFade = Tween<double>(begin: 1, end: 0.45).animate(CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.45, curve: Curves.easeOut)));
    _arrow = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5, curve: Curves.easeOut));
    _wolfScale = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.85, curve: Curves.elasticOut));
    _text = CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final wolfColor = context.readable(AppColors.blood);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Text(
                loc.enfantSauvageRevealOverline.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 1.6,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _LabelledRole(
                    role: RoleId.enfantSauvage,
                    label: loc.roleShortName(RoleId.enfantSauvage),
                    opacity: _childFade,
                  ),
                  FadeTransition(
                    opacity: _arrow,
                    child: SlideTransition(
                      position: Tween(
                              begin: const Offset(-0.4, 0), end: Offset.zero)
                          .animate(_arrow),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(Icons.arrow_forward_rounded,
                            size: 36, color: wolfColor),
                      ),
                    ),
                  ),
                  ScaleTransition(
                    scale: _wolfScale,
                    child: _LabelledRole(
                      role: RoleId.loupGarou,
                      label: loc.roleShortName(RoleId.loupGarou),
                      labelColor: wolfColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              FadeTransition(
                opacity: _text,
                child: Column(
                  children: [
                    Text(
                      loc.enfantSauvageRevealTitle,
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      loc.enfantSauvageRevealBody,
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmEnfantSauvageReveal,
                  child: Text(loc.upcomingStepButton(gp.upcomingStep())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabelledRole extends StatelessWidget {
  final RoleId role;
  final String label;
  final Color? labelColor;
  final Animation<double>? opacity;

  const _LabelledRole({
    required this.role,
    required this.label,
    this.labelColor,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final fade = opacity;
    final image = RoleImage(role: role, size: 96);
    return SizedBox(
      width: 110,
      child: Column(
        children: [
          // Seule l'illustration s'efface : le nom reste lisible.
          fade == null ? image : FadeTransition(opacity: fade, child: image),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: labelColor, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
