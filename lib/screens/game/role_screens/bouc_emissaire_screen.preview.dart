import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'bouc_emissaire_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Bouc Émissaire')
Widget boucEmissaireScreenPreview() {
  return buildRoleScreenPreview(child: const BoucEmissaireScreen());
}