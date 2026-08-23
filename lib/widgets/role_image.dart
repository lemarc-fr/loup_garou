import 'package:flutter/material.dart';
import '../models/role.dart';

/// Affiche l'illustration d'un rôle si le fichier existe dans les assets,
/// sinon retombe proprement sur une icône colorée. Ça permet de développer
/// et faire tourner l'app avant même que les images finales soient prêtes
/// (voir assets/IMAGES_A_CREER.md).
class RoleImage extends StatelessWidget {
  final RoleId role;
  final double size;
  final bool circular;

  const RoleImage(
      {super.key, required this.role, this.size = 96, this.circular = true});

  @override
  Widget build(BuildContext context) {
    final info = role.info;
    final fallback = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: info.accent.withValues(alpha: 0.18),
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circular ? null : BorderRadius.circular(16),
        border: Border.all(color: info.accent, width: 2),
      ),
      child: Icon(info.fallbackIcon, color: info.accent, size: size * 0.5),
    );

    return ClipRRect(
      borderRadius:
          circular ? BorderRadius.circular(size) : BorderRadius.circular(16),
      child: Image.asset(
        info.imageAsset,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}
