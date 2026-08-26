import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Écran tampon affiché entre deux actions de joueurs différents :
/// évite que la personne qui tient le téléphone voie l'écran suivant
/// avant que le bon joueur ne l'ait officiellement récupéré.
class PassDeviceGate extends StatefulWidget {
  final String toName;
  final String? subtitle;
  final Color accent;
  final WidgetBuilder contentBuilder;
  final bool pluralToName;

  const PassDeviceGate({
    super.key,
    required this.toName,
    required this.contentBuilder,
    this.subtitle,
    this.accent = AppColors.lantern,
    this.pluralToName = false,
  });

  @override
  State<PassDeviceGate> createState() => _PassDeviceGateState();
}

class _PassDeviceGateState extends State<PassDeviceGate> {
  bool _confirmed = false;

  @override
  void didUpdateWidget(covariant PassDeviceGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si on ré-utilise ce widget pour un·e autre joueur·se, on redemande confirmation.
    if (oldWidget.toName != widget.toName) {
      _confirmed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmed) return widget.contentBuilder(context);

    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phonelink_ring, size: 72, color: widget.accent),
              const SizedBox(height: 28),
              Text(widget.pluralToName ? 'Passe le téléphone aux' : 'Passe le téléphone à',
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                widget.toName,
                style: theme.textTheme.displayMedium
                    ?.copyWith(color: widget.accent),
                textAlign: TextAlign.center,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 16),
                Text(widget.subtitle!,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center),
              ],
              const SizedBox(height: 40),
              FilledButton.icon(
                onPressed: () => setState(() => _confirmed = true),
                icon: const Icon(Icons.check),
                label: const Text("C'est moi, j'ai le téléphone"),
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
