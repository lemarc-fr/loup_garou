import 'package:flutter/material.dart';

/// Fait entrer en douceur chaque nouvel écran de la partie : fondu et léger
/// glissement vers le haut.
///
/// Seul l'écran entrant est animé, l'écran sortant disparaît aussitôt. Un
/// AnimatedSwitcher le garderait affiché pendant la transition, et il se
/// reconstruirait alors sur un état de partie qui a déjà changé (joueur
/// mort, rôle muté...) : plusieurs écrans de rôle lèveraient une exception.
///
/// L'animation rejoue à chaque changement de [key] (voir GameMainScreen).
class PhaseEntrance extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const PhaseEntrance({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
  });

  @override
  State<PhaseEntrance> createState() => _PhaseEntranceState();
}

class _PhaseEntranceState extends State<PhaseEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration)..forward();
  late final Animation<double> _progress =
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  late final Animation<Offset> _offset =
      Tween(begin: const Offset(0, 0.03), end: Offset.zero).animate(_progress);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Réglage d'accessibilité « supprimer les animations » du téléphone.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return FadeTransition(
      opacity: _progress,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}
