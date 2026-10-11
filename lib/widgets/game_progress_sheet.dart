import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';

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
    final loc = AppLocalizations.of(context)!;
    final label = isNight
        ? loc.gameProgressNightCounter(state.night)
        : loc.gameProgressDayCounter(state.day);

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
    final loc = AppLocalizations.of(context)!;
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
                  child: Text(loc.gameProgressSheetTitle,
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
                    icon: Icons.dark_mode,
                    label: loc.gameProgressNightCounter(state.night)),
                const SizedBox(width: 10),
                _CounterChip(
                    icon: Icons.wb_sunny,
                    label: loc.gameProgressDayCounter(state.day)),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.nightLine),
          Expanded(
            child: rounds.isEmpty
                ? Center(
                    child: Text(loc.gameProgressStarting,
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

  const _CounterChip({required this.icon, required this.label});

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
          Text(label, style: theme.textTheme.bodyMedium),
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
    final loc = AppLocalizations.of(context)!;
    final title = isNight
        ? loc.gameProgressNightTitle(round.number)
        : loc.gameProgressDayTitle(round.number);

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
            ? Text(loc.gameProgressInProgress,
                style: const TextStyle(color: AppColors.lantern))
            : null,
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: round.steps.isEmpty
            ? [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(loc.gameProgressInProgressDots,
                      style: theme.textTheme.bodyMedium),
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
    final theme = Theme.of(context);
    final dimmed = step.status == StepStatus.pending;
    return ListTile(
      dense: true,
      leading: _StatusIcon(status: step.status),
      title: Text(
        gamePhaseLabel(AppLocalizations.of(context)!, step.phase),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: dimmed ? AppColors.moonlight.withValues(alpha: 0.45) : null,
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  final StepStatus status;
  const _StatusIcon({required this.status});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      transitionBuilder: (child, anim) => ScaleTransition(
        scale: anim,
        child: FadeTransition(opacity: anim, child: child),
      ),
      child: _iconFor(status),
    );
  }

  Widget _iconFor(StepStatus status) {
    switch (status) {
      case StepStatus.pending:
        return const Icon(Icons.radio_button_unchecked,
            key: ValueKey('pending'), color: AppColors.nightLine, size: 22);
      case StepStatus.done:
        return const Icon(Icons.check_circle,
            key: ValueKey('done'), color: AppColors.forest, size: 22);
      case StepStatus.skipped:
        return const Icon(Icons.cancel,
            key: ValueKey('skipped'), color: AppColors.blood, size: 22);
      case StepStatus.current:
        return const SizedBox(
          key: ValueKey('current'),
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
String gamePhaseLabel(AppLocalizations loc, GamePhase phase) {
  switch (phase) {
    case GamePhase.nightVoleur:
      return loc.phaseNightVoleur;
    case GamePhase.nightCupidon:
      return loc.phaseNightCupidon;
    case GamePhase.nightEnfantSauvage:
      return loc.phaseNightEnfantSauvage;
    case GamePhase.nightSalvateur:
      return loc.phaseNightSalvateur;
    case GamePhase.nightVoyante:
      return loc.phaseNightVoyante;
    case GamePhase.nightLoups:
      return loc.phaseNightLoups;
    case GamePhase.nightPetiteFille:
      return loc.phaseNightPetiteFille;
    case GamePhase.nightLoupBlanc:
      return loc.phaseNightLoupBlanc;
    case GamePhase.nightGrandMechantLoup:
      return loc.phaseNightGrandMechantLoup;
    case GamePhase.nightEnfantSauvageCheck:
      return loc.phaseNightEnfantSauvageCheck;
    case GamePhase.nightInfectPereDesLoups:
      return loc.phaseNightInfectPereDesLoups;
    case GamePhase.nightRenard:
      return loc.phaseNightRenard;
    case GamePhase.nightCorbeau:
      return loc.phaseNightCorbeau;
    case GamePhase.nightSorciere:
      return loc.phaseNightSorciere;
    case GamePhase.chasseurRevange:
      return loc.phaseChasseurRevange;
    case GamePhase.successionMaire:
      return loc.phaseSuccessionMaire;
    case GamePhase.enfantsauvageReveal:
      return loc.phaseEnfantsauvageReveal;
    case GamePhase.dayReveal:
      return loc.phaseDayReveal;
    case GamePhase.mayorElectionExplain:
      return loc.phaseMayorElectionExplain;
    case GamePhase.mayorElection:
      return loc.phaseMayorElection;
    case GamePhase.mayorReveal:
      return loc.phaseMayorReveal;
    case GamePhase.debate:
      return loc.phaseDebate;
    case GamePhase.jugeBegueDecision:
      return loc.phaseJugeBegueDecision;
    case GamePhase.villageVote:
      return loc.phaseVillageVote;
    case GamePhase.voteResult:
      return loc.phaseVoteResult;
    case GamePhase.villagePowerLoss:
      return loc.phaseVillagePowerLoss;
    case GamePhase.servanteDevouee:
      return loc.phaseServanteDevouee;
    case GamePhase.boucEmissaire:
      return loc.phaseBoucEmissaire;
    case GamePhase.idiotduvillageCivicRightLoss:
      return loc.phaseIdiotduvillageCivicRightLoss;
    case GamePhase.endGame:
      return loc.phaseEndGame;
    default:
      return phase.name;
  }
}
