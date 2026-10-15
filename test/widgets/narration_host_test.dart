import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/providers/settings_provider.dart';
import 'package:thiercelieux/services/narration_script.dart';
import 'package:thiercelieux/services/sound_service.dart';
import 'package:thiercelieux/widgets/narration_host.dart';

/// Enregistre la bande-son au lieu de la jouer.
class _RecordingSoundService extends SoundService {
  final played = <SoundAction>[];
  final spokenTexts = <String>[];
  int stops = 0;
  bool? voiceEnabled;
  bool? musicEnabled;
  String? languageCode;
  bool disposed = false;
  String Function(NarrationCue)? _textFor;

  @override
  void configure({required bool voiceEnabled, required bool musicEnabled}) {
    this.voiceEnabled = voiceEnabled;
    this.musicEnabled = musicEnabled;
  }

  @override
  void setLanguage(
      String languageCode, String Function(NarrationCue cue) textFor) {
    this.languageCode = languageCode;
    _textFor = textFor;
  }

  @override
  void play(List<SoundAction> actions) {
    played.addAll(actions);
    for (final a in actions.whereType<SpeakCue>()) {
      spokenTexts.add(_textFor!(a.cue));
    }
  }

  @override
  void stop() => stops++;

  @override
  void dispose() => disposed = true;
}

void main() {
  late GameProvider gp;
  late SettingsProvider sp;
  late _RecordingSoundService sound;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    gp = GameProvider();
    sp = SettingsProvider();
    sound = _RecordingSoundService();
  });

  Future<void> pumpHost(WidgetTester tester,
          {Locale locale = const Locale('fr')}) =>
      tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: gp),
            ChangeNotifierProvider.value(value: sp),
          ],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: NarrationHost(
              soundService: sound,
              child: const SizedBox.shrink(),
            ),
          ),
        ),
      );

  void startGame() {
    gp.state = gp.engine.initGame(
      GameConfig(playerCount: 3, roleCounts: {
        RoleId.loupGarou: 1,
        RoleId.voyante: 1,
        RoleId.simpleVillageois: 1,
      }),
      ['Alice', 'Bob', 'Chloé'],
      GameSettings(),
    );
    gp.engine.startFirstNight(gp.state!);
    gp.advanceGeneric(); // notifie : intro de la nuit → Voyante
  }

  testWidgets('annonce la nuit puis le réveil de la Voyante, en français',
      (tester) async {
    await pumpHost(tester);
    expect(sound.languageCode, 'fr');
    expect(sound.voiceEnabled, isTrue);
    expect(sound.musicEnabled, isTrue);

    startGame();

    expect(sound.played, contains(const StartMusic()));
    expect(sound.spokenTexts, ['La Voyante se réveille.']);
  });

  testWidgets('parle anglais quand l\'app est en anglais', (tester) async {
    await pumpHost(tester, locale: const Locale('en'));
    startGame();
    expect(sound.languageCode, 'en');
    expect(sound.spokenTexts, ['The Seer wakes up.']);
  });

  testWidgets('ne répète rien si la phase ne change pas', (tester) async {
    await pumpHost(tester);
    startGame();
    final count = sound.played.length;
    gp.notifyListeners();
    expect(sound.played, hasLength(count));
  });

  testWidgets('suit les réglages du son', (tester) async {
    await pumpHost(tester);
    await sp.setMusicEnabled(false);
    expect(sound.musicEnabled, isFalse);
    await sp.setNarrationEnabled(false);
    expect(sound.voiceEnabled, isFalse);
  });

  testWidgets('coupe tout quand la partie est abandonnée ou quittée',
      (tester) async {
    await pumpHost(tester);
    startGame();
    gp.abandonGame();
    expect(sound.stops, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(sound.disposed, isTrue);
  });
}
