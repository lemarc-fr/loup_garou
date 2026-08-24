import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_image.dart';

/// Révélation animée : le village a pendu l'Ancien par erreur, tous les
/// villageois à pouvoir perdent leur don. Chaque carte se dévoile avec un
/// léger décalage puis bascule visuellement vers "Simple Villageois".
class VillagePowerLossScreen extends StatefulWidget {
  const VillagePowerLossScreen({super.key});

  @override
  State<VillagePowerLossScreen> createState() => _VillagePowerLossScreenState();
}

class _VillagePowerLossScreenState extends State<VillagePowerLossScreen> {
  bool _introDone = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _introDone = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    final entries = state.powerLossThisWave;

    return Scaffold(
      appBar: AppBar(title: const Text("La sagesse s'éteint")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              AnimatedOpacity(
                opacity: _introDone ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome_outlined,
                        size: 56, color: AppColors.blood),
                    const SizedBox(height: 12),
                    Text(
                      "Le village a fait pendre l'Ancien par erreur.",
                      style: theme.textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Privé de sa sagesse, le village voit ses pouvoirs se tarir...',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _PowerLossCard(
                    playerName: state.byId(entries[index].playerId).name,
                    previousRole: entries[index].previousRole,
                    delay: Duration(milliseconds: 500 + index * 350),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmPowerLossReveal,
                  child: const Text('La nuit tombe à nouveau'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PowerLossCard extends StatefulWidget {
  final String playerName;
  final RoleId previousRole;
  final Duration delay;

  const _PowerLossCard({
    required this.playerName,
    required this.previousRole,
    required this.delay,
  });

  @override
  State<_PowerLossCard> createState() => _PowerLossCardState();
}

class _PowerLossCardState extends State<_PowerLossCard> {
  bool _visible = false;
  bool _switched = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
    Future.delayed(widget.delay + const Duration(milliseconds: 550), () {
      if (mounted) setState(() => _switched = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = widget.previousRole.info;
    final mutedColor =
        theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6);

    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.15),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 400),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, anim) => ScaleTransition(
                    scale: anim,
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: _switched
                      ? RoleImage(
                          key: const ValueKey('villageois'),
                          role: RoleId.simpleVillageois,
                          size: 48,
                        )
                      : RoleImage(
                          key: const ValueKey('previous'),
                          role: widget.previousRole,
                          size: 48,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.playerName,
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Text(
                          _switched ? 'Devient Simple Villageois' : info.name,
                          key: ValueKey(_switched),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _switched ? mutedColor : info.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedOpacity(
                  opacity: _switched ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: const Icon(Icons.power_off, color: AppColors.blood),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
