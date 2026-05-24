import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Temple-inspired palette — warm saffron, maroon, gold, diya glow.
abstract final class BhaktiTheme {
  static const Color saffron = Color(0xFFE8850C);
  static const Color saffronLight = Color(0xFFFFB347);
  static const Color maroon = Color(0xFF4A0E0E);
  static const Color maroonDeep = Color(0xFF2D0808);
  static const Color gold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFF5E6B8);
  static const Color cream = Color(0xFFFFF5E6);
  static const Color creamDim = Color(0xFFF0E0C8);
  static const Color diyaGlow = Color(0xFFFF9A3C);
  static const Color lotusPink = Color(0xFFE8A0A0);
  static const Color textOnDark = Color(0xFFFFF8F0);
  static const Color textMuted = Color(0xFFD4C4A8);

  static const LinearGradient templeSky = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1A0505),
      Color(0xFF3D1212),
      Color(0xFF5C1A1A),
      Color(0xFF8B3A12),
    ],
    stops: [0.0, 0.35, 0.65, 1.0],
  );

  static const LinearGradient goldShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF5E6B8), Color(0xFFD4AF37), Color(0xFFB8962E)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6B1F1F),
      Color(0xFF4A1212),
    ],
  );

  // Cached once — scroll par har frame par font rebuild नहीं।
  static final TextStyle displayHi = GoogleFonts.yatraOne(
    fontSize: 32,
    color: goldLight,
    height: 1.2,
    shadows: const [
      Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );

  static final TextStyle titleHi = GoogleFonts.yatraOne(
    fontSize: 22,
    color: goldLight,
    height: 1.3,
  );

  static final TextStyle bodyHi = GoogleFonts.notoSansDevanagari(
    fontSize: 17,
    color: cream,
    height: 1.65,
  );

  static final TextStyle bodyHiDark = GoogleFonts.notoSansDevanagari(
    fontSize: 17,
    color: maroonDeep,
    height: 1.65,
  );

  static final TextStyle mantraHi = GoogleFonts.notoSansDevanagari(
    fontSize: 19,
    color: saffronLight,
    fontStyle: FontStyle.italic,
    height: 1.7,
  );

  static final TextStyle labelSub = GoogleFonts.notoSansDevanagari(
    fontSize: 13,
    color: textMuted,
    height: 1.4,
  );

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: maroonDeep,
      colorScheme: const ColorScheme.dark(
        primary: saffron,
        secondary: gold,
        surface: Color(0xFF4A1212),
        onPrimary: maroonDeep,
        onSurface: textOnDark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleHi.copyWith(fontSize: 20),
        iconTheme: const IconThemeData(color: goldLight),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF5C1A1A),
        elevation: 8,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x44D4AF37), width: 1),
        ),
      ),
      iconTheme: const IconThemeData(color: goldLight),
    );
  }
}
