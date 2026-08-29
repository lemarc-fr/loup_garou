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

/// Catalogue statique de tous les rôles disponibles dans le jeu.
const Map<RoleId, RoleInfo> kRoleCatalog = {
  // ─────────────────────────────────────────────────────────────────────────
  // CAMP DES LOUPS
  // ─────────────────────────────────────────────────────────────────────────

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

  RoleId.grandMechantLoup: RoleInfo(
    id: RoleId.grandMechantLoup,
    name: 'Grand Méchant Loup',
    nameShort: 'Grand Méchant Loup',
    camp: Camp.loups,
    description:
    "Il agit avec les autres Loups-Garous et peut, tant qu'aucun Loup-Garou "
        "n'est mort, dévorer une seconde victime chaque nuit.",
    nightInstruction:
    "Avec les autres loups, désignez la victime. Vous pouvez ensuite désigner une seconde victime.",
    imageAsset: 'assets/images/roles/grand_mechant_loup.png',
    fallbackIcon: Icons.pets,
    accent: AppColors.blood,
    actsAtNight: true,
  ),

  RoleId.infectPereDesLoups: RoleInfo(
    id: RoleId.infectPereDesLoups,
    name: 'Infect Père des Loups',
    nameShort: 'Infect',
    camp: Camp.loups,
    description:
    "Il est un Loup-Garou. Une fois par partie, il peut infecter la victime "
        "des loups afin de la transformer en Loup-Garou au lieu de la tuer.",
    nightInstruction:
    "Désignez la victime des loups, puis décidez si vous utilisez votre pouvoir d'infection.",
    imageAsset: 'assets/images/roles/infect_pere_des_loups.png',
    fallbackIcon: Icons.coronavirus,
    accent: AppColors.blood,
    actsAtNight: true,
  ),

  RoleId.loupBlanc: RoleInfo(
    id: RoleId.loupBlanc,
    name: 'Loup-Garou Blanc',
    nameShort: 'Loup Blanc',
    camp: Camp.seul,
    description:
    "Il est considéré comme un Loup-Garou par les autres loups, mais son "
        "objectif est de rester le dernier survivant. Une nuit sur deux, il "
        "peut éliminer secrètement un autre Loup-Garou.",
    nightInstruction:
    "Les loups désignent leur victime. Si votre pouvoir est disponible, vous pouvez éliminer un loup.",
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
    "Elle possède deux potions à usage unique : une potion de vie pour sauver "
        "la victime des loups, et une potion de mort pour éliminer un joueur de son choix.",
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
    actsAtNight: false,
  ),

  RoleId.voleur: RoleInfo(
    id: RoleId.voleur,
    name: 'Le Voleur',
    nameShort: 'Voleur',
    camp: Camp.village,
    description:
    "La première nuit, il regarde deux cartes restées sur la table et peut échanger "
        "son rôle contre l'une d'elles.",
    nightInstruction:
    "Regardez les deux cartes restantes et choisissez d'échanger ou non.",
    imageAsset: '',
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
    imageAsset: 'assets/images/roles/villageois.png',
    fallbackIcon: Icons.person,
    accent: AppColors.forest,
    actsAtNight: false,
    unique: false,
  ),

  RoleId.ancien: RoleInfo(
    id: RoleId.ancien,
    name: "L'Ancien",
    nameShort: 'Ancien',
    camp: Camp.village,
    description:
    "Grâce à sa sagesse, il résiste à une première attaque des Loups-Garous. "
        "S'il est tué par le village, les villageois à pouvoir perdent leurs capacités.",
    nightInstruction: "",
    imageAsset: 'assets/images/roles/ancien.png',
    fallbackIcon: Icons.elderly,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.boucEmissaire: RoleInfo(
    id: RoleId.boucEmissaire,
    name: 'Le Bouc Émissaire',
    nameShort: 'Bouc Émissaire',
    camp: Camp.village,
    description:
    "S'il est éliminé par le vote du village, il peut désigner un joueur "
        "qui ne se réveillera pas lors de la nuit suivante.",
    nightInstruction: "",
    imageAsset: '',
    fallbackIcon: Icons.how_to_vote,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.idiotDuVillage: RoleInfo(
    id: RoleId.idiotDuVillage,
    name: "L'Idiot du Village",
    nameShort: 'Idiot',
    camp: Camp.village,
    description:
    "S'il est condamné par le vote du village, il révèle son rôle et reste en vie, "
        "mais perd définitivement son droit de vote.",
    nightInstruction: "",
    imageAsset: '',
    fallbackIcon: Icons.sentiment_very_satisfied,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.salvateur: RoleInfo(
    id: RoleId.salvateur,
    name: 'Le Salvateur',
    nameShort: 'Salvateur',
    camp: Camp.village,
    description:
    "Chaque nuit, il protège un joueur contre les Loups-Garous. "
        "Il ne peut pas protéger le même joueur deux nuits consécutives.",
    nightInstruction:
    "Choisissez le joueur que vous souhaitez protéger cette nuit.",
    imageAsset: '',
    fallbackIcon: Icons.shield,
    accent: AppColors.forest,
    actsAtNight: true,
  ),

  RoleId.enfantSauvage: RoleInfo(
    id: RoleId.enfantSauvage,
    name: "L'Enfant Sauvage",
    nameShort: 'Enfant Sauvage',
    camp: Camp.village,
    description:
    "Au début de la partie, il choisit un modèle parmi les autres joueurs. "
        "Si son modèle meurt, il devient Loup-Garou.",
    nightInstruction:
    "Choisissez le joueur qui sera votre modèle.",
    imageAsset: 'assets/images/roles/enfant_sauvage.png',
    fallbackIcon: Icons.child_care,
    accent: AppColors.forest,
    actsAtNight: true,
    firstNightOnly: true,
  ),

  RoleId.jugeBegue: RoleInfo(
    id: RoleId.jugeBegue,
    name: 'Le Juge Bègue',
    nameShort: 'Juge Bègue',
    camp: Camp.village,
    description:
    "Une fois par partie, il peut décider secrètement que le vote du village "
        "sera rejoué immédiatement.",
    nightInstruction: "",
    imageAsset: '',
    fallbackIcon: Icons.gavel,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.servanteDevouee: RoleInfo(
    id: RoleId.servanteDevouee,
    name: 'La Servante Dévouée',
    nameShort: 'Servante',
    camp: Camp.village,
    description:
    "Lorsqu'un joueur est éliminé par le vote, elle peut révéler son rôle "
        "et prendre immédiatement sa carte.",
    nightInstruction: "",
    imageAsset: '',
    fallbackIcon: Icons.volunteer_activism,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.montreurDours: RoleInfo(
    id: RoleId.montreurDours,
    name: "Le Montreur d'Ours",
    nameShort: "Montreur d'Ours",
    camp: Camp.village,
    description:
    "Chaque matin, si un Loup-Garou se trouve parmi ses voisins encore vivants, "
        "l'ours grogne.",
    nightInstruction: "",
    imageAsset: 'assets/images/roles/montreur_d_ours.png',
    fallbackIcon: Icons.pets,
    accent: AppColors.forest,
    actsAtNight: false,
  ),

  RoleId.renard: RoleInfo(
    id: RoleId.renard,
    name: 'Le Renard',
    nameShort: 'Renard',
    camp: Camp.village,
    description:
    "La nuit, il peut désigner un groupe de trois joueurs. Le meneur lui indique "
        "si au moins un Loup-Garou se trouve parmi eux.",
    nightInstruction:
    "Choisissez trois joueurs voisins pour utiliser votre flair.",
    imageAsset: 'assets/images/roles/renard.png',
    fallbackIcon: Icons.pets,
    accent: AppColors.forest,
    actsAtNight: true,
  ),
};

extension RoleInfoX on RoleId {
  RoleInfo get info => kRoleCatalog[this]!;
}
