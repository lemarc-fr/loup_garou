import '../services/narration_script.dart';
import 'app_localizations.dart';

/// Texte de chaque phrase de narration (voir [NarrationCue]). Sert à la
/// synthèse vocale du téléphone quand le fichier audio de la phrase
/// n'existe pas, et de script au générateur tool/audio/generate_voices.dart.
///
/// Pour ajouter une phrase : ajoute une valeur à [NarrationCue], sa clé
/// `narration<Nom>` dans les fichiers .arb, puis un cas dans le switch
/// ci-dessous.
extension NarrationLocalizations on AppLocalizations {
  String narrationText(NarrationCue cue) => switch (cue) {
        NarrationCue.nightFalls => narrationNightFalls,
        NarrationCue.dayBreaks => narrationDayBreaks,
        NarrationCue.loversReveal => narrationLoversReveal,
        NarrationCue.wakeVoleur => narrationWakeVoleur,
        NarrationCue.sleepVoleur => narrationSleepVoleur,
        NarrationCue.wakeCupidon => narrationWakeCupidon,
        NarrationCue.sleepCupidon => narrationSleepCupidon,
        NarrationCue.wakeEnfantSauvage => narrationWakeEnfantSauvage,
        NarrationCue.sleepEnfantSauvage => narrationSleepEnfantSauvage,
        NarrationCue.wakeSalvateur => narrationWakeSalvateur,
        NarrationCue.sleepSalvateur => narrationSleepSalvateur,
        NarrationCue.wakeVoyante => narrationWakeVoyante,
        NarrationCue.sleepVoyante => narrationSleepVoyante,
        NarrationCue.wakeLoups => narrationWakeLoups,
        NarrationCue.sleepLoups => narrationSleepLoups,
        NarrationCue.wakeLoupBlanc => narrationWakeLoupBlanc,
        NarrationCue.sleepLoupBlanc => narrationSleepLoupBlanc,
        NarrationCue.wakeGrandMechantLoup => narrationWakeGrandMechantLoup,
        NarrationCue.sleepGrandMechantLoup => narrationSleepGrandMechantLoup,
        NarrationCue.wakeInfectPereDesLoups => narrationWakeInfectPereDesLoups,
        NarrationCue.sleepInfectPereDesLoups =>
          narrationSleepInfectPereDesLoups,
        NarrationCue.wakeRenard => narrationWakeRenard,
        NarrationCue.sleepRenard => narrationSleepRenard,
        NarrationCue.wakeCorbeau => narrationWakeCorbeau,
        NarrationCue.sleepCorbeau => narrationSleepCorbeau,
        NarrationCue.wakeSorciere => narrationWakeSorciere,
        NarrationCue.sleepSorciere => narrationSleepSorciere,
      };
}
