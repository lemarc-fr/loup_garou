import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'juge_begue_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Juge Bègue')
Widget jugeBegueScreenPreview() {
  return buildRoleScreenPreview(child: const JugeBegueScreen());
}