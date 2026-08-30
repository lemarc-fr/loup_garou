import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'petite_fille_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Petite Fille')
Widget petiteFilleScreenPreview() {
  return buildRoleScreenPreview(child: const PetiteFilleScreen());
}