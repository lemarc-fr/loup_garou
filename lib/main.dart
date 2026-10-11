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
  const ThiercelieuxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()..load()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..load()),
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
