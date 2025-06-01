import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryColor = Color.fromARGB(255, 7, 3, 255);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color textColor = Color(0xFF212121);
  static const Color errorColor = Color(0xFFD32F2F);

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color.fromARGB(255, 8, 31, 176),
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    
    // Text Theme
    textTheme: TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 32, 
        fontWeight: FontWeight.bold, 
        color: textColor,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 24, 
        fontWeight: FontWeight.w600, 
        color: textColor,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16, 
        color: textColor,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14, 
        color: textColor.withOpacity(0.8),
      ),
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      color: primaryColor,
      elevation: 4,
      titleTextStyle: GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  // Dark Theme (Optional)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    // Similar configuration as light theme, 
    // with dark mode color adjustments
  );

  // Custom Text Styles
  static TextStyle get heading1 => GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static TextStyle get subtitle1 => GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor.withOpacity(0.8),
  );
}