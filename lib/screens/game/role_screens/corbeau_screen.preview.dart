import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'corbeau_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Corbeau')
Widget corbeauScreenPreview() {
  return buildRoleScreenPreview(child: const CorbeauScreen());
}