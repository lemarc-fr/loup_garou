import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../l10n/narration_localizations.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../services/narration_script.dart';
import '../services/sound_service.dart';

/// Fait parler le téléphone pendant la partie : à chaque changement de
/// phase du [GameProvider], demande à [NarrationScript] quoi dire et le
/// transmet au [SoundService], dans la langue de l'app et selon les
/// réglages du son.
///
/// Placé autour de tout le déroulé de la partie (voir GameFlowScreen) :
/// quitter la partie vers l'accueil le démonte et coupe le son.
class NarrationHost extends StatefulWidget {
  final Widget child;

  /// Remplaçable dans les tests, pour observer la bande-son sans plugin
  /// audio.
  final SoundService? soundService;

  const NarrationHost({super.key, required this.child, this.soundService});

  @override
  State<NarrationHost> createState() => _NarrationHostState();
}

class _NarrationHostState extends State<NarrationHost>
    with WidgetsBindingObserver {
  late final GameProvider _game;
  late final SettingsProvider _settings;
  late final SoundService _sound;
  final _script = NarrationScript();

  /// Dernière étape annoncée : (partie, phase, position dans la file).
  /// Le GameProvider notifie aussi pour des changements qui ne changent
  /// pas de phase (sélection en cours du Renard...) : on ne dit rien.
  (String, GamePhase, int)? _lastStep;

  @override
  void initState() {
    super.initState();
    _sound = widget.soundService ?? SoundService();
    _game = context.read<GameProvider>()..addListener(_onGameChanged);
    _settings = context.read<SettingsProvider>()
      ..addListener(_onSettingsChanged);
    WidgetsBinding.instance.addObserver(this);
    _onSettingsChanged();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = AppLocalizations.of(context)!;
    _sound.setLanguage(loc.localeName, loc.narrationText);
    // Première annonce une fois la langue connue (retour dans une partie
    // en cours depuis l'accueil).
    _onGameChanged();
  }

  @override
  void dispose() {
    _game.removeListener(_onGameChanged);
    _settings.removeListener(_onSettingsChanged);
    WidgetsBinding.instance.removeObserver(this);
    _sound.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _sound.resume();
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _sound.suspend();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onSettingsChanged() {
    _sound.configure(
      voiceEnabled: _settings.narrationEnabled,
      musicEnabled: _settings.musicEnabled,
    );
  }

  void _onGameChanged() {
    final state = _game.state;
    if (state == null) {
      // Partie abandonnée ou nouvelle partie en préparation.
      if (_lastStep != null) {
        _lastStep = null;
        _script.reset();
        _sound.stop();
      }
      return;
    }

    final step = (state.id, state.phase, state.phaseIndex);
    if (step == _lastStep) return;
    if (_lastStep != null && _lastStep!.$1 != state.id) {
      _script.reset();
      _sound.stop();
    }
    _lastStep = step;
    _sound.play(_script.onPhase(state.phase));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
