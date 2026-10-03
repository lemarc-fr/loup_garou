// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Thiercelieux';

  @override
  String get continueButtonLabel => 'Continue';

  @override
  String get confirmButtonLabel => 'Confirm';

  @override
  String get cancelButtonLabel => 'Cancel';

  @override
  String get goBackToSleepButton => 'Go back to sleep';

  @override
  String get nightFallsAgainButton => 'Night falls again';

  @override
  String get usePowerButton => 'Use my power';

  @override
  String get doNotUsePowerButton => 'Do not use my power';

  @override
  String get campWolves => 'Werewolf Team';

  @override
  String get campVillagers => 'Villager Team';

  @override
  String get passDeviceToPlural => 'Pass the phone to the';

  @override
  String get passDeviceToSingular => 'Pass the phone to';

  @override
  String get passDeviceConfirmButton => 'It\'s me, I have the phone';

  @override
  String get homeSubtitle => 'The Werewolves — local party game';

  @override
  String get resumeGameButton => 'Resume game';

  @override
  String get newGameButton => 'New game';

  @override
  String get abandonGameDialogTitle => 'Abandon game?';

  @override
  String get abandonGameDialogMessage =>
      'The current game will be lost and not recorded in statistics.';

  @override
  String get abandonGameConfirmLabel => 'Abandon';

  @override
  String get statsButton => 'Statistics';

  @override
  String get gameSettingsButton => 'Game settings';

  @override
  String get gameRulesButton => 'Game rules';

  @override
  String get gameRulesRolesTitle => 'Roles';

  @override
  String get newGameTitle => 'New game';

  @override
  String get playerCountHowMany => 'How many players?';

  @override
  String get playerCountRangeDescription =>
      'From 5 to 24 players around the table.';

  @override
  String get roleSelectionTitle => 'Role distribution';

  @override
  String get gameSettingsTooltip => 'Game settings';

  @override
  String roleSelectionPlayerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count players',
      one: '1 player',
    );
    return '$_temp0';
  }

  @override
  String get roleSelectionVoleurExtraCards => ' · +2 cards for the Thief';

  @override
  String roleSelectionTooManyRoles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roles too many',
      one: '1 role too many',
    );
    return '$_temp0';
  }

  @override
  String roleSelectionAutoVillagers(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count automatic Simple Villagers',
      one: '1 automatic Simple Villager',
    );
    return '$_temp0';
  }

  @override
  String get playerNamesTitle => 'Players';

  @override
  String get playerNamesInstruction =>
      'Enter each player\'s name in the order they will discover their role.';

  @override
  String playerNamesPlayerLabel(int number) {
    return 'Player $number';
  }

  @override
  String get playerNamesErrorEmpty => 'Each player must have a name.';

  @override
  String get playerNamesErrorDuplicate =>
      'Two players cannot have the same name.';

  @override
  String get dealRolesButton => 'Deal roles';

  @override
  String get roleRevealSubtitle =>
      'Your role will be displayed. Make sure no one else is looking at the screen.';

  @override
  String roleRevealPlayerProgress(int current, int total) {
    return 'Player $current / $total';
  }

  @override
  String get roleRevealTapToDiscover => 'Tap to discover your role';

  @override
  String get roleRevealRevealButton => 'Reveal my role';

  @override
  String get roleRevealHideButton => 'I\'ve seen it, hide my role';

  @override
  String get boucEmissaireTitle => 'The Scapegoat';

  @override
  String get boucEmissaireInstruction =>
      'You must designate the player who will not participate in the next village vote.';

  @override
  String get chasseurTitle => 'The Hunter';

  @override
  String get chasseurInstruction =>
      'You have been eliminated. Choose immediately a player to take down with you.';

  @override
  String get corbeauSubtitle => 'Choose your victim';

  @override
  String get corbeauTitle => 'The Raven';

  @override
  String get corbeauInstruction =>
      'Designate a player who will receive two votes against them in the village vote.';

  @override
  String get cupidonSubtitle => 'It is Cupid\'s turn. Wake up.';

  @override
  String get cupidonTitle => 'Cupid';

  @override
  String cupidonInstruction(int count, int max) {
    return 'Designate the two Lovers ($count/$max). You can choose yourself.';
  }

  @override
  String get cupidonConfirmButton => 'Confirm Lovers';

  @override
  String get enfantSauvageTitle => 'The Wild Child';

  @override
  String get enfantSauvageInstruction =>
      'Choose your role model. If they die, you will immediately join the Werewolves.';

  @override
  String get enfantSauvagePassTo => 'the Wild Child';

  @override
  String get enfantSauvageCheckSubtitle =>
      'It is the Wild Child\'s turn. Wake up.';

  @override
  String get enfantSauvageModelAliveInstruction =>
      'Your role model is still alive: you remain a simple villager without any special power.';

  @override
  String get enfantSauvageMutationTitle => 'Transformation';

  @override
  String get enfantSauvageMutationInstruction =>
      'Their role model has died: the Wild Child now joins the pack.';

  @override
  String get grandMechantLoupSubtitle =>
      'Wake up alone, the other Werewolves may go back to sleep.';

  @override
  String get grandMechantLoupTitle => 'The Big Bad Wolf';

  @override
  String grandMechantLoupInstructionWithVictim(String name) {
    return 'The Werewolves have already chosen $name. As long as no Werewolf has died, you may choose a second victim.';
  }

  @override
  String get grandMechantLoupInstructionNoVictim =>
      'As long as no Werewolf has died, you may choose a second victim tonight.';

  @override
  String get skipPowerThisNightButton => 'Do not use my power tonight';

  @override
  String get idiotDuVillageRevealTitle => 'The Village Idiot';

  @override
  String idiotDuVillageRevealInstruction(String name) {
    return 'The village voted against $name, but they reveal their role and survive.';
  }

  @override
  String idiotDuVillageVoteLossMessage(String name) {
    return '$name permanently loses the right to vote.';
  }

  @override
  String get infectPereDesLoupsSubtitle => 'It is your turn. Wake up alone.';

  @override
  String get infectPereDesLoupsTitle => 'Vile Father of Wolves';

  @override
  String infectPereDesLoupsInstructionWithVictim(String name) {
    return 'The Werewolves chose $name. Do you want to infect them instead of letting them die?';
  }

  @override
  String get infectPereDesLoupsInstructionNoVictim =>
      'The Werewolves did not choose anyone tonight.';

  @override
  String get infectPereDesLoupsInfectButton => 'Infect';

  @override
  String get infectPereDesLoupsDoNotInfectButton => 'Do not infect';

  @override
  String get jugeBegueSubtitle =>
      'It is the Stuttering Judge\'s turn. Nobody else must know who they are.';

  @override
  String get jugeBegueTitle => 'The Stuttering Judge';

  @override
  String get jugeBegueInstruction =>
      'Once per game, you can secretly decide that the village vote will be replayed immediately.';

  @override
  String get jugeBegueQuestion => 'Do you want to use this power now?';

  @override
  String get loupBlancSubtitle => 'Choose your victim';

  @override
  String get loupBlancTitle => 'The White Werewolf';

  @override
  String get loupBlancInstruction =>
      'Choose a player to eliminate secretly during your turn.';

  @override
  String get loupsSubtitle => 'Wake up and silently agree on your victim.';

  @override
  String get loupsTitle => 'The Werewolves';

  @override
  String get loupsInstruction =>
      'Agree in silence, then designate your victim.';

  @override
  String get petiteFilleSubtitle => 'It is the Little Girl\'s turn. Wake up.';

  @override
  String get petiteFilleTitle => 'The Little Girl';

  @override
  String get petiteFilleWarning =>
      'Warning: if the Werewolves catch you, you will take the place of their victim.';

  @override
  String get petiteFilleSpyButton => 'Peek and spy';

  @override
  String get petiteFilleSleepButton => 'Stay peacefully asleep';

  @override
  String get renardSubtitle => 'It is the Fox\'s turn. Wake up.';

  @override
  String get renardTitle => 'The Fox';

  @override
  String renardInstruction(int count, int max) {
    return 'Choose three neighboring players ($count/$max).';
  }

  @override
  String get salvateurSubtitle => 'Wake up and designate the one you protect.';

  @override
  String get salvateurTitle => 'The Bodyguard';

  @override
  String get salvateurInstruction =>
      'Choose the player protected from attacks tonight.';

  @override
  String get servanteDevoueeSubtitle =>
      'It is the Devoted Servant\'s turn. Wake up.';

  @override
  String get servanteDevoueeTitle => 'The Devoted Servant';

  @override
  String servanteDevoueeInstruction(String name) {
    return '$name has just been eliminated. Do you want to take their role?';
  }

  @override
  String get servanteDevoueeTakeRoleButton => 'Yes, take this role';

  @override
  String get servanteDevoueeKeepRoleButton => 'No, remain Devoted Servant';

  @override
  String get sorciereSubtitle => 'It is the Witch\'s turn. Wake up.';

  @override
  String get sorciereTitle => 'The Witch';

  @override
  String sorciereInstructionWithVictim(String name) {
    return 'Tonight, the Werewolves chose $name.';
  }

  @override
  String get sorciereInstructionNoVictim =>
      'Tonight, the Werewolves did not choose anyone.';

  @override
  String sorciereUseLifePotion(String name) {
    return 'Use life potion to save $name';
  }

  @override
  String get sorciereLifePotionAlreadyUsed => 'Life potion already used.';

  @override
  String get sorciereSelfSaveBlocked =>
      'You are the designated victim, but you cannot save yourself.';

  @override
  String get sorciereNoVictimToSave => 'No victim to save tonight.';

  @override
  String get sorciereUseDeathPotion => 'Use death potion';

  @override
  String get sorciereChooseDeathPotionTarget =>
      'Choose the victim of the potion:';

  @override
  String get sorciereDeathPotionAlreadyUsed => 'Death potion already used.';

  @override
  String get confirmAndGoBackToSleepButton => 'Confirm and go back to sleep';

  @override
  String get voleurSubtitle => 'It is the Thief\'s turn. Wake up.';

  @override
  String get voleurTitle => 'The Thief';

  @override
  String get voleurBothWolvesWarning =>
      'Both cards are Werewolves: you must take one!';

  @override
  String get voleurExchangeRoleButton => 'Exchange my role for this one';

  @override
  String get voleurKeepCurrentRoleButton => 'Keep my current role';

  @override
  String get voyanteSubtitle => 'It is the Seer\'s turn. Wake up.';

  @override
  String get voyanteTitle => 'The Seer';

  @override
  String voyanteObservedTargetInstruction(String name) {
    return 'You observed $name. Their role is revealed.';
  }

  @override
  String get voyanteDoneButton => 'I have seen, continue';

  @override
  String get voyanteChooseTargetInstruction =>
      'Choose a player to discover their role.';

  @override
  String dayRevealDayRises(int day) {
    return 'Day $day rises';
  }

  @override
  String get dayRevealNoDeaths => 'Miracle! Nobody died tonight.';

  @override
  String get dayRevealMultipleDeaths => 'The village mourns its dead...';

  @override
  String get dayRevealSingleDeath => 'The village mourns its dead...';

  @override
  String get montreurDoursGrowlsText =>
      'The Bear Tamer\'s bear growls: a Werewolf is hiding among its neighbors.';

  @override
  String get montreurDoursCalmText =>
      'The Bear Tamer\'s bear remains calm tonight.';

  @override
  String get villageWakesUpButton => 'The village wakes up';

  @override
  String get deathCauseDevoreParLesLoups => 'devoured by Werewolves';

  @override
  String get deathCausePotionDeMort => 'poisoned by the Witch';

  @override
  String get deathCauseChagrinDAmourCupidon => 'died of a broken heart';

  @override
  String get deathCauseVengeanceDuChasseur => 'shot by the Hunter';

  @override
  String get deathCauseVote => 'hanged by the village';

  @override
  String get deathCauseTueParLoupBlanc => 'killed by the White Werewolf';

  @override
  String get debateTitle => 'Debate';

  @override
  String get debateVillageDebates => 'The village debates';

  @override
  String get debateInstruction =>
      'The survivors discuss to unmask Werewolves. Werewolves must bluff to pass as villagers.';

  @override
  String get goToVoteButton => 'Proceed to vote';

  @override
  String get endGameTitle => 'Game Over';

  @override
  String get endGameWinnerVillage => 'The Village wins!';

  @override
  String get endGameWinnerWolves => 'The Werewolves win!';

  @override
  String get endGameWinnerLovers => 'The Lovers win!';

  @override
  String get endGameWinnerSolo => 'Solo victory!';

  @override
  String get endGameViewStatsButton => 'View statistics';

  @override
  String get endGameReturnHomeButton => 'Return to home';

  @override
  String get mayorElectionExplainText => 'You are going to elect the Mayor';

  @override
  String get mayorElectionExplainContinueButton => 'Continue to the vote';

  @override
  String get mayorElectionTitle => 'Mayor election';

  @override
  String get mayorElectionInstruction =>
      'Each player designates the future village mayor.';

  @override
  String get mayorRevealTitle => 'The village has chosen its mayor';

  @override
  String get mayorRevealSubtitle => 'Their vote will count double during ties.';

  @override
  String get mayorRevealContinueButton => 'Continue to the debate';

  @override
  String get mayorSuccessionTitle => 'Mayor succession';

  @override
  String get mayorSuccessionInstruction =>
      'The mayor has died. Before drawing their last breath, they designate their successor.';

  @override
  String get nightIntroFirstNight => 'Night falls on Thiercelieux';

  @override
  String nightIntroOtherNights(int night) {
    return 'Night $night falls again';
  }

  @override
  String get nightIntroSleepInstruction =>
      'The whole village closes their eyes and goes to sleep.\nPlace the phone in the center of the table.';

  @override
  String get nightIntroEveryoneAsleepButton => 'Everyone is asleep';

  @override
  String get nightGoBackToSleepTitle => 'You may go back to sleep';

  @override
  String get nightGoBackToSleepInstruction =>
      'Close your eyes. The village continues to sleep...';

  @override
  String get voteSecretSubtitle => 'Secret vote: other players must not look.';

  @override
  String get voteRunoffTieNotice =>
      'Tie in previous round — revoting among tied candidates.';

  @override
  String get powerLossPrivatePassSubtitle =>
      'Private information will be shown. Make sure no one else looks at the screen.';

  @override
  String get powerLossTitle => 'Wisdom fades';

  @override
  String powerLossPlayerCount(int current, int total) {
    return 'Player $current / $total';
  }

  @override
  String get powerLossAncienHangedHeadline =>
      'The village mistakenly hanged the Elder.';

  @override
  String get powerLossReallyLostNotice =>
      'Deprived of their wisdom, you lose your gift:';

  @override
  String get powerLossNowSimpleVillageois => 'You are now a Simple Villager.';

  @override
  String get powerLossFakeGiftNotice =>
      'The Elder\'s wisdom grants you a gift:';

  @override
  String get powerLossFakeGiftName => 'Gift of Deep Sleep';

  @override
  String get powerLossFakeGiftUseless =>
      '...completely useless. Nothing changes for you.';

  @override
  String get powerLossKeepSecretWarning =>
      'Keep it to yourself: nobody else at the table should know what was shown on this screen.';

  @override
  String get powerLossUnderstoodButton => 'Understood, hide';

  @override
  String get powerLossPublicExplanation =>
      'Deprived of their wisdom, some villagers felt their gift fade... but only they know who.';

  @override
  String get powerLossNightFallsAgainButton => 'Night falls again';

  @override
  String get villageVoteTitle => 'Village vote';

  @override
  String get villageVoteInstruction =>
      'Each player designates the suspect to eliminate.';

  @override
  String get voteResultTitle => 'Vote result';

  @override
  String get voteResultNoDeaths => 'The village did not eliminate anyone.';

  @override
  String get voteResultVillageHasVoted => 'The village has voted...';

  @override
  String get gameSettingsTitle => 'Game settings';

  @override
  String get statsTitle => 'Statistics';

  @override
  String get statsResetTooltip => 'Reset statistics';

  @override
  String get statsResetDialogTitle => 'Reset statistics?';

  @override
  String get statsResetDialogMessage =>
      'All game history will be permanently deleted.';

  @override
  String get statsResetConfirmLabel => 'Reset';

  @override
  String get statsEmptyMessage =>
      'No games recorded yet.\nPlay a full game to see your statistics here.';

  @override
  String statsCardSummary(int gamesPlayed, int winRate) {
    String _temp0 = intl.Intl.pluralLogic(
      gamesPlayed,
      locale: localeName,
      other: '$gamesPlayed games',
      one: '1 game',
    );
    return '$_temp0 · $winRate% win rate';
  }

  @override
  String statsFavoriteSuffix(String roleName) {
    return ' · $roleName favorite';
  }

  @override
  String statsWinsAbbr(int wins) {
    return '$wins W';
  }

  @override
  String statsLossesAbbr(int losses) {
    return '$losses L';
  }

  @override
  String get gameProgressSheetTitle => 'Game summary';

  @override
  String gameProgressNightCounter(int number) {
    return 'Night $number';
  }

  @override
  String gameProgressDayCounter(int number) {
    return 'Day $number';
  }

  @override
  String get gameProgressStarting => 'The game begins...';

  @override
  String get gameProgressInProgress => 'In progress';

  @override
  String get gameProgressInProgressDots => 'In progress...';

  @override
  String gameProgressNightTitle(int number) {
    return 'Night $number';
  }

  @override
  String gameProgressDayTitle(int number) {
    return 'Day $number';
  }

  @override
  String get phaseNightVoleur => 'The Thief';

  @override
  String get phaseNightCupidon => 'Cupid';

  @override
  String get phaseNightEnfantSauvage => 'The Wild Child — role model choice';

  @override
  String get phaseNightSalvateur => 'The Bodyguard';

  @override
  String get phaseNightVoyante => 'The Seer';

  @override
  String get phaseNightLoups => 'The Werewolves';

  @override
  String get phaseNightPetiteFille => 'The Little Girl';

  @override
  String get phaseNightLoupBlanc => 'The White Werewolf';

  @override
  String get phaseNightGrandMechantLoup => 'The Big Bad Wolf';

  @override
  String get phaseNightEnfantSauvageCheck => 'The Wild Child';

  @override
  String get phaseNightInfectPereDesLoups => 'Vile Father of Wolves';

  @override
  String get phaseNightRenard => 'The Fox';

  @override
  String get phaseNightCorbeau => 'The Raven';

  @override
  String get phaseNightSorciere => 'The Witch';

  @override
  String get phaseChasseurRevange => 'Hunter\'s Revenge';

  @override
  String get phaseSuccessionMaire => 'Mayor Succession';

  @override
  String get phaseEnfantsauvageReveal => 'Wild Child Transformation';

  @override
  String get phaseDayReveal => 'Village Waking';

  @override
  String get phaseMayorElectionExplain => 'Mayor Election';

  @override
  String get phaseMayorElection => 'Vote for Mayor';

  @override
  String get phaseMayorReveal => 'Election Result';

  @override
  String get phaseDebate => 'Debate';

  @override
  String get phaseJugeBegueDecision => 'The Stuttering Judge';

  @override
  String get phaseVillageVote => 'Village Vote';

  @override
  String get phaseVoteResult => 'Vote Result';

  @override
  String get phaseVillagePowerLoss => 'Power Loss';

  @override
  String get phaseServanteDevouee => 'The Devoted Servant';

  @override
  String get phaseBoucEmissaire => 'The Scapegoat';

  @override
  String get phaseIdiotduvillageCivicRightLoss => 'Loss of Civic Rights';

  @override
  String get phaseEndGame => 'Game Over';
}
