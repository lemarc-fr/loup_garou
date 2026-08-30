import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'enfant_sauvage_check_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Enfant Sauvage check')
Widget enfantSauvageCheckScreenPreview() {
  return buildRoleScreenPreview(child: const EnfantSauvageCheckScreen());
}