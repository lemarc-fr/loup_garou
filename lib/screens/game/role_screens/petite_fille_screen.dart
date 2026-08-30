import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import 'role_screen_chrome.dart';

class PetiteFilleScreen extends StatelessWidget {
  const PetiteFilleScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return PassDeviceGate(
      toName: "Petite Fille",
      subtitle: 'C\'est le rôle de la Petite Fille. Réveille-toi.',
      accent: RoleId.petiteFille.info.accent,
      contentBuilder: (_) => const _PetiteFilleContent(),
    );
  }
}

class _PetiteFilleContent extends StatelessWidget {
  const _PetiteFilleContent();

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();

    return RoleScreenFrame(
      title: 'La Petite Fille',
      accent: RoleId.petiteFille.info.accent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoleInstructionCard(
            text: RoleId.petiteFille.info.nightInstruction,
            accent: RoleId.petiteFille.info.accent,
          ),
          const SizedBox(height: 14),
          const RoleSectionCard(
            child: Text(
              'Attention : si les Loups-Garous te surprennent, tu prendras la place de leur victime.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.blood),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => gp.resolvePetiteFille(tried: true),
              child: const Text('Entrouvrir les yeux et espionner'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => gp.resolvePetiteFille(tried: false),
              child: const Text('Rester sagement endormie'),
            ),
          ),
        ],
      ),
    );
  }
}