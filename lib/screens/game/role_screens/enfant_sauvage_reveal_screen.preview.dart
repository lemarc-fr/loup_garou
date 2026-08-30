import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'enfant_sauvage_reveal_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Enfant Sauvage reveal')
Widget enfantSauvageRevealScreenPreview() {
  return buildRoleScreenPreview(child: const EnfantSauvageRevealScreen());
}