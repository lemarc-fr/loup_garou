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
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(Color base) {
    final display = GoogleFonts.cinzelTextTheme();
    final body = GoogleFonts.workSansTextTheme();
    return body
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
      primary: AppColors.lantern,
      secondary: AppColors.amethyst,
      error: AppColors.blood,
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
      primary: AppColors.forest,
      secondary: AppColors.lantern,
      error: AppColors.blood,
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
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.55),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.ink.withValues(alpha: 0.15)),
        ),
      ),
    );
  }
}
