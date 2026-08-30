import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

import 'role_screens_preview_support.dart';
import 'servante_devouee_screen.dart';

@Preview(name: 'Servante Dévouée')
Widget servanteDevoueeScreenPreview() {
  return buildRoleScreenPreview(child: const ServanteDevoueeScreen());
}