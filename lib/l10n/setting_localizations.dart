import '../models/game_settings.dart';
import 'app_localizations.dart';

/// Textes traduits des options de jeu (voir [kGameSettingDefinitions]).
///
/// Pour ajouter une option : ajoute ses clés `setting<Nom>Label` et
/// `setting<Nom>Description` dans les fichiers .arb, puis un cas dans
/// chacun des switch ci-dessous.
extension SettingLocalizations on AppLocalizations {
  String settingLabel(SettingId id) => switch (id) {
        SettingId.allowWerewolfToKillThemselves =>
          settingAllowWerewolfToKillThemselvesLabel,
        SettingId.allowHunterToShootAfterWitchDeathCause =>
          settingAllowHunterToShootAfterWitchDeathCauseLabel,
        SettingId.allowWitchToPlayIfWerewolfDeathCause =>
          settingAllowWitchToPlayIfWerewolfDeathCauseLabel,
        SettingId.allowWitchToSaveHerself => settingAllowWitchToSaveHerselfLabel,
        SettingId.enfantSauvagePublicReveal =>
          settingEnfantSauvagePublicRevealLabel,
        SettingId.randomLoversInsteadOfCupidon =>
          settingRandomLoversInsteadOfCupidonLabel,
        SettingId.hunterCanOverturnFinishedGame =>
          settingHunterCanOverturnFinishedGameLabel,
        SettingId.voleurPlaysNewRoleFirstNight =>
          settingVoleurPlaysNewRoleFirstNightLabel,
        SettingId.infectCanInfectProtectedVictim =>
          settingInfectCanInfectProtectedVictimLabel,
        SettingId.infectedKeepsPower => settingInfectedKeepsPowerLabel,
        SettingId.mayorBreaksTies => settingMayorBreaksTiesLabel,
        SettingId.tieMeansNoElimination => settingTieMeansNoEliminationLabel,
        SettingId.idiotDiesOnSecondVote => settingIdiotDiesOnSecondVoteLabel,
        SettingId.loupBlancMustBeLastSurvivor =>
          settingLoupBlancMustBeLastSurvivorLabel,
        SettingId.ancienPowerLossByAnyVillager =>
          settingAncienPowerLossByAnyVillagerLabel,
      };

  String settingDescription(SettingId id) => switch (id) {
        SettingId.allowWerewolfToKillThemselves =>
          settingAllowWerewolfToKillThemselvesDescription,
        SettingId.allowHunterToShootAfterWitchDeathCause =>
          settingAllowHunterToShootAfterWitchDeathCauseDescription,
        SettingId.allowWitchToPlayIfWerewolfDeathCause =>
          settingAllowWitchToPlayIfWerewolfDeathCauseDescription,
        SettingId.allowWitchToSaveHerself =>
          settingAllowWitchToSaveHerselfDescription,
        SettingId.enfantSauvagePublicReveal =>
          settingEnfantSauvagePublicRevealDescription,
        SettingId.randomLoversInsteadOfCupidon =>
          settingRandomLoversInsteadOfCupidonDescription,
        SettingId.hunterCanOverturnFinishedGame =>
          settingHunterCanOverturnFinishedGameDescription,
        SettingId.voleurPlaysNewRoleFirstNight =>
          settingVoleurPlaysNewRoleFirstNightDescription,
        SettingId.infectCanInfectProtectedVictim =>
          settingInfectCanInfectProtectedVictimDescription,
        SettingId.infectedKeepsPower => settingInfectedKeepsPowerDescription,
        SettingId.mayorBreaksTies => settingMayorBreaksTiesDescription,
        SettingId.tieMeansNoElimination =>
          settingTieMeansNoEliminationDescription,
        SettingId.idiotDiesOnSecondVote =>
          settingIdiotDiesOnSecondVoteDescription,
        SettingId.loupBlancMustBeLastSurvivor =>
          settingLoupBlancMustBeLastSurvivorDescription,
        SettingId.ancienPowerLossByAnyVillager =>
          settingAncienPowerLossByAnyVillagerDescription,
      };
}
