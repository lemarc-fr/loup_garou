import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pass_device_gate.dart';
import '../../../widgets/role_image.dart';
import 'role_screen_chrome.dart';

class VoleurScreen extends StatelessWidget {
  const VoleurScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return PassDeviceGate(
      toName: "La Voleuse",
      subtitle: 'C\'est le rôle du Voleur. Réveille-toi.',
      accent: RoleId.voleur.info.accent,
      contentBuilder: (_) => const _VoleurContent(),
    );
  }
}

class _VoleurContent extends StatefulWidget {
  const _VoleurContent();
  @override
  State<_VoleurContent> createState() => _VoleurContentState();
}

class _VoleurContentState extends State<_VoleurContent> {
  RoleId? selected;

  @override
  Widget build(BuildContext context) {
    final gp = context.read<GameProvider>();
    final state = gp.state!;
    final cards = state.voleurTableCards;
    final forced =
        cards.isNotEmpty && cards.every((c) => c == RoleId.loupGarou);

    return RoleScreenFrame(
      title: 'Le Voleur',
      accent: RoleId.voleur.info.accent,
      child: Column(
        children: [
          RoleInstructionCard(
            text: RoleId.voleur.info.nightInstruction,
            accent: RoleId.voleur.info.accent,
          ),
          if (forced) ...[
            const SizedBox(height: 10),
            const RoleSectionCard(
              child: Text(
                'Les deux cartes sont des Loups-Garous : tu es obligé d’en prendre une !',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.blood),
              ),
            ),
          ],
          const SizedBox(height: 18),
          RoleSectionCard(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 14,
              runSpacing: 14,
              children: [
                for (final card in cards)
                  _CardChoice(
                    role: card,
                    selected: selected == card,
                    onTap: () => setState(() => selected = card),
                  ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  selected == null ? null : () => gp.resolveVoleur(selected),
              child: const Text('Échanger mon rôle contre celle-ci'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: forced ? null : () => gp.resolveVoleur(null),
              child: const Text('Garder mon rôle actuel'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardChoice extends StatelessWidget {
  final RoleId role;
  final bool selected;
  final VoidCallback onTap;
  const _CardChoice(
      {required this.role, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.nightAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? AppColors.lantern : AppColors.nightLine,
              width: selected ? 2.5 : 1),
        ),
        child: Column(
          children: [
            RoleImage(role: role, size: 84),
            const SizedBox(height: 8),
            Text(role.info.name, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
