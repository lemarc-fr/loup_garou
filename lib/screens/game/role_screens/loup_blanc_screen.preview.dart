import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'loup_blanc_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Loup Blanc')
Widget loupBlancScreenPreview() {
  return buildRoleScreenPreview(child: const LoupBlancScreen());
}