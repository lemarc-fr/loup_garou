import 'dart:async';
import 'dart:collection';
import 'dart:math' show max;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'narration_script.dart';

/// Joue la bande-son décidée par [NarrationScript] : phrases du narrateur,
/// bruitages et musique d'ambiance de la nuit.
///
/// Chaque phrase est lue depuis son fichier audio s'il existe
/// (`assets/audio/voice/<langue>/<nom>.mp3`), sinon par la synthèse vocale
/// du téléphone : l'app parle donc dès maintenant, et les fichiers générés
/// (voir tool/audio/README.md) remplacent la voix du téléphone au fur et à
/// mesure qu'on les ajoute. Musique et bruitages, eux, sont simplement
/// absents tant que leur fichier n'existe pas.
///
/// Les étapes sont jouées une par une, dans l'ordre : une phrase ne coupe
/// jamais la précédente. Pendant qu'une phrase est lue, la musique baisse.
/// Aucune erreur audio (plugin absent, fichier illisible...) ne remonte :
/// le son ne doit jamais bloquer la partie.
class SoundService {
  static const _musicVolume = 0.35;
  static const _duckedMusicVolume = 0.12;

  /// mp3 en priorité ; pas d'ogg, illisible sur iOS.
  static const _extensions = ['mp3', 'm4a', 'wav'];

  /// Filet de sécurité : un fichier ou une synthèse qui ne signale jamais
  /// sa fin ne doit pas bloquer la suite de la nuit.
  static const _clipTimeout = Duration(seconds: 30);

  bool _voiceEnabled = true;
  bool _musicEnabled = true;
  String _languageCode = 'fr';
  String Function(NarrationCue cue)? _textFor;

  final _queue = Queue<SoundAction>();
  bool _running = false;

  /// Incrémenté par [stop] : la séquence en cours s'arrête dès la fin de
  /// son étape actuelle.
  int _generation = 0;

  /// Complété pour couper net l'étape en cours (phrase, pause).
  Completer<void> _interrupt = Completer<void>();

  /// Vrai entre StartMusic et StopMusic, que la musique soit activée ou
  /// non : la réactiver en pleine nuit la fait repartir.
  bool _musicWanted = false;
  bool _musicPlaying = false;
  bool _suspended = false;
  bool _ducked = false;
  double _currentMusicVolume = 0;
  Timer? _fadeTimer;

  AudioPlayer? _voicePlayer;
  AudioPlayer? _musicPlayer;
  FlutterTts? _tts;
  String? _ttsLanguageCode;
  Set<String>? _audioAssets;
  bool _disposed = false;

  void configure({required bool voiceEnabled, required bool musicEnabled}) {
    if (_voiceEnabled && !voiceEnabled) _cutCurrentClip();
    _voiceEnabled = voiceEnabled;
    _musicEnabled = musicEnabled;
    _updateMusic();
  }

  /// [textFor] : texte de chaque phrase dans la langue [languageCode], pour
  /// la synthèse vocale de secours.
  void setLanguage(
      String languageCode, String Function(NarrationCue cue) textFor) {
    _languageCode = languageCode;
    _textFor = textFor;
  }

  /// Ajoute [actions] à la suite de ce qui reste à jouer.
  void play(List<SoundAction> actions) {
    if (_disposed || actions.isEmpty) return;
    _queue.addAll(actions);
    _run();
  }

  /// Coupe tout : phrase en cours, file d'attente et musique.
  void stop() {
    _generation++;
    _queue.clear();
    _running = false;
    _cutCurrentClip();
    _musicWanted = false;
    _updateMusic();
  }

  /// L'app passe en arrière-plan : la musique s'arrête, elle reprendra
  /// avec [resume].
  void suspend() {
    _suspended = true;
    _updateMusic();
  }

  void resume() {
    _suspended = false;
    _updateMusic();
  }

  void dispose() {
    stop();
    _disposed = true;
    _fadeTimer?.cancel();
    _ignoreErrors(_voicePlayer?.dispose());
    _ignoreErrors(_musicPlayer?.dispose());
    _ignoreErrors(_tts?.stop());
  }

  // -------------------------------------------------------------------------
  // File d'attente
  // -------------------------------------------------------------------------

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    final generation = _generation;
    while (_queue.isNotEmpty && generation == _generation && !_disposed) {
      final action = _queue.removeFirst();
      try {
        await _perform(action);
      } catch (e) {
        debugPrint('SoundService : $action a échoué ($e)');
      }
    }
    if (generation == _generation) _running = false;
  }

  Future<void> _perform(SoundAction action) async {
    switch (action) {
      // La musique démarre ou s'arrête en fond : la narration n'attend pas
      // la fin du fondu (ni un lecteur lent à démarrer).
      case StartMusic():
        _musicWanted = true;
        unawaited(_updateMusic());
      case StopMusic():
        _musicWanted = false;
        unawaited(_updateMusic());
      case Pause(:final duration):
        if (_voiceEnabled) await _interruptible(Future.delayed(duration));
      case PlaySfx(:final effect):
        // Les bruitages font partie de l'ambiance, pas de la narration.
        if (!_musicEnabled) return;
        final asset = await _findAsset('assets/audio/sfx/${effect.name}');
        if (asset != null) await _withMusicDucked(() => _playClip(asset));
      case SpeakCue(:final cue):
        if (!_voiceEnabled) return;
        final asset =
            await _findAsset('assets/audio/voice/$_languageCode/${cue.name}');
        final text = _textFor?.call(cue);
        await _withMusicDucked(() async {
          if (asset != null) {
            await _playClip(asset);
          } else if (text != null) {
            await _speak(text);
          }
        });
    }
  }

  Future<void> _interruptible(Future<void> future) =>
      Future.any([future, _interrupt.future]);

  void _cutCurrentClip() {
    _interrupt.complete();
    _interrupt = Completer<void>();
    _ignoreErrors(_voicePlayer?.stop());
    _ignoreErrors(_tts?.stop());
  }

  // -------------------------------------------------------------------------
  // Fichiers audio
  // -------------------------------------------------------------------------

  /// Clé d'asset de [basePath] avec la première extension disponible, ou
  /// null si aucun fichier n'a été ajouté pour lui.
  Future<String?> _findAsset(String basePath) async {
    final assets = _audioAssets ??= await _loadAudioAssets();
    for (final ext in _extensions) {
      final key = '$basePath.$ext';
      if (assets.contains(key)) return key;
    }
    return null;
  }

  static Future<Set<String>> _loadAudioAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      return manifest
          .listAssets()
          .where((a) => a.startsWith('assets/audio/'))
          .toSet();
    } catch (_) {
      return {};
    }
  }

  /// AudioCache (utilisé par AssetSource) ajoute lui-même le "assets/".
  static AssetSource _source(String assetKey) =>
      AssetSource(assetKey.substring('assets/'.length));

  Future<AudioPlayer> _createPlayer(ReleaseMode releaseMode) async {
    final player = AudioPlayer();
    // Sans prise du "focus audio" : la voix et la musique de l'app (et la
    // synthèse vocale) se mélangent au lieu de s'interrompre.
    await player.setAudioContext(
      AudioContextConfig(focus: AudioContextConfigFocus.mixWithOthers).build(),
    );
    await player.setReleaseMode(releaseMode);
    return player;
  }

  Future<void> _playClip(String assetKey) async {
    final player = _voicePlayer ??= await _createPlayer(ReleaseMode.stop);
    // Écouté avant play() pour ne pas rater la fin d'un clip très court.
    // Le then<void> est indispensable : sous le type Stream<void>, c'est un
    // Stream<AudioEvent>, et un onTimeout qui ne renvoie rien planterait.
    final completed = player.onPlayerComplete.first
        .then<void>((_) {})
        .timeout(_clipTimeout, onTimeout: () {})
        .catchError((Object _) {});
    await player.play(_source(assetKey));
    await _interruptible(completed);
  }

  // -------------------------------------------------------------------------
  // Synthèse vocale du téléphone (quand le fichier d'une phrase manque)
  // -------------------------------------------------------------------------

  Future<void> _speak(String text) async {
    final tts = _tts ??= await _createTts();
    if (_ttsLanguageCode != _languageCode) {
      await tts.setLanguage(_ttsLocale(_languageCode));
      _ttsLanguageCode = _languageCode;
    }
    await _interruptible(
      tts.speak(text).timeout(_clipTimeout, onTimeout: () => null),
    );
  }

  static Future<FlutterTts> _createTts() async {
    final tts = FlutterTts();
    await tts.awaitSpeakCompletion(true);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      await tts.setSharedInstance(true);
      await tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [IosTextToSpeechAudioCategoryOptions.mixWithOthers],
      );
    }
    // Un peu plus lent et plus grave que la normale : on raconte une
    // histoire (vitesse normale : 0,5 sur mobile, 1 sur le web).
    await tts.setSpeechRate(kIsWeb ? 0.85 : 0.43);
    await tts.setPitch(0.9);
    return tts;
  }

  static String _ttsLocale(String languageCode) => switch (languageCode) {
        'fr' => 'fr-FR',
        'en' => 'en-US',
        _ => languageCode,
      };

  // -------------------------------------------------------------------------
  // Musique d'ambiance
  // -------------------------------------------------------------------------

  Future<void> _updateMusic() async {
    final shouldPlay =
        _musicWanted && _musicEnabled && !_suspended && !_disposed;
    if (shouldPlay == _musicPlaying) return;
    _musicPlaying = shouldPlay;

    if (!shouldPlay) {
      _fadeMusicTo(0, const Duration(milliseconds: 2500),
          then: () => _ignoreErrors(_musicPlayer?.stop()));
      return;
    }

    try {
      final asset = await _findAsset('assets/audio/music/night');
      if (asset == null || !_musicPlaying) return;
      final player = _musicPlayer ??= await _createPlayer(ReleaseMode.loop);
      _fadeTimer?.cancel();
      _currentMusicVolume = 0;
      await player.setVolume(0);
      await player.play(_source(asset));
      if (!_musicPlaying) {
        // Arrêtée pendant qu'on la lançait.
        await player.stop();
        return;
      }
      _fadeMusicTo(_musicLevel, const Duration(seconds: 3));
    } catch (e) {
      debugPrint('SoundService : musique impossible à lancer ($e)');
    }
  }

  double get _musicLevel => _ducked ? _duckedMusicVolume : _musicVolume;

  Future<void> _withMusicDucked(Future<void> Function() body) async {
    _ducked = true;
    if (_musicPlaying) {
      _fadeMusicTo(_musicLevel, const Duration(milliseconds: 400));
    }
    try {
      await body();
    } finally {
      _ducked = false;
      if (_musicPlaying) {
        _fadeMusicTo(_musicLevel, const Duration(milliseconds: 1200));
      }
    }
  }

  /// Fondu par petits paliers. Un nouveau fondu annule le précédent, y
  /// compris son [then] (un arrêt prévu n'a plus lieu si la musique est
  /// relancée entre-temps).
  void _fadeMusicTo(double target, Duration duration, {VoidCallback? then}) {
    _fadeTimer?.cancel();
    final player = _musicPlayer;
    if (player == null) return;
    const tick = Duration(milliseconds: 50);
    final steps = max(1, duration.inMilliseconds ~/ tick.inMilliseconds);
    final start = _currentMusicVolume;
    var step = 0;
    _fadeTimer = Timer.periodic(tick, (timer) {
      step++;
      _currentMusicVolume = start + (target - start) * step / steps;
      _ignoreErrors(player.setVolume(_currentMusicVolume));
      if (step >= steps) {
        timer.cancel();
        then?.call();
      }
    });
  }

  static void _ignoreErrors(Future<void>? future) {
    future?.catchError((Object e) {
      debugPrint('SoundService : $e');
    });
  }
}
