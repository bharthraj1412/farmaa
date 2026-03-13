import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Farmaa Design System — Farm-themed color palette with premium aesthetics.
class AppTheme {
  AppTheme._();

  // ── Color Palette ─────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF1A5E20);
  static const Color primaryGreenLight = Color(0xFF4CAF50);
  static const Color primaryGreenDark = Color(0xFF0A3D10);

  static const Color accentAmber = Color(0xFFF9A825);
  static const Color accentAmberLight = Color(0xFFFFCC02);
  static const Color accentAmberDark = Color(0xFFF57F17);

  static const Color surfaceCream = Color(0xFFFAFAF0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCard = Color(0xFFF5F7F0);

  static const Color textDark = Color(0xFF1C2B1A);
  static const Color textMedium = Color(0xFF4A5E47);
  static const Color textLight = Color(0xFF8A9E87);
  static const Color textHint = Color(0xFFB0BDB0);

  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color warningAmber = Color(0xFFF57C00);
  static const Color infoBlue = Color(0xFF1565C0);

  static const Color borderLight = Color(0xFFE0E8DC);
  static const Color borderMedium = Color(0xFFC5D4C0);

  static const Color priceLockColor =
      Color(0xFF6D4C41); // warm brown for lock badge

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF1A5E20)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF9A825), Color(0xFFF57C00)],
  );

  // ── Shadows ───────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: const Color(0xFF1A5E20).withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: const Color(0xFF1A5E20).withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  // ── Border Radius ─────────────────────────────────────────
  static final BorderRadius radiusSmall = BorderRadius.circular(8);
  static final BorderRadius radiusMedium = BorderRadius.circular(12);
  static final BorderRadius radiusLarge = BorderRadius.circular(16);
  static final BorderRadius radiusXLarge = BorderRadius.circular(24);
  static final BorderRadius radiusRound = BorderRadius.circular(100);

  // ── Light Theme ───────────────────────────────────────────
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryGreen,
        primary: primaryGreen,
        onPrimary: Colors.white,
        secondary: accentAmber,
        onSecondary: textDark,
        surface: surfaceWhite,
        onSurface: textDark,
        error: errorRed,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: surfaceCream,
      textTheme: _buildTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 2,
        shadowColor: borderLight,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: radiusLarge),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radiusRound),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: radiusRound),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryGreen,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMedium,
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        hintStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: textHint,
        ),
        labelStyle: GoogleFonts.nunito(
          fontSize: 14,
          color: textMedium,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceCard,
        selectedColor: primaryGreen,
        labelStyle:
            GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: radiusRound),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryGreen,
        unselectedItemColor: textLight,
        backgroundColor: surfaceWhite,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: borderLight,
        thickness: 1,
        space: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: GoogleFonts.nunito(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: radiusMedium),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static TextTheme _buildTextTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: textDark,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textMedium,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textDark,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textDark,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMedium,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      labelMedium: GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: textMedium,
      ),
      labelSmall: GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textLight,
      ),
    );
  }
}
