import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// Titre principal de l'application
  ///
  /// In fr, this message translates to:
  /// **'Thiercelieux'**
  String get appTitle;

  /// Libellé générique du bouton Continuer
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get continueButtonLabel;

  /// Libellé générique du bouton Confirmer
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirmButtonLabel;

  /// Libellé générique du bouton Annuler
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancelButtonLabel;

  /// Bouton pour se rendormir après vérification de rôle
  ///
  /// In fr, this message translates to:
  /// **'Se rendormir'**
  String get goBackToSleepButton;

  /// Bouton pour faire retomber la nuit
  ///
  /// In fr, this message translates to:
  /// **'La nuit tombe à nouveau'**
  String get nightFallsAgainButton;

  /// Bouton pour utiliser un pouvoir de rôle
  ///
  /// In fr, this message translates to:
  /// **'Utiliser mon pouvoir'**
  String get usePowerButton;

  /// Bouton pour refuser d'utiliser un pouvoir
  ///
  /// In fr, this message translates to:
  /// **'Ne pas utiliser mon pouvoir'**
  String get doNotUsePowerButton;

  /// Libellé du camp des loups-garous
  ///
  /// In fr, this message translates to:
  /// **'Camp des Loups-Garous'**
  String get campWolves;

  /// Libellé du camp des villageois
  ///
  /// In fr, this message translates to:
  /// **'Camp des Villageois'**
  String get campVillagers;

  /// Texte d'invite pour passer le téléphone à plusieurs personnes
  ///
  /// In fr, this message translates to:
  /// **'Passe le téléphone aux'**
  String get passDeviceToPlural;

  /// Texte d'invite pour passer le téléphone à une personne
  ///
  /// In fr, this message translates to:
  /// **'Passe le téléphone à'**
  String get passDeviceToSingular;

  /// Bouton de confirmation de prise en main du téléphone
  ///
  /// In fr, this message translates to:
  /// **'C\'est moi, j\'ai le téléphone'**
  String get passDeviceConfirmButton;

  /// Sous-titre sur l'écran d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous — partie en local'**
  String get homeSubtitle;

  /// Bouton pour reprendre la partie active
  ///
  /// In fr, this message translates to:
  /// **'Reprendre la partie'**
  String get resumeGameButton;

  /// Bouton pour lancer une nouvelle partie
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle partie'**
  String get newGameButton;

  /// Titre du dialogue d'abandon de partie
  ///
  /// In fr, this message translates to:
  /// **'Abandonner la partie ?'**
  String get abandonGameDialogTitle;

  /// Message du dialogue d'abandon de partie
  ///
  /// In fr, this message translates to:
  /// **'La partie en cours sera perdue et non comptabilisée dans les statistiques.'**
  String get abandonGameDialogMessage;

  /// Bouton de confirmation d'abandon de partie
  ///
  /// In fr, this message translates to:
  /// **'Abandonner'**
  String get abandonGameConfirmLabel;

  /// Bouton d'accès à l'écran de statistiques
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsButton;

  /// Bouton d'accès aux options de jeu
  ///
  /// In fr, this message translates to:
  /// **'Options de jeu'**
  String get gameSettingsButton;

  /// Bouton d'accès aux règles du jeu
  ///
  /// In fr, this message translates to:
  /// **'Règles du jeu'**
  String get gameRulesButton;

  /// Titre de la section des rôles dans les règles
  ///
  /// In fr, this message translates to:
  /// **'Les rôles'**
  String get gameRulesRolesTitle;

  /// Titre de l'écran du choix du nombre de joueurs
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle partie'**
  String get newGameTitle;

  /// Question sur le nombre de joueurs
  ///
  /// In fr, this message translates to:
  /// **'Combien de joueurs ?'**
  String get playerCountHowMany;

  /// Explication de la limite de joueurs
  ///
  /// In fr, this message translates to:
  /// **'De 5 à 24 joueurs autour de la table.'**
  String get playerCountRangeDescription;

  /// Titre de l'écran de sélection des rôles
  ///
  /// In fr, this message translates to:
  /// **'Répartition des rôles'**
  String get roleSelectionTitle;

  /// Tooltip du bouton options de jeu dans la sélection des rôles
  ///
  /// In fr, this message translates to:
  /// **'Options de jeu'**
  String get gameSettingsTooltip;

  /// Affichage du nombre de joueurs sélectionnés
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 joueur} other{{count} joueurs}}'**
  String roleSelectionPlayerCount(int count);

  /// Indication des 2 cartes supplémentaires réservées pour le voleur
  ///
  /// In fr, this message translates to:
  /// **' · +2 cartes pour le Voleur'**
  String get roleSelectionVoleurExtraCards;

  /// Indication d'un surplus de rôles configurés
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 rôle en trop} other{{count} rôles en trop}}'**
  String roleSelectionTooManyRoles(int count);

  /// Indication des villageois ajoutés automatiquement
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 Simple Villageois automatique} other{{count} Simples Villageois automatiques}}'**
  String roleSelectionAutoVillagers(int count);

  /// Titre de l'écran de saisie des noms
  ///
  /// In fr, this message translates to:
  /// **'Les joueurs'**
  String get playerNamesTitle;

  /// Instruction pour la saisie des prénoms
  ///
  /// In fr, this message translates to:
  /// **'Entrez le prénom de chaque joueur, dans l\'ordre où vous voulez leur faire découvrir leur rôle.'**
  String get playerNamesInstruction;

  /// Label du champ prénom de joueur
  ///
  /// In fr, this message translates to:
  /// **'Joueur {number}'**
  String playerNamesPlayerLabel(int number);

  /// Erreur si un prénom est vide
  ///
  /// In fr, this message translates to:
  /// **'Chaque joueur doit avoir un prénom.'**
  String get playerNamesErrorEmpty;

  /// Erreur si deux prénoms sont identiques
  ///
  /// In fr, this message translates to:
  /// **'Deux joueurs ne peuvent pas avoir le même prénom.'**
  String get playerNamesErrorDuplicate;

  /// Bouton pour valider les prénoms et distribuer les rôles
  ///
  /// In fr, this message translates to:
  /// **'Distribuer les rôles'**
  String get dealRolesButton;

  /// Sous-titre d'avertissement de l'écran de découverte du rôle
  ///
  /// In fr, this message translates to:
  /// **'Ton rôle va s\'afficher. Assure-toi que personne d\'autre ne regarde l\'écran.'**
  String get roleRevealSubtitle;

  /// Indicateur d'avancement de découverte des rôles
  ///
  /// In fr, this message translates to:
  /// **'Joueur {current} / {total}'**
  String roleRevealPlayerProgress(int current, int total);

  /// Invite à appuyer pour révéler son rôle
  ///
  /// In fr, this message translates to:
  /// **'Appuie pour découvrir ton rôle'**
  String get roleRevealTapToDiscover;

  /// Bouton pour afficher la carte du rôle
  ///
  /// In fr, this message translates to:
  /// **'Révéler mon rôle'**
  String get roleRevealRevealButton;

  /// Bouton pour masquer la carte après lecture
  ///
  /// In fr, this message translates to:
  /// **'J\'ai vu, masquer mon rôle'**
  String get roleRevealHideButton;

  /// Titre de l'écran du Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Le Bouc Émissaire'**
  String get boucEmissaireTitle;

  /// Instruction d'action pour le Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Tu dois désigner le joueur qui ne participera pas au prochain vote du village.'**
  String get boucEmissaireInstruction;

  /// Titre de l'écran du Chasseur
  ///
  /// In fr, this message translates to:
  /// **'Le Chasseur'**
  String get chasseurTitle;

  /// Instruction d'action pour le Chasseur éliminé
  ///
  /// In fr, this message translates to:
  /// **'Tu as été éliminé. Choisis immédiatement un joueur à emporter avec toi.'**
  String get chasseurInstruction;

  /// Sous-titre d'action pour le Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Choisis ta victime'**
  String get corbeauSubtitle;

  /// Titre de l'écran du Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Le Corbeau'**
  String get corbeauTitle;

  /// Instruction d'action pour le Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Désigne un joueur qui recevra deux voix contre lui au vote.'**
  String get corbeauInstruction;

  /// Sous-titre du réveil de Cupidon
  ///
  /// In fr, this message translates to:
  /// **'C\'est le rôle de Cupidon. Réveille-toi.'**
  String get cupidonSubtitle;

  /// Titre de l'écran de Cupidon
  ///
  /// In fr, this message translates to:
  /// **'Cupidon'**
  String get cupidonTitle;

  /// Instruction pour le choix des deux amoureux par Cupidon
  ///
  /// In fr, this message translates to:
  /// **'Désigne les deux Amoureux ({count}/{max}). Tu peux te choisir toi-même.'**
  String cupidonInstruction(int count, int max);

  /// Bouton pour valider la désignation des deux amoureux
  ///
  /// In fr, this message translates to:
  /// **'Confirmer les Amoureux'**
  String get cupidonConfirmButton;

  /// Titre de l'écran de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'L’Enfant Sauvage'**
  String get enfantSauvageTitle;

  /// Instruction pour le choix du modèle de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton modèle. S’il meurt, tu rejoindras immédiatement les Loups-Garous.'**
  String get enfantSauvageInstruction;

  /// Nom du rôle Enfant Sauvage lors du passage de téléphone
  ///
  /// In fr, this message translates to:
  /// **'l\'Enfant Sauvage'**
  String get enfantSauvagePassTo;

  /// Sous-titre du réveil de l'Enfant Sauvage lors du check
  ///
  /// In fr, this message translates to:
  /// **'C\'est le tour de l\'Enfant Sauvage. Réveille-toi.'**
  String get enfantSauvageCheckSubtitle;

  /// Message indiquant que le modèle de l'Enfant Sauvage est vivant
  ///
  /// In fr, this message translates to:
  /// **'Ton modèle est toujours vivant : tu restes un simple villageois sans pouvoir particulier.'**
  String get enfantSauvageModelAliveInstruction;

  /// Titre de la révélation de mutation de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'Mutation'**
  String get enfantSauvageMutationTitle;

  /// Explication de la mutation de l'Enfant Sauvage en loup-garou
  ///
  /// In fr, this message translates to:
  /// **'Son modèle est mort : l’Enfant Sauvage rejoint désormais la meute.'**
  String get enfantSauvageMutationInstruction;

  /// Sous-titre du tour du Grand Méchant Loup
  ///
  /// In fr, this message translates to:
  /// **'Réveille-toi seul, les autres Loups peuvent se rendormir.'**
  String get grandMechantLoupSubtitle;

  /// Titre de l'écran du Grand Méchant Loup
  ///
  /// In fr, this message translates to:
  /// **'Le Grand Méchant Loup'**
  String get grandMechantLoupTitle;

  /// Instruction pour le Grand Méchant Loup lorsqu'une victime existe déjà
  ///
  /// In fr, this message translates to:
  /// **'Les Loups ont déjà désigné {name}. Tant qu’aucun Loup n’est mort, tu peux choisir une seconde victime.'**
  String grandMechantLoupInstructionWithVictim(String name);

  /// Instruction pour le Grand Méchant Loup sans victime préalable
  ///
  /// In fr, this message translates to:
  /// **'Tant qu’aucun Loup n’est mort, tu peux choisir une seconde victime cette nuit.'**
  String get grandMechantLoupInstructionNoVictim;

  /// Bouton pour passer son tour de pouvoir sans agir
  ///
  /// In fr, this message translates to:
  /// **'Ne pas utiliser mon pouvoir cette nuit'**
  String get skipPowerThisNightButton;

  /// Titre de l'écran de révélation de l'Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'L\'Idiot du Village'**
  String get idiotDuVillageRevealTitle;

  /// Texte explicatif lors de la grâce de l'Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'Le village a voté contre {name}, mais il révèle son rôle et survit.'**
  String idiotDuVillageRevealInstruction(String name);

  /// Message indiquant la perte du droit de vote pour l'Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'{name} perd définitivement son droit de vote.'**
  String idiotDuVillageVoteLossMessage(String name);

  /// Sous-titre du tour de l'Infect Père des Loups
  ///
  /// In fr, this message translates to:
  /// **'C\'est ton tour. Réveille-toi seul.'**
  String get infectPereDesLoupsSubtitle;

  /// Titre de l'écran de l'Infect Père des Loups
  ///
  /// In fr, this message translates to:
  /// **'Infect Père des Loups'**
  String get infectPereDesLoupsTitle;

  /// Instruction pour infecter la victime désignée
  ///
  /// In fr, this message translates to:
  /// **'Les Loups ont désigné {name}. Veux-tu l’infecter au lieu de le laisser mourir ?'**
  String infectPereDesLoupsInstructionWithVictim(String name);

  /// Message si aucune victime n'a été désignée par les loups
  ///
  /// In fr, this message translates to:
  /// **'Les Loups n’ont désigné personne cette nuit.'**
  String get infectPereDesLoupsInstructionNoVictim;

  /// Bouton pour confirmer l'infection
  ///
  /// In fr, this message translates to:
  /// **'Infecter'**
  String get infectPereDesLoupsInfectButton;

  /// Bouton pour refuser l'infection
  ///
  /// In fr, this message translates to:
  /// **'Ne pas infecter'**
  String get infectPereDesLoupsDoNotInfectButton;

  /// Sous-titre du tour du Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'C\'est le tour du Juge Bègue. Personne d\'autre ne doit savoir qui il est.'**
  String get jugeBegueSubtitle;

  /// Titre de l'écran du Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Le Juge Bègue'**
  String get jugeBegueTitle;

  /// Instruction d'action pour le Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Une fois par partie, tu peux décider en secret que le vote du village sera rejoué immédiatement.'**
  String get jugeBegueInstruction;

  /// Question posée au Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Veux-tu utiliser ce pouvoir maintenant ?'**
  String get jugeBegueQuestion;

  /// Sous-titre du tour du Loup Blanc
  ///
  /// In fr, this message translates to:
  /// **'Choisis ta victime'**
  String get loupBlancSubtitle;

  /// Titre de l'écran du Loup Blanc
  ///
  /// In fr, this message translates to:
  /// **'Le Loup Blanc'**
  String get loupBlancTitle;

  /// Instruction d'action pour le Loup Blanc
  ///
  /// In fr, this message translates to:
  /// **'Choisis un joueur à éliminer secrètement pendant ton tour.'**
  String get loupBlancInstruction;

  /// Sous-titre du tour des Loups-Garous
  ///
  /// In fr, this message translates to:
  /// **'Réveillez-vous et mettez-vous d\'accord en silence sur votre victime.'**
  String get loupsSubtitle;

  /// Titre de l'écran des Loups-Garous
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous'**
  String get loupsTitle;

  /// Instruction d'action pour les Loups-Garous
  ///
  /// In fr, this message translates to:
  /// **'Mettez-vous d’accord en silence, puis désignez votre victime.'**
  String get loupsInstruction;

  /// Sous-titre du tour de la Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'C\'est le rôle de la Petite Fille. Réveille-toi.'**
  String get petiteFilleSubtitle;

  /// Titre de l'écran de la Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'La Petite Fille'**
  String get petiteFilleTitle;

  /// Avertissement pour la Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'Attention : si les Loups-Garous te surprennent, tu prendras la place de leur victime.'**
  String get petiteFilleWarning;

  /// Bouton pour espionner les loups
  ///
  /// In fr, this message translates to:
  /// **'Entrouvrir les yeux et espionner'**
  String get petiteFilleSpyButton;

  /// Bouton pour ne pas espionner
  ///
  /// In fr, this message translates to:
  /// **'Rester sagement endormie'**
  String get petiteFilleSleepButton;

  /// Sous-titre du tour du Renard
  ///
  /// In fr, this message translates to:
  /// **'C\'est le tour du Renard. Réveille-toi.'**
  String get renardSubtitle;

  /// Titre de l'écran du Renard
  ///
  /// In fr, this message translates to:
  /// **'Le Renard'**
  String get renardTitle;

  /// Instruction pour le Renard choisissant des voisins
  ///
  /// In fr, this message translates to:
  /// **'Choisis trois joueurs voisins ({count}/{max}).'**
  String renardInstruction(int count, int max);

  /// No description provided for @renardInstructionCenter.
  ///
  /// In fr, this message translates to:
  /// **'Pick a player: they and their two living neighbors will be sniffed.'**
  String get renardInstructionCenter;

  /// No description provided for @renardResultWolfFound.
  ///
  /// In fr, this message translates to:
  /// **'Il y a au moins un Loup-Garou parmi ces trois joueurs ! Vous conservez votre flair et pourrez le réutiliser la nuit prochaine.'**
  String get renardResultWolfFound;

  /// No description provided for @renardResultNoWolf.
  ///
  /// In fr, this message translates to:
  /// **'Aucun Loup-Garou parmi ces trois joueurs : ils sont tous innocents ! Mais vous perdez définitivement votre pouvoir.'**
  String get renardResultNoWolf;

  /// No description provided for @renardResultTrioLabel.
  ///
  /// In fr, this message translates to:
  /// **'Le joueur désigné et ses deux voisins :'**
  String get renardResultTrioLabel;

  /// Sous-titre du tour du Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Réveille-toi et désigne ton protégé.'**
  String get salvateurSubtitle;

  /// Titre de l'écran du Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Le Salvateur'**
  String get salvateurTitle;

  /// Instruction d'action pour le Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Choisis le joueur protégé contre les attaques de cette nuit.'**
  String get salvateurInstruction;

  /// Sous-titre du tour de la Servante Dévouée
  ///
  /// In fr, this message translates to:
  /// **'C\'est le rôle de la Servante Dévouée. Réveille-toi.'**
  String get servanteDevoueeSubtitle;

  /// Titre de l'écran de la Servante Dévouée
  ///
  /// In fr, this message translates to:
  /// **'La Servante Dévouée'**
  String get servanteDevoueeTitle;

  /// Instruction proposant à la servante de reprendre le rôle du joueur éliminé
  ///
  /// In fr, this message translates to:
  /// **'{name} vient d\'être éliminé(e). Veux-tu prendre son rôle ?'**
  String servanteDevoueeInstruction(String name);

  /// Bouton d'acceptation du nouveau rôle par la servante
  ///
  /// In fr, this message translates to:
  /// **'Oui, prendre ce rôle'**
  String get servanteDevoueeTakeRoleButton;

  /// Bouton de refus du nouveau rôle par la servante
  ///
  /// In fr, this message translates to:
  /// **'Non, rester Servante Dévouée'**
  String get servanteDevoueeKeepRoleButton;

  /// Sous-titre du tour de la Sorcière
  ///
  /// In fr, this message translates to:
  /// **'C\'est le tour de la Sorcière. Réveille-toi.'**
  String get sorciereSubtitle;

  /// Titre de l'écran de la Sorcière
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière'**
  String get sorciereTitle;

  /// Annonce de la victime des loups à la sorcière
  ///
  /// In fr, this message translates to:
  /// **'Cette nuit, les Loups-Garous ont désigné {name}.'**
  String sorciereInstructionWithVictim(String name);

  /// Annonce à la sorcière qu'il n'y a pas eu de victime
  ///
  /// In fr, this message translates to:
  /// **'Cette nuit, les Loups-Garous n’ont désigné personne.'**
  String get sorciereInstructionNoVictim;

  /// Option pour utiliser la potion de guérison
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la potion de vie pour sauver {name}'**
  String sorciereUseLifePotion(String name);

  /// Message indiquant que la potion de vie n'est plus disponible
  ///
  /// In fr, this message translates to:
  /// **'Potion de vie déjà utilisée.'**
  String get sorciereLifePotionAlreadyUsed;

  /// Message lorsque la règle interdit à la sorcière de se sauver elle-même
  ///
  /// In fr, this message translates to:
  /// **'Vous êtes vous-même la victime désignée, mais vous ne pouvez pas vous sauver vous-même.'**
  String get sorciereSelfSaveBlocked;

  /// Message lorsqu'il n'y a personne à sauver
  ///
  /// In fr, this message translates to:
  /// **'Aucune victime à sauver cette nuit.'**
  String get sorciereNoVictimToSave;

  /// Option pour activer la potion de mort
  ///
  /// In fr, this message translates to:
  /// **'Utiliser la potion de mort'**
  String get sorciereUseDeathPotion;

  /// Instruction pour désigner la cible de la potion de mort
  ///
  /// In fr, this message translates to:
  /// **'Choisissez la victime de la potion :'**
  String get sorciereChooseDeathPotionTarget;

  /// Message indiquant que la potion de mort n'est plus disponible
  ///
  /// In fr, this message translates to:
  /// **'Potion de mort déjà utilisée.'**
  String get sorciereDeathPotionAlreadyUsed;

  /// Bouton pour valider ses choix de sorcière et se rendormir
  ///
  /// In fr, this message translates to:
  /// **'Confirmer et se rendormir'**
  String get confirmAndGoBackToSleepButton;

  /// Sous-titre du tour du Voleur
  ///
  /// In fr, this message translates to:
  /// **'C\'est le rôle du Voleur. Réveille-toi.'**
  String get voleurSubtitle;

  /// Titre de l'écran du Voleur
  ///
  /// In fr, this message translates to:
  /// **'Le Voleur'**
  String get voleurTitle;

  /// Avertissement si les deux cartes au centre sont des loups
  ///
  /// In fr, this message translates to:
  /// **'Les deux cartes sont des Loups-Garous : tu es obligé d’en prendre une !'**
  String get voleurBothWolvesWarning;

  /// Bouton pour échanger sa carte contre la sélectionnée
  ///
  /// In fr, this message translates to:
  /// **'Échanger mon rôle contre celle-ci'**
  String get voleurExchangeRoleButton;

  /// Bouton pour conserver son rôle sans échanger
  ///
  /// In fr, this message translates to:
  /// **'Garder mon rôle actuel'**
  String get voleurKeepCurrentRoleButton;

  /// Sous-titre du tour de la Voyante
  ///
  /// In fr, this message translates to:
  /// **'C\'est le tour de la Voyante. Réveille-toi.'**
  String get voyanteSubtitle;

  /// Titre de l'écran de la Voyante
  ///
  /// In fr, this message translates to:
  /// **'La Voyante'**
  String get voyanteTitle;

  /// Message révélant le rôle observé par la Voyante
  ///
  /// In fr, this message translates to:
  /// **'Tu as observé {name}. Son rôle est révélé.'**
  String voyanteObservedTargetInstruction(String name);

  /// Bouton pour clore l'observation de la Voyante
  ///
  /// In fr, this message translates to:
  /// **'J\'ai vu, continuer'**
  String get voyanteDoneButton;

  /// Instruction pour sélectionner la cible de la Voyante
  ///
  /// In fr, this message translates to:
  /// **'Choisis un joueur pour découvrir son rôle.'**
  String get voyanteChooseTargetInstruction;

  /// Titre de l'aube du jour
  ///
  /// In fr, this message translates to:
  /// **'Le jour {day} se lève'**
  String dayRevealDayRises(int day);

  /// Message si aucune victime n'a été faite durant la nuit
  ///
  /// In fr, this message translates to:
  /// **'Miracle ! Personne n\'est mort cette nuit.'**
  String get dayRevealNoDeaths;

  /// Message lors du décès de plusieurs villageois dans la nuit
  ///
  /// In fr, this message translates to:
  /// **'Le village pleure ses morts...'**
  String get dayRevealMultipleDeaths;

  /// Message lors du décès d'un seul villageois dans la nuit
  ///
  /// In fr, this message translates to:
  /// **'Le village pleure son mort...'**
  String get dayRevealSingleDeath;

  /// Message quand l'ours grogne au réveil
  ///
  /// In fr, this message translates to:
  /// **'L\'ours du Montreur d\'Ours grogne : un Loup-Garou se cache parmi ses voisins.'**
  String get montreurDoursGrowlsText;

  /// Message quand l'ours reste calme au réveil
  ///
  /// In fr, this message translates to:
  /// **'L\'ours du Montreur d\'Ours reste calme cette nuit.'**
  String get montreurDoursCalmText;

  /// Bouton pour confirmer les révélations de l'aube
  ///
  /// In fr, this message translates to:
  /// **'Le village se réveille'**
  String get villageWakesUpButton;

  /// Cause de décès par les loups
  ///
  /// In fr, this message translates to:
  /// **'dévoré(e) par les Loups-Garous'**
  String get deathCauseDevoreParLesLoups;

  /// Cause de décès par poison de sorcière
  ///
  /// In fr, this message translates to:
  /// **'empoisonné(e) par la Sorcière'**
  String get deathCausePotionDeMort;

  /// Cause de décès par amour brisé
  ///
  /// In fr, this message translates to:
  /// **'mort(e) de chagrin d\'amour'**
  String get deathCauseChagrinDAmourCupidon;

  /// Cause de décès par tir de chasseur
  ///
  /// In fr, this message translates to:
  /// **'abattu(e) par le Chasseur'**
  String get deathCauseVengeanceDuChasseur;

  /// Cause de décès par vote du village
  ///
  /// In fr, this message translates to:
  /// **'pendu(e) par le village'**
  String get deathCauseVote;

  /// Cause de décès par le loup blanc
  ///
  /// In fr, this message translates to:
  /// **'dévoré(e) par le Loup Blanc'**
  String get deathCauseTueParLoupBlanc;

  /// Titre de l'écran de débat
  ///
  /// In fr, this message translates to:
  /// **'Débat'**
  String get debateTitle;

  /// Grand titre de l'écran de débat
  ///
  /// In fr, this message translates to:
  /// **'Le village débat'**
  String get debateVillageDebates;

  /// Instruction pour la phase de débat
  ///
  /// In fr, this message translates to:
  /// **'Les survivants discutent pour démasquer les Loups-Garous. Les Loups doivent bluffer pour se faire passer pour des villageois.'**
  String get debateInstruction;

  /// Bouton pour terminer le débat et passer au vote
  ///
  /// In fr, this message translates to:
  /// **'Passer au vote'**
  String get goToVoteButton;

  /// Titre de l'écran de fin de partie
  ///
  /// In fr, this message translates to:
  /// **'Fin de la partie'**
  String get endGameTitle;

  /// Annonce de la victoire du village
  ///
  /// In fr, this message translates to:
  /// **'Le Village l\'emporte !'**
  String get endGameWinnerVillage;

  /// Annonce de la victoire des loups-garous
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous l\'emportent !'**
  String get endGameWinnerWolves;

  /// Annonce de la victoire des amoureux
  ///
  /// In fr, this message translates to:
  /// **'Les Amoureux l\'emportent !'**
  String get endGameWinnerLovers;

  /// Annonce d'une victoire solo
  ///
  /// In fr, this message translates to:
  /// **'Il l\'emporte !'**
  String get endGameWinnerSolo;

  /// Bouton pour afficher les statistiques après la fin de partie
  ///
  /// In fr, this message translates to:
  /// **'Voir les statistiques'**
  String get endGameViewStatsButton;

  /// Bouton pour revenir à l'écran d'accueil
  ///
  /// In fr, this message translates to:
  /// **'Retour à l\'accueil'**
  String get endGameReturnHomeButton;

  /// Explication avant le vote de l'élection du maire
  ///
  /// In fr, this message translates to:
  /// **'Vous allez élire le Capitaine'**
  String get mayorElectionExplainText;

  /// Bouton pour avancer vers le vote du maire
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers le vote'**
  String get mayorElectionExplainContinueButton;

  /// Titre du vote du maire
  ///
  /// In fr, this message translates to:
  /// **'Élection du maire'**
  String get mayorElectionTitle;

  /// Instruction pour le vote du maire
  ///
  /// In fr, this message translates to:
  /// **'Chaque joueur désigne le futur maire du village.'**
  String get mayorElectionInstruction;

  /// Titre de révélation du maire élu
  ///
  /// In fr, this message translates to:
  /// **'Le village a choisi son maire'**
  String get mayorRevealTitle;

  /// Explication du pouvoir du maire
  ///
  /// In fr, this message translates to:
  /// **'Son vote comptera double en cas d\'égalité.'**
  String get mayorRevealSubtitle;

  /// Bouton pour aller au débat après l'élection du maire
  ///
  /// In fr, this message translates to:
  /// **'Continuer vers le débat'**
  String get mayorRevealContinueButton;

  /// Titre de l'écran de succession du maire
  ///
  /// In fr, this message translates to:
  /// **'Succession du maire'**
  String get mayorSuccessionTitle;

  /// Instruction pour désigner le successeur du maire
  ///
  /// In fr, this message translates to:
  /// **'Le maire est mort. Avant de rendre son dernier souffle, il désigne son successeur.'**
  String get mayorSuccessionInstruction;

  /// Titre de la première nuit
  ///
  /// In fr, this message translates to:
  /// **'La nuit tombe sur Thiercelieux'**
  String get nightIntroFirstNight;

  /// Titre des nuits suivantes
  ///
  /// In fr, this message translates to:
  /// **'La nuit {night} tombe à nouveau'**
  String nightIntroOtherNights(int night);

  /// Instruction d'endormissement du village
  ///
  /// In fr, this message translates to:
  /// **'Tout le village ferme les yeux et s\'endort.\nPose le téléphone au centre de la table.'**
  String get nightIntroSleepInstruction;

  /// Bouton confirmant que tout le monde est endormi
  ///
  /// In fr, this message translates to:
  /// **'Tout le monde dort'**
  String get nightIntroEveryoneAsleepButton;

  /// Titre pour se rendormir après son tour
  ///
  /// In fr, this message translates to:
  /// **'Tu peux te rendormir'**
  String get nightGoBackToSleepTitle;

  /// Texte incitant à refermer les yeux
  ///
  /// In fr, this message translates to:
  /// **'Referme les yeux. Le village continue de dormir...'**
  String get nightGoBackToSleepInstruction;

  /// Avertissement de confidentialité lors du vote
  ///
  /// In fr, this message translates to:
  /// **'Vote secret : les autres joueurs ne doivent pas regarder.'**
  String get voteSecretSubtitle;

  /// Avis de second tour en cas d'égalité
  ///
  /// In fr, this message translates to:
  /// **'Égalité au tour précédent — on revote entre les candidats à égalité.'**
  String get voteRunoffTieNotice;

  /// Avertissement avant d'afficher la perte de pouvoir
  ///
  /// In fr, this message translates to:
  /// **'Une information privée va s\'afficher. Assure-toi que personne d\'autre ne regarde l\'écran.'**
  String get powerLossPrivatePassSubtitle;

  /// Titre de la perte de pouvoir suite à la mort de l'Ancien
  ///
  /// In fr, this message translates to:
  /// **'La sagesse s\'éteint'**
  String get powerLossTitle;

  /// Numéro du joueur passant devant l'écran de perte de pouvoir
  ///
  /// In fr, this message translates to:
  /// **'Joueur {current} / {total}'**
  String powerLossPlayerCount(int current, int total);

  /// Accroche annonçant la pendaison de l'Ancien
  ///
  /// In fr, this message translates to:
  /// **'Le village a fait pendre l\'Ancien par erreur.'**
  String get powerLossAncienHangedHeadline;

  /// Message annonçant la perte de pouvoir réelle
  ///
  /// In fr, this message translates to:
  /// **'Privé(e) de sa sagesse, tu perds ton don :'**
  String get powerLossReallyLostNotice;

  /// Indication du nouveau rôle Simple Villageois
  ///
  /// In fr, this message translates to:
  /// **'Tu es désormais un Simple Villageois.'**
  String get powerLossNowSimpleVillageois;

  /// Message leurre accordant un don fictif
  ///
  /// In fr, this message translates to:
  /// **'La sagesse de l\'Ancien t\'accorde un don :'**
  String get powerLossFakeGiftNotice;

  /// Nom du faux don de sommeil profond
  ///
  /// In fr, this message translates to:
  /// **'Don du Sommeil Profond'**
  String get powerLossFakeGiftName;

  /// Explication humoristique du don fictif
  ///
  /// In fr, this message translates to:
  /// **'...totalement inutile. Rien ne change pour toi.'**
  String get powerLossFakeGiftUseless;

  /// Avertissement de discrétion pour la perte de pouvoir
  ///
  /// In fr, this message translates to:
  /// **'Garde-le pour toi : personne d\'autre à la table ne doit savoir ce qui s\'est affiché sur cet écran.'**
  String get powerLossKeepSecretWarning;

  /// Bouton pour acquitter la perte de pouvoir et masquer l'écran
  ///
  /// In fr, this message translates to:
  /// **'J\'ai compris, masquer'**
  String get powerLossUnderstoodButton;

  /// Explication publique lors de la mort de l'Ancien
  ///
  /// In fr, this message translates to:
  /// **'Privés de sa sagesse, certains villageois ont senti leur don s\'éteindre... mais eux seuls savent lesquels.'**
  String get powerLossPublicExplanation;

  /// Bouton pour clore l'annonce publique de perte de pouvoirs
  ///
  /// In fr, this message translates to:
  /// **'La nuit tombe à nouveau'**
  String get powerLossNightFallsAgainButton;

  /// Titre de l'écran du vote du village
  ///
  /// In fr, this message translates to:
  /// **'Vote du village'**
  String get villageVoteTitle;

  /// Instruction pour le vote d'élimination du village
  ///
  /// In fr, this message translates to:
  /// **'Chaque joueur désigne le suspect à éliminer.'**
  String get villageVoteInstruction;

  /// Titre de l'écran de résultat du vote
  ///
  /// In fr, this message translates to:
  /// **'Résultat du vote'**
  String get voteResultTitle;

  /// Résultat de vote sans élimination
  ///
  /// In fr, this message translates to:
  /// **'Le village n\'a éliminé personne.'**
  String get voteResultNoDeaths;

  /// Résultat de vote avec élimination
  ///
  /// In fr, this message translates to:
  /// **'Le village a voté...'**
  String get voteResultVillageHasVoted;

  /// Titre de l'écran des options de jeu
  ///
  /// In fr, this message translates to:
  /// **'Options de jeu'**
  String get gameSettingsTitle;

  /// Titre de l'écran des statistiques
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get statsTitle;

  /// Tooltip pour réinitialiser les statistiques
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les statistiques'**
  String get statsResetTooltip;

  /// Titre du dialogue de réinitialisation des statistiques
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser les statistiques ?'**
  String get statsResetDialogTitle;

  /// Message d'avertissement de réinitialisation des statistiques
  ///
  /// In fr, this message translates to:
  /// **'Tout l\'historique des parties sera définitivement supprimé.'**
  String get statsResetDialogMessage;

  /// Bouton de confirmation de réinitialisation des statistiques
  ///
  /// In fr, this message translates to:
  /// **'Réinitialiser'**
  String get statsResetConfirmLabel;

  /// Message affiché quand aucune statistique n'est enregistrée
  ///
  /// In fr, this message translates to:
  /// **'Aucune partie enregistrée pour l\'instant.\nJouez une partie complète pour voir apparaître vos statistiques ici.'**
  String get statsEmptyMessage;

  /// Résumé des parties jouées et taux de victoires
  ///
  /// In fr, this message translates to:
  /// **'{gamesPlayed, plural, =1{1 partie} other{{gamesPlayed} parties}} · {winRate}% de victoires'**
  String statsCardSummary(int gamesPlayed, int winRate);

  /// Suffixe mentionnant le rôle favori
  ///
  /// In fr, this message translates to:
  /// **' · {roleName} favori'**
  String statsFavoriteSuffix(String roleName);

  /// Nombre de victoires abrégé
  ///
  /// In fr, this message translates to:
  /// **'{wins} V'**
  String statsWinsAbbr(int wins);

  /// Nombre de défaites abrégé
  ///
  /// In fr, this message translates to:
  /// **'{losses} D'**
  String statsLossesAbbr(int losses);

  /// Titre du panneau de progression de partie
  ///
  /// In fr, this message translates to:
  /// **'Résumé de la partie'**
  String get gameProgressSheetTitle;

  /// Compteur de nuit dans le panneau de progression
  ///
  /// In fr, this message translates to:
  /// **'Nuit {number}'**
  String gameProgressNightCounter(int number);

  /// Compteur de jour dans le panneau de progression
  ///
  /// In fr, this message translates to:
  /// **'Jour {number}'**
  String gameProgressDayCounter(int number);

  /// Texte quand aucune manche n'a encore débuté
  ///
  /// In fr, this message translates to:
  /// **'La partie commence...'**
  String get gameProgressStarting;

  /// Indication qu'une manche est en cours
  ///
  /// In fr, this message translates to:
  /// **'En cours'**
  String get gameProgressInProgress;

  /// Indication que des étapes sont en cours
  ///
  /// In fr, this message translates to:
  /// **'En cours...'**
  String get gameProgressInProgressDots;

  /// Titre d'une manche de nuit dans la liste
  ///
  /// In fr, this message translates to:
  /// **'Nuit {number}'**
  String gameProgressNightTitle(int number);

  /// Titre d'une manche de jour dans la liste
  ///
  /// In fr, this message translates to:
  /// **'Jour {number}'**
  String gameProgressDayTitle(int number);

  /// Nom de phase pour le Voleur
  ///
  /// In fr, this message translates to:
  /// **'Le Voleur'**
  String get phaseNightVoleur;

  /// Nom de phase pour Cupidon
  ///
  /// In fr, this message translates to:
  /// **'Cupidon'**
  String get phaseNightCupidon;

  /// Nom de phase pour le choix du modèle de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'L\'Enfant Sauvage — choix du modèle'**
  String get phaseNightEnfantSauvage;

  /// Nom de phase pour le Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Le Salvateur'**
  String get phaseNightSalvateur;

  /// Nom de phase pour la Voyante
  ///
  /// In fr, this message translates to:
  /// **'La Voyante'**
  String get phaseNightVoyante;

  /// Nom de phase pour les Loups-Garous
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous'**
  String get phaseNightLoups;

  /// Nom de phase pour la Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'La Petite Fille'**
  String get phaseNightPetiteFille;

  /// Nom de phase pour le Loup Blanc
  ///
  /// In fr, this message translates to:
  /// **'Le Loup Blanc'**
  String get phaseNightLoupBlanc;

  /// Nom de phase pour le Grand Méchant Loup
  ///
  /// In fr, this message translates to:
  /// **'Le Grand Méchant Loup'**
  String get phaseNightGrandMechantLoup;

  /// Nom de phase pour le réveil de vérification de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'L\'Enfant Sauvage'**
  String get phaseNightEnfantSauvageCheck;

  /// Nom de phase pour l'Infect Père des Loups
  ///
  /// In fr, this message translates to:
  /// **'Infect Père des Loups'**
  String get phaseNightInfectPereDesLoups;

  /// Nom de phase pour le Renard
  ///
  /// In fr, this message translates to:
  /// **'Le Renard'**
  String get phaseNightRenard;

  /// Nom de phase pour le Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Le Corbeau'**
  String get phaseNightCorbeau;

  /// Nom de phase pour la Sorcière
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière'**
  String get phaseNightSorciere;

  /// Nom de phase pour la riposte du Chasseur
  ///
  /// In fr, this message translates to:
  /// **'Riposte du Chasseur'**
  String get phaseChasseurRevange;

  /// Nom de phase pour la succession du Maire
  ///
  /// In fr, this message translates to:
  /// **'Succession du Maire'**
  String get phaseSuccessionMaire;

  /// Nom de phase pour la mutation de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'Mutation de l\'Enfant Sauvage'**
  String get phaseEnfantsauvageReveal;

  /// Nom de phase pour le réveil du village
  ///
  /// In fr, this message translates to:
  /// **'Réveil du village'**
  String get phaseDayReveal;

  /// Nom de phase pour l'explication de l'élection du maire
  ///
  /// In fr, this message translates to:
  /// **'Élection du maire'**
  String get phaseMayorElectionExplain;

  /// Nom de phase pour le vote du maire
  ///
  /// In fr, this message translates to:
  /// **'Vote pour le maire'**
  String get phaseMayorElection;

  /// Nom de phase pour le résultat de l'élection du maire
  ///
  /// In fr, this message translates to:
  /// **'Résultat de l\'élection'**
  String get phaseMayorReveal;

  /// Nom de phase pour le débat du village
  ///
  /// In fr, this message translates to:
  /// **'Débat'**
  String get phaseDebate;

  /// Nom de phase pour la décision du Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Le Juge Bègue'**
  String get phaseJugeBegueDecision;

  /// Nom de phase pour le vote du village
  ///
  /// In fr, this message translates to:
  /// **'Vote du village'**
  String get phaseVillageVote;

  /// Nom de phase pour le résultat du vote
  ///
  /// In fr, this message translates to:
  /// **'Résultat du vote'**
  String get phaseVoteResult;

  /// Nom de phase pour la perte des pouvoirs après pendaison de l'Ancien
  ///
  /// In fr, this message translates to:
  /// **'Perte des pouvoirs'**
  String get phaseVillagePowerLoss;

  /// Nom de phase pour la Servante Dévouée
  ///
  /// In fr, this message translates to:
  /// **'La Servante Dévouée'**
  String get phaseServanteDevouee;

  /// Nom de phase pour le Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Le Bouc Émissaire'**
  String get phaseBoucEmissaire;

  /// Nom de phase pour la perte de droit civique de l'Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'Perte de droit civique'**
  String get phaseIdiotduvillageCivicRightLoss;

  /// Nom de phase pour la fin de partie
  ///
  /// In fr, this message translates to:
  /// **'Fin de partie'**
  String get phaseEndGame;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
