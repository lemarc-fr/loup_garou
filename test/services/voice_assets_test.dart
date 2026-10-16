import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/services/narration_script.dart';

/// L'app n'a pas de voix de secours : une phrase sans fichier audio n'est
/// pas dite. Chaque phrase doit donc exister dans chaque langue de l'app
/// (mêmes extensions que SoundService).
void main() {
  const extensions = ['mp3', 'm4a', 'wav'];

  for (final locale in AppLocalizations.supportedLocales) {
    final lang = locale.languageCode;
    test('chaque phrase du narrateur a son fichier audio ($lang)', () {
      final missing = [
        for (final cue in NarrationCue.values)
          if (!extensions.any((ext) =>
              File('assets/audio/voice/$lang/${cue.name}.$ext').existsSync()))
            cue.name,
      ];
      expect(missing, isEmpty,
          reason: 'Fichiers manquants dans assets/audio/voice/$lang/ '
              '(voir tool/audio/README.md)');
    });
  }
}
