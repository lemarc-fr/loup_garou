import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/l10n/role_localizations.dart';

import '../models/game_progress.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import 'game_toolbar.dart';

/// Bouton compact de la barre d'outils de la partie (voir GameToolbar) :
/// résume en un coup d'œil où on en est ("Nuit 2", "Jour 1"...) et ouvre le
/// résumé complet de la partie au tap.
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

    return ToolbarPill(
      onTap: () => showGameProgressSheet(context),
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
    );
  }
}

/// Ouvre le résumé complet de la partie dans une ModalBottomSheet.
///
/// La feuille a toujours un fond "nuit" : on force donc le thème nuit,
/// sinon, ouverte en journée, elle hériterait du texte encre du thème jour
/// (illisible sur ce fond sombre).
void showGameProgressSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.nightAlt,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        Theme(data: AppTheme.night, child: const GameProgressSheet()),
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
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Compte rendu : morts, élections, résultat des votes. Une nuit
          // n'en a qu'une fois terminée (ses morts sont annoncées au jour).
          if (round.events.isNotEmpty || !isLatest) ...[
            _SubTitle(loc.gameProgressEventsTitle),
            if (round.events.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: Text(loc.gameEventNone,
                    style: theme.textTheme.bodyMedium),
              ),
            for (final event in round.events) _EventTile(event: event),
            _SubTitle(loc.gameProgressStepsTitle),
          ],
          if (round.steps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(loc.gameProgressInProgressDots,
                  style: theme.textTheme.bodyMedium),
            )
          else
            for (final step in round.steps) _StepTile(step: step),
        ],
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  final String text;
  const _SubTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.lantern, letterSpacing: 1.1),
        ),
      );
}

/// Une ligne du compte rendu d'un round (voir RoundEvent).
class _EventTile extends StatelessWidget {
  final RoundEvent event;
  const _EventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final state = context.read<GameProvider>().state!;
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final player = state.tryById(event.playerId);
    final name = player?.name ?? '';

    final (icon, color, text) = switch (event.kind) {
      RoundEventKind.death => (
          Icons.close,
          AppColors.blood,
          // Cause de la mort : selon le réglage, comme à l'annonce.
          state.settings.revealDeathCause && event.cause != null
              ? loc.gameEventDeathWithCause(name, loc.playerRoleLabel(player!),
                  loc.deathCauseLabel(event.cause!))
              : loc.gameEventDeath(name, loc.playerRoleLabel(player!)),
        ),
      RoundEventKind.mayorElected => (
          Icons.emoji_events,
          AppColors.lantern,
          loc.gameEventMayorElected(name),
        ),
      RoundEventKind.mayorSuccession => (
          Icons.emoji_events,
          AppColors.lantern,
          loc.gameEventMayorSuccession(name),
        ),
      RoundEventKind.villageVote => (
          Icons.gavel,
          AppColors.moonlight,
          loc.gameEventVillageVote(name),
        ),
      RoundEventKind.nobodyEliminated => (
          Icons.balance,
          AppColors.moonlight,
          loc.gameEventNobodyEliminated,
        ),
      RoundEventKind.idiotSpared => (
          Icons.sentiment_satisfied,
          AppColors.forest,
          loc.gameEventIdiotSpared(name),
        ),
    };

    final details = [
      if (event.tieRule case final tie?)
        switch (tie) {
          VoteTieRule.boucEmissaire => loc.voteResultTieBouc,
          VoteTieRule.mayorDecides => loc.voteResultTieMayor,
          VoteTieRule.nobodyEliminated => loc.voteResultTieNobody,
          VoteTieRule.runoff => '',
        },
      if (event.votes case final votes? when votes.isNotEmpty)
        votes.entries
            .map((e) =>
                loc.gameEventVotes(state.tryById(e.key)?.name ?? '', e.value))
            .join(' · '),
    ].where((d) => d.isNotEmpty);

    return ListTile(
      dense: true,
      leading: Icon(icon,
          size: 22,
          color: AppColors.readableOn(color, AppColors.nightAlt,
              minContrast: 3.5)),
      title: Text(text, style: theme.textTheme.bodyMedium),
      subtitle: details.isEmpty
          ? null
          : Text(details.join('\n'),
              style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.moonlight.withValues(alpha: 0.85))),
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
          color: dimmed ? AppColors.moonlight.withValues(alpha: 0.62) : null,
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
        return Icon(Icons.radio_button_unchecked,
            key: const ValueKey('pending'),
            color: AppColors.moonlight.withValues(alpha: 0.5),
            size: 22);
      case StepStatus.done:
        return Icon(Icons.check_circle,
            key: const ValueKey('done'),
            color: AppColors.readableOn(AppColors.forest, AppColors.nightAlt,
                minContrast: 3),
            size: 22);
      case StepStatus.skipped:
        return Icon(Icons.cancel,
            key: const ValueKey('skipped'),
            color: AppColors.readableOn(AppColors.blood, AppColors.nightAlt,
                minContrast: 3),
            size: 22);
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
    case GamePhase.nightLoversReveal:
      return loc.phaseNightLoversReveal;
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
