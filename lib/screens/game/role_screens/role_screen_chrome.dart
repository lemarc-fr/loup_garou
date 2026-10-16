import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Fond des cartes posées sur un écran de rôle. Suit le thème courant :
/// ces écrans s'affichent la nuit (thème sombre) mais aussi le jour pour
/// les suites d'une mort (Chasseur, Servante, Bouc Émissaire...), en thème
/// parchemin — des couleurs "nuit" en dur y rendaient le texte illisible.
Color _cardColor(ThemeData theme, {double alpha = 0.9}) =>
    theme.brightness == Brightness.dark
        ? AppColors.nightAlt.withValues(alpha: alpha)
        : Colors.white.withValues(alpha: 0.6);

class RoleScreenFrame extends StatelessWidget {
  final String title;
  final Color accent;
  final Widget child;

  const RoleScreenFrame({
    super.key,
    required this.title,
    required this.accent,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(accent.withValues(alpha: 0.12), background),
              background,
              background,
            ],
            stops: const [0, 0.35, 1],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class RoleInstructionCard extends StatelessWidget {
  final String text;
  final Color accent;

  const RoleInstructionCard({
    super.key,
    required this.text,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor(theme),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: context.readableIcon(accent)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class RoleSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const RoleSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: _cardColor(theme, alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor),
      ),
      // Les ListTile (interrupteurs de la Sorcière...) dessinent leur effet
      // d'appui sur le Material le plus proche : sans celui-ci, le fond de
      // la carte le masquerait.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}