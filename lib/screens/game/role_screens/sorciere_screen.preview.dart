import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'role_screens_preview_support.dart';
import 'sorciere_screen.dart';

@Preview(name: 'Sorcière')
Widget sorciereScreenPreview() {
  return buildRoleScreenPreview(child: const SorciereScreen());
}