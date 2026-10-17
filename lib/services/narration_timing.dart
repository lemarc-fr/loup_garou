import 'package:flutter/services.dart';

import 'mp3_duration.dart';
import 'narration_script.dart';

/// Combien de temps le narrateur met à dire une étape (voir
/// NarrationScript), d'après la longueur réelle de ses fichiers audio.
/// Sert à caler l'écran « tu peux te rendormir » sur la phrase entendue.
abstract final class NarrationTiming {
  /// Durées déjà lues (null : fichier absent ou illisible). On garde la
  /// valeur et non le Future : un même calcul peut être attendu ailleurs.
  static final Map<String, Duration?> _clips = {};

  /// Durée de l'étape [actions] dans la langue [languageCode] : les
  /// phrases et les silences, pas la musique ni les bruitages.
  static Future<Duration> of(List<SoundAction> actions, String languageCode,
      {AssetBundle? bundle}) async {
    var total = Duration.zero;
    for (final action in actions) {
      switch (action) {
        case Pause(:final duration):
          total += duration;
        case SpeakCue(:final cue):
          total += await clip(languageCode, cue, bundle: bundle) ??
              Duration.zero;
        case PlaySfx():
        case StartMusic():
        case StopMusic():
          break;
      }
    }
    return total;
  }

  static Future<Duration?> clip(String languageCode, NarrationCue cue,
      {AssetBundle? bundle}) async {
    final key = 'assets/audio/voice/$languageCode/${cue.name}.mp3';
    if (_clips.containsKey(key)) return _clips[key];
    Duration? duration;
    try {
      final data = await (bundle ?? rootBundle).load(key);
      duration = mp3Duration(data.buffer.asUint8List(
          data.offsetInBytes, data.lengthInBytes));
    } catch (_) {
      duration = null;
    }
    return _clips[key] = duration;
  }
}
