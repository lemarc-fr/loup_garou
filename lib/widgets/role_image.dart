import 'package:flutter/material.dart';
import '../models/role.dart';

/// Affiche l’illustration d’un rôle si le fichier existe dans les assets,
/// sinon retombe proprement sur une icône colorée.
///
/// Si [animated] est activé, l'image/logo effectue un tour complet
/// en une seconde puis s'arrête.
class RoleImage extends StatefulWidget {
  final RoleId role;
  final double size;
  final bool circular;
  final bool animated;

  const RoleImage({
    super.key,
    required this.role,
    this.size = 96,
    this.circular = true,
    this.animated = false,
  });

  @override
  State<RoleImage> createState() => _RoleImageState();
}

class _RoleImageState extends State<RoleImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.animated) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant RoleImage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.animated && widget.animated) {
      _controller.forward(from: 0);
    }

    if (oldWidget.animated && !widget.animated) {
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.role.info;

    final fallback = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: info.accent.withValues(alpha: 0.18),
        shape: widget.circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius:
        widget.circular ? null : BorderRadius.circular(16),
        border: Border.all(
          color: info.accent,
          width: 2,
        ),
      ),
      child: Icon(
        info.fallbackIcon,
        color: info.accent,
        size: widget.size * 0.5,
      ),
    );

    final image = ClipRRect(
      borderRadius: widget.circular
          ? BorderRadius.circular(widget.size)
          : BorderRadius.circular(16),
      child: Image.asset(
        info.imageAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );

    if (!widget.animated) {
      return image;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: image,
      builder: (context, child) {
        final progress = Curves.easeOutExpo.transform(_controller.value);

        // 8 tours complets en 1 seconde.
        final rotation = progress * 8 * 2 * 3.141592653589793;

        return Transform.rotate(
          angle: rotation,
          child: child,
        );
      },
    );

  }
}

