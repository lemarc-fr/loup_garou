// Côté ordinateur de integration_test/screenshots_test.dart : écrit chaque
// capture reçue de l'appareil dans $SCREENSHOT_DIR (par défaut screenshots/).
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  final dir = Platform.environment['SCREENSHOT_DIR'] ?? 'screenshots';
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final file = File('$dir/$name.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      stdout.writeln('Capture : ${file.path}');
      return true;
    },
  );
}
