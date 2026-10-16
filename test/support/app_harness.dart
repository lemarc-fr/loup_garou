import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiercelieux/main.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/providers/settings_provider.dart';
import 'package:thiercelieux/providers/stats_provider.dart';
import 'package:thiercelieux/services/game_engine.dart';

/// L'application complète, prête pour un test : écran de téléphone, langue
/// choisie, son coupé (aucun plugin audio n'est appelé), hasard reproductible.
class AppHarness {
  final GameProvider game;
  final SettingsProvider settings;
  final StatsProvider stats;

  AppHarness._(this.game, this.settings, this.stats);

  static Future<AppHarness> start(
    WidgetTester tester, {
    String language = 'fr',
    int seed = 1,
    Map<String, Object> preferences = const {},
    // Faux, sur un vrai appareil (integration_test) : on garde son écran.
    bool simulatePhoneScreen = true,
  }) async {
    if (simulatePhoneScreen) {
      // Un téléphone courant : 411 × 914 points.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
    }

    SharedPreferences.setMockInitialValues({
      'thiercelieux.locale.v1': language,
      'thiercelieux.sound.narration.v1': false,
      'thiercelieux.sound.music.v1': false,
      ...preferences,
    });
    final settings = SettingsProvider();
    await settings.load();
    final stats = StatsProvider();
    await stats.load();
    final game = GameProvider(engine: GameEngine(random: Random(seed)));

    await tester.pumpWidget(ThiercelieuxApp(
      gameProvider: game,
      settingsProvider: settings,
      statsProvider: stats,
    ));
    await tester.pump();
    return AppHarness._(game, settings, stats);
  }
}

/// L'accueil anime sa scène de nuit en boucle : pumpAndSettle n'y finirait
/// jamais. On tape puis on laisse passer la transition.
Future<void> tapOnHome(WidgetTester tester, String label) async {
  await tester.tap(find.text(label));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}
