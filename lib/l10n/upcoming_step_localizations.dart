import '../services/game_engine.dart' show UpcomingStep;
import 'app_localizations.dart';

extension UpcomingStepLocalizations on AppLocalizations {
  /// Libellé du bouton qui valide un écran de résolution (récapitulatif de
  /// la nuit, résultat du vote...), selon ce qui va suivre.
  String upcomingStepButton(UpcomingStep step) => switch (step) {
        UpcomingStep.gameOver => seeGameResultButton,
        UpcomingStep.followUp => continueButtonLabel,
        UpcomingStep.revote => replayVoteButton,
        UpcomingStep.nightFalls => nightFallsAgainButton,
        UpcomingStep.dayStarts => villageWakesUpButton,
      };
}
