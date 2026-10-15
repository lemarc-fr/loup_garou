import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/services/game_engine.dart';
import 'package:thiercelieux/services/narration_script.dart';

const _wakePause = Pause(NarrationScript.wakeDelay);

void main() {
  late NarrationScript script;

  setUp(() => script = NarrationScript());

  group('NarrationScript', () {
    test('ouvre la nuit, réveille et endort chaque rôle, puis lève le jour',
        () {
      expect(script.onPhase(GamePhase.nightIntro), const [
        StartMusic(),
        PlaySfx(SoundEffect.nightfall),
        SpeakCue(NarrationCue.nightFalls),
      ]);
      expect(script.onPhase(GamePhase.nightVoyante),
          const [_wakePause, SpeakCue(NarrationCue.wakeVoyante)]);
      expect(script.onPhase(GamePhase.nightGoBackToSleep),
          const [SpeakCue(NarrationCue.sleepVoyante)]);
      expect(script.onPhase(GamePhase.nightLoups),
          const [_wakePause, SpeakCue(NarrationCue.wakeLoups)]);
      expect(script.onPhase(GamePhase.nightGoBackToSleep),
          const [SpeakCue(NarrationCue.sleepLoups)]);
      expect(script.onPhase(GamePhase.dayReveal), const [
        StopMusic(),
        PlaySfx(SoundEffect.daybreak),
        SpeakCue(NarrationCue.dayBreaks),
      ]);
    });

    test("endort les Loups avant de réveiller le Loup-Garou Blanc", () {
      script.onPhase(GamePhase.nightIntro);
      script.onPhase(GamePhase.nightLoups);
      expect(script.onPhase(GamePhase.nightLoupBlanc), const [
        SpeakCue(NarrationCue.sleepLoups),
        _wakePause,
        SpeakCue(NarrationCue.wakeLoupBlanc),
      ]);
      expect(script.onPhase(GamePhase.nightGoBackToSleep),
          const [SpeakCue(NarrationCue.sleepLoupBlanc)]);
    });

    test("un second écran « rendors-toi » d'affilée ne dit rien", () {
      script.onPhase(GamePhase.nightIntro);
      script.onPhase(GamePhase.nightCorbeau);
      script.onPhase(GamePhase.nightGoBackToSleep);
      // Sorcière sautée : le moteur enchaîne sur l'écran suivant de la file.
      expect(script.onPhase(GamePhase.nightGoBackToSleep), isEmpty);
    });

    test("pas de « se rendort » après la révélation des Amoureux", () {
      script.onPhase(GamePhase.nightIntro);
      script.onPhase(GamePhase.nightCupidon);
      script.onPhase(GamePhase.nightGoBackToSleep);
      expect(script.onPhase(GamePhase.nightLoversReveal),
          const [_wakePause, SpeakCue(NarrationCue.loversReveal)]);
      expect(script.onPhase(GamePhase.nightEnfantSauvage),
          const [_wakePause, SpeakCue(NarrationCue.wakeEnfantSauvage)]);
    });

    test("la mutation secrète s'annonce comme un réveil de l'Enfant Sauvage",
        () {
      script.onPhase(GamePhase.nightIntro);
      expect(script.onPhase(GamePhase.nightEnfantSauvageMutation),
          const [_wakePause, SpeakCue(NarrationCue.wakeEnfantSauvage)]);
      expect(script.onPhase(GamePhase.nightGoBackToSleep),
          const [SpeakCue(NarrationCue.sleepEnfantSauvage)]);
    });

    test('relance la musique en arrivant en pleine nuit', () {
      expect(script.onPhase(GamePhase.nightSalvateur), const [
        StartMusic(),
        _wakePause,
        SpeakCue(NarrationCue.wakeSalvateur),
      ]);
    });

    test('ne dit rien de jour ni pendant la distribution des rôles', () {
      for (final phase in [
        GamePhase.roleReveal,
        GamePhase.debate,
        GamePhase.villageVote,
        GamePhase.voteResult,
        GamePhase.chasseurRevange,
        GamePhase.endGame,
      ]) {
        expect(script.onPhase(phase), isEmpty, reason: phase.name);
      }
    });

    test('reset oublie le rôle réveillé et la musique', () {
      script.onPhase(GamePhase.nightIntro);
      script.onPhase(GamePhase.nightVoyante);
      script.reset();
      expect(script.onPhase(GamePhase.dayReveal), isEmpty);
    });
  });

  group('NarrationScript sur une vraie partie', () {
    test('chaque rôle réveillé est rendormi avant le lever du jour', () {
      final engine = GameEngine();
      final names = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
      final s = engine.initGame(
        GameConfig(playerCount: names.length, roleCounts: {
          RoleId.cupidon: 1,
          RoleId.enfantSauvage: 1,
          RoleId.salvateur: 1,
          RoleId.voyante: 1,
          RoleId.loupGarou: 2,
          RoleId.loupBlanc: 1,
          RoleId.renard: 1,
          RoleId.corbeau: 1,
          RoleId.sorciere: 1,
        }),
        names,
        GameSettings(),
      );
      engine.startFirstNight(s);

      final spoken = <NarrationCue>[];
      void record() => spoken.addAll(
          script.onPhase(s.phase).whereType<SpeakCue>().map((a) => a.cue));

      // Joue les nuits 1 et 2 (le Loup-Garou Blanc ne joue que les nuits
      // paires) en faisant le choix le plus simple à chaque écran.
      record();
      var nights = 0;
      while (nights < 2) {
        if (s.phase == GamePhase.dayReveal) {
          nights++;
          if (nights == 2) break;
          _skipDay(engine, s);
        } else {
          _playNightPhase(engine, s);
        }
        record();
      }

      expect(spoken.first, NarrationCue.nightFalls);
      expect(spoken.last, NarrationCue.dayBreaks);
      expect(spoken.where((c) => c == NarrationCue.nightFalls), hasLength(2));
      expect(spoken, contains(NarrationCue.wakeLoupBlanc));

      final wakes = spoken.where((c) => c.name.startsWith('wake')).toList();
      final sleeps = spoken.where((c) => c.name.startsWith('sleep')).toList();
      expect(
        sleeps.map((c) => c.name.substring('sleep'.length)),
        wakes.map((c) => c.name.substring('wake'.length)),
        reason: 'chaque "se réveille" est suivi de son "se rendort"',
      );
    });
  });

  test('chaque phrase a son texte dans chaque fichier de langue', () {
    for (final arb in ['lib/l10n/app_fr.arb', 'lib/l10n/app_en.arb']) {
      final json = jsonDecode(File(arb).readAsStringSync()) as Map;
      final cues = json.keys
          .cast<String>()
          .where((k) => k.startsWith('narration'))
          .map((k) => k[9].toLowerCase() + k.substring(10))
          .toSet();
      expect(cues, NarrationCue.values.map((c) => c.name).toSet(), reason: arb);
    }
  });
}

void _playNightPhase(GameEngine engine, GameState s) {
  final others = s.alivePlayers;
  String someoneElseThan(RoleId role) =>
      others.firstWhere((p) => p.role != role).id;

  switch (s.phase) {
    case GamePhase.nightCupidon:
      engine.resolveCupidon(s, others[0].id, others[1].id);
    case GamePhase.nightLoversReveal:
      engine.confirmLoversReveal(s);
    case GamePhase.nightEnfantSauvage:
      engine.resolveEnfantSauvageMentor(
          s, someoneElseThan(RoleId.enfantSauvage));
    case GamePhase.nightSalvateur:
      engine.resolveSalvateur(s, someoneElseThan(RoleId.salvateur));
    case GamePhase.nightLoups:
      // Une victime protégée par le Salvateur : personne ne meurt, la
      // partie continue jusqu'à la nuit 2.
      engine.setLoupsVictim(s, s.salvateurProtectedId!);
    case GamePhase.nightLoupBlanc:
      engine.resolveLoupBlanc(s, null);
    case GamePhase.nightRenard:
      engine.resolveRenardCenter(s, others.first.id);
    case GamePhase.nightCorbeau:
      engine.resolveCorbeau(s, others.first.id);
    case GamePhase.nightSorciere:
      engine.resolveSorciere(s);
    default:
      engine.advance(s);
  }
}

void _skipDay(GameEngine engine, GameState s) {
  engine.confirmDayReveal(s);
  while (s.phase != GamePhase.villageVote) {
    switch (s.phase) {
      case GamePhase.mayorElectionExplain:
        engine.confirmMayorElectionExplain(s, VoteMode.collective);
      case GamePhase.mayorElection:
        engine.resolveMayorElection(s, s.alivePlayers.first.id);
      case GamePhase.mayorReveal:
        engine.confirmMayorReveal(s);
      case GamePhase.debate:
        engine.confirmDebate(s, VoteMode.collective);
      default:
        fail('phase de jour inattendue : ${s.phase}');
    }
  }
  final corbeau = s.alivePlayersWithRole(RoleId.corbeau).first;
  engine.resolveVillageVote(s, corbeau.id);
  engine.confirmVoteResult(s);
  // Suites possibles de cette mort, selon le tirage des rôles.
  while (s.phase != GamePhase.nightIntro) {
    switch (s.phase) {
      case GamePhase.successionMaire:
        engine.resolveMayorSuccession(s, s.alivePlayers.first.id);
      case GamePhase.enfantsauvageReveal:
        engine.confirmEnfantSauvageReveal(s);
      default:
        fail('suite de vote inattendue : ${s.phase}');
    }
  }
}
