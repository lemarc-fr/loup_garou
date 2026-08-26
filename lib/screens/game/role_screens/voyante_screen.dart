import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';
import '../../../widgets/role_image.dart';

class VoyanteScreen extends StatelessWidget {
  const VoyanteScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return PassDeviceGate(
      toName: "La Voyante",
      subtitle: 'C\'est le tour de la Voyante. Réveille-toi.',
      accent: RoleId.voyante.info.accent,
      contentBuilder: (_) => const _VoyanteContent(),
    );
  }
}

class _VoyanteContent extends StatefulWidget {
  const _VoyanteContent();
  @override
  State<_VoyanteContent> createState() => _VoyanteContentState();
}

class _VoyanteContentState extends State<_VoyanteContent> {
  String? targetId;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);

    if (targetId != null) {
      final target = state.byId(targetId!);
      final info = target.role.info;
      return Scaffold(
        appBar: AppBar(title: const Text('La Voyante')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Text(target.name,
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                RoleImage(role: target.role, size: 120),
                const SizedBox(height: 16),
                Text(info.name,
                    style: theme.textTheme.displayMedium
                        ?.copyWith(color: info.accent),
                    textAlign: TextAlign.center),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: gp.confirmVoyanteDone,
                      child: const Text("J'ai vu, continuer")),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('La Voyante')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Choisis un joueur pour découvrir son rôle.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: state.alivePlayers,
                    onSelect: (id) => setState(() => targetId = id),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
