import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/providers/stats_provider.dart';
import 'package:thiercelieux/theme/app_theme.dart';

/// Affiche un seul écran de jeu, avec les providers, les traductions et le
/// thème de l'app. Renvoie les traductions pour chercher les libellés.
Future<AppLocalizations> pumpScreen(
  WidgetTester tester,
  GameProvider gp,
  Widget screen, {
  Locale locale = const Locale('fr'),
  ThemeData? theme,
}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: gp),
      ChangeNotifierProvider(create: (_) => StatsProvider()),
    ],
    child: MaterialApp(
      locale: locale,
      theme: theme ?? AppTheme.night,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  ));
  await tester.pumpAndSettle();
  return AppLocalizations.of(tester.element(find.byWidget(screen)))!;
}
