import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import '../models/role.dart';
import 'role_image.dart';

@Preview(name: 'role image')
Widget main() {
  return const RoleImage(
    role: RoleId.loupGarou,
    size: 96,
    circular: true,
    animated: true,
  );
}