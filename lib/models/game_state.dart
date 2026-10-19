import 'game_config.dart';
import 'game_settings.dart';
import 'player.dart';
import 'role.dart';
import 'game_progress.dart';

/// Toutes les phases possibles de la machine à états du jeu.
enum GamePhase {
  // Configuration (avant la partie)
  setupPlayerCount,
  setupRoles,
  setupNames,
  roleReveal,

  // Nuit
  nightIntro,
  // Transition générique affichée après qu'un rôle a fini son action de
  // nuit, avant de passer au rôle suivant : "tu peux te rendormir". Ne
  // porte aucune information sur le rôle qui vient d'agir (voir
  // GameEngine.buildNightQueue) — elle est volontairement neutre.
  nightGoBackToSleep,
  nightVoleur,
  nightCupidon,
  // Juste après Cupidon : le téléphone passe chez chaque joueur, les deux
  // Amoureux apprennent en secret qui est leur moitié, les autres voient un
  // écran neutre (voir LoversRevealScreen).
  nightLoversReveal,
  nightEnfantSauvage,
  nightEnfantSauvageMutation,
  // Le joueur infecté la nuit précédente l'apprend en secret, juste avant
  // de se réveiller pour la première fois avec la meute.
  nightInfectedReveal,
  nightSalvateur,
  nightVoyante,
  nightLoups,
  nightPetiteFille,
  nightLoupBlanc,
  nightGrandMechantLoup,
  nightEnfantSauvageCheck,
  nightInfectPereDesLoups,
  nightRenard,
  nightCorbeau,
  nightSorciere,

  // Suites déclenchées par une mort. Il n'y a plus de file générique
  // d'actions en attente : chaque mort pose un flag précis sur le
  // GameState (chasseurRevengeTargetId, mayorSuccessionNeededFor,
  // enfantSauvageTransformedId, ...) et GameEngine._resolveFollowUps
  // regarde ces flags, dans un ordre fixe, pour savoir sur quelle phase
  // basculer. Voir game_engine.dart pour le détail.
  chasseurRevange,
  successionMaire,
  enfantsauvageReveal,

  // Jour
  dayReveal,
  mayorElectionExplain,
  mayorElection,
  mayorReveal,
  debate,
  jugeBegueDecision,
  villageVote,
  voteResult,

  villagePowerLoss,
  servanteDevouee,
  boucEmissaire,
  idiotduvillageCivicRightLoss,

  // Fin
  endGame,
}

/// D'où viennent les morts en cours de résolution (nuit ou vote) : permet
/// à [GameEngine._resolveFollowUps] de savoir quoi faire une fois que
/// tous les flags de suivi ont été traités.
enum FollowUpOrigin { nightDeaths, voteDeaths }

/// Mode du prochain vote (élection du maire ou vote du village), choisi
/// juste avant : vote secret (le téléphone passe de main en main) ou vote
/// collectif (toute la table vote ensemble, le résultat est saisi une fois).
enum VoteMode { secret, collective }

/// Ce qui règle une égalité au vote du village (voir
/// GameEngine.villageVoteTieRule).
enum VoteTieRule {
  /// Le Bouc Émissaire, vivant, est éliminé à la place des ex aequo.
  boucEmissaire,

  /// Le maire désigne l'éliminé parmi les ex aequo.
  mayorDecides,

  /// Personne n'est éliminé ce jour-là.
  nobodyEliminated,

  /// Le village revote entre les ex aequo.
  runoff,
}

/// Un villageois qui vient de perdre son pouvoir suite à l'exécution
/// erronée de l'Ancien. On garde son ancien rôle pour l'animation de
/// révélation, même si Player.role a déjà basculé sur simpleVillageois.
class PowerLossEntry {
  final String playerId;
  final RoleId previousRole;
  const PowerLossEntry(this.playerId, this.previousRole);
}

class GameResult {
  /// null : plus personne n'est en vie, personne ne gagne.
  final Camp? winner;
  final List<String> winningPlayerIds;
  const GameResult(this.winner, this.winningPlayerIds);
}

class GameState {
  final String id;
  final DateTime startedAt;
  final GameConfig config;
  final List<Player> players;
  /// Règles de cette partie, copiées à sa création : seules les options
  /// [GameSettingDefinition.liveInGame] y sont reportées ensuite.
  final GameSettings settings;

  /// Nombre de changements de réglages faits pendant la partie (affiché
  /// en haut de l'écran des réglages).
  int settingsChangeCount = 0;

  int night = 1;
  int day = 0;
  GamePhase phase;
  String currentWave = 'night'; // 'night' ou 'day'

  List<GamePhase> phaseQueue = [];
  int phaseIndex = 0;
  /// Historique complet de la partie (une entrée par nuit/jour), pour le
  /// résumé "live" affiché depuis l'écran de jeu (voir GameProgressSheet).
  List<RoundRecord> rounds = [];

  String? mayorId;
  VoteMode voteMode = VoteMode.secret;
  bool ancienExtraLifeUsed = false;
  List<PowerLossEntry> powerLossThisWave = [];

  // --- Loups ---
  String? loupsVictimId; // victime "officielle" désignée par les loups
  String? grandMechantLoupSecondVictimId;
  bool infectPereDesLoupsUsed = false;
  String? infectedTonightId;
  /// Joueur infecté qui ne le sait pas encore : il l'apprend en secret au
  /// début de la nuit suivante.
  String? infectedRevealPendingId;
  String? loupBlancVictimId;

  // --- Protections / substitutions ---
  String? salvateurProtectedId; // choix de cette nuit
  String? salvateurLastProtectedId; // choix de la nuit précédente
  bool petiteFilleTriedTonight = false;
  bool petiteFilleCaughtTonight = false;
  String? finalNightVictimId; // victime réelle, après protections/substitutions

  // --- Sorcière ---
  bool sorciereVieUsed = false;
  bool sorciereMortUsed = false;
  String? sorciereSavedIdTonight;
  String? sorciereKilledIdTonight;

  // --- Voleur / Cupidon ---
  List<RoleId> voleurTableCards = [];
  List<String> loversIds = []; // 0 ou 2 ids

  // --- Renard / Corbeau / Juge Bègue ---
  List<String> renardTargetIds = [];
  bool? renardFoundWolfLastQuery;
  bool renardPowerLost = false;
  String? corbeauCursedId;
  bool jugeBegueUsed = false;
  bool voteReplayPending = false;

  // --- Bouc Émissaire / Idiot du Village ---
  /// Les seuls joueurs autorisés à voter au jour [boucVoteRestrictionDay],
  /// désignés par le Bouc Émissaire mort à la place des ex aequo.
  Set<String> boucAllowedVoterIds = {};
  int? boucVoteRestrictionDay;
  Set<String> disenfranchisedPlayerIds = {};

  /// Comment s'est réglée l'égalité du dernier vote du village (null : pas
  /// d'égalité), pour l'annoncer au résultat.
  VoteTieRule? lastVoteTie;

  /// Décompte du dernier vote secret dépouillé (voir GameEngine.tallyVotes),
  /// repris dans le résumé de la partie quand ce vote est validé.
  Map<String, int>? lastVoteCounts;

  // --- Morts de la vague en cours (nuit ou vote), pas encore révélées ---
  List<String> deathsThisWave = [];

  FollowUpOrigin? followUpOrigin;
  String? chasseurRevengeTargetId; // id du Chasseur qui doit tirer
  String? mayorSuccessionNeededFor; // id de l'ancien maire, mort
  String? enfantSauvageTransformedId; // id de l'Enfant Sauvage venant de muter
  RoleId? enfantSauvagePreviousRole; // pour l'animation de révélation
  String? enfantSauvageNightMutationId; // mutation à annoncer en privé la nuit suivante
  String? servanteDevoueeOfferId; // id du joueur mort dont le rôle est disponible
  String? boucEmissaireChoiceNeededId; // id du Bouc Émissaire qui vient d'être voté
  String? idiotDuVillageRevealId; // id de l'Idiot qui vient d'être voté (survit)

  GameResult? result;

  GameState({
    required this.id,
    required this.startedAt,
    required this.config,
    required this.players,
    required this.settings,
    this.phase = GamePhase.roleReveal,
  });

  Player byId(String id) => players.firstWhere((p) => p.id == id);
  Player? tryById(String? id) =>
      id == null ? null : players.where((p) => p.id == id).firstOrNull;

  List<Player> get alivePlayers => players.where((p) => p.alive).toList();
  List<Player> alivePlayersWithRole(RoleId role) =>
      alivePlayers.where((p) => p.role == role).toList();
  bool hasAliveRole(RoleId role) => alivePlayersWithRole(role).isNotEmpty;
  bool gameHasRole(RoleId role) => players.any((p) => p.role == role);

  /// Nombre de cartes de chaque rôle de la partie qui n'ont pas encore été
  /// révélées par une mort : ce que tout le village peut savoir, sans
  /// rien trahir (une carte restée sur la table du Voleur compte comme
  /// encore en jeu). Seuls les rôles de la partie y figurent.
  Map<RoleId, int> get remainingRoleCounts {
    final remaining = {
      for (final e in config.roleCounts.entries)
        if (e.value > 0) e.key: e.value,
    };
    for (final p in players.where((p) => !p.alive)) {
      final left = remaining[p.card];
      if (left != null && left > 0) remaining[p.card] = left - 1;
    }
    return remaining;
  }

  /// Vrai si [phase] est un « faux tour » : le rôle est appelé comme
  /// d'habitude (réglage fakeTurnsForPowerlessRoles), mais n'a plus rien à
  /// faire. Le joueur se réveille quelques secondes puis se rendort, pour
  /// qu'à l'oreille rien ne distingue cette nuit des autres.
  bool isFakeTurn(GamePhase phase) {
    switch (phase) {
      case GamePhase.nightSorciere:
        if (sorciereVieUsed && sorciereMortUsed) return true;
        final sorciere = alivePlayersWithRole(RoleId.sorciere);
        // Réglage : la Sorcière dévorée cette nuit ne joue pas.
        return !settings.allowWitchToPlayIfWerewolfDeathCause &&
            sorciere.isNotEmpty &&
            finalNightVictimId == sorciere.first.id;
      case GamePhase.nightRenard:
        return renardPowerLost;
      case GamePhase.nightInfectPereDesLoups:
        return infectPereDesLoupsUsed;
      case GamePhase.nightGrandMechantLoup:
        return !wolfPackIntact;
      default:
        return false;
    }
  }
  /// Joueurs vivants pouvant participer au vote du village. L'Idiot du
  /// Village, une fois démasqué, en a perdu le droit — mais reste éligible
  /// en tant que candidat. Le lendemain de sa mort, le Bouc Émissaire a pu
  /// restreindre les votants (sauf s'ils sont tous morts entre-temps).
  List<Player> get eligibleVoters {
    final voters = alivePlayers
        .where((p) => !disenfranchisedPlayerIds.contains(p.id))
        .toList();
    if (boucVoteRestrictionDay != day) return voters;
    final allowed =
        voters.where((p) => boucAllowedVoterIds.contains(p.id)).toList();
    return allowed.isEmpty ? voters : allowed;
  }

  /// Vrai si le Bouc Émissaire a restreint les votants aujourd'hui.
  bool get voteRestrictedByBouc =>
      boucVoteRestrictionDay == day &&
      eligibleVoters.length < alivePlayers
          .where((p) => !disenfranchisedPlayerIds.contains(p.id))
          .length;

  /// La victime que la Sorcière voit à son réveil : celle désignée par les
  /// loups, même protégée par le Salvateur (elle ne le sait pas et peut
  /// gaspiller sa potion), mais pas une victime infectée, qui ne meurt pas.
  String? get sorciereSeesVictimId =>
      loupsVictimId == infectedTonightId ? null : loupsVictimId;

  List<Player> get aliveWolves =>
      alivePlayers.where((p) => p.camp == Camp.loups).toList();

  /// Membre de la meute qui se réveille au tour des Loups : les Loups-Garous
  /// et le Loup-Garou Blanc, qui chasse avec eux (son camp est pourtant
  /// Camp.seul). C'est aussi un loup pour l'ours du Montreur et le flair
  /// du Renard.
  bool isWolfPackMember(Player p) =>
      p.camp == Camp.loups || p.role == RoleId.loupBlanc;

  List<Player> get aliveWolfPack =>
      alivePlayers.where(isWolfPackMember).toList();

  /// Vrai tant qu'un loup se réveille au tour des Loups — y compris le Loup
  /// Blanc seul, une fois la meute décimée.
  bool get wolfPackAwake => alivePlayers.any(isWolfPackMember);

  /// Le Salvateur ne peut pas protéger la même personne deux nuits de
  /// suite.
  bool salvateurCanProtect(String playerId) =>
      playerId != salvateurLastProtectedId;
  List<Player> get aliveVillagers =>
      alivePlayers.where((p) => p.camp == Camp.village).toList();

  /// Vrai tant qu'aucun membre du camp des Loups n'est mort — condition
  /// d'activation du pouvoir du Grand Méchant Loup.
  bool get wolfPackIntact =>
      players.where((p) => p.camp == Camp.loups).every((p) => p.alive);

  /// Vrai si un Loup-Garou se trouve parmi les voisins vivants (immédiats,
  /// dans l'ordre de la liste des joueurs) du Montreur d'Ours.
  bool get montreurDoursGrowls {
    if (!hasAliveRole(RoleId.montreurDours)) return false;
    final bear = alivePlayersWithRole(RoleId.montreurDours).first;
    final ordered = alivePlayers;
    final idx = ordered.indexOf(bear);
    if (idx == -1 || ordered.length < 2) return false;
    final left = ordered[(idx - 1 + ordered.length) % ordered.length];
    final right = ordered[(idx + 1) % ordered.length];
    return isWolfPackMember(left) || isWolfPackMember(right);
  }

  /// Le joueur [centerId] et ses deux voisins vivants immédiats (ordre de
  /// la liste des joueurs, comme pour le Montreur d'Ours). Avec très peu de
  /// joueurs vivants, les doublons sont fusionnés (groupe de 1 ou 2).
  List<String> renardTrioAround(String centerId) {
    final ordered = alivePlayers;
    final idx = ordered.indexWhere((p) => p.id == centerId);
    if (idx == -1) return [];
    final n = ordered.length;
    return <String>{
      ordered[(idx - 1 + n) % n].id,
      centerId,
      ordered[(idx + 1) % n].id,
    }.toList();
  }
  /// Vrai si au moins un Loup-Garou se trouve parmi [ids]. Le Loup-Garou
  /// Blanc compte comme un loup pour le flair (son camp est Camp.seul).
  bool renardTrioHasWolf(List<String> ids) => ids.any((id) {
    final p = tryById(id);
    return p != null && isWolfPackMember(p);
  });
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}