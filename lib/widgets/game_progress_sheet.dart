import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_progress.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';

/// Bouton compact affiché en overlay au-dessus de l'écran de jeu (voir
/// GameMainScreen) : résume en un coup d'œil où on en est ("Nuit 2",
/// "Jour 1"...) et ouvre le résumé complet de la partie au tap.
class GameProgressButton extends StatelessWidget {
  const GameProgressButton({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state;
    if (state == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isNight = state.currentWave == 'night';
    final label = isNight ? 'Nuit ${state.night}' : 'Jour ${state.day}';

    return Padding(
      padding: const EdgeInsets.only(top: 6, right: 6),
      child: Material(
        color: AppColors.nightAlt.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(20),
        elevation: 3,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => showGameProgressSheet(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(isNight ? Icons.dark_mode : Icons.wb_sunny,
                    size: 18, color: AppColors.lantern),
                const SizedBox(width: 6),
                Text(label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.moonlight)),
                const SizedBox(width: 6),
                const Icon(Icons.checklist_rtl,
                    size: 16, color: AppColors.moonlight),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ouvre le résumé complet de la partie dans une ModalBottomSheet.
void showGameProgressSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightAlt,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const GameProgressSheet(),
  );
}

class GameProgressSheet extends StatelessWidget {
  const GameProgressSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GameProvider>();
    final state = gp.state!;
    final theme = Theme.of(context);
    // Le plus récent (donc le round en cours) en premier.
    final rounds = state.rounds.reversed.toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Row(
              children: [
                const Icon(Icons.checklist_rtl, color: AppColors.lantern),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Résumé de la partie',
                      style: theme.textTheme.titleLarge),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Row(
              children: [
                _CounterChip(
                    icon: Icons.dark_mode, label: 'Nuit', value: state.night),
                const SizedBox(width: 10),
                _CounterChip(
                    icon: Icons.wb_sunny, label: 'Jour', value: state.day),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.nightLine),
          Expanded(
            child: rounds.isEmpty
                ? Center(
                    child: Text('La partie commence...',
                        style: theme.textTheme.bodyMedium),
                  )
                : ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 20),
                    itemCount: rounds.length,
                    itemBuilder: (ctx, i) =>
                        _RoundTile(round: rounds[i], isLatest: i == 0),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CounterChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;

  const _CounterChip(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.night.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.nightLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.lantern),
          const SizedBox(width: 8),
          Text('$label $value', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _RoundTile extends StatelessWidget {
  final RoundRecord round;
  final bool isLatest;
  const _RoundTile({required this.round, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isNight = round.wave == 'night';
    final title = isNight ? 'Nuit ${round.number}' : 'Jour ${round.number}';

    return Card(
      key: ValueKey('${round.wave}-${round.number}'),
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: AppColors.night.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLatest ? AppColors.lantern : AppColors.nightLine,
          width: isLatest ? 1.4 : 1,
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: isLatest,
        leading: Icon(isNight ? Icons.dark_mode : Icons.wb_sunny,
            color: AppColors.lantern),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: isLatest
            ? const Text('En cours', style: TextStyle(color: AppColors.lantern))
            : null,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: round.steps.isEmpty
            ? [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('En cours...', style: theme.textTheme.bodyMedium),
                ),
              ]
            : [for (final step in round.steps) _StepTile(step: step)],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  final StepRecord step;
  const _StepTile({required this.step});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: _StatusIcon(status: step.status),
      title: Text(gamePhaseLabel(step.phase)),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final StepStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case StepStatus.done:
        return const Icon(Icons.check_circle, color: AppColors.forest);
      case StepStatus.skipped:
        return const Icon(Icons.cancel, color: AppColors.blood);
      case StepStatus.current:
        return const SizedBox(
          width: 22,
          height: 22,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: AppColors.lantern),
          ),
        );
    }
  }
}

/// Libellé affiché pour chaque étape dans le résumé de la partie.
String gamePhaseLabel(GamePhase phase) {
  switch (phase) {
    case GamePhase.nightVoleur:
      return 'Le Voleur';
    case GamePhase.nightCupidon:
      return 'Cupidon';
    case GamePhase.nightEnfantSauvage:
      return "L'Enfant Sauvage — choix du modèle";
    case GamePhase.nightSalvateur:
      return 'Le Salvateur';
    case GamePhase.nightVoyante:
      return 'La Voyante';
    case GamePhase.nightLoups:
      return 'Les Loups-Garous';
    case GamePhase.nightPetiteFille:
      return 'La Petite Fille';
    case GamePhase.nightLoupBlanc:
      return 'Le Loup Blanc';
    case GamePhase.nightGrandMechantLoup:
      return 'Le Grand Méchant Loup';
    case GamePhase.nightEnfantSauvageCheck:
      return "L'Enfant Sauvage";
    case GamePhase.nightInfectPereDesLoups:
      return 'Infect Père des Loups';
    case GamePhase.nightRenard:
      return 'Le Renard';
    case GamePhase.nightCorbeau:
      return 'Le Corbeau';
    case GamePhase.nightSorciere:
      return 'La Sorcière';
    case GamePhase.chasseurRevange:
      return 'Riposte du Chasseur';
    case GamePhase.successionMaire:
      return 'Succession du Maire';
    case GamePhase.enfantsauvageReveal:
      return "Mutation de l'Enfant Sauvage";
    case GamePhase.dayReveal:
      return 'Réveil du village';
    case GamePhase.mayorElectionExplain:
      return 'Élection du maire';
    case GamePhase.mayorElection:
      return 'Vote pour le maire';
    case GamePhase.mayorReveal:
      return "Résultat de l'élection";
    case GamePhase.debate:
      return 'Débat';
    case GamePhase.jugeBegueDecision:
      return 'Le Juge Bègue';
    case GamePhase.villageVote:
      return 'Vote du village';
    case GamePhase.voteResult:
      return 'Résultat du vote';
    case GamePhase.villagePowerLoss:
      return 'Perte des pouvoirs';
    case GamePhase.servanteDevouee:
      return 'La Servante Dévouée';
    case GamePhase.boucEmissaire:
      return 'Le Bouc Émissaire';
    case GamePhase.idiotduvillageCivicRightLoss:
      return "L'Idiot du Village";
    case GamePhase.endGame:
      return 'Fin de la partie';
    default:
      return phase.name;
  }
}