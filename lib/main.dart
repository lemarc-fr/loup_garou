import 'package:flutter/material.dart' show MaterialApp, StatelessWidget, BuildContext, runApp, Widget, Locale;
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart' show MultiProvider, ChangeNotifierProvider, Selector;
import 'package:thiercelieux/providers/settings_provider.dart' show SettingsProvider;
import 'providers/game_provider.dart' show GameProvider;
import 'providers/stats_provider.dart' show StatsProvider;
import 'screens/home/home_screen.dart' show HomeScreen;
import 'theme/app_theme.dart' show AppTheme;

void main() {
  runApp(const ThiercelieuxApp());
}

class ThiercelieuxApp extends StatelessWidget {
  /// Remplaçables dans les tests (hasard contrôlé, réglages déjà chargés).
  final GameProvider? gameProvider;
  final SettingsProvider? settingsProvider;
  final StatsProvider? statsProvider;

  const ThiercelieuxApp({
    super.key,
    this.gameProvider,
    this.settingsProvider,
    this.statsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        gameProvider != null
            ? ChangeNotifierProvider.value(value: gameProvider!)
            : ChangeNotifierProvider(create: (_) => GameProvider()),
        statsProvider != null
            ? ChangeNotifierProvider.value(value: statsProvider!)
            : ChangeNotifierProvider(create: (_) => StatsProvider()..load()),
        settingsProvider != null
            ? ChangeNotifierProvider.value(value: settingsProvider!)
            : ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
      ],
      // La langue choisie dans les réglages (null = celle du téléphone).
      child: Selector<SettingsProvider, Locale?>(
        selector: (_, sp) => sp.locale,
        builder: (_, locale, __) => MaterialApp(
          title: 'Thiercelieux',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.night,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
