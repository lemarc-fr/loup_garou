import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'providers/stats_provider.dart';
import 'screens/home/home_screen.dart';
import 'theme/app_theme.dart';

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
      ],
      child: MaterialApp(
        title: 'Thiercelieux',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.night,
        home: const HomeScreen(),
      ),
    );
  }
}
