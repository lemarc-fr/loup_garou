import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:thiercelieux/main.dart';
import 'package:thiercelieux/theme/app_theme.dart';

/// L'app ne télécharge aucune police (voir configureBundledFonts) : chaque
/// graisse utilisée par le thème doit se trouver dans assets/google_fonts/.
void main() {
  setUp(configureBundledFonts);

  testWidgets('chaque police du thème est embarquée dans l\'app',
      (tester) async {
    // Construire les thèmes demande toutes les polices qu'ils utilisent.
    expect(AppTheme.night.textTheme.displayLarge, isNotNull);
    expect(AppTheme.day.textTheme.bodyMedium, isNotNull);
    await tester.runAsync(GoogleFonts.pendingFonts);
  });

  // Cinzel Black (w900) n'est volontairement pas embarquée : le thème ne
  // l'utilise pas. google_fonts affiche son erreur avec debugPrint : on la
  // retient ici, sans quoi elle s'afficherait dans la sortie des tests
  // comme un vrai problème.
  testWidgets('une graisse absente serait détectée', (tester) async {
    Object? error;
    final printed = <String>[];
    final originalDebugPrint = debugPrint;
    debugPrint = (message, {wrapWidth}) => printed.add(message ?? '');
    try {
      await tester.runAsync(() async {
        try {
          GoogleFonts.cinzel(fontWeight: FontWeight.w900);
          await GoogleFonts.pendingFonts();
        } catch (e) {
          error = e;
        }
      });
    } finally {
      debugPrint = originalDebugPrint;
    }
    expect(error.toString(), contains('Cinzel-Black'));
    expect(printed.join(), contains('Cinzel-Black'));
  });

  test('les licences des polices accompagnent l\'app', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final licenses = await LicenseRegistry.licenses.toList();
    final packages = licenses.expand((l) => l.packages).toSet();
    expect(packages, containsAll(['Cinzel', 'WorkSans']));
    final cinzel = await rootBundle.loadString('assets/google_fonts/OFL-Cinzel.txt');
    expect(cinzel, contains('SIL Open Font License'));
  });
}
