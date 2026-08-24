import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';

/// Public reveal after the mayor election — the whole table sees who won,
/// with a short badge animation before moving on to the debate.
class MayorRevealScreen extends StatefulWidget {
  const MayorRevealScreen({super.key});

  @override
  State<MayorRevealScreen> createState() => _MayorRevealScreenState();
}

class _MayorRevealScreenState extends State<MayorRevealScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final mayor = state.byId(state.mayorId!);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.lantern,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events,
                      size: 56, color: AppColors.night),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'The village has chosen its mayor',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                mayor.name,
                style: theme.textTheme.displayMedium
                    ?.copyWith(color: AppColors.lantern),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Their vote will count double during ties.',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmMayorReveal,
                  child: const Text('Continue to the debate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
