import 'package:flutter/material.dart';
import 'package:thiercelieux/l10n/app_localizations.dart';

Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final theme = Theme.of(context);
  final loc = AppLocalizations.of(context);
  final effectiveConfirm =
      confirmLabel ?? loc?.confirmButtonLabel ?? 'Confirmer';
  final effectiveCancel = cancelLabel ?? loc?.cancelButtonLabel ?? 'Annuler';
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(effectiveCancel)),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: destructive
              ? FilledButton.styleFrom(backgroundColor: theme.colorScheme.error)
              : null,
          child: Text(effectiveConfirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
