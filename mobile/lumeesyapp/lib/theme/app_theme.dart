import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // PRINCIPAIS

  static const Color mainIvory = Color(0xFFFBFDF0);
  static const Color mainGreen = Color(0xFFADC178);
  static const Color mainDark = Color(0xFF17180D);

  // AUXILIARES

  static const Color auxSand = Color(0xFFF0EAD2);
  static const Color auxSage = Color(0xFFDDE5B6);
  static const Color auxOlive = Color(0xFF626D43);
  static const Color auxDanger = Color(0xFFBC4749);

  // SUPERFÍCIES

  static const Color surfacePrimary = Colors.white;
  static const Color surfaceReport = auxSand;
  static const Color surfaceSensor = Colors.white;
  static const Color surfaceAlert = auxDanger;

  // TEMA

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: mainIvory,

    colorScheme: ColorScheme.fromSeed(
      seedColor: mainGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: mainGreen,
      secondary: auxOlive,
      surface: mainIvory,
      error: auxDanger,
    ),

    textTheme: GoogleFonts.interTextTheme().apply(
      bodyColor: mainDark,
      displayColor: mainDark,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: mainIvory,
      foregroundColor: mainDark,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: mainDark,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: auxOlive,
        foregroundColor: mainIvory,
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    cardTheme: CardThemeData(
      color: auxSand,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    iconTheme: const IconThemeData(
      color: auxOlive,
    ),

    dividerColor: auxSage,
  );

  // ESTILOS PRONTOS

  static const TextStyle titleLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: mainDark,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: mainDark,
  );

  static const TextStyle titleSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: mainDark,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 18,
    color: mainDark,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    color: mainDark,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
    color: mainDark,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: mainIvory,
  );
}