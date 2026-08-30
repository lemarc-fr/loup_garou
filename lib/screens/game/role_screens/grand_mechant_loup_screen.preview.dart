import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'grand_mechant_loup_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Grand Méchant Loup')
Widget grandMechantLoupScreenPreview() {
  return buildRoleScreenPreview(child: const GrandMechantLoupScreen());
}