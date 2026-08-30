import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'role_screens_preview_support.dart';
import 'voleur_screen.dart';

@Preview(name: 'Voleur')
Widget voleurScreenPreview() {
  return buildRoleScreenPreview(child: const VoleurScreen());
}