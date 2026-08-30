import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'enfant_sauvage_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Enfant Sauvage')
Widget enfantSauvageScreenPreview() {
  return buildRoleScreenPreview(child: const EnfantSauvageScreen());
}