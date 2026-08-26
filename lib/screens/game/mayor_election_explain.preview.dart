import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../../models/game_config.dart';
import '../../models/game_settings.dart';
import '../../models/role.dart';
import '../../providers/game_provider.dart';
import '../../theme/app_theme.dart';
import 'mayor_election_explain.dart';

@Preview(name: 'Mayor ElectionExplain — party of 5')
Widget mayorElectionExplainPreview() {
  final gp = GameProvider();

  gp.state = gp.engine.initGame(
    GameConfig(
      playerCount: 5,
      roleCounts: {
        RoleId.loupGarou: 1,
        RoleId.simpleVillageois: 4,
      },
    ),
    ['Alice', 'Bob', 'Chloé', 'David', 'Emma'],
    GameSettings(),
  );

  // Chloé est maire.
  gp.state!.mayorId = gp.state!.players[2].id;

  return ChangeNotifierProvider.value(
    value: gp,
    child: MaterialApp(
      theme: AppTheme.day,
      home: const SizedBox(
        child: MayorElectionExplainScreen(),
      ),
    ),
  );
}
