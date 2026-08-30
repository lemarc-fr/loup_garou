import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'chasseur_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Chasseur')
Widget chasseurScreenPreview() {
  return buildRoleScreenPreview(child: const ChasseurScreen());
}