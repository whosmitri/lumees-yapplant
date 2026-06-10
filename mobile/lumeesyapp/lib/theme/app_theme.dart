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

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    textTheme: GoogleFonts.interTextTheme(),
    scaffoldBackgroundColor: mainIvory,
  );
}