// test/widgets/day_reveal_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:thiercelieux/models/game_config.dart';
import 'package:thiercelieux/models/game_settings.dart';
import 'package:thiercelieux/models/game_state.dart';
import 'package:thiercelieux/models/role.dart';
import 'package:thiercelieux/providers/game_provider.dart';
import 'package:thiercelieux/screens/game/day_reveal_screen.dart';

void main() {
  testWidgets('affiche les morts de la nuit et permet de continuer',
      (tester) async {
    final gp = GameProvider();
    gp.state = gp.engine.initGame(
      GameConfig(playerCount: 3, roleCounts: {
        RoleId.loupGarou: 1,
        RoleId.simpleVillageois: 2,
      }),
      ['Alice', 'Bob', 'Chloé'],GameSettings()
    );
    gp.state!.deathsThisWave = [gp.state!.players[1].id];
    gp.state!.players[1].alive = false;

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: gp,
        child: const MaterialApp(home: DayRevealScreen()),
      ),
    );

    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Le village se réveille'), findsOneWidget);

    await tester.tap(find.text('Le village se réveille'));
    await tester.pump();
    // vérifie que confirmDayReveal a bien fait avancer la phase
    expect(gp.state!.phase, isNot(GamePhase.dayReveal));
  });
}
