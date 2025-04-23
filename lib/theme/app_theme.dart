import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryOrange = Color(0xFFFF7043);
  static const Color lightBlue = Color(0xFFB3E5FC);
  static const Color darkGrey = Color(0xFF424242);
  static const Color yellow = Color(0xFFFFEB3B);
  
  static ThemeData get theme => ThemeData(
    primaryColor: primaryOrange,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.light(
      primary: primaryOrange,
      secondary: lightBlue,
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSecondary: darkGrey,
      onSurface: darkGrey,
      onBackground: darkGrey,
    ),
    textTheme: GoogleFonts.robotoTextTheme(
      TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: darkGrey,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: darkGrey,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primaryOrange,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.roboto(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: GoogleFonts.roboto(
        color: darkGrey,
      ),
      hintStyle: GoogleFonts.roboto(
        color: Colors.grey,
      ),
    ),
  );
} 