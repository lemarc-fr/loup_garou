import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'loups_screen.dart';
import 'role_screens_preview_support.dart';

@Preview(name: 'Loups-Garous')
Widget loupsScreenPreview() {
  return buildRoleScreenPreview(child: const LoupsScreen());
}