import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'role_screens_preview_support.dart';
import 'salvateur_screen.dart';

@Preview(name: 'Salvateur')
Widget salvateurScreenPreview() {
  return buildRoleScreenPreview(child: const SalvateurScreen());
}