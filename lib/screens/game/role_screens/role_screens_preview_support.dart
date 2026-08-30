import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/game_config.dart';
import '../../../models/game_settings.dart';
import '../../../models/game_state.dart';
import '../../../models/role.dart';
import '../../../providers/game_provider.dart';
import '../../../theme/app_theme.dart';

GameProvider buildRoleScreenPreviewProvider({
  void Function(GameState state)? configureState,
}) {
  final gp = GameProvider();
  gp.state = gp.engine.initGame(
    GameConfig(
      playerCount: 20,
      roleCounts: {
        RoleId.voleur: 1,
        RoleId.cupidon: 1,
        RoleId.enfantSauvage: 1,
        RoleId.salvateur: 1,
        RoleId.voyante: 1,
        RoleId.petiteFille: 1,
        RoleId.loupBlanc: 1,
        RoleId.grandMechantLoup: 1,
        RoleId.infectPereDesLoups: 1,
        RoleId.renard: 1,
        RoleId.corbeau: 1,
        RoleId.sorciere: 1,
        RoleId.chasseur: 1,
        RoleId.servanteDevouee: 1,
        RoleId.boucEmissaire: 1,
        RoleId.idiotDuVillage: 1,
        RoleId.jugeBegue: 1,
        RoleId.loupGarou: 2,
        RoleId.simpleVillageois: 3,
      },
    ),
    List.generate(20, (i) => 'Joueur ${i + 1}'),
    GameSettings(),
  );

  final state = gp.state!;
  final roles = [
    RoleId.voleur,
    RoleId.cupidon,
    RoleId.enfantSauvage,
    RoleId.salvateur,
    RoleId.voyante,
    RoleId.petiteFille,
    RoleId.loupBlanc,
    RoleId.grandMechantLoup,
    RoleId.infectPereDesLoups,
    RoleId.renard,
    RoleId.corbeau,
    RoleId.sorciere,
    RoleId.chasseur,
    RoleId.servanteDevouee,
    RoleId.boucEmissaire,
    RoleId.idiotDuVillage,
    RoleId.jugeBegue,
    RoleId.loupGarou,
    RoleId.loupGarou,
    RoleId.simpleVillageois,
  ];
  for (var i = 0; i < state.players.length; i++) {
    state.players[i].role = roles[i];
  }

  state.voleurTableCards = const [RoleId.loupGarou, RoleId.simpleVillageois];
  state.loupsVictimId = state.players[19].id;
  state.finalNightVictimId = state.players[19].id;
  state.servanteDevoueeOfferId = state.players[15].id;
  state.idiotDuVillageRevealId = state.players[15].id;

  configureState?.call(state);
  return gp;
}

Widget buildRoleScreenPreview({
  required Widget child,
  void Function(GameState state)? configureState,
}) {
  final gp = buildRoleScreenPreviewProvider(configureState: configureState);

  return ChangeNotifierProvider.value(
    value: gp,
    child: MaterialApp(
      theme: AppTheme.night,
      home: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    ),
  );
}