import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Camp d'appartenance d'un rôle. Les Amoureux ne sont pas un camp à part :
/// c'est un statut transversal (voir Player.loverId) qui peut créer une
/// victoire spéciale si les deux amoureux sont de camps différents.
enum Camp { loups, village }

enum RoleId {
  loupGarou,
  voyante,
  sorciere,
  chasseur,
  cupidon,
  petiteFille,
  voleur,
  simpleVillageois,
}

/// Cause de décès, utile pour l'affichage et pour la page de stats.
enum DeathCause {
  devoreParLesLoups,
  potionDeMort,
  chagrinDAmour,
  vengeanceDuChasseur,
  vote,
}

class RoleInfo {
  final RoleId id;
  final String name;
  final String nameShort;
  final Camp camp;
  final String description;
  final String nightInstruction; // ce qu'on affiche pendant son tour de nuit
  final String imageAsset;
  final IconData fallbackIcon;
  final Color accent;
  final bool actsAtNight;
  final bool firstNightOnly;
  final bool unique; // un seul exemplaire possible dans la partie

  const RoleInfo({
    required this.id,
    required this.name,
    required this.nameShort,
    required this.camp,
    required this.description,
    required this.nightInstruction,
    required this.imageAsset,
    required this.fallbackIcon,
    required this.accent,
    this.actsAtNight = false,
    this.firstNightOnly = false,
    this.unique = true,
  });
}

/// Catalogue statique de tous les rôles disponibles dans le jeu de base.
const Map<RoleId, RoleInfo> kRoleCatalog = {
  RoleId.loupGarou: RoleInfo(
    id: RoleId.loupGarou,
    name: 'Loup-Garou',
    nameShort: 'Loup',
    camp: Camp.loups,
    description:
        "Chaque nuit, les Loups-Garous se réunissent pour dévorer un villageois. "
        "Le jour, ils se fondent dans la foule et bluffent pour ne pas être démasqués.",
    nightInstruction:
        "Mettez-vous d'accord en silence, puis désignez votre victime.",
    imageAsset: 'assets/images/roles/loup_garou.png',
    fallbackIcon: Icons.dark_mode,
    accent: AppColors.blood,
    actsAtNight: true,
    unique: false,
  ),
  RoleId.voyante: RoleInfo(
    id: RoleId.voyante,
    name: 'La Voyante',
    nameShort: 'Voyante',
    camp: Camp.village,
    description:
        "Chaque nuit, elle découvre en secret la véritable identité d'un joueur de son choix.",
    nightInstruction: "Choisissez un joueur pour découvrir son rôle.",
    imageAsset: 'assets/images/roles/voyante.png',
    fallbackIcon: Icons.remove_red_eye,
    accent: AppColors.amethyst,
    actsAtNight: true,
  ),
  RoleId.sorciere: RoleInfo(
    id: RoleId.sorciere,
    name: 'La Sorcière',
    nameShort: 'Sorcière',
    camp: Camp.village,
    description:
        "Elle possède deux potions à usage unique : une potion de vie pour sauver la "
        "victime des loups, une potion de mort pour éliminer un joueur de son choix.",
    nightInstruction:
        "Découvrez la victime des loups, puis utilisez vos potions si vous le souhaitez.",
    imageAsset: 'assets/images/roles/sorciere.png',
    fallbackIcon: Icons.science,
    accent: AppColors.amethyst,
    actsAtNight: true,
  ),
  RoleId.chasseur: RoleInfo(
    id: RoleId.chasseur,
    name: 'Le Chasseur',
    nameShort: 'Chasseur',
    camp: Camp.village,
    description:
        "S'il meurt, de nuit comme de jour, il réplique aussitôt en abattant un autre joueur de son choix.",
    nightInstruction: "",
    imageAsset: 'assets/images/roles/chasseur.png',
    fallbackIcon: Icons.gps_fixed,
    accent: AppColors.forest,
    actsAtNight: false,
  ),
  RoleId.cupidon: RoleInfo(
    id: RoleId.cupidon,
    name: 'Cupidon',
    nameShort: 'Cupidon',
    camp: Camp.village,
    description:
        "La première nuit seulement, il désigne deux joueurs qui tombent amoureux. "
        "Si l'un meurt, l'autre meurt aussitôt de chagrin.",
    nightInstruction:
        "Désignez les deux Amoureux (vous pouvez vous choisir vous-même).",
    imageAsset: 'assets/images/roles/cupidon.png',
    fallbackIcon: Icons.favorite,
    accent: AppColors.amethyst,
    actsAtNight: true,
    firstNightOnly: true,
  ),
  RoleId.petiteFille: RoleInfo(
    id: RoleId.petiteFille,
    name: 'La Petite Fille',
    nameShort: 'Petite Fille',
    camp: Camp.village,
    description:
        "Pendant le tour des loups, elle peut entrouvrir les yeux pour espionner. "
        "Si elle se fait surprendre, elle meurt à la place de la victime prévue.",
    nightInstruction:
        "Vous pouvez tenter d'espionner les loups. Restez discrète...",
    imageAsset: 'assets/images/roles/petite_fille.png',
    fallbackIcon: Icons.visibility,
    accent: AppColors.forest,
    actsAtNight: true,
  ),
  RoleId.voleur: RoleInfo(
    id: RoleId.voleur,
    name: 'Le Voleur',
    nameShort: 'Voleur',
    camp: Camp.village,
    description:
        "La première nuit, il regarde deux cartes restées sur la table et peut échanger "
        "son rôle contre l'une d'elles (obligatoire si ce sont deux Loups-Garous).",
    nightInstruction:
        "Regardez les deux cartes restantes et choisissez d'échanger ou non.",
    imageAsset: 'assets/images/roles/voleur.png',
    fallbackIcon: Icons.swap_horiz,
    accent: AppColors.lantern,
    actsAtNight: true,
    firstNightOnly: true,
  ),
  RoleId.simpleVillageois: RoleInfo(
    id: RoleId.simpleVillageois,
    name: 'Simple Villageois',
    nameShort: 'Villageois',
    camp: Camp.village,
    description:
        "Aucun pouvoir particulier. Son arme : l'observation, l'écoute, et le vote le jour venu.",
    nightInstruction: "",
    imageAsset: 'assets/images/roles/simple_villageois.png',
    fallbackIcon: Icons.person,
    accent: AppColors.forest,
    actsAtNight: false,
    unique: false,
  ),
};

extension RoleInfoX on RoleId {
  RoleInfo get info => kRoleCatalog[this]!;
}
