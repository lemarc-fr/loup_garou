import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette "veillée nocturne à Thiercelieux" :
/// un ciel d'encre, la lueur ambrée des lanternes, le rouge-sang des loups,
/// et le vert sourd de la forêt pour le camp du village.
class AppColors {
  AppColors._();

  static const Color night =
      Color(0xFF0F1626); // fond principal (ciel nocturne)
  static const Color nightAlt =
      Color(0xFF1B2438); // cartes / surfaces sur fond nuit
  static const Color nightLine = Color(0xFF2C3752); // séparateurs discrets

  static const Color parchment =
      Color(0xFFF3E8CE); // fond "jour" façon parchemin
  static const Color parchmentAlt = Color(0xFFE9DAB4);
  static const Color ink = Color(0xFF241A12); // texte sur parchemin

  static const Color lantern =
      Color(0xFFE8A33D); // accent ambré (lanternes, maire)
  static const Color blood = Color(0xFFA6293B); // accent loups / danger / mort
  static const Color moonlight = Color(0xFFC9D6E3); // texte clair sur fond nuit
  static const Color forest = Color(0xFF3C6355); // camp village / vie / voyante
  static const Color amethyst =
      Color(0xFF6E4B8E); // pouvoirs magiques (sorcière, cupidon)

  /// Rapport de contraste WCAG entre deux couleurs opaques (de 1 à 21).
  static double contrast(Color a, Color b) {
    final la = a.computeLuminance();
    final lb = b.computeLuminance();
    final hi = la > lb ? la : lb;
    final lo = la > lb ? lb : la;
    return (hi + 0.05) / (lo + 0.05);
  }

  /// Variante de [accent] assez contrastée pour être lue (texte, icône)
  /// posée sur [background].
  ///
  /// Les couleurs de la palette sont pensées comme des aplats : utilisées
  /// telles quelles pour du texte, certaines deviennent illisibles (vert
  /// forêt, améthyste ou rouge sang sur le fond nuit, ambre sur le
  /// parchemin du jour...). On garde la teinte mais on l'éclaircit (fond
  /// sombre) ou on l'assombrit (fond clair) jusqu'à atteindre
  /// [minContrast] — 4.5 pour du texte (WCAG AA), 3 suffit pour une icône.
  static Color readableOn(Color accent, Color background,
      {double minContrast = 4.5}) {
    if (contrast(accent, background) >= minContrast) return accent;
    final hsl = HSLColor.fromColor(accent);
    final lighten = background.computeLuminance() < 0.5;
    var lightness = hsl.lightness;
    while (lighten ? lightness < 1 : lightness > 0) {
      lightness = (lighten ? lightness + 0.02 : lightness - 0.02).clamp(0.0, 1.0);
      final candidate = hsl.withLightness(lightness).toColor();
      if (contrast(candidate, background) >= minContrast) return candidate;
    }
    return lighten ? Colors.white : Colors.black;
  }

  /// Couleur de texte/icône à poser sur un aplat de couleur [fill]
  /// (bouton plein, pastille...).
  static Color onFill(Color fill) =>
      ThemeData.estimateBrightnessForColor(fill) == Brightness.dark
          ? Colors.white
          : night;
}

/// Raccourcis pour obtenir une couleur d'accent lisible sur le fond de
/// l'écran courant, qu'il soit en thème nuit ou en thème jour.
extension ReadableColors on BuildContext {
  Color readable(Color accent, {double minContrast = 4.5}) =>
      AppColors.readableOn(accent, Theme.of(this).scaffoldBackgroundColor,
          minContrast: minContrast);

  /// Comme [readable], avec le seuil plus souple des icônes et éléments
  /// graphiques (WCAG : 3:1, un peu relevé car l'icône est souvent posée
  /// sur une carte légèrement plus claire que le fond de l'écran).
  Color readableIcon(Color accent) => readable(accent, minContrast: 3.5);
}

class AppTheme {
  AppTheme._();

  /// Équivalent de `GoogleFonts.workSansTextTheme()`, qui depuis
  /// google_fonts 9 renvoie le TextTheme du package material_ui, et non
  /// celui de Flutter (incompatibles).
  static TextTheme _workSansTextTheme() {
    final t = ThemeData.light().textTheme;
    TextStyle ws(TextStyle? style) => GoogleFonts.workSans(textStyle: style);
    return TextTheme(
      displayLarge: ws(t.displayLarge),
      displayMedium: ws(t.displayMedium),
      displaySmall: ws(t.displaySmall),
      headlineLarge: ws(t.headlineLarge),
      headlineMedium: ws(t.headlineMedium),
      headlineSmall: ws(t.headlineSmall),
      titleLarge: ws(t.titleLarge),
      titleMedium: ws(t.titleMedium),
      titleSmall: ws(t.titleSmall),
      bodyLarge: ws(t.bodyLarge),
      bodyMedium: ws(t.bodyMedium),
      bodySmall: ws(t.bodySmall),
      labelLarge: ws(t.labelLarge),
      labelMedium: ws(t.labelMedium),
      labelSmall: ws(t.labelSmall),
    );
  }

  static TextTheme _textTheme(Color base) {
    GoogleFonts.cinzelTextTheme();
    return _workSansTextTheme()
        .copyWith(
          displayLarge: GoogleFonts.cinzel(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              color: base,
              letterSpacing: 0.5),
          displayMedium: GoogleFonts.cinzel(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              color: base,
              letterSpacing: 0.5),
          headlineMedium: GoogleFonts.cinzel(
              fontSize: 24, fontWeight: FontWeight.w600, color: base),
          titleLarge: GoogleFonts.cinzel(
              fontSize: 20, fontWeight: FontWeight.w600, color: base),
          bodyLarge:
              GoogleFonts.workSans(fontSize: 16, color: base, height: 1.4),
          bodyMedium:
              GoogleFonts.workSans(fontSize: 14, color: base, height: 1.4),
          labelLarge: GoogleFonts.workSans(
              fontSize: 14, fontWeight: FontWeight.w600, color: base),
        )
        .apply(displayColor: base, bodyColor: base);
  }

  /// Thème "nuit" — utilisé pour l'accueil, le setup, les écrans de rôles nocturnes.
  static ThemeData get night {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.lantern,
      brightness: Brightness.dark,
      surface: AppColors.nightAlt,
      onSurface: AppColors.moonlight,
      primary: AppColors.lantern,
      onPrimary: AppColors.night,
      secondary: AppColors.amethyst,
      onSecondary: Colors.white,
      error: AppColors.readableOn(AppColors.blood, AppColors.nightAlt),
      onError: AppColors.night,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.night,
      textTheme: _textTheme(AppColors.moonlight),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.moonlight),
        iconTheme: const IconThemeData(color: AppColors.moonlight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lantern,
          foregroundColor: AppColors.night,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle:
              GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.moonlight,
          side: const BorderSide(color: AppColors.nightLine, width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightAlt,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.nightLine),
        ),
      ),
      dividerColor: AppColors.nightLine,
    );
  }

  /// Thème "jour" — parchemin, pour le débat, le vote, l'élection du maire.
  static ThemeData get day {
    final base = ColorScheme.fromSeed(
      seedColor: AppColors.forest,
      brightness: Brightness.light,
      surface: AppColors.parchmentAlt,
      onSurface: AppColors.ink,
      primary: AppColors.forest,
      onPrimary: AppColors.parchment,
      secondary: AppColors.lantern,
      onSecondary: AppColors.ink,
      error: AppColors.blood,
      onError: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: base,
      scaffoldBackgroundColor: AppColors.parchment,
      textTheme: _textTheme(AppColors.ink),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.cinzel(
            fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink),
        iconTheme: const IconThemeData(color: AppColors.ink),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.parchment,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle:
              GoogleFonts.workSans(fontSize: 16, fontWeight: FontWeight.w600),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: BorderSide(
              color: AppColors.ink.withValues(alpha: 0.35), width: 1.4),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.55),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.ink.withValues(alpha: 0.15)),
        ),
      ),
      dividerColor: AppColors.ink.withValues(alpha: 0.15),
    );
  }
}
