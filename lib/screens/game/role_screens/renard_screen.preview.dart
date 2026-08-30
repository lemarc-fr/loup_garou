import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'renard_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Renard')
Widget renardScreenPreview() {
  return buildRoleScreenPreview(child: const RenardScreen());
}