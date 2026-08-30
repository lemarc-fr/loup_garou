import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'cupidon_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Cupidon')
Widget cupidonScreenPreview() {
  return buildRoleScreenPreview(child: const CupidonScreen());
}