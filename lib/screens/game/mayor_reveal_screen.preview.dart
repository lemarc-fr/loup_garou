import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widget_previews.dart';
import 'package:thiercelieux/models/game_settings.dart';
import '../../models/game_config.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'mayor_reveal_screen.dart';

@Preview(name: 'Mayor reveal — party of 5')
Widget mayorRevealPreview() {
  final gp = GameProvider();
  gp.state = gp.engine.initGame(
    GameConfig(playerCount: 5, roleCounts: {
      RoleId.loupGarou: 1,
      RoleId.simpleVillageois: 4,
    }),
    ['Alice', 'Bob', 'Chloé', 'David', 'Emma'],
    GameSettings()
  );
  gp.state!.mayorId = gp.state!.players[2].id; // Chloé maire

  return ChangeNotifierProvider.value(
    value: gp,
    child: MaterialApp(theme: AppTheme.day, home: const MayorRevealScreen()),
  );
}
