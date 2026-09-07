import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFFB72B);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        surface: const Color(0xFFFFFCF7),
        onSurface: const Color(0xFF252525),
        surfaceContainerLow: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFCF7),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFCF7),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF252525)),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        surface: const Color(0xFF1A1A1A),
        onSurface: const Color(0xFFE0E0E0),
        surfaceContainerLow: const Color(0xFF252525),
      ),
      scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFFE0E0E0)),
      ),
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ),
    );
  }
}
