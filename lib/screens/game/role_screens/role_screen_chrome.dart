import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

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
    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              accent.withValues(alpha: 0.12),
              AppColors.night,
              AppColors.night,
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
        color: AppColors.nightAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: accent),
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
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.nightAlt.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.nightLine),
      ),
      child: child,
    );
  }
}