// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Thiercelieux';

  @override
  String get continueButtonLabel => 'Continuer';

  @override
  String get confirmButtonLabel => 'Confirmer';

  @override
  String get cancelButtonLabel => 'Annuler';

  @override
  String get goBackToSleepButton => 'Se rendormir';

  @override
  String get nightFallsAgainButton => 'La nuit tombe à nouveau';

  @override
  String get usePowerButton => 'Utiliser mon pouvoir';

  @override
  String get doNotUsePowerButton => 'Ne pas utiliser mon pouvoir';

  @override
  String get campWolves => 'Camp des Loups-Garous';

  @override
  String get campVillagers => 'Camp des Villageois';

  @override
  String get passDeviceToPlural => 'Passe le téléphone aux';

  @override
  String get passDeviceToSingular => 'Passe le téléphone à';

  @override
  String get passDeviceConfirmButton => 'C\'est moi, j\'ai le téléphone';

  @override
  String get homeSubtitle => 'Les Loups-Garous — partie en local';

  @override
  String get resumeGameButton => 'Reprendre la partie';

  @override
  String get newGameButton => 'Nouvelle partie';

  @override
  String get abandonGameDialogTitle => 'Abandonner la partie ?';

  @override
  String get abandonGameDialogMessage =>
      'La partie en cours sera perdue et non comptabilisée dans les statistiques.';

  @override
  String get abandonGameConfirmLabel => 'Abandonner';

  @override
  String get statsButton => 'Statistiques';

  @override
  String get gameSettingsButton => 'Options de jeu';

  @override
  String get gameRulesButton => 'Règles du jeu';

  @override
  String get gameRulesRolesTitle => 'Les rôles';

  @override
  String get newGameTitle => 'Nouvelle partie';

  @override
  String get playerCountHowMany => 'Combien de joueurs ?';

  @override
  String get playerCountRangeDescription =>
      'De 5 à 24 joueurs autour de la table.';

  @override
  String get roleSelectionTitle => 'Répartition des rôles';

  @override
  String get gameSettingsTooltip => 'Options de jeu';

  @override
  String roleSelectionPlayerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count joueurs',
      one: '1 joueur',
    );
    return '$_temp0';
  }

  @override
  String get roleSelectionVoleurExtraCards => ' · +2 cartes pour le Voleur';

  @override
  String roleSelectionTooManyRoles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rôles en trop',
      one: '1 rôle en trop',
    );
    return '$_temp0';
  }

  @override
  String roleSelectionAutoVillagers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Simples Villageois automatiques',
      one: '1 Simple Villageois automatique',
    );
    return '$_temp0';
  }

  @override
  String get playerNamesTitle => 'Les joueurs';

  @override
  String get playerNamesInstruction =>
      'Entrez le prénom de chaque joueur, dans l\'ordre où vous voulez leur faire découvrir leur rôle.';

  @override
  String playerNamesPlayerLabel(int number) {
    return 'Joueur $number';
  }

  @override
  String get playerNamesErrorEmpty => 'Chaque joueur doit avoir un prénom.';

  @override
  String get playerNamesErrorDuplicate =>
      'Deux joueurs ne peuvent pas avoir le même prénom.';

  @override
  String get dealRolesButton => 'Distribuer les rôles';

  @override
  String get roleRevealSubtitle =>
      'Ton rôle va s\'afficher. Assure-toi que personne d\'autre ne regarde l\'écran.';

  @override
  String roleRevealPlayerProgress(int current, int total) {
    return 'Joueur $current / $total';
  }

  @override
  String get roleRevealTapToDiscover => 'Appuie pour découvrir ton rôle';

  @override
  String get roleRevealRevealButton => 'Révéler mon rôle';

  @override
  String get roleRevealHideButton => 'J\'ai vu, masquer mon rôle';

  @override
  String get boucEmissaireTitle => 'Le Bouc Émissaire';

  @override
  String get boucEmissaireInstruction =>
      'Tu dois désigner le joueur qui ne participera pas au prochain vote du village.';

  @override
  String get chasseurTitle => 'Le Chasseur';

  @override
  String get chasseurInstruction =>
      'Tu as été éliminé. Choisis immédiatement un joueur à emporter avec toi.';

  @override
  String get corbeauSubtitle => 'Choisis ta victime';

  @override
  String get corbeauTitle => 'Le Corbeau';

  @override
  String get corbeauInstruction =>
      'Désigne un joueur qui recevra deux voix contre lui au vote.';

  @override
  String get cupidonSubtitle => 'C\'est le rôle de Cupidon. Réveille-toi.';

  @override
  String get cupidonTitle => 'Cupidon';

  @override
  String cupidonInstruction(int count, int max) {
    return 'Désigne les deux Amoureux ($count/$max). Tu peux te choisir toi-même.';
  }

  @override
  String get cupidonConfirmButton => 'Confirmer les Amoureux';

  @override
  String get enfantSauvageTitle => 'L’Enfant Sauvage';

  @override
  String get enfantSauvageInstruction =>
      'Choisis ton modèle. S’il meurt, tu rejoindras immédiatement les Loups-Garous.';

  @override
  String get enfantSauvagePassTo => 'l\'Enfant Sauvage';

  @override
  String get enfantSauvageCheckSubtitle =>
      'C\'est le tour de l\'Enfant Sauvage. Réveille-toi.';

  @override
  String get enfantSauvageModelAliveInstruction =>
      'Ton modèle est toujours vivant : tu restes un simple villageois sans pouvoir particulier.';

  @override
  String get enfantSauvageMutationTitle => 'Mutation';

  @override
  String get enfantSauvageMutationInstruction =>
      'Son modèle est mort : l’Enfant Sauvage rejoint désormais la meute.';

  @override
  String get grandMechantLoupSubtitle =>
      'Réveille-toi seul, les autres Loups peuvent se rendormir.';

  @override
  String get grandMechantLoupTitle => 'Le Grand Méchant Loup';

  @override
  String grandMechantLoupInstructionWithVictim(String name) {
    return 'Les Loups ont déjà désigné $name. Tant qu’aucun Loup n’est mort, tu peux choisir une seconde victime.';
  }

  @override
  String get grandMechantLoupInstructionNoVictim =>
      'Tant qu’aucun Loup n’est mort, tu peux choisir une seconde victime cette nuit.';

  @override
  String get skipPowerThisNightButton =>
      'Ne pas utiliser mon pouvoir cette nuit';

  @override
  String get idiotDuVillageRevealTitle => 'L\'Idiot du Village';

  @override
  String idiotDuVillageRevealInstruction(String name) {
    return 'Le village a voté contre $name, mais il révèle son rôle et survit.';
  }

  @override
  String idiotDuVillageVoteLossMessage(String name) {
    return '$name perd définitivement son droit de vote.';
  }

  @override
  String get infectPereDesLoupsSubtitle =>
      'C\'est ton tour. Réveille-toi seul.';

  @override
  String get infectPereDesLoupsTitle => 'Infect Père des Loups';

  @override
  String infectPereDesLoupsInstructionWithVictim(String name) {
    return 'Les Loups ont désigné $name. Veux-tu l’infecter au lieu de le laisser mourir ?';
  }

  @override
  String get infectPereDesLoupsInstructionNoVictim =>
      'Les Loups n’ont désigné personne cette nuit.';

  @override
  String get infectPereDesLoupsInfectButton => 'Infecter';

  @override
  String get infectPereDesLoupsDoNotInfectButton => 'Ne pas infecter';

  @override
  String get jugeBegueSubtitle =>
      'C\'est le tour du Juge Bègue. Personne d\'autre ne doit savoir qui il est.';

  @override
  String get jugeBegueTitle => 'Le Juge Bègue';

  @override
  String get jugeBegueInstruction =>
      'Une fois par partie, tu peux décider en secret que le vote du village sera rejoué immédiatement.';

  @override
  String get jugeBegueQuestion => 'Veux-tu utiliser ce pouvoir maintenant ?';

  @override
  String get loupBlancSubtitle => 'Choisis ta victime';

  @override
  String get loupBlancTitle => 'Le Loup Blanc';

  @override
  String get loupBlancInstruction =>
      'Choisis un joueur à éliminer secrètement pendant ton tour.';

  @override
  String get loupsSubtitle =>
      'Réveillez-vous et mettez-vous d\'accord en silence sur votre victime.';

  @override
  String get loupsTitle => 'Les Loups-Garous';

  @override
  String get loupsInstruction =>
      'Mettez-vous d’accord en silence, puis désignez votre victime.';

  @override
  String get petiteFilleSubtitle =>
      'C\'est le rôle de la Petite Fille. Réveille-toi.';

  @override
  String get petiteFilleTitle => 'La Petite Fille';

  @override
  String get petiteFilleWarning =>
      'Attention : si les Loups-Garous te surprennent, tu prendras la place de leur victime.';

  @override
  String get petiteFilleSpyButton => 'Entrouvrir les yeux et espionner';

  @override
  String get petiteFilleSleepButton => 'Rester sagement endormie';

  @override
  String get renardSubtitle => 'C\'est le tour du Renard. Réveille-toi.';

  @override
  String get renardTitle => 'Le Renard';

  @override
  String renardInstruction(int count, int max) {
    return 'Choisis trois joueurs voisins ($count/$max).';
  }

  @override
  String get renardInstructionCenter =>
      'Pick a player: they and their two living neighbors will be sniffed.';

  @override
  String get renardResultWolfFound =>
      'Il y a au moins un Loup-Garou parmi ces trois joueurs ! Vous conservez votre flair et pourrez le réutiliser la nuit prochaine.';

  @override
  String get renardResultNoWolf =>
      'Aucun Loup-Garou parmi ces trois joueurs : ils sont tous innocents ! Mais vous perdez définitivement votre pouvoir.';

  @override
  String get renardResultTrioLabel => 'Le joueur désigné et ses deux voisins :';

  @override
  String get salvateurSubtitle => 'Réveille-toi et désigne ton protégé.';

  @override
  String get salvateurTitle => 'Le Salvateur';

  @override
  String get salvateurInstruction =>
      'Choisis le joueur protégé contre les attaques de cette nuit.';

  @override
  String get servanteDevoueeSubtitle =>
      'C\'est le rôle de la Servante Dévouée. Réveille-toi.';

  @override
  String get servanteDevoueeTitle => 'La Servante Dévouée';

  @override
  String servanteDevoueeInstruction(String name) {
    return '$name vient d\'être éliminé(e). Veux-tu prendre son rôle ?';
  }

  @override
  String get servanteDevoueeTakeRoleButton => 'Oui, prendre ce rôle';

  @override
  String get servanteDevoueeKeepRoleButton => 'Non, rester Servante Dévouée';

  @override
  String get sorciereSubtitle => 'C\'est le tour de la Sorcière. Réveille-toi.';

  @override
  String get sorciereTitle => 'La Sorcière';

  @override
  String sorciereInstructionWithVictim(String name) {
    return 'Cette nuit, les Loups-Garous ont désigné $name.';
  }

  @override
  String get sorciereInstructionNoVictim =>
      'Cette nuit, les Loups-Garous n’ont désigné personne.';

  @override
  String sorciereUseLifePotion(String name) {
    return 'Utiliser la potion de vie pour sauver $name';
  }

  @override
  String get sorciereLifePotionAlreadyUsed => 'Potion de vie déjà utilisée.';

  @override
  String get sorciereSelfSaveBlocked =>
      'Vous êtes vous-même la victime désignée, mais vous ne pouvez pas vous sauver vous-même.';

  @override
  String get sorciereNoVictimToSave => 'Aucune victime à sauver cette nuit.';

  @override
  String get sorciereUseDeathPotion => 'Utiliser la potion de mort';

  @override
  String get sorciereChooseDeathPotionTarget =>
      'Choisissez la victime de la potion :';

  @override
  String get sorciereDeathPotionAlreadyUsed => 'Potion de mort déjà utilisée.';

  @override
  String get confirmAndGoBackToSleepButton => 'Confirmer et se rendormir';

  @override
  String get voleurSubtitle => 'C\'est le rôle du Voleur. Réveille-toi.';

  @override
  String get voleurTitle => 'Le Voleur';

  @override
  String get voleurBothWolvesWarning =>
      'Les deux cartes sont des Loups-Garous : tu es obligé d’en prendre une !';

  @override
  String get voleurExchangeRoleButton => 'Échanger mon rôle contre celle-ci';

  @override
  String get voleurKeepCurrentRoleButton => 'Garder mon rôle actuel';

  @override
  String get voyanteSubtitle => 'C\'est le tour de la Voyante. Réveille-toi.';

  @override
  String get voyanteTitle => 'La Voyante';

  @override
  String voyanteObservedTargetInstruction(String name) {
    return 'Tu as observé $name. Son rôle est révélé.';
  }

  @override
  String get voyanteDoneButton => 'J\'ai vu, continuer';

  @override
  String get voyanteChooseTargetInstruction =>
      'Choisis un joueur pour découvrir son rôle.';

  @override
  String dayRevealDayRises(int day) {
    return 'Le jour $day se lève';
  }

  @override
  String get dayRevealNoDeaths => 'Miracle ! Personne n\'est mort cette nuit.';

  @override
  String get dayRevealMultipleDeaths => 'Le village pleure ses morts...';

  @override
  String get dayRevealSingleDeath => 'Le village pleure son mort...';

  @override
  String get montreurDoursGrowlsText =>
      'L\'ours du Montreur d\'Ours grogne : un Loup-Garou se cache parmi ses voisins.';

  @override
  String get montreurDoursCalmText =>
      'L\'ours du Montreur d\'Ours reste calme cette nuit.';

  @override
  String get villageWakesUpButton => 'Le village se réveille';

  @override
  String get deathCauseDevoreParLesLoups => 'dévoré(e) par les Loups-Garous';

  @override
  String get deathCausePotionDeMort => 'empoisonné(e) par la Sorcière';

  @override
  String get deathCauseChagrinDAmourCupidon => 'mort(e) de chagrin d\'amour';

  @override
  String get deathCauseVengeanceDuChasseur => 'abattu(e) par le Chasseur';

  @override
  String get deathCauseVote => 'pendu(e) par le village';

  @override
  String get deathCauseTueParLoupBlanc => 'dévoré(e) par le Loup Blanc';

  @override
  String get debateTitle => 'Débat';

  @override
  String get debateVillageDebates => 'Le village débat';

  @override
  String get debateInstruction =>
      'Les survivants discutent pour démasquer les Loups-Garous. Les Loups doivent bluffer pour se faire passer pour des villageois.';

  @override
  String get goToVoteButton => 'Passer au vote';

  @override
  String get endGameTitle => 'Fin de la partie';

  @override
  String get endGameWinnerVillage => 'Le Village l\'emporte !';

  @override
  String get endGameWinnerWolves => 'Les Loups-Garous l\'emportent !';

  @override
  String get endGameWinnerLovers => 'Les Amoureux l\'emportent !';

  @override
  String get endGameWinnerSolo => 'Il l\'emporte !';

  @override
  String get endGameViewStatsButton => 'Voir les statistiques';

  @override
  String get endGameReturnHomeButton => 'Retour à l\'accueil';

  @override
  String get mayorElectionExplainText => 'Vous allez élire le Capitaine';

  @override
  String get mayorElectionExplainContinueButton => 'Continuer vers le vote';

  @override
  String get mayorElectionTitle => 'Élection du maire';

  @override
  String get mayorElectionInstruction =>
      'Chaque joueur désigne le futur maire du village.';

  @override
  String get mayorRevealTitle => 'Le village a choisi son maire';

  @override
  String get mayorRevealSubtitle =>
      'Son vote comptera double en cas d\'égalité.';

  @override
  String get mayorRevealContinueButton => 'Continuer vers le débat';

  @override
  String get mayorSuccessionTitle => 'Succession du maire';

  @override
  String get mayorSuccessionInstruction =>
      'Le maire est mort. Avant de rendre son dernier souffle, il désigne son successeur.';

  @override
  String get nightIntroFirstNight => 'La nuit tombe sur Thiercelieux';

  @override
  String nightIntroOtherNights(int night) {
    return 'La nuit $night tombe à nouveau';
  }

  @override
  String get nightIntroSleepInstruction =>
      'Tout le village ferme les yeux et s\'endort.\nPose le téléphone au centre de la table.';

  @override
  String get nightIntroEveryoneAsleepButton => 'Tout le monde dort';

  @override
  String get nightGoBackToSleepTitle => 'Tu peux te rendormir';

  @override
  String get nightGoBackToSleepInstruction =>
      'Referme les yeux. Le village continue de dormir...';

  @override
  String get voteSecretSubtitle =>
      'Vote secret : les autres joueurs ne doivent pas regarder.';

  @override
  String get voteRunoffTieNotice =>
      'Égalité au tour précédent — on revote entre les candidats à égalité.';

  @override
  String get powerLossPrivatePassSubtitle =>
      'Une information privée va s\'afficher. Assure-toi que personne d\'autre ne regarde l\'écran.';

  @override
  String get powerLossTitle => 'La sagesse s\'éteint';

  @override
  String powerLossPlayerCount(int current, int total) {
    return 'Joueur $current / $total';
  }

  @override
  String get powerLossAncienHangedHeadline =>
      'Le village a fait pendre l\'Ancien par erreur.';

  @override
  String get powerLossReallyLostNotice =>
      'Privé(e) de sa sagesse, tu perds ton don :';

  @override
  String get powerLossNowSimpleVillageois =>
      'Tu es désormais un Simple Villageois.';

  @override
  String get powerLossFakeGiftNotice =>
      'La sagesse de l\'Ancien t\'accorde un don :';

  @override
  String get powerLossFakeGiftName => 'Don du Sommeil Profond';

  @override
  String get powerLossFakeGiftUseless =>
      '...totalement inutile. Rien ne change pour toi.';

  @override
  String get powerLossKeepSecretWarning =>
      'Garde-le pour toi : personne d\'autre à la table ne doit savoir ce qui s\'est affiché sur cet écran.';

  @override
  String get powerLossUnderstoodButton => 'J\'ai compris, masquer';

  @override
  String get powerLossPublicExplanation =>
      'Privés de sa sagesse, certains villageois ont senti leur don s\'éteindre... mais eux seuls savent lesquels.';

  @override
  String get powerLossNightFallsAgainButton => 'La nuit tombe à nouveau';

  @override
  String get villageVoteTitle => 'Vote du village';

  @override
  String get villageVoteInstruction =>
      'Chaque joueur désigne le suspect à éliminer.';

  @override
  String get voteResultTitle => 'Résultat du vote';

  @override
  String get voteResultNoDeaths => 'Le village n\'a éliminé personne.';

  @override
  String get voteResultVillageHasVoted => 'Le village a voté...';

  @override
  String get gameSettingsTitle => 'Options de jeu';

  @override
  String get statsTitle => 'Statistiques';

  @override
  String get statsResetTooltip => 'Réinitialiser les statistiques';

  @override
  String get statsResetDialogTitle => 'Réinitialiser les statistiques ?';

  @override
  String get statsResetDialogMessage =>
      'Tout l\'historique des parties sera définitivement supprimé.';

  @override
  String get statsResetConfirmLabel => 'Réinitialiser';

  @override
  String get statsEmptyMessage =>
      'Aucune partie enregistrée pour l\'instant.\nJouez une partie complète pour voir apparaître vos statistiques ici.';

  @override
  String statsCardSummary(int gamesPlayed, int winRate) {
    String _temp0 = intl.Intl.pluralLogic(
      gamesPlayed,
      locale: localeName,
      other: '$gamesPlayed parties',
      one: '1 partie',
    );
    return '$_temp0 · $winRate% de victoires';
  }

  @override
  String statsFavoriteSuffix(String roleName) {
    return ' · $roleName favori';
  }

  @override
  String statsWinsAbbr(int wins) {
    return '$wins V';
  }

  @override
  String statsLossesAbbr(int losses) {
    return '$losses D';
  }

  @override
  String get gameProgressSheetTitle => 'Résumé de la partie';

  @override
  String gameProgressNightCounter(int number) {
    return 'Nuit $number';
  }

  @override
  String gameProgressDayCounter(int number) {
    return 'Jour $number';
  }

  @override
  String get gameProgressStarting => 'La partie commence...';

  @override
  String get gameProgressInProgress => 'En cours';

  @override
  String get gameProgressInProgressDots => 'En cours...';

  @override
  String gameProgressNightTitle(int number) {
    return 'Nuit $number';
  }

  @override
  String gameProgressDayTitle(int number) {
    return 'Jour $number';
  }

  @override
  String get phaseNightVoleur => 'Le Voleur';

  @override
  String get phaseNightCupidon => 'Cupidon';

  @override
  String get phaseNightEnfantSauvage => 'L\'Enfant Sauvage — choix du modèle';

  @override
  String get phaseNightSalvateur => 'Le Salvateur';

  @override
  String get phaseNightVoyante => 'La Voyante';

  @override
  String get phaseNightLoups => 'Les Loups-Garous';

  @override
  String get phaseNightPetiteFille => 'La Petite Fille';

  @override
  String get phaseNightLoupBlanc => 'Le Loup Blanc';

  @override
  String get phaseNightGrandMechantLoup => 'Le Grand Méchant Loup';

  @override
  String get phaseNightEnfantSauvageCheck => 'L\'Enfant Sauvage';

  @override
  String get phaseNightInfectPereDesLoups => 'Infect Père des Loups';

  @override
  String get phaseNightRenard => 'Le Renard';

  @override
  String get phaseNightCorbeau => 'Le Corbeau';

  @override
  String get phaseNightSorciere => 'La Sorcière';

  @override
  String get phaseChasseurRevange => 'Riposte du Chasseur';

  @override
  String get phaseSuccessionMaire => 'Succession du Maire';

  @override
  String get phaseEnfantsauvageReveal => 'Mutation de l\'Enfant Sauvage';

  @override
  String get phaseDayReveal => 'Réveil du village';

  @override
  String get phaseMayorElectionExplain => 'Élection du maire';

  @override
  String get phaseMayorElection => 'Vote pour le maire';

  @override
  String get phaseMayorReveal => 'Résultat de l\'élection';

  @override
  String get phaseDebate => 'Débat';

  @override
  String get phaseJugeBegueDecision => 'Le Juge Bègue';

  @override
  String get phaseVillageVote => 'Vote du village';

  @override
  String get phaseVoteResult => 'Résultat du vote';

  @override
  String get phaseVillagePowerLoss => 'Perte des pouvoirs';

  @override
  String get phaseServanteDevouee => 'La Servante Dévouée';

  @override
  String get phaseBoucEmissaire => 'Le Bouc Émissaire';

  @override
  String get phaseIdiotduvillageCivicRightLoss => 'Perte de droit civique';

  @override
  String get phaseEndGame => 'Fin de partie';
}
