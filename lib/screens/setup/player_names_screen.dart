import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

enum _NameError { empty, duplicate }

class PlayerNamesScreen extends StatefulWidget {
  const PlayerNamesScreen({super.key});

  @override
  State<PlayerNamesScreen> createState() => _PlayerNamesScreenState();
}

class _PlayerNamesScreenState extends State<PlayerNamesScreen> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  _NameError? _error;

  @override
  void initState() {
    super.initState();
    final gp = context.read<GameProvider>();
    _controllers =
        List.generate(gp.draftNames.length, (_) => TextEditingController());
    _focusNodes =
        List.generate(gp.draftNames.length, (_) => FocusNode());

  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }

  }

  void _submit() {
    final gp = context.read<GameProvider>();
    final settings = context.read<SettingsProvider>().settings;
    final names = _controllers.map((c) => c.text.trim()).toList();

    if (names.any((n) => n.isEmpty)) {
      setState(() => _error = _NameError.empty);
      return;
    }
    final unique = names.map((n) => n.toLowerCase()).toSet();
    if (unique.length != names.length) {
      setState(() => _error = _NameError.duplicate);
      return;
    }

    for (var i = 0; i < names.length; i++) {
      gp.setPlayerName(i, names[i]);
    }
    setState(() => _error = null);
    gp.confirmNamesAndDeal(settings);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.playerNamesTitle)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
              child: Text(
                loc.playerNamesInstruction,
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.moonlight.withValues(alpha: 0.75)),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _controllers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  textCapitalization: TextCapitalization.words,
                  textInputAction: index == _controllers.length - 1
                      ? TextInputAction.done
                      : TextInputAction.next,
                  onSubmitted: (_) {
                    if (index < _controllers.length - 1) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _submit();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: loc.playerNamesPlayerLabel(index + 1),
                    prefixIcon: const Icon(Icons.person_outline),
                    filled: true,
                    fillColor: AppColors.nightAlt,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  switch (_error!) {
                    _NameError.empty => loc.playerNamesErrorEmpty,
                    _NameError.duplicate => loc.playerNamesErrorDuplicate,
                  },
                  style: const TextStyle(color: AppColors.blood),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text(loc.dealRolesButton),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
