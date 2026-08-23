import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/player_grid_selector.dart';

class CupidonScreen extends StatelessWidget {
  const CupidonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final cupidon = gp.state!.alivePlayersWithRole(RoleId.cupidon).first;

    return PassDeviceGate(
      toName: cupidon.name,
      subtitle: 'C\'est le rôle de Cupidon. Réveille-toi.',
      accent: RoleId.cupidon.info.accent,
      contentBuilder: (_) => const _CupidonContent(),
    );
  }
}

class _CupidonContent extends StatefulWidget {
  const _CupidonContent();
  @override
  State<_CupidonContent> createState() => _CupidonContentState();
}

class _CupidonContentState extends State<_CupidonContent> {
  final List<String> chosen = [];

  void _toggle(String id) {
    setState(() {
      if (chosen.contains(id)) {
        chosen.remove(id);
      } else if (chosen.length < 2) {
        chosen.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final players = gp.state!.alivePlayers;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cupidon')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Désigne les deux Amoureux (${chosen.length}/2). Tu peux te choisir toi-même.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: PlayerGridSelector(
                    players: players,
                    selectedId: null,
                    highlightedIds: chosen.toSet(),
                    onSelect: _toggle,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: chosen.length == 2
                    ? () => gp.resolveCupidon(chosen[0], chosen[1])
                    : null,
                child: const Text('Confirmer les Amoureux'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
