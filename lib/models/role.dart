import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Camp d'appartenance d'un rôle. Les Amoureux ne sont pas un camp à part :
/// c'est un statut transversal (voir Player.loverId) qui peut créer une
/// victoire spéciale si les deux amoureux sont de camps différents.
enum Camp { loups, village, seul, amoureux }

enum RoleId {
  // jeu de base :
  loupGarou,
  voyante,
  sorciere,
  chasseur,
  cupidon,
  petiteFille,
  voleur,
  simpleVillageois,

  // Extension Nouvelle Lune :
  ancien,
  boucEmissaire, // option : si il meurt, il designe un joueur qui ne se reveille pas la nuit suivante
  idiotDuVillage,
  salvateur,

  // Extension le village :
  corbeau,
  loupBlanc,

  grandMechantLoup,
  infectPereDesLoups,
  enfantSauvage,
  jugeBegue,
  servanteDevouee,
  montreurDours,
  renard,

}

/// Cause de décès, utile pour l'affichage et pour la page de stats.
enum DeathCause {
  devoreParLesLoups,
  potionDeMort,
  chagrinDAmourCupidon,
  vengeanceDuChasseur,
  vote, tueParLoupBlanc,
}

/// Données "techniques" d'un rôle. Les textes affichés (nom, description)
/// sont traduits : voir l10n/role_localizations.dart.
class RoleInfo {
  final RoleId id;
  final Camp camp;
  final String imageAsset;
  final IconData fallbackIcon;
  final Color accent;
  final bool actsAtNight;
  final bool firstNightOnly;
  final bool unique; // un seul exemplaire possible dans la partie

  const RoleInfo({
    required this.id,
    required this.camp,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.accent,
    this.actsAtNight = false,
    this.firstNightOnly = false,
    this.unique = true,
  });
}

/// Catalogue statique de tous les rôles disponibles dans le jeu.
const Map<RoleId, RoleInfo> kRoleCatalog = {
  // ─────────────────────────────────────────────────────────────────────────
  // CAMP DES LOUPS
  // ─────────────────────────────────────────────────────────────────────────

  RoleId.loupGarou: RoleInfo(
    id: RoleId.loupGarou,
    camp: Camp.loups,
    imageAsset: 'assets/images/roles/loup_garou.png',
    fallbackIcon: Icons.dark_mode,
    accent: AppColors.blood,
    actsAtNight: true,
    unique: false,
  ),

  RoleId.grandMechantLoup: RoleInfo(
    id: RoleId.grandMechantLoup,
    camp: Camp.loups,
    imageAsset: 'assets/images/roles/grand_mechant_loup.png',
    fallbackIcon: Icons.pets,
    accent: AppColors.blood,
    actsAtNight: true,
  ),

  RoleId.infectPereDesLoups: RoleInfo(
    id: RoleId.infectPereDesLoups,
    camp: Camp.loups,
    imageAsset: 'assets/images/roles/infect_pere_des_loups.png',
    fallbackIcon: Icons.coronavirus,
    accent: AppColors.blood,
    actsAtNight: true,
  ),

  RoleId.loupBlanc: RoleInfo(
    id: RoleId.loupBlanc,
    camp: Camp.seul,
    imageAsset: 'assets/images/roles/loup_blanc.png',
    fallbackIcon: Icons.ac_unit,
    accent: AppColors.blood,
    actsAtNight: true,
  ),

  // ─────────────────────────────────────────────────────────────────────────
  // CAMP DU VILLAGE
  // ─────────────────────────────────────────────────────────────────────────

  RoleId.voyante: RoleInfo(
    id: RoleId.voyante,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/voyante.png',
    fallbackIcon: Icons.remove_red_eye,
    accent: AppColors.amethyst,
    actsAtNight: true,
  ),

  RoleId.sorciere: RoleInfo(
    id: RoleId.sorciere,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/sorciere.png',
    fallbackIcon: Icons.science,
    accent: AppColors.amethyst,
    actsAtNight: true,
  ),

  RoleId.chasseur: RoleInfo(
    id: RoleId.chasseur,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/chasseur.png',
    fallbackIcon: Icons.gps_fixed,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.cupidon: RoleInfo(
    id: RoleId.cupidon,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/cupidon.png',
    fallbackIcon: Icons.favorite,
    accent: AppColors.amethyst,
    actsAtNight: true,
    firstNightOnly: true,
  ),

  RoleId.petiteFille: RoleInfo(
    id: RoleId.petiteFille,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/petite_fille.png',
    fallbackIcon: Icons.visibility,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.voleur: RoleInfo(
    id: RoleId.voleur,
    camp: Camp.village,
    imageAsset: '',
    fallbackIcon: Icons.swap_horiz,
    accent: AppColors.lantern,
    actsAtNight: true,
    firstNightOnly: true,
  ),

  RoleId.simpleVillageois: RoleInfo(
    id: RoleId.simpleVillageois,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/villageois.png',
    fallbackIcon: Icons.person,
    accent: AppColors.forest,
    actsAtNight: false,
    unique: false,
  ),

  RoleId.ancien: RoleInfo(
    id: RoleId.ancien,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/ancien.png',
    fallbackIcon: Icons.elderly,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.boucEmissaire: RoleInfo(
    id: RoleId.boucEmissaire,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/bouc_emissaire.png',
    fallbackIcon: Icons.how_to_vote,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.idiotDuVillage: RoleInfo(
    id: RoleId.idiotDuVillage,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/idiot_du_village.png',
    fallbackIcon: Icons.sentiment_very_satisfied,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.salvateur: RoleInfo(
    id: RoleId.salvateur,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/salvateur.png',
    fallbackIcon: Icons.shield,
    accent: AppColors.forest,
    actsAtNight: true,
  ),

  RoleId.enfantSauvage: RoleInfo(
    id: RoleId.enfantSauvage,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/enfant_sauvage.png',
    fallbackIcon: Icons.child_care,
    accent: AppColors.forest,
    actsAtNight: true,
    firstNightOnly: true,
  ),

  RoleId.jugeBegue: RoleInfo(
    id: RoleId.jugeBegue,
    camp: Camp.village,
    imageAsset: '',
    fallbackIcon: Icons.gavel,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.servanteDevouee: RoleInfo(
    id: RoleId.servanteDevouee,
    camp: Camp.village,
    imageAsset: '',
    fallbackIcon: Icons.volunteer_activism,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.montreurDours: RoleInfo(
    id: RoleId.montreurDours,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/montreur_d_ours.png',
    fallbackIcon: Icons.pets,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.renard: RoleInfo(
    id: RoleId.renard,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/renard.png',
    fallbackIcon: Icons.pets,
    accent: AppColors.forest,
    actsAtNight: true,
  ),
  RoleId.corbeau: RoleInfo(
    id: RoleId.corbeau,
    camp: Camp.village,
    imageAsset: 'assets/images/roles/corbeau.png',
    fallbackIcon: Icons.handshake,
    accent: AppColors.forest,
    actsAtNight: true,
  ),
};

extension RoleInfoX on RoleId {
  RoleInfo get info => kRoleCatalog[this]!;
}
