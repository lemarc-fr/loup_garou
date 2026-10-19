import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/services/mp3_duration.dart';
import 'package:thiercelieux/services/narration_script.dart';
import 'package:thiercelieux/services/narration_timing.dart';

/// [count] trames MPEG-1 couche III à 128 kbit/s, 44,1 kHz (sans son).
Uint8List silentMp3({required int count, bool id3 = false}) {
  final bytes = BytesBuilder();
  if (id3) {
    // En-tête ID3v2.4 annonçant 20 octets de balise.
    bytes.add([0x49, 0x44, 0x33, 4, 0, 0, 0, 0, 0, 20]);
    bytes.add(List.filled(20, 0));
  }
  for (var i = 0; i < count; i++) {
    final padding = i.isOdd ? 1 : 0;
    // 0xFFFB : synchro, MPEG-1, couche III ; 0x90 : 128 kbit/s, 44,1 kHz.
    final frame = Uint8List(144 * 128000 ~/ 44100 + padding)
      ..setAll(0, [0xff, 0xfb, 0x90 | padding << 1, 0x64]);
    bytes.add(frame);
  }
  return bytes.toBytes();
}

void main() {
  group('Durée d\'un MP3', () {
    test('somme exacte des trames, balise ID3 ignorée', () {
      // 1152 échantillons par trame à 44 100 Hz.
      const frames = 100;
      final expected = Duration(microseconds: (frames * 1152 * 1e6 / 44100).round());
      expect(mp3Duration(silentMp3(count: frames)), expected);
      expect(mp3Duration(silentMp3(count: frames, id3: true)), expected);
    });

    test('pas un MP3 : pas de durée', () {
      expect(mp3Duration(Uint8List.fromList(List.filled(500, 7))), isNull);
      expect(mp3Duration(Uint8List(0)), isNull);
    });

    for (final locale in AppLocalizations.supportedLocales) {
      final lang = locale.languageCode;
      test('chaque phrase du narrateur a une durée plausible ($lang)', () {
        for (final cue in NarrationCue.values) {
          final file = File('assets/audio/voice/$lang/${cue.name}.mp3');
          if (!file.existsSync()) continue; // voir voice_assets_test.dart
          final duration = mp3Duration(file.readAsBytesSync());
          expect(duration, isNotNull, reason: file.path);
          expect(duration!.inMilliseconds, inInclusiveRange(300, 15000),
              reason: file.path);
        }
      });
    }
  });

  testWidgets('durée d\'une étape : phrases et silences, sans la musique',
      (tester) async {
    final clip = (await tester.runAsync(
        () => NarrationTiming.clip('fr', NarrationCue.sleepVoyante)))!;
    final step = await tester.runAsync(() => NarrationTiming.of(const [
          StartMusic(),
          PlaySfx(SoundEffect.howl),
          Pause(Duration(seconds: 2)),
          SpeakCue(NarrationCue.sleepVoyante),
        ], 'fr'));
    expect(step, clip + const Duration(seconds: 2));
    expect(clip.inMilliseconds, greaterThan(300));
  });
}
