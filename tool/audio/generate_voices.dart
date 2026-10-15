// Génère les fichiers audio du narrateur à partir des textes des fichiers
// .arb (clés `narration<Nom>`), qui restent la seule source des phrases.
//
//   dart run tool/audio/generate_voices.dart list
//   dart run tool/audio/generate_voices.dart piper --lang fr --model fr_FR-upmc-medium.onnx --speaker 1
//   dart run tool/audio/generate_voices.dart openai --lang en
//   dart run tool/audio/generate_voices.dart elevenlabs --lang fr --voice-id <id>
//
// Mode d'emploi complet : tool/audio/README.md.

import 'dart:convert';
import 'dart:io';

const _usage = '''
Génère les phrases du narrateur dans assets/audio/voice/<langue>/<phrase>.mp3

Commandes :
  list         Liste les phrases à enregistrer et les fichiers déjà présents.
  piper        Voix locale et gratuite (https://github.com/OHF-Voice/piper1-gpl).
  openai       API OpenAI (variable d'environnement OPENAI_API_KEY).
  elevenlabs   API ElevenLabs (variable d'environnement ELEVENLABS_API_KEY).

Options communes :
  --lang fr,en         Langues à générer (défaut : toutes celles des .arb).
  --only a,b           Seulement ces phrases (ex : wakeVoyante,sleepVoyante).
  --force              Remplace les fichiers existants (sinon : ignorés).
  --reverb             Ajoute un léger écho de "grande salle" (ffmpeg requis).

piper :
  --model <.onnx>      Modèle de voix (obligatoire), ex : fr_FR-upmc-medium.onnx
  --speaker <n>        Numéro de locuteur pour les modèles à plusieurs voix.
  --speed <x>          Lenteur de la diction (défaut 1.15 ; 1 = normal).
  --piper <commande>   Exécutable piper (défaut : piper).

openai :
  --voice <nom>        Voix OpenAI (défaut : onyx).
  --model <nom>        Modèle (défaut : gpt-4o-mini-tts).
  --instructions <t>   Consignes de jeu d'acteur (défaut : narrateur grave).

elevenlabs :
  --voice-id <id>      Identifiant de la voix (obligatoire).
  --model <nom>        Modèle (défaut : eleven_multilingual_v2).
''';

/// Consignes de jeu d'acteur pour gpt-4o-mini-tts (voir aussi
/// tool/audio/prompts.md).
String _openAiInstructions(String lang) => '''
Voice: a deep, warm storyteller — the game master of a Werewolf party game, speaking at night to players who have their eyes closed.
Tone: calm, mysterious, slightly hushed, never theatrical or cartoonish.
Pacing: slow and steady, with a short pause after each sentence.
Pronunciation: ${lang == 'fr' ? 'native French from France' : 'native British English'}, articulate every word clearly.''';

Future<void> main(List<String> argv) async {
  if (argv.isEmpty || const ['help', '-h', '--help'].contains(argv.first)) {
    stdout.write(_usage);
    exit(0);
  }
  final command = argv.first;
  final options = _parseOptions(argv.skip(1).toList());
  final root = _projectRoot();

  final languages = options['lang']?.split(',') ?? _availableLanguages(root);
  final only = options['only']?.split(',').toSet();

  final lines = <_Line>[
    for (final lang in languages)
      for (final line in _readLines(root, lang))
        if (only == null || only.contains(line.cue)) line,
  ];
  if (lines.isEmpty) {
    _fail('Aucune phrase à générer (vérifie --lang / --only).');
  }

  if (command == 'list') {
    _list(root, lines);
    return;
  }

  final synthesize = switch (command) {
    'piper' => _piper(options),
    'openai' => _openAi(options),
    'elevenlabs' => _elevenLabs(options),
    _ => _fail('Commande inconnue : $command\n\n$_usage'),
  };

  final hasFfmpeg = await _hasFfmpeg();
  if (!hasFfmpeg) {
    stderr.writeln('⚠ ffmpeg introuvable : pas de normalisation du volume'
        '${command == 'piper' ? ', fichiers laissés en .wav' : ''}.');
  }
  if (options.containsKey('reverb') && !hasFfmpeg) {
    _fail('--reverb nécessite ffmpeg.');
  }

  final tmp = await Directory.systemTemp.createTemp('thiercelieux_voices');
  var generated = 0, skipped = 0, failed = 0;
  try {
    for (final line in lines) {
      final existing = _existingFiles(root, line);
      if (existing.isNotEmpty && !options.containsKey('force')) {
        skipped++;
        continue;
      }
      stdout.write('${line.lang}/${line.cue} … ');
      try {
        final raw = await synthesize(line, tmp);
        for (final f in existing) {
          f.deleteSync();
        }
        final out = await _finalize(root, line, raw,
            ffmpeg: hasFfmpeg, reverb: options.containsKey('reverb'));
        stdout.writeln('ok (${_relative(root, out)})');
        generated++;
      } catch (e) {
        stdout.writeln('ÉCHEC');
        stderr.writeln('  $e');
        failed++;
      }
    }
  } finally {
    await tmp.delete(recursive: true);
  }
  stdout.writeln('\n$generated générée(s), $skipped déjà présente(s)'
      '${skipped > 0 ? ' (--force pour les refaire)' : ''}, $failed échec(s).');
  if (failed > 0) exit(1);
}

// ---------------------------------------------------------------------------
// Phrases
// ---------------------------------------------------------------------------

class _Line {
  final String lang;
  final String cue;
  final String text;
  const _Line(this.lang, this.cue, this.text);
}

const _keyPrefix = 'narration';
const _extensions = ['mp3', 'm4a', 'wav'];

List<String> _availableLanguages(Directory root) {
  final arbs = Directory('${root.path}/lib/l10n')
      .listSync()
      .map((e) => e.uri.pathSegments.last)
      .where((n) => n.startsWith('app_') && n.endsWith('.arb'))
      .map((n) => n.substring(4, n.length - 4))
      .toList()
    ..sort();
  return arbs;
}

/// Le nom d'une phrase est sa clé .arb sans "narration", en minuscule
/// initiale : `narrationWakeVoyante` → `wakeVoyante` (= NarrationCue.name).
List<_Line> _readLines(Directory root, String lang) {
  final file = File('${root.path}/lib/l10n/app_$lang.arb');
  if (!file.existsSync()) _fail('Fichier introuvable : ${file.path}');
  final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  return [
    for (final e in json.entries)
      if (e.key.startsWith(_keyPrefix))
        _Line(
          lang,
          e.key[_keyPrefix.length].toLowerCase() +
              e.key.substring(_keyPrefix.length + 1),
          e.value as String,
        ),
  ];
}

String _basePath(Directory root, _Line line) =>
    '${root.path}/assets/audio/voice/${line.lang}/${line.cue}';

List<File> _existingFiles(Directory root, _Line line) => [
      for (final ext in _extensions)
        if (File('${_basePath(root, line)}.$ext').existsSync())
          File('${_basePath(root, line)}.$ext'),
    ];

void _list(Directory root, List<_Line> lines) {
  stdout.writeln('| Fichier | Présent | Texte |');
  stdout.writeln('|---|---|---|');
  for (final line in lines) {
    final present = _existingFiles(root, line).isNotEmpty ? '✅' : '—';
    stdout
        .writeln('| ${line.lang}/${line.cue}.mp3 | $present | ${line.text} |');
  }
}

// ---------------------------------------------------------------------------
// Moteurs de synthèse : chacun écrit un fichier brut dans [tmp] et renvoie
// son chemin.
// ---------------------------------------------------------------------------

typedef _Synthesizer = Future<File> Function(_Line line, Directory tmp);

_Synthesizer _piper(Map<String, String> options) {
  final model = options['model'] ??
      _fail('piper : --model <fichier.onnx> est obligatoire.');
  if (!File(model).existsSync()) _fail('Modèle introuvable : $model');
  final executable = options['piper'] ?? 'piper';
  final speed = options['speed'] ?? '1.15';
  final speaker = options['speaker'];

  return (line, tmp) async {
    final out = File('${tmp.path}/${line.lang}_${line.cue}.wav');
    final process = await Process.start(
      executable,
      [
        '-m',
        model,
        '-f',
        out.path,
        '--length_scale',
        speed,
        '--sentence_silence',
        '0.4',
        if (speaker != null) ...['-s', speaker],
      ],
      runInShell: Platform.isWindows,
    );
    process.stdin.writeln(line.text);
    await process.stdin.close();
    final errors = await process.stderr.transform(utf8.decoder).join();
    await process.stdout.drain<void>();
    if (await process.exitCode != 0 || !out.existsSync()) {
      throw 'piper a échoué : $errors';
    }
    return out;
  };
}

_Synthesizer _openAi(Map<String, String> options) {
  final key = Platform.environment['OPENAI_API_KEY'] ??
      _fail('openai : définis la variable d\'environnement OPENAI_API_KEY.');
  final model = options['model'] ?? 'gpt-4o-mini-tts';
  final voice = options['voice'] ?? 'onyx';

  return (line, tmp) => _post(
        Uri.parse('https://api.openai.com/v1/audio/speech'),
        headers: {'Authorization': 'Bearer $key'},
        body: {
          'model': model,
          'voice': voice,
          'input': line.text,
          // Seul gpt-4o-mini-tts tient compte des consignes de jeu.
          if (model.startsWith('gpt-'))
            'instructions':
                options['instructions'] ?? _openAiInstructions(line.lang),
          'response_format': 'mp3',
        },
        out: File('${tmp.path}/${line.lang}_${line.cue}.mp3'),
      );
}

_Synthesizer _elevenLabs(Map<String, String> options) {
  final key = Platform.environment['ELEVENLABS_API_KEY'] ??
      _fail(
          'elevenlabs : définis la variable d\'environnement ELEVENLABS_API_KEY.');
  final voiceId = options['voice-id'] ??
      _fail('elevenlabs : --voice-id <id> est obligatoire.');
  final model = options['model'] ?? 'eleven_multilingual_v2';

  return (line, tmp) => _post(
        Uri.parse('https://api.elevenlabs.io/v1/text-to-speech/$voiceId'
            '?output_format=mp3_44100_128'),
        headers: {'xi-api-key': key, 'Accept': 'audio/mpeg'},
        body: {
          'text': line.text,
          'model_id': model,
          'voice_settings': {
            'stability': 0.6,
            'similarity_boost': 0.8,
            'style': 0.15,
            'use_speaker_boost': true,
          },
        },
        out: File('${tmp.path}/${line.lang}_${line.cue}.mp3'),
      );
}

Future<File> _post(
  Uri uri, {
  required Map<String, String> headers,
  required Map<String, Object> body,
  required File out,
}) async {
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri);
    headers.forEach(request.headers.set);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode(body)));
    final response = await request.close();
    if (response.statusCode != 200) {
      final message = await response.transform(utf8.decoder).join();
      throw 'HTTP ${response.statusCode} : $message';
    }
    await response.pipe(out.openWrite());
    return out;
  } finally {
    client.close();
  }
}

// ---------------------------------------------------------------------------
// Post-traitement
// ---------------------------------------------------------------------------

Future<bool> _hasFfmpeg() async {
  try {
    final r = await Process.run('ffmpeg', ['-version'],
        runInShell: Platform.isWindows);
    return r.exitCode == 0;
  } on ProcessException {
    return false;
  }
}

/// Volume homogène entre toutes les phrases (-16 LUFS, la norme des
/// podcasts), mono, mp3. Sans ffmpeg : le fichier brut est copié tel quel.
Future<File> _finalize(
  Directory root,
  _Line line,
  File raw, {
  required bool ffmpeg,
  required bool reverb,
}) async {
  Directory('${root.path}/assets/audio/voice/${line.lang}')
      .createSync(recursive: true);
  if (!ffmpeg) {
    final ext = raw.path.split('.').last;
    return raw.copySync('${_basePath(root, line)}.$ext');
  }
  final out = File('${_basePath(root, line)}.mp3');
  final filters = [
    if (reverb) 'aecho=0.8:0.6:45|80:0.22|0.12',
    'loudnorm=I=-16:TP=-1.5:LRA=11',
    'apad=pad_dur=0.3',
  ].join(',');
  final r = await Process.run(
    'ffmpeg',
    [
      '-y',
      '-loglevel',
      'error',
      '-i',
      raw.path,
      '-af',
      filters,
      '-ac',
      '1',
      '-ar',
      '44100',
      '-codec:a',
      'libmp3lame',
      '-q:a',
      '4',
      out.path,
    ],
    runInShell: Platform.isWindows,
  );
  if (r.exitCode != 0) throw 'ffmpeg a échoué : ${r.stderr}';
  return out;
}

// ---------------------------------------------------------------------------
// Utilitaires
// ---------------------------------------------------------------------------

Map<String, String> _parseOptions(List<String> args) {
  final options = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    if (!arg.startsWith('--')) _fail('Argument inattendu : $arg\n\n$_usage');
    final name = arg.substring(2);
    final hasValue = i + 1 < args.length && !args[i + 1].startsWith('--');
    options[name] = hasValue ? args[++i] : '';
  }
  return options;
}

/// Racine du projet : le dossier courant s'il contient lib/l10n, sinon
/// deux niveaux au-dessus de ce script.
Directory _projectRoot() {
  if (Directory('lib/l10n').existsSync()) return Directory.current;
  final fromScript = File.fromUri(Platform.script).parent.parent.parent;
  if (Directory('${fromScript.path}/lib/l10n').existsSync()) return fromScript;
  _fail('Lance ce script depuis la racine du projet.');
}

String _relative(Directory root, File f) =>
    f.path.substring(root.path.length + 1);

Never _fail(String message) {
  stderr.writeln(message);
  exit(64);
}
