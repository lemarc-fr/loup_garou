import '../models/player.dart';
import '../models/role.dart';
import 'app_localizations.dart';

/// Textes traduits des rôles. Le catalogue [kRoleCatalog] ne garde que les
/// données "techniques" d'un rôle (camp, illustration, couleur...) : tout
/// ce qui s'affiche passe par ici pour suivre la langue de l'application.
///
/// Pour ajouter un rôle : ajoute ses clés `role<Nom>Name`,
/// `role<Nom>ShortName` et `role<Nom>Description` dans les fichiers .arb,
/// puis un cas dans chacun des switch ci-dessous.
extension RoleLocalizations on AppLocalizations {
  String roleName(RoleId role) => switch (role) {
        RoleId.loupGarou => roleLoupGarouName,
        RoleId.voyante => roleVoyanteName,
        RoleId.sorciere => roleSorciereName,
        RoleId.chasseur => roleChasseurName,
        RoleId.cupidon => roleCupidonName,
        RoleId.petiteFille => rolePetiteFilleName,
        RoleId.voleur => roleVoleurName,
        RoleId.simpleVillageois => roleSimpleVillageoisName,
        RoleId.ancien => roleAncienName,
        RoleId.boucEmissaire => roleBoucEmissaireName,
        RoleId.idiotDuVillage => roleIdiotDuVillageName,
        RoleId.salvateur => roleSalvateurName,
        RoleId.corbeau => roleCorbeauName,
        RoleId.loupBlanc => roleLoupBlancName,
        RoleId.grandMechantLoup => roleGrandMechantLoupName,
        RoleId.infectPereDesLoups => roleInfectPereDesLoupsName,
        RoleId.enfantSauvage => roleEnfantSauvageName,
        RoleId.jugeBegue => roleJugeBegueName,
        RoleId.servanteDevouee => roleServanteDevoueeName,
        RoleId.montreurDours => roleMontreurDoursName,
        RoleId.renard => roleRenardName,
      };

  String roleShortName(RoleId role) => switch (role) {
        RoleId.loupGarou => roleLoupGarouShortName,
        RoleId.voyante => roleVoyanteShortName,
        RoleId.sorciere => roleSorciereShortName,
        RoleId.chasseur => roleChasseurShortName,
        RoleId.cupidon => roleCupidonShortName,
        RoleId.petiteFille => rolePetiteFilleShortName,
        RoleId.voleur => roleVoleurShortName,
        RoleId.simpleVillageois => roleSimpleVillageoisShortName,
        RoleId.ancien => roleAncienShortName,
        RoleId.boucEmissaire => roleBoucEmissaireShortName,
        RoleId.idiotDuVillage => roleIdiotDuVillageShortName,
        RoleId.salvateur => roleSalvateurShortName,
        RoleId.corbeau => roleCorbeauShortName,
        RoleId.loupBlanc => roleLoupBlancShortName,
        RoleId.grandMechantLoup => roleGrandMechantLoupShortName,
        RoleId.infectPereDesLoups => roleInfectPereDesLoupsShortName,
        RoleId.enfantSauvage => roleEnfantSauvageShortName,
        RoleId.jugeBegue => roleJugeBegueShortName,
        RoleId.servanteDevouee => roleServanteDevoueeShortName,
        RoleId.montreurDours => roleMontreurDoursShortName,
        RoleId.renard => roleRenardShortName,
      };

  String roleDescription(RoleId role) => switch (role) {
        RoleId.loupGarou => roleLoupGarouDescription,
        RoleId.voyante => roleVoyanteDescription,
        RoleId.sorciere => roleSorciereDescription,
        RoleId.chasseur => roleChasseurDescription,
        RoleId.cupidon => roleCupidonDescription,
        RoleId.petiteFille => rolePetiteFilleDescription,
        RoleId.voleur => roleVoleurDescription,
        RoleId.simpleVillageois => roleSimpleVillageoisDescription,
        RoleId.ancien => roleAncienDescription,
        RoleId.boucEmissaire => roleBoucEmissaireDescription,
        RoleId.idiotDuVillage => roleIdiotDuVillageDescription,
        RoleId.salvateur => roleSalvateurDescription,
        RoleId.corbeau => roleCorbeauDescription,
        RoleId.loupBlanc => roleLoupBlancDescription,
        RoleId.grandMechantLoup => roleGrandMechantLoupDescription,
        RoleId.infectPereDesLoups => roleInfectPereDesLoupsDescription,
        RoleId.enfantSauvage => roleEnfantSauvageDescription,
        RoleId.jugeBegue => roleJugeBegueDescription,
        RoleId.servanteDevouee => roleServanteDevoueeDescription,
        RoleId.montreurDours => roleMontreurDoursDescription,
        RoleId.renard => roleRenardDescription,
      };

  /// Rôle d'un joueur tel qu'annoncé à sa mort ou en fin de partie. Si le
  /// joueur a muté en cours de partie, on rappelle son rôle d'origine :
  /// "Loup-Garou (anciennement Enfant Sauvage)".
  String playerRoleLabel(Player player) {
    final former = player.formerRole;
    if (former == null || former == player.role) return roleName(player.role);
    return roleWithFormerRole(roleName(player.role), roleShortName(former));
  }

  /// Libellé du camp tel qu'annoncé au joueur lors de la découverte de
  /// son rôle.
  String campLabel(Camp camp) => switch (camp) {
        Camp.loups => campWolves,
        Camp.village => campVillagers,
        Camp.seul || Camp.amoureux => campSolo,
      };
}
