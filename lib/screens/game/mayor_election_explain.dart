import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';


class MayorElectionExplainScreen extends StatefulWidget {
  const MayorElectionExplainScreen({super.key});

  @override
  State<MayorElectionExplainScreen> createState() => _MayorElectionExplainScreenState();
}

class _MayorElectionExplainScreenState extends State<MayorElectionExplainScreen>
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
                  child: Image.asset('assets/images/roles/mayor_insign.png')
                ),
              ),
              const SizedBox(height: 28),
              const Text("you're going to elect the mayor"),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: gp.confirmMayorElectionExplain,
                  child: const Text('Continue to the vote'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
