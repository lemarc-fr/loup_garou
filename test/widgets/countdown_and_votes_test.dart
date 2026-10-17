import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/screens/game/night_go_back_to_sleep_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/corbeau_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/enfant_sauvage_screen.dart';
import 'package:thiercelieux/screens/game/role_screens/loups_screen.dart';
import 'package:thiercelieux/screens/game/village_vote_screen.dart';
import 'package:thiercelieux/services/game_engine.dart';
import 'package:thiercelieux/services/narration_script.dart';
import 'package:thiercelieux/services/narration_timing.dart';
import 'package:thiercelieux/theme/app_theme.dart';
import 'package:thiercelieux/widgets/countdown_button.dart';
import 'package:thiercelieux/widgets/narration_host.dart';
import 'package:thiercelieux/widgets/player_grid_selector.dart';

import '../support/game_fixtures.dart';
import '../support/screen_harness.dart';

void main() {
  late GameProvider gp;

  GameState newGame(List<Seat> seats, {GameSettings? settings}) {
    gp = GameProvider(engine: GameEngine(random: Random(1)));
    return gp.state = startedGame(gp.engine, seats, settings: settings);
  }

  List<String> gridNames(WidgetTester tester) => tester
      .widget<PlayerGridSelector>(find.byType(PlayerGridSelector))
      .players
      .map((p) => p.name)
      .toList();

  group('Bouton à compte à rebours', () {
    Future<List<int>> pumpButton(WidgetTester tester, Duration? duration) async {
      final presses = <int>[];
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.night,
        home: Scaffold(
          body: Center(
            child: CountdownButton(
              label: 'Continuer',
              duration: duration,
              onPressed: () => presses.add(presses.length),
            ),
          ),
        ),
      ));
      return presses;
    }

    double filled(WidgetTester tester) => tester
        .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
        .widthFactor!;

    testWidgets('se valide tout seul à la fin, la barre se remplissant',
        (tester) async {
      final presses = await pumpButton(tester, const Duration(seconds: 2));
      expect(filled(tester), 0);
      await tester.pump(const Duration(seconds: 1));
      expect(filled(tester), closeTo(0.5, 0.05));
      expect(presses, isEmpty);
      await tester.pump(const Duration(milliseconds: 1100));
      expect(presses, hasLength(1));
      await tester.pump(const Duration(seconds: 3));
      expect(presses, hasLength(1), reason: 'Une seule validation');
    });

    testWidgets('un appui valide tout de suite, une seule fois',
        (tester) async {
      final presses = await pumpButton(tester, const Duration(seconds: 5));
      await tester.tap(find.text('Continuer'));
      await tester.pump(const Duration(seconds: 6));
      expect(presses, hasLength(1));
    });

    testWidgets('durée inconnue : bouton ordinaire', (tester) async {
      final presses = await pumpButton(tester, null);
      await tester.pump(const Duration(minutes: 1));
      expect(presses, isEmpty);
      await tester.tap(find.text('Continuer'));
      expect(presses, hasLength(1));
    });
  });

  testWidgets('« rendors-toi » passe au rôle suivant après la phrase du narrateur',
      (tester) async {
    final s = newGame([
      ('Voy', RoleId.voyante),
      ('Lg', RoleId.loupGarou),
      for (var i = 1; i <= 3; i++) ('V$i', RoleId.simpleVillageois),
    ]);
    gp.engine.skipTo(s, GamePhase.nightVoyante);
    gp.engine.confirmVoyanteDone(s);
    expect(s.phase, GamePhase.nightGoBackToSleep);

    // La durée réelle du fichier « la Voyante se rendort ».
    final phrase = (await tester.runAsync(
        () => NarrationTiming.clip('fr', NarrationCue.sleepVoyante)))!;
    final step = ValueNotifier<List<SoundAction>>(
        const [SpeakCue(NarrationCue.sleepVoyante)]);
    addTearDown(step.dispose);

    await tester.pumpWidget(ChangeNotifierProvider.value(
      value: gp,
      child: MaterialApp(
        locale: const Locale('fr'),
        theme: AppTheme.night,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CurrentNarration(
          step: step,
          child: const NightGoBackToSleepScreen(),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(phrase - const Duration(milliseconds: 200));
    expect(s.phase, GamePhase.nightGoBackToSleep, reason: 'Phrase pas finie');
    await tester.pump(const Duration(milliseconds: 400));
    expect(s.phase, GamePhase.nightLoups);
  });

  group('Voix du Corbeau au vote du village', () {
    late GameState s;

    setUp(() {
      s = newGame([
        ('Cor', RoleId.corbeau),
        ('Lg', RoleId.loupGarou),
        for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
      ]);
      gp.engine.skipTo(s, GamePhase.nightLoups);
      gp.engine.setLoupsVictim(s, s.idOf('V1'));
      gp.engine.skipTo(s, GamePhase.nightCorbeau);
      gp.engine.resolveCorbeau(s, s.idOf('V3'));
      gp.engine.finishNight(s);
    });

    testWidgets('vote public : rappelée à toute la table', (tester) async {
      gp.engine.confirmDayReveal(s);
      gp.engine.confirmMayorElectionExplain(s, VoteMode.collective);
      gp.engine.resolveMayorElection(s, s.idOf('V2'));
      gp.engine.confirmMayorReveal(s);
      gp.engine.confirmDebate(s, VoteMode.collective);

      final loc = await pumpScreen(tester, gp, const VillageVoteScreen(),
          theme: AppTheme.day);
      expect(find.text(loc.collectiveVoteCorbeauCurse('V3')), findsOneWidget);
      expect(find.text(loc.collectiveVoteMayorDoubleVoice('V2')),
          findsOneWidget);
    });

    testWidgets('vote secret : rappelée à chaque votant', (tester) async {
      gp.engine.dayToVote(s, mayor: s.idOf('V2'));
      final loc = await pumpScreen(tester, gp, const VillageVoteScreen(),
          theme: AppTheme.day);
      await tester.tap(find.text(loc.passDeviceConfirmButton));
      await tester.pumpAndSettle();
      expect(find.text(loc.collectiveVoteCorbeauCurse('V3')), findsOneWidget);
    });
  });

  testWidgets('Corbeau : peut renoncer cette nuit', (tester) async {
    final s = newGame([
      ('Cor', RoleId.corbeau),
      ('Lg', RoleId.loupGarou),
      for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
    ]);
    gp.engine.skipTo(s, GamePhase.nightLoups);
    gp.engine.setLoupsVictim(s, s.idOf('V1'));
    gp.engine.skipTo(s, GamePhase.nightCorbeau);
    final loc = await pumpScreen(tester, gp, const CorbeauScreen());
    await tester.tap(find.text(loc.passDeviceConfirmButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text(loc.skipPowerThisNightButton));
    await tester.pump();
    expect(s.corbeauCursedId, isNull);
    expect(s.phase, GamePhase.nightGoBackToSleep);
  });

  testWidgets('les loups qui ne se dévorent pas épargnent aussi le Loup Blanc',
      (tester) async {
    final s = newGame([
      ('Lg', RoleId.loupGarou),
      ('Lb', RoleId.loupBlanc),
      for (var i = 1; i <= 4; i++) ('V$i', RoleId.simpleVillageois),
    ], settings: settingsWith({SettingId.allowWerewolfToKillThemselves: false}));
    gp.engine.skipTo(s, GamePhase.nightLoups);
    final loc = await pumpScreen(tester, gp, const LoupsScreen());
    await tester.tap(find.text(loc.passDeviceConfirmButton));
    await tester.pumpAndSettle();
    expect(gridNames(tester), ['V1', 'V2', 'V3', 'V4']);
  });

  testWidgets("l'Enfant Sauvage reçoit le téléphone avant de choisir",
      (tester) async {
    final s = newGame([
      ('Enf', RoleId.enfantSauvage),
      ('Lg', RoleId.loupGarou),
      for (var i = 1; i <= 3; i++) ('V$i', RoleId.simpleVillageois),
    ]);
    gp.engine.skipTo(s, GamePhase.nightEnfantSauvage);
    final loc = await pumpScreen(tester, gp, const EnfantSauvageScreen());
    expect(find.byType(PlayerGridSelector), findsNothing);
    expect(find.text(loc.enfantSauvagePassTo), findsOneWidget);
    await tester.tap(find.text(loc.passDeviceConfirmButton));
    await tester.pumpAndSettle();
    expect(gridNames(tester), ['Lg', 'V1', 'V2', 'V3']);
  });
}
