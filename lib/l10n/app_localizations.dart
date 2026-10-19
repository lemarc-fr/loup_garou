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

  /// Bouton affiché quand la partie vient de se terminer (victoire d'un camp)
  ///
  /// In fr, this message translates to:
  /// **'Voir le résultat de la partie'**
  String get seeGameResultButton;

  /// Bouton affiché quand le Juge Bègue a demandé que le vote soit rejoué
  ///
  /// In fr, this message translates to:
  /// **'Rejouer le vote'**
  String get replayVoteButton;

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

  /// Libellé du camp d'un rôle solitaire (Loup-Garou Blanc)
  ///
  /// In fr, this message translates to:
  /// **'Seul contre tous'**
  String get campSolo;

  /// Nom du rôle Loup-Garou
  ///
  /// In fr, this message translates to:
  /// **'Loup-Garou'**
  String get roleLoupGarouName;

  /// Nom court du rôle Loup-Garou
  ///
  /// In fr, this message translates to:
  /// **'Loup'**
  String get roleLoupGarouShortName;

  /// Nom du rôle Loup-Garou au pluriel (passage du téléphone à la meute)
  ///
  /// In fr, this message translates to:
  /// **'Loups-Garous'**
  String get roleLoupGarouPlural;

  /// Description du rôle Loup-Garou
  ///
  /// In fr, this message translates to:
  /// **'Chaque nuit, les Loups-Garous se réunissent pour dévorer un villageois. Le jour, ils se fondent dans la foule et bluffent pour ne pas être démasqués.'**
  String get roleLoupGarouDescription;

  /// Nom du rôle Grand Méchant Loup
  ///
  /// In fr, this message translates to:
  /// **'Grand Méchant Loup'**
  String get roleGrandMechantLoupName;

  /// Nom court du rôle Grand Méchant Loup
  ///
  /// In fr, this message translates to:
  /// **'Grand Méchant Loup'**
  String get roleGrandMechantLoupShortName;

  /// Description du rôle Grand Méchant Loup
  ///
  /// In fr, this message translates to:
  /// **'Il agit avec les autres Loups-Garous et peut, tant qu\'aucun Loup-Garou n\'est mort, dévorer une seconde victime chaque nuit.'**
  String get roleGrandMechantLoupDescription;

  /// Nom du rôle Infect Père des Loups
  ///
  /// In fr, this message translates to:
  /// **'Infect Père des Loups'**
  String get roleInfectPereDesLoupsName;

  /// Nom court du rôle Infect Père des Loups
  ///
  /// In fr, this message translates to:
  /// **'Infect'**
  String get roleInfectPereDesLoupsShortName;

  /// Description du rôle Infect Père des Loups
  ///
  /// In fr, this message translates to:
  /// **'Il est un Loup-Garou. Une fois par partie, il peut infecter la victime des loups afin de la transformer en Loup-Garou au lieu de la tuer.'**
  String get roleInfectPereDesLoupsDescription;

  /// Nom du rôle Loup-Garou Blanc
  ///
  /// In fr, this message translates to:
  /// **'Loup-Garou Blanc'**
  String get roleLoupBlancName;

  /// Nom court du rôle Loup-Garou Blanc
  ///
  /// In fr, this message translates to:
  /// **'Loup Blanc'**
  String get roleLoupBlancShortName;

  /// Description du rôle Loup-Garou Blanc
  ///
  /// In fr, this message translates to:
  /// **'Il est considéré comme un Loup-Garou par les autres loups, mais son objectif est de rester le dernier survivant. Une nuit sur deux, il peut éliminer secrètement un autre Loup-Garou.'**
  String get roleLoupBlancDescription;

  /// Nom du rôle Voyante
  ///
  /// In fr, this message translates to:
  /// **'La Voyante'**
  String get roleVoyanteName;

  /// Nom court du rôle Voyante
  ///
  /// In fr, this message translates to:
  /// **'Voyante'**
  String get roleVoyanteShortName;

  /// Description du rôle Voyante
  ///
  /// In fr, this message translates to:
  /// **'Chaque nuit, elle découvre en secret la véritable identité d\'un joueur de son choix.'**
  String get roleVoyanteDescription;

  /// Nom du rôle Sorcière
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière'**
  String get roleSorciereName;

  /// Nom court du rôle Sorcière
  ///
  /// In fr, this message translates to:
  /// **'Sorcière'**
  String get roleSorciereShortName;

  /// Description du rôle Sorcière
  ///
  /// In fr, this message translates to:
  /// **'Elle possède deux potions à usage unique : une potion de vie pour sauver la victime des loups, et une potion de mort pour éliminer un joueur de son choix.'**
  String get roleSorciereDescription;

  /// Nom du rôle Chasseur
  ///
  /// In fr, this message translates to:
  /// **'Le Chasseur'**
  String get roleChasseurName;

  /// Nom court du rôle Chasseur
  ///
  /// In fr, this message translates to:
  /// **'Chasseur'**
  String get roleChasseurShortName;

  /// Description du rôle Chasseur
  ///
  /// In fr, this message translates to:
  /// **'S\'il meurt, de nuit comme de jour, il réplique aussitôt en abattant un autre joueur de son choix.'**
  String get roleChasseurDescription;

  /// Nom du rôle Cupidon
  ///
  /// In fr, this message translates to:
  /// **'Cupidon'**
  String get roleCupidonName;

  /// Nom court du rôle Cupidon
  ///
  /// In fr, this message translates to:
  /// **'Cupidon'**
  String get roleCupidonShortName;

  /// Description du rôle Cupidon
  ///
  /// In fr, this message translates to:
  /// **'La première nuit seulement, il désigne deux joueurs qui tombent amoureux. Si l\'un meurt, l\'autre meurt aussitôt de chagrin.'**
  String get roleCupidonDescription;

  /// Nom du rôle Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'La Petite Fille'**
  String get rolePetiteFilleName;

  /// Nom court du rôle Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'Petite Fille'**
  String get rolePetiteFilleShortName;

  /// Description du rôle Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'Pendant le tour des loups, elle peut entrouvrir les yeux pour espionner.'**
  String get rolePetiteFilleDescription;

  /// Nom du rôle Voleur
  ///
  /// In fr, this message translates to:
  /// **'Le Voleur'**
  String get roleVoleurName;

  /// Nom court du rôle Voleur
  ///
  /// In fr, this message translates to:
  /// **'Voleur'**
  String get roleVoleurShortName;

  /// Description du rôle Voleur
  ///
  /// In fr, this message translates to:
  /// **'La première nuit, il regarde deux cartes restées sur la table et peut échanger son rôle contre l\'une d\'elles.'**
  String get roleVoleurDescription;

  /// Nom du rôle Simple Villageois
  ///
  /// In fr, this message translates to:
  /// **'Simple Villageois'**
  String get roleSimpleVillageoisName;

  /// Nom court du rôle Simple Villageois
  ///
  /// In fr, this message translates to:
  /// **'Villageois'**
  String get roleSimpleVillageoisShortName;

  /// Description du rôle Simple Villageois
  ///
  /// In fr, this message translates to:
  /// **'Aucun pouvoir particulier. Son arme : l\'observation, l\'écoute, et le vote le jour venu.'**
  String get roleSimpleVillageoisDescription;

  /// Nom du rôle Ancien
  ///
  /// In fr, this message translates to:
  /// **'L\'Ancien'**
  String get roleAncienName;

  /// Nom court du rôle Ancien
  ///
  /// In fr, this message translates to:
  /// **'Ancien'**
  String get roleAncienShortName;

  /// Description du rôle Ancien
  ///
  /// In fr, this message translates to:
  /// **'Grâce à sa sagesse, il résiste à une première attaque des Loups-Garous. S\'il est tué par le village, les villageois à pouvoir perdent leurs capacités.'**
  String get roleAncienDescription;

  /// Nom du rôle Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Le Bouc Émissaire'**
  String get roleBoucEmissaireName;

  /// Nom court du rôle Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Bouc Émissaire'**
  String get roleBoucEmissaireShortName;

  /// Description du rôle Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Si le vote du village finit à égalité, c\'est lui qui est éliminé à la place des ex aequo. Avant de mourir, il désigne qui pourra voter le lendemain.'**
  String get roleBoucEmissaireDescription;

  /// Nom du rôle Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'L\'Idiot du Village'**
  String get roleIdiotDuVillageName;

  /// Nom court du rôle Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'Idiot'**
  String get roleIdiotDuVillageShortName;

  /// Description du rôle Idiot du Village
  ///
  /// In fr, this message translates to:
  /// **'S\'il est condamné par le vote du village, il révèle son rôle et reste en vie, mais perd définitivement son droit de vote.'**
  String get roleIdiotDuVillageDescription;

  /// Nom du rôle Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Le Salvateur'**
  String get roleSalvateurName;

  /// Nom court du rôle Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Salvateur'**
  String get roleSalvateurShortName;

  /// Description du rôle Salvateur
  ///
  /// In fr, this message translates to:
  /// **'Chaque nuit, il protège un joueur contre les Loups-Garous. Il ne peut pas protéger le même joueur deux nuits consécutives.'**
  String get roleSalvateurDescription;

  /// Nom du rôle Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'L\'Enfant Sauvage'**
  String get roleEnfantSauvageName;

  /// Nom court du rôle Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'Enfant Sauvage'**
  String get roleEnfantSauvageShortName;

  /// Description du rôle Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'Au début de la partie, il choisit un modèle parmi les autres joueurs. Si son modèle meurt, il devient Loup-Garou.'**
  String get roleEnfantSauvageDescription;

  /// Nom du rôle Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Le Juge Bègue'**
  String get roleJugeBegueName;

  /// Nom court du rôle Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Juge Bègue'**
  String get roleJugeBegueShortName;

  /// Description du rôle Juge Bègue
  ///
  /// In fr, this message translates to:
  /// **'Une fois par partie, il peut décider secrètement que le vote du village sera rejoué immédiatement.'**
  String get roleJugeBegueDescription;

  /// Nom du rôle Servante Dévouée
  ///
  /// In fr, this message translates to:
  /// **'La Servante Dévouée'**
  String get roleServanteDevoueeName;

  /// Nom court du rôle Servante Dévouée
  ///
  /// In fr, this message translates to:
  /// **'Servante'**
  String get roleServanteDevoueeShortName;

  /// Description du rôle Servante Dévouée
  ///
  /// In fr, this message translates to:
  /// **'Lorsqu\'un joueur est éliminé par le vote, elle peut révéler son rôle et prendre immédiatement sa carte.'**
  String get roleServanteDevoueeDescription;

  /// Nom du rôle Montreur d'Ours
  ///
  /// In fr, this message translates to:
  /// **'Le Montreur d\'Ours'**
  String get roleMontreurDoursName;

  /// Nom court du rôle Montreur d'Ours
  ///
  /// In fr, this message translates to:
  /// **'Montreur d\'Ours'**
  String get roleMontreurDoursShortName;

  /// Description du rôle Montreur d'Ours
  ///
  /// In fr, this message translates to:
  /// **'Chaque matin, si un Loup-Garou se trouve parmi ses voisins encore vivants, l\'ours grogne.'**
  String get roleMontreurDoursDescription;

  /// Nom du rôle Renard
  ///
  /// In fr, this message translates to:
  /// **'Le Renard'**
  String get roleRenardName;

  /// Nom court du rôle Renard
  ///
  /// In fr, this message translates to:
  /// **'Renard'**
  String get roleRenardShortName;

  /// Description du rôle Renard
  ///
  /// In fr, this message translates to:
  /// **'La nuit, il désigne un joueur : celui-ci et ses deux voisins vivants forment un groupe de trois. Le meneur lui indique si au moins un Loup-Garou s\'y trouve.'**
  String get roleRenardDescription;

  /// Nom du rôle Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Le Corbeau'**
  String get roleCorbeauName;

  /// Nom court du rôle Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Corbeau'**
  String get roleCorbeauShortName;

  /// Rôle d'un joueur ayant muté en cours de partie, ex. Loup-Garou (anciennement Enfant Sauvage)
  ///
  /// In fr, this message translates to:
  /// **'{role} (anciennement {formerRole})'**
  String roleWithFormerRole(String role, String formerRole);

  /// Description du rôle Corbeau
  ///
  /// In fr, this message translates to:
  /// **'Chaque nuit, il peut désigner un joueur qui aura deux voix de plus contre lui lors du prochain vote du village.'**
  String get roleCorbeauDescription;

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
  /// **'Désigne un joueur qui recevra deux voix contre lui au vote, ou renonce cette nuit.'**
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

  /// Titre de l'écran privé de révélation des Amoureux (identique pour tous les joueurs)
  ///
  /// In fr, this message translates to:
  /// **'Message de la nuit'**
  String get loversRevealTitle;

  /// Avertissement avant d'afficher l'écran privé de révélation des Amoureux
  ///
  /// In fr, this message translates to:
  /// **'Un message secret t\'attend peut-être. Assure-toi que personne d\'autre ne regarde l\'écran.'**
  String get loversRevealPassSubtitle;

  /// Titre affiché à un des deux Amoureux
  ///
  /// In fr, this message translates to:
  /// **'Cupidon t\'a touché de sa flèche !'**
  String get loversRevealLoverHeadline;

  /// Titre affiché aux joueurs qui ne sont pas Amoureux
  ///
  /// In fr, this message translates to:
  /// **'Aucun message pour toi'**
  String get loversRevealNothingHeadline;

  /// Texte affiché aux joueurs qui ne sont pas Amoureux
  ///
  /// In fr, this message translates to:
  /// **'Il ne s\'est rien passé pour toi. Garde un visage impassible !'**
  String get loversRevealNothingBody;

  /// Bouton pour valider l'écran privé de révélation des Amoureux
  ///
  /// In fr, this message translates to:
  /// **'J\'ai compris, je me rendors'**
  String get loversRevealDoneButton;

  /// Annonce à un Amoureux de l'identité de sa moitié
  ///
  /// In fr, this message translates to:
  /// **'Tu formes un couple d\'Amoureux avec {name}.'**
  String loverBondMessage(String name);

  /// Rappel de la règle des Amoureux
  ///
  /// In fr, this message translates to:
  /// **'Si l\'un de vous meurt, l\'autre meurt aussitôt de chagrin. Gardez votre secret !'**
  String get loverBondRule;

  /// Case à cocher de la répartition des rôles (mode sans Cupidon)
  ///
  /// In fr, this message translates to:
  /// **'Ajouter deux Amoureux tirés au sort'**
  String get roleSelectionRandomLovers;

  /// Précision sous la case à cocher des Amoureux tirés au sort
  ///
  /// In fr, this message translates to:
  /// **'Ils l\'apprendront en découvrant leur rôle.'**
  String get roleSelectionRandomLoversHint;

  /// Libellé de l'option randomLoversInsteadOfCupidon
  ///
  /// In fr, this message translates to:
  /// **'Amoureux tirés au sort (sans Cupidon)'**
  String get settingRandomLoversInsteadOfCupidonLabel;

  /// Description de l'option randomLoversInsteadOfCupidon
  ///
  /// In fr, this message translates to:
  /// **'Si activé, Cupidon n\'est plus proposé : une case dans la répartition des rôles permet d\'ajouter deux Amoureux tirés au sort, qui l\'apprennent en découvrant leur rôle. Si désactivé, Cupidon désigne les Amoureux la première nuit, puis le téléphone passe chez chaque joueur pour les prévenir en secret.'**
  String get settingRandomLoversInsteadOfCupidonDescription;

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

  /// Surtitre de l'annonce publique de la mutation de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'Annonce au village'**
  String get enfantSauvageRevealOverline;

  /// Titre de l'annonce publique de la mutation de l'Enfant Sauvage
  ///
  /// In fr, this message translates to:
  /// **'L\'Enfant Sauvage a rejoint la meute'**
  String get enfantSauvageRevealTitle;

  /// Texte de l'annonce publique de la mutation de l'Enfant Sauvage (sans nommer le joueur)
  ///
  /// In fr, this message translates to:
  /// **'Son modèle vient de mourir. Désormais Loup-Garou, l\'Enfant Sauvage se réveillera avec les autres loups dès la nuit prochaine. Son identité reste secrète.'**
  String get enfantSauvageRevealBody;

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
  /// **'Choisis un autre Loup-Garou à éliminer secrètement, ou renonce cette nuit.'**
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

  /// Instruction d'action pour la Petite Fille
  ///
  /// In fr, this message translates to:
  /// **'Tu peux tenter d\'espionner les Loups-Garous. Reste discrète...'**
  String get petiteFilleInstruction;

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

  /// Instruction pour le Renard : choix du joueur central du trio
  ///
  /// In fr, this message translates to:
  /// **'Désigne un joueur : lui et ses deux voisins vivants seront flairés.'**
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
  /// **'Choisis le joueur protégé contre les attaques de cette nuit (pas le même que la nuit dernière).'**
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

  /// Instruction d'action pour le Voleur
  ///
  /// In fr, this message translates to:
  /// **'Regarde les deux cartes restantes et choisis d\'échanger ou non.'**
  String get voleurInstruction;

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

  /// Annonce de fin de partie quand tous les joueurs sont morts
  ///
  /// In fr, this message translates to:
  /// **'Personne ne survit : aucun vainqueur'**
  String get endGameWinnerNobody;

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
  /// **'Sa voix comptera double lors des votes du village.'**
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

  /// Titre de la section des réglages de l'application
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get settingsAppSectionTitle;

  /// Titre de la section des options de règles du jeu
  ///
  /// In fr, this message translates to:
  /// **'Règles de la partie'**
  String get settingsGameRulesSectionTitle;

  /// Libellé du choix de la langue de l'application
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguageLabel;

  /// Description du choix de la langue de l'application
  ///
  /// In fr, this message translates to:
  /// **'Langue utilisée dans toute l\'application.'**
  String get settingsLanguageDescription;

  /// Option de langue : suivre la langue du téléphone
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get settingsLanguageSystem;

  /// Libellé de l'option de narration audio
  ///
  /// In fr, this message translates to:
  /// **'Voix du narrateur'**
  String get settingsSoundNarrationLabel;

  /// Description de l'option de narration audio
  ///
  /// In fr, this message translates to:
  /// **'Pendant la nuit, une voix annonce quel rôle se réveille ou se rendort, pour que personne n\'ait à lire l\'écran.'**
  String get settingsSoundNarrationDescription;

  /// Libellé de l'option de musique d'ambiance
  ///
  /// In fr, this message translates to:
  /// **'Musique d\'ambiance'**
  String get settingsSoundMusicLabel;

  /// Description de l'option de musique d'ambiance
  ///
  /// In fr, this message translates to:
  /// **'Une musique douce tourne en boucle pendant la nuit et couvre les bruits de ceux qui jouent.'**
  String get settingsSoundMusicDescription;

  /// Libellé de l'option allowWerewolfToKillThemselves
  ///
  /// In fr, this message translates to:
  /// **'Les Loups peuvent se dévorer entre eux'**
  String get settingAllowWerewolfToKillThemselvesLabel;

  /// Description de l'option allowWerewolfToKillThemselves
  ///
  /// In fr, this message translates to:
  /// **'Si activé, un Loup-Garou peut être désigné comme victime par ses coéquipiers pendant la phase des Loups.'**
  String get settingAllowWerewolfToKillThemselvesDescription;

  /// Libellé de l'option allowHunterToShootAfterWitchDeathCause
  ///
  /// In fr, this message translates to:
  /// **'Le Chasseur peut tirer s\'il est tué par la Sorcière'**
  String get settingAllowHunterToShootAfterWitchDeathCauseLabel;

  /// Description de l'option allowHunterToShootAfterWitchDeathCause
  ///
  /// In fr, this message translates to:
  /// **'Si activé, le Chasseur peut utiliser son pouvoir de tir après avoir été empoisonné par la Sorcière.'**
  String get settingAllowHunterToShootAfterWitchDeathCauseDescription;

  /// Libellé de l'option allowWitchToPlayIfWerewolfDeathCause
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière joue même si elle est visée par les Loups'**
  String get settingAllowWitchToPlayIfWerewolfDeathCauseLabel;

  /// Description de l'option allowWitchToPlayIfWerewolfDeathCause
  ///
  /// In fr, this message translates to:
  /// **'Si activé, la Sorcière est quand même réveillée pour son tour même si elle est la victime désignée par les Loups-Garous cette nuit-là. Si désactivé, elle ne joue pas et succombe directement, sans utiliser ses potions.'**
  String get settingAllowWitchToPlayIfWerewolfDeathCauseDescription;

  /// Libellé de l'option allowWitchToSaveHerself
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière peut se sauver elle-même'**
  String get settingAllowWitchToSaveHerselfLabel;

  /// Description de l'option allowWitchToSaveHerself
  ///
  /// In fr, this message translates to:
  /// **'Si activé, la Sorcière peut utiliser sa potion de vie sur elle-même lorsqu\'elle est la victime désignée par les Loups-Garous.'**
  String get settingAllowWitchToSaveHerselfDescription;

  /// Libellé de l'option enfantSauvagePublicReveal
  ///
  /// In fr, this message translates to:
  /// **'Mutation de l\'Enfant Sauvage annoncée à tous'**
  String get settingEnfantSauvagePublicRevealLabel;

  /// Description de l'option enfantSauvagePublicReveal
  ///
  /// In fr, this message translates to:
  /// **'Si activé, la mutation de l\'Enfant Sauvage est révélée publiquement dès la mort de son modèle (pas d\'écran de nuit). Si désactivé, rien n\'est annoncé : l\'Enfant Sauvage est prévenu en secret au début de la nuit suivante.'**
  String get settingEnfantSauvagePublicRevealDescription;

  /// Libellé de l'option hunterCanOverturnFinishedGame
  ///
  /// In fr, this message translates to:
  /// **'Le Chasseur peut renverser une partie gagnée'**
  String get settingHunterCanOverturnFinishedGameLabel;

  /// Description de l'option hunterCanOverturnFinishedGame
  ///
  /// In fr, this message translates to:
  /// **'Si activé, le Chasseur tire avant que la partie ne soit jugée : quand sa mort semble donner la victoire à un camp, sa balle peut encore en changer l\'issue. Si désactivé, la partie se termine aussitôt, sans son tir.'**
  String get settingHunterCanOverturnFinishedGameDescription;

  /// Libellé de l'option voleurPlaysNewRoleFirstNight
  ///
  /// In fr, this message translates to:
  /// **'Le Voleur joue son nouveau rôle dès la première nuit'**
  String get settingVoleurPlaysNewRoleFirstNightLabel;

  /// Description de l'option voleurPlaysNewRoleFirstNight
  ///
  /// In fr, this message translates to:
  /// **'Si activé, le rôle pris sur la table (Voyante, Loup-Garou, Cupidon...) est appelé dès la première nuit. Si désactivé, il ne joue qu\'à partir de la nuit suivante : un rôle de première nuit (Cupidon, Enfant Sauvage) n\'agira alors jamais.'**
  String get settingVoleurPlaysNewRoleFirstNightDescription;

  /// Libellé de l'option infectCanInfectProtectedVictim
  ///
  /// In fr, this message translates to:
  /// **'L\'Infect Père peut infecter une victime protégée'**
  String get settingInfectCanInfectProtectedVictimLabel;

  /// Description de l'option infectCanInfectProtectedVictim
  ///
  /// In fr, this message translates to:
  /// **'Si activé, l\'Infect Père des Loups infecte la victime des loups même si le Salvateur la protège. Si désactivé, la protection empêche aussi l\'infection, et l\'Infect Père garde son pouvoir pour une autre nuit.'**
  String get settingInfectCanInfectProtectedVictimDescription;

  /// Libellé de l'option infectedKeepsPower
  ///
  /// In fr, this message translates to:
  /// **'L\'infecté garde son pouvoir'**
  String get settingInfectedKeepsPowerLabel;

  /// Description de l'option infectedKeepsPower
  ///
  /// In fr, this message translates to:
  /// **'Si activé, le joueur infecté par l\'Infect Père rejoint la meute en gardant son rôle et son pouvoir (une Voyante infectée continue de sonder, pour les loups). Si désactivé, il devient un simple Loup-Garou.'**
  String get settingInfectedKeepsPowerDescription;

  /// Libellé de l'option mayorBreaksTies
  ///
  /// In fr, this message translates to:
  /// **'Égalité au vote : le maire tranche'**
  String get settingMayorBreaksTiesLabel;

  /// Description de l'option mayorBreaksTies
  ///
  /// In fr, this message translates to:
  /// **'Si activé, quand le vote du village finit à égalité, le maire désigne lui-même qui est éliminé parmi les ex aequo. Sans maire vivant (ou si désactivé), c\'est l\'option suivante qui s\'applique. Un Bouc Émissaire vivant passe avant tout : c\'est lui qui est éliminé.'**
  String get settingMayorBreaksTiesDescription;

  /// Libellé de l'option tieMeansNoElimination
  ///
  /// In fr, this message translates to:
  /// **'Égalité au vote : personne n\'est éliminé'**
  String get settingTieMeansNoEliminationLabel;

  /// Description de l'option tieMeansNoElimination
  ///
  /// In fr, this message translates to:
  /// **'Si activé, une égalité que le maire ne tranche pas n\'élimine personne ce jour-là. Si désactivé, le village revote entre les ex aequo.'**
  String get settingTieMeansNoEliminationDescription;

  /// Libellé de l'option idiotDiesOnSecondVote
  ///
  /// In fr, this message translates to:
  /// **'L\'Idiot du Village n\'est gracié qu\'une fois'**
  String get settingIdiotDiesOnSecondVoteLabel;

  /// Description de l'option idiotDiesOnSecondVote
  ///
  /// In fr, this message translates to:
  /// **'Si activé, l\'Idiot déjà démasqué meurt s\'il est de nouveau désigné par le vote. Si désactivé, il survit à chaque vote.'**
  String get settingIdiotDiesOnSecondVoteDescription;

  /// Libellé de l'option loupBlancMustBeLastSurvivor
  ///
  /// In fr, this message translates to:
  /// **'Le Loup Blanc empêche la victoire des loups'**
  String get settingLoupBlancMustBeLastSurvivorLabel;

  /// Description de l'option loupBlancMustBeLastSurvivor
  ///
  /// In fr, this message translates to:
  /// **'Si activé, tant que le Loup-Garou Blanc vit, les loups ne gagnent pas : la partie continue jusqu\'à ce qu\'il reste seul ou meure. Si désactivé, les loups gagnent dès qu\'ils sont majoritaires, et le Loup Blanc perd avec le village.'**
  String get settingLoupBlancMustBeLastSurvivorDescription;

  /// Libellé de l'option ancienPowerLossByAnyVillager
  ///
  /// In fr, this message translates to:
  /// **'L\'Ancien tué par un villageois coûte leurs pouvoirs au village'**
  String get settingAncienPowerLossByAnyVillagerLabel;

  /// Description de l'option ancienPowerLossByAnyVillager
  ///
  /// In fr, this message translates to:
  /// **'Si activé, les villageois perdent leurs pouvoirs si l\'Ancien est pendu, empoisonné par la Sorcière ou abattu par le Chasseur. Si désactivé, seulement s\'il est pendu par le vote.'**
  String get settingAncienPowerLossByAnyVillagerDescription;

  /// Titre de l'écran privé qui apprend à un joueur qu'il a été infecté
  ///
  /// In fr, this message translates to:
  /// **'Infection'**
  String get infectedRevealTitle;

  /// Message privé au joueur infecté
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous t\'ont infecté(e) : tu fais désormais partie de la meute. Tu te réveilles avec eux dès cette nuit.'**
  String get infectedRevealInstruction;

  /// Ajout quand l'infecté garde son pouvoir
  ///
  /// In fr, this message translates to:
  /// **'Tu gardes ton pouvoir de {role}.'**
  String infectedRevealKeepsPower(String role);

  /// Rôle d'un joueur infecté, en fin de partie ou à sa mort
  ///
  /// In fr, this message translates to:
  /// **'{role} infecté(e)'**
  String roleInfected(String role);

  /// Bouton des Loups quand il ne reste que des loups à dévorer et qu'ils ne peuvent pas se dévorer entre eux
  ///
  /// In fr, this message translates to:
  /// **'Aucune victime possible cette nuit'**
  String get loupsNoPossibleVictimButton;

  /// Consigne du Bouc Émissaire, éliminé à la place des ex aequo
  ///
  /// In fr, this message translates to:
  /// **'Avant de mourir, désigne qui pourra voter demain : touche les joueurs pour les retirer ou les remettre.'**
  String get boucEmissaireVotersInstruction;

  /// Bouton de validation du Bouc Émissaire
  ///
  /// In fr, this message translates to:
  /// **'Confirmer ({count} votant(s) demain)'**
  String boucEmissaireConfirmVoters(int count);

  /// Rappel avant le vote du village quand le Bouc Émissaire a restreint les votants
  ///
  /// In fr, this message translates to:
  /// **'Le Bouc Émissaire n\'a laissé voter aujourd\'hui que : {names}.'**
  String voteRestrictedByBouc(String names);

  /// Rappel de la règle d'égalité
  ///
  /// In fr, this message translates to:
  /// **'En cas d\'égalité, c\'est le Bouc Émissaire qui est éliminé.'**
  String get voteTieRuleBouc;

  /// Rappel de la règle d'égalité
  ///
  /// In fr, this message translates to:
  /// **'En cas d\'égalité, le maire désigne qui est éliminé parmi les ex aequo.'**
  String get voteTieRuleMayor;

  /// Rappel de la règle d'égalité
  ///
  /// In fr, this message translates to:
  /// **'En cas d\'égalité, personne n\'est éliminé.'**
  String get voteTieRuleNobody;

  /// Rappel de la règle d'égalité
  ///
  /// In fr, this message translates to:
  /// **'En cas d\'égalité, revotez entre les ex aequo.'**
  String get voteTieRuleRunoff;

  /// Bouton du vote collectif quand la table est à égalité
  ///
  /// In fr, this message translates to:
  /// **'Égalité'**
  String get voteTieButton;

  /// Titre de l'écran où le maire départage
  ///
  /// In fr, this message translates to:
  /// **'Égalité !'**
  String get voteTieMayorTitle;

  /// Consigne au maire qui départage
  ///
  /// In fr, this message translates to:
  /// **'{mayor}, maire, désigne qui est éliminé parmi les ex aequo.'**
  String voteTieMayorInstruction(String mayor);

  /// Résultat d'un vote à égalité
  ///
  /// In fr, this message translates to:
  /// **'Égalité : le Bouc Émissaire est éliminé à la place des ex aequo.'**
  String get voteResultTieBouc;

  /// Résultat d'un vote à égalité
  ///
  /// In fr, this message translates to:
  /// **'Égalité : le maire a tranché.'**
  String get voteResultTieMayor;

  /// Résultat d'un vote à égalité
  ///
  /// In fr, this message translates to:
  /// **'Égalité : personne n\'est éliminé.'**
  String get voteResultTieNobody;

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

  /// Nom de phase pour la révélation des Amoureux après Cupidon
  ///
  /// In fr, this message translates to:
  /// **'Révélation des Amoureux'**
  String get phaseNightLoversReveal;

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

  /// Rappel du pouvoir du maire avant son élection
  ///
  /// In fr, this message translates to:
  /// **'Sa voix comptera double lors des votes du village.'**
  String get mayorElectionDoubleVoiceExplain;

  /// Question avant un vote : collectif ou secret
  ///
  /// In fr, this message translates to:
  /// **'Comment voulez-vous voter ?'**
  String get voteModeQuestion;

  /// Choix du vote collectif
  ///
  /// In fr, this message translates to:
  /// **'Vote collectif'**
  String get voteModeCollectiveButton;

  /// Explication du vote collectif
  ///
  /// In fr, this message translates to:
  /// **'Tout le monde vote en même temps, à voix haute ou à main levée.'**
  String get voteModeCollectiveHint;

  /// Choix du vote secret
  ///
  /// In fr, this message translates to:
  /// **'Vote secret'**
  String get voteModeSecretButton;

  /// Explication du vote secret
  ///
  /// In fr, this message translates to:
  /// **'Le téléphone passe de main en main, chacun vote en secret.'**
  String get voteModeSecretHint;

  /// Instruction du vote collectif pour le maire
  ///
  /// In fr, this message translates to:
  /// **'Votez tous ensemble, puis sélectionnez le joueur élu maire.'**
  String get collectiveVoteMayorInstruction;

  /// Instruction du vote collectif du village
  ///
  /// In fr, this message translates to:
  /// **'Votez tous ensemble, puis sélectionnez le joueur qui a reçu le plus de voix.'**
  String get collectiveVoteVillageInstruction;

  /// Bouton désactivé tant qu'aucun joueur n'est sélectionné
  ///
  /// In fr, this message translates to:
  /// **'Sélectionnez un joueur'**
  String get collectiveVoteSelectPlayer;

  /// Rappel de la voix double du maire en vote collectif
  ///
  /// In fr, this message translates to:
  /// **'{name} est maire : sa voix compte double.'**
  String collectiveVoteMayorDoubleVoice(String name);

  /// Rappel de la malédiction du Corbeau en vote collectif
  ///
  /// In fr, this message translates to:
  /// **'Le Corbeau a désigné {name} : 2 voix de plus contre lui ou elle.'**
  String collectiveVoteCorbeauCurse(String name);

  /// Rappel qu'un joueur ne peut plus voter
  ///
  /// In fr, this message translates to:
  /// **'{name} a perdu son droit de vote.'**
  String collectiveVoteCannotVote(String name);

  /// Bouton de confirmation du vote collectif du maire
  ///
  /// In fr, this message translates to:
  /// **'Confirmer : {name} est élu(e) maire'**
  String collectiveVoteConfirmMayorButton(String name);

  /// Bouton de confirmation du vote collectif du village
  ///
  /// In fr, this message translates to:
  /// **'Confirmer : {name} est éliminé(e)'**
  String collectiveVoteConfirmEliminationButton(String name);

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/nightFalls.mp3). Début de chaque nuit. Ton grave et posé.
  ///
  /// In fr, this message translates to:
  /// **'Le village s\'endort.'**
  String get narrationNightFalls;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/dayBreaks.mp3). Fin de la nuit, avant l'annonce des morts. Ton plus clair.
  ///
  /// In fr, this message translates to:
  /// **'Le jour se lève.'**
  String get narrationDayBreaks;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/loversReveal.mp3). Juste après Cupidon : le téléphone passe chez chaque joueur.
  ///
  /// In fr, this message translates to:
  /// **'Les Amoureux vont se découvrir. Le téléphone va faire le tour de la table : quand il arrive entre vos mains, ouvrez les yeux, lisez votre message secret, donnez le téléphone au joueur indiqué, puis rendormez-vous.'**
  String get narrationLoversReveal;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeVoleur.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Le Voleur se réveille.'**
  String get narrationWakeVoleur;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepVoleur.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Le Voleur se rendort.'**
  String get narrationSleepVoleur;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeCupidon.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Cupidon se réveille.'**
  String get narrationWakeCupidon;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepCupidon.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Cupidon se rendort.'**
  String get narrationSleepCupidon;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeEnfantSauvage.mp3). Dite aussi quand l'Enfant Sauvage apprend en secret qu'il est devenu Loup-Garou.
  ///
  /// In fr, this message translates to:
  /// **'L\'Enfant Sauvage se réveille.'**
  String get narrationWakeEnfantSauvage;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepEnfantSauvage.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'L\'Enfant Sauvage se rendort.'**
  String get narrationSleepEnfantSauvage;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeSalvateur.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Le Salvateur se réveille.'**
  String get narrationWakeSalvateur;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepSalvateur.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Le Salvateur se rendort.'**
  String get narrationSleepSalvateur;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeVoyante.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'La Voyante se réveille.'**
  String get narrationWakeVoyante;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepVoyante.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'La Voyante se rendort.'**
  String get narrationSleepVoyante;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeLoups.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous se réveillent.'**
  String get narrationWakeLoups;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepLoups.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Les Loups-Garous se rendorment.'**
  String get narrationSleepLoups;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeLoupBlanc.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Le Loup-Garou Blanc se réveille.'**
  String get narrationWakeLoupBlanc;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepLoupBlanc.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Le Loup-Garou Blanc se rendort.'**
  String get narrationSleepLoupBlanc;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeGrandMechantLoup.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Le Grand Méchant Loup se réveille.'**
  String get narrationWakeGrandMechantLoup;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepGrandMechantLoup.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Le Grand Méchant Loup se rendort.'**
  String get narrationSleepGrandMechantLoup;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeInfectPereDesLoups.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'L\'Infect Père des Loups se réveille.'**
  String get narrationWakeInfectPereDesLoups;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepInfectPereDesLoups.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'L\'Infect Père des Loups se rendort.'**
  String get narrationSleepInfectPereDesLoups;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeRenard.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Le Renard se réveille.'**
  String get narrationWakeRenard;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepRenard.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Le Renard se rendort.'**
  String get narrationSleepRenard;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeCorbeau.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'Le Corbeau se réveille.'**
  String get narrationWakeCorbeau;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepCorbeau.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'Le Corbeau se rendort.'**
  String get narrationSleepCorbeau;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/wakeSorciere.mp3). Dite quand ce rôle se réveille.
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière se réveille.'**
  String get narrationWakeSorciere;

  /// Narration audio lue pendant la nuit (fichier assets/audio/voice/<langue>/sleepSorciere.mp3). Dite quand ce rôle se rendort.
  ///
  /// In fr, this message translates to:
  /// **'La Sorcière se rendort.'**
  String get narrationSleepSorciere;

  /// Libellé de l'option des faux tours.
  ///
  /// In fr, this message translates to:
  /// **'Appeler les rôles sans pouvoir'**
  String get settingFakeTurnsForPowerlessRolesLabel;

  /// Description de l'option des faux tours.
  ///
  /// In fr, this message translates to:
  /// **'Si activé, comme un vrai meneur, le narrateur appelle quand même la Sorcière sans potion, le Renard sans flair, l\'Infect Père des Loups qui a déjà infecté ou le Grand Méchant Loup privé de son pouvoir : ils se réveillent quelques secondes pour rien. Sinon, leur silence trahirait qu\'ils n\'ont plus de pouvoir.'**
  String get settingFakeTurnsForPowerlessRolesDescription;

  /// Libellé de l'option d'annonce de la cause des morts.
  ///
  /// In fr, this message translates to:
  /// **'Annoncer la cause des morts'**
  String get settingRevealDeathCauseLabel;

  /// Description de l'option d'annonce de la cause des morts.
  ///
  /// In fr, this message translates to:
  /// **'Si activé, l\'annonce de chaque mort précise comment le joueur est mort (dévoré par les Loups-Garous, empoisonné par la Sorcière...). Sinon, seuls son nom et son rôle sont révélés.'**
  String get settingRevealDeathCauseDescription;

  /// Rubrique des réglages : déroulé de la nuit, annonces.
  ///
  /// In fr, this message translates to:
  /// **'Nuit et annonces'**
  String get settingCategoryNight;

  /// Rubrique des réglages consacrée aux loups.
  ///
  /// In fr, this message translates to:
  /// **'Loups-Garous'**
  String get settingCategoryWolves;

  /// Rubrique des réglages consacrée à la Sorcière.
  ///
  /// In fr, this message translates to:
  /// **'Sorcière'**
  String get settingCategoryWitch;

  /// Rubrique des réglages consacrée au Chasseur.
  ///
  /// In fr, this message translates to:
  /// **'Chasseur'**
  String get settingCategoryHunter;

  /// Rubrique des réglages consacrée aux votes.
  ///
  /// In fr, this message translates to:
  /// **'Votes du village'**
  String get settingCategoryVote;

  /// Rubrique des réglages pour les autres rôles.
  ///
  /// In fr, this message translates to:
  /// **'Autres rôles'**
  String get settingCategoryOtherRoles;

  /// Bandeau de l'écran des réglages ouvert pendant une partie.
  ///
  /// In fr, this message translates to:
  /// **'Partie en cours : les changements s\'appliquent tout de suite.'**
  String get settingsInGameNotice;

  /// Bouton en bas des réglages.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir les règles par défaut'**
  String get settingsResetRulesButton;

  /// Titre de la confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir les règles ?'**
  String get settingsResetRulesDialogTitle;

  /// Message de la confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les règles reprennent leur valeur par défaut. La langue et le son ne changent pas.'**
  String get settingsResetRulesDialogMessage;

  /// Bouton de confirmation.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir'**
  String get settingsResetRulesConfirmLabel;

  /// Curseur du volume de la musique.
  ///
  /// In fr, this message translates to:
  /// **'Volume de la musique'**
  String get settingsSoundMusicVolumeLabel;

  /// Curseur du volume des bruitages.
  ///
  /// In fr, this message translates to:
  /// **'Volume des bruitages'**
  String get settingsSoundSfxVolumeLabel;

  /// Explication sous le curseur des bruitages.
  ///
  /// In fr, this message translates to:
  /// **'Hurlement des loups à leur réveil, chant du coq au lever du jour. À zéro, ils sont coupés.'**
  String get settingsSoundSfxDescription;

  /// Choix de langue : suivre celle du téléphone (libellé court).
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get settingsLanguageSystemShort;

  /// Écran d'un faux tour : le rôle n'a plus rien à faire.
  ///
  /// In fr, this message translates to:
  /// **'Fais comme si tu jouais : garde les yeux ouverts quelques secondes. Le narrateur te dira quand te rendormir.'**
  String get fakeTurnInstruction;

  /// Faux tour de la Sorcière : plus de potion.
  ///
  /// In fr, this message translates to:
  /// **'Tu as utilisé tes deux potions.'**
  String get fakeTurnSorciereNoPotion;

  /// Faux tour de la Sorcière : empêchée de jouer (réglage).
  ///
  /// In fr, this message translates to:
  /// **'Cette nuit, tu ne peux pas utiliser tes potions.'**
  String get fakeTurnSorciereCannotPlay;

  /// Faux tour du Renard.
  ///
  /// In fr, this message translates to:
  /// **'Tu as perdu ton flair.'**
  String get fakeTurnRenard;

  /// Faux tour de l'Infect Père des Loups.
  ///
  /// In fr, this message translates to:
  /// **'Tu as déjà utilisé ton pouvoir d\'infection.'**
  String get fakeTurnInfectPereDesLoups;

  /// Faux tour du Grand Méchant Loup.
  ///
  /// In fr, this message translates to:
  /// **'Un membre de la meute est mort : tu ne peux plus dévorer de seconde victime.'**
  String get fakeTurnGrandMechantLoup;

  /// Bouton d'un faux tour, qui se valide tout seul.
  ///
  /// In fr, this message translates to:
  /// **'Patiente...'**
  String get fakeTurnWaitButton;

  /// Bulle du bouton qui ouvre la liste des rôles.
  ///
  /// In fr, this message translates to:
  /// **'Rôles de la partie'**
  String get gameRolesTooltip;

  /// Titre de la liste des rôles de la partie.
  ///
  /// In fr, this message translates to:
  /// **'Rôles de la partie'**
  String get gameRolesSheetTitle;

  /// Explication en haut de la liste des rôles.
  ///
  /// In fr, this message translates to:
  /// **'Chaque carte de la partie. Une carte n\'est plus en jeu une fois révélée par la mort de son joueur.'**
  String get gameRolesSheetIntro;

  /// Nombre de cartes d'un rôle encore en jeu.
  ///
  /// In fr, this message translates to:
  /// **'{remaining} / {total} en jeu'**
  String gameRolesRemaining(int remaining, int total);

  /// Toutes les cartes de ce rôle ont été révélées.
  ///
  /// In fr, this message translates to:
  /// **'Plus en jeu'**
  String get gameRolesNoneLeft;

  /// Résumé : liste des morts et des élections d'un round.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui s\'est passé'**
  String get gameProgressEventsTitle;

  /// Résumé : liste des étapes d'un round.
  ///
  /// In fr, this message translates to:
  /// **'Déroulé'**
  String get gameProgressStepsTitle;

  /// Résumé : un mort, sans la cause.
  ///
  /// In fr, this message translates to:
  /// **'{name} ({role}) est mort(e)'**
  String gameEventDeath(String name, String role);

  /// Résumé : un mort et sa cause.
  ///
  /// In fr, this message translates to:
  /// **'{name} ({role}) : {cause}'**
  String gameEventDeathWithCause(String name, String role, String cause);

  /// Résumé : élection du maire.
  ///
  /// In fr, this message translates to:
  /// **'{name} est élu(e) maire'**
  String gameEventMayorElected(String name);

  /// Résumé : succession du maire.
  ///
  /// In fr, this message translates to:
  /// **'{name} succède au maire'**
  String gameEventMayorSuccession(String name);

  /// Résumé : résultat du vote du village.
  ///
  /// In fr, this message translates to:
  /// **'Le village désigne {name}'**
  String gameEventVillageVote(String name);

  /// Résumé : vote sans élimination.
  ///
  /// In fr, this message translates to:
  /// **'Le village n\'élimine personne'**
  String get gameEventNobodyEliminated;

  /// Résumé : l'Idiot du Village gracié.
  ///
  /// In fr, this message translates to:
  /// **'{name} se révèle Idiot du Village et survit'**
  String gameEventIdiotSpared(String name);

  /// Résumé : voix reçues par un candidat.
  ///
  /// In fr, this message translates to:
  /// **'{name} : {count, plural, =1{1 voix} other{{count} voix}}'**
  String gameEventVotes(String name, int count);

  /// Résumé : round sans événement.
  ///
  /// In fr, this message translates to:
  /// **'Aucun mort, aucune élection.'**
  String get gameEventNone;
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
