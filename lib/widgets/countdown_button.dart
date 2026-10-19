import 'package:flutter/material.dart';

/// Bouton qui se valide tout seul au bout de [duration] : une barre
/// estompée remplit le bouton de gauche à droite pendant le compte à
/// rebours. Un appui le valide aussitôt, sauf avec [waitForEnd]. Tant que
/// [duration] est null (durée encore inconnue), c'est un bouton ordinaire.
class CountdownButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Duration? duration;

  /// Un appui ne fait rien : seul le compte à rebours valide le bouton
  /// (faux tour, qui doit durer comme un vrai).
  final bool waitForEnd;

  const CountdownButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.duration,
    this.waitForEnd = false,
  });

  @override
  State<CountdownButton> createState() => _CountdownButtonState();
}

class _CountdownButtonState extends State<CountdownButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress = AnimationController(vsync: this)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) _press();
    });

  /// Validé une seule fois, que ce soit par le compte à rebours ou au doigt.
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant CountdownButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) _start();
  }

  void _start() {
    final duration = widget.duration;
    if (duration == null || _pressed) return;
    _progress.duration = duration;
    _progress.forward(from: 0);
  }

  void _press() {
    if (_pressed) return;
    _pressed = true;
    _progress.stop();
    widget.onPressed();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor =
        theme.elevatedButtonTheme.style?.foregroundColor?.resolve({}) ??
            theme.colorScheme.onPrimary;
    final fill = textColor.withValues(alpha: 0.22);

    return ElevatedButton(
      // Une fonction vide plutôt que null : le bouton garde son aspect actif.
      onPressed: widget.waitForEnd ? () {} : _press,
      clipBehavior: Clip.antiAlias,
      style: ButtonStyle(
        backgroundBuilder: (context, states, content) => AnimatedBuilder(
          animation: _progress,
          builder: (context, content) => Stack(
            children: [
              Positioned.fill(
                child: FractionallySizedBox(
                  alignment: AlignmentDirectional.centerStart,
                  widthFactor: _progress.value,
                  child: ColoredBox(color: fill),
                ),
              ),
              content!,
            ],
          ),
          child: content,
        ),
      ),
      child: Text(widget.label),
    );
  }
}
