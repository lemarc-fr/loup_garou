import '../models/game_state.dart';

/// Phrases lues à voix haute pendant la nuit, quand plus personne ne peut
/// lire l'écran. Le texte de chaque phrase est traduit dans les fichiers
/// .arb (clé `narration<Nom>`, script du générateur) et le fichier audio
/// correspondant s'appelle
/// `assets/audio/voice/<langue>/<nom>.mp3` (ex : `fr/wakeVoyante.mp3`).
/// Voir tool/audio/README.md pour générer ces fichiers.
enum NarrationCue {
  nightFalls,
  dayBreaks,
  loversReveal,
  wakeVoleur,
  sleepVoleur,
  wakeCupidon,
  sleepCupidon,
  wakeEnfantSauvage,
  sleepEnfantSauvage,
  wakeSalvateur,
  sleepSalvateur,
  wakeVoyante,
  sleepVoyante,
  wakeLoups,
  sleepLoups,
  wakeLoupBlanc,
  sleepLoupBlanc,
  wakeGrandMechantLoup,
  sleepGrandMechantLoup,
  wakeInfectPereDesLoups,
  sleepInfectPereDesLoups,
  wakeRenard,
  sleepRenard,
  wakeCorbeau,
  sleepCorbeau,
  wakeSorciere,
  sleepSorciere,
}

/// Bruitages facultatifs, communs à toutes les langues :
/// `assets/audio/sfx/<nom>.mp3`. Simplement ignorés si le fichier manque.
/// [howl] : le hurlement des loups, au moment où la meute se réveille.
enum SoundEffect { howl, daybreak }

/// Une étape de la bande-son. Les étapes sont jouées l'une après l'autre,
/// dans l'ordre (voir SoundService) : une phrase ne coupe jamais la
/// précédente.
sealed class SoundAction {
  const SoundAction();
}

class SpeakCue extends SoundAction {
  final NarrationCue cue;
  const SpeakCue(this.cue);

  @override
  bool operator ==(Object other) => other is SpeakCue && other.cue == cue;
  @override
  int get hashCode => cue.hashCode;
  @override
  String toString() => 'SpeakCue(${cue.name})';
}

class PlaySfx extends SoundAction {
  final SoundEffect effect;
  const PlaySfx(this.effect);

  @override
  bool operator ==(Object other) => other is PlaySfx && other.effect == effect;
  @override
  int get hashCode => effect.hashCode;
  @override
  String toString() => 'PlaySfx(${effect.name})';
}

/// Silence entre deux phrases, le temps que le joueur qui vient de toucher
/// le téléphone le repose et ferme les yeux.
class Pause extends SoundAction {
  final Duration duration;
  const Pause(this.duration);

  @override
  bool operator ==(Object other) =>
      other is Pause && other.duration == duration;
  @override
  int get hashCode => duration.hashCode;
  @override
  String toString() => 'Pause(${duration.inMilliseconds}ms)';
}

/// Démarre (en fondu) la musique d'ambiance de la nuit, jouée en boucle.
class StartMusic extends SoundAction {
  const StartMusic();
  @override
  bool operator ==(Object other) => other is StartMusic;
  @override
  int get hashCode => runtimeType.hashCode;
  @override
  String toString() => 'StartMusic';
}

/// Arrête (en fondu) la musique d'ambiance.
class StopMusic extends SoundAction {
  const StopMusic();
  @override
  bool operator ==(Object other) => other is StopMusic;
  @override
  int get hashCode => runtimeType.hashCode;
  @override
  String toString() => 'StopMusic';
}

/// Décide de ce qu'il faut dire à chaque changement de phase, comme le
/// ferait un meneur de jeu : "La nuit tombe", "La Voyante se réveille",
/// "La Voyante se rendort", "Le jour se lève". Rien d'autre n'est lu : ni
/// prénom, ni victime, ni résultat — tout ça reste à l'écran.
///
/// Logique pure, sans plugin audio : [onPhase] reçoit chaque nouvelle
/// phase affichée et renvoie les étapes de bande-son à jouer.
///
/// On retient soi-même le rôle actuellement réveillé ([_awake]) plutôt que
/// de relire la file de phases du moteur : une phase sautée (Sorcière
/// empêchée de jouer...) ne doit jamais faire dire "se rendort" à un rôle
/// qu'on n'a pas réveillé.
class NarrationScript {
  /// Silence avant chaque "X se réveille".
  static const wakeDelay = Duration(seconds: 2);

  GamePhase? _awake;
  bool _night = false;

  /// Oublie tout (nouvelle partie, partie abandonnée).
  void reset() {
    _awake = null;
    _night = false;
  }

  List<SoundAction> onPhase(GamePhase phase) {
    final actions = <SoundAction>[];

    if (!_isNightPhase(phase)) {
      _putAwakeRoleToSleep(actions);
      if (_night) {
        _night = false;
        actions.add(const StopMusic());
        if (phase == GamePhase.dayReveal) {
          actions.addAll(const [
            PlaySfx(SoundEffect.daybreak),
            SpeakCue(NarrationCue.dayBreaks),
          ]);
        }
      }
      return actions;
    }

    // On peut arriver en pleine nuit (retour dans une partie en cours
    // depuis l'accueil) : la musique repart quand même.
    if (!_night) {
      _night = true;
      actions.add(const StartMusic());
    }

    if (phase == GamePhase.nightIntro) {
      _awake = null;
      actions.add(const SpeakCue(NarrationCue.nightFalls));
      return actions;
    }

    if (phase == GamePhase.nightGoBackToSleep) {
      _putAwakeRoleToSleep(actions);
      return actions;
    }

    final wake = _wakeCue(phase);
    if (wake == null) return actions;
    // Passage direct d'un rôle à un autre sans écran "rendors-toi" (les
    // Loups puis le Loup-Garou Blanc...) : on endort d'abord le premier.
    _putAwakeRoleToSleep(actions);
    actions.add(const Pause(wakeDelay));
    // Les loups hurlent en se réveillant : le hurlement annonce leur tour,
    // pas la tombée de la nuit.
    if (phase == GamePhase.nightLoups) {
      actions.add(const PlaySfx(SoundEffect.howl));
    }
    actions.add(SpeakCue(wake));
    _awake = phase;
    return actions;
  }

  void _putAwakeRoleToSleep(List<SoundAction> actions) {
    final awake = _awake;
    if (awake == null) return;
    _awake = null;
    final sleep = _sleepCue(awake);
    if (sleep != null) actions.add(SpeakCue(sleep));
  }

  static bool _isNightPhase(GamePhase phase) =>
      phase == GamePhase.nightIntro ||
      phase == GamePhase.nightGoBackToSleep ||
      // Révélation silencieuse : on passe juste le téléphone à l'infecté.
      phase == GamePhase.nightInfectedReveal ||
      _wakeCue(phase) != null ||
      phase == GamePhase.nightPetiteFille;

  static NarrationCue? _wakeCue(GamePhase phase) => switch (phase) {
        GamePhase.nightVoleur => NarrationCue.wakeVoleur,
        GamePhase.nightCupidon => NarrationCue.wakeCupidon,
        GamePhase.nightLoversReveal => NarrationCue.loversReveal,
        // Le joueur muté en secret est réveillé comme l'Enfant Sauvage
        // qu'il était : à l'oreille, rien ne distingue cette nuit des
        // autres.
        GamePhase.nightEnfantSauvage ||
        GamePhase.nightEnfantSauvageCheck ||
        GamePhase.nightEnfantSauvageMutation =>
          NarrationCue.wakeEnfantSauvage,
        GamePhase.nightSalvateur => NarrationCue.wakeSalvateur,
        GamePhase.nightVoyante => NarrationCue.wakeVoyante,
        GamePhase.nightLoups => NarrationCue.wakeLoups,
        GamePhase.nightLoupBlanc => NarrationCue.wakeLoupBlanc,
        GamePhase.nightGrandMechantLoup => NarrationCue.wakeGrandMechantLoup,
        GamePhase.nightInfectPereDesLoups =>
          NarrationCue.wakeInfectPereDesLoups,
        GamePhase.nightRenard => NarrationCue.wakeRenard,
        GamePhase.nightCorbeau => NarrationCue.wakeCorbeau,
        GamePhase.nightSorciere => NarrationCue.wakeSorciere,
        _ => null,
      };

  /// Null pour la révélation des Amoureux : chaque joueur se rendort de
  /// lui-même en rendant le téléphone.
  static NarrationCue? _sleepCue(GamePhase phase) => switch (phase) {
        GamePhase.nightVoleur => NarrationCue.sleepVoleur,
        GamePhase.nightCupidon => NarrationCue.sleepCupidon,
        GamePhase.nightEnfantSauvage ||
        GamePhase.nightEnfantSauvageCheck ||
        GamePhase.nightEnfantSauvageMutation =>
          NarrationCue.sleepEnfantSauvage,
        GamePhase.nightSalvateur => NarrationCue.sleepSalvateur,
        GamePhase.nightVoyante => NarrationCue.sleepVoyante,
        GamePhase.nightLoups => NarrationCue.sleepLoups,
        GamePhase.nightLoupBlanc => NarrationCue.sleepLoupBlanc,
        GamePhase.nightGrandMechantLoup => NarrationCue.sleepGrandMechantLoup,
        GamePhase.nightInfectPereDesLoups =>
          NarrationCue.sleepInfectPereDesLoups,
        GamePhase.nightRenard => NarrationCue.sleepRenard,
        GamePhase.nightCorbeau => NarrationCue.sleepCorbeau,
        GamePhase.nightSorciere => NarrationCue.sleepSorciere,
        _ => null,
      };
}
