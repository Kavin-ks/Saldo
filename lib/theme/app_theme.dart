import 'package:flutter/material.dart';

class AppTheme {
  // 1. Color System
  static const Color primaryColor = Color(0xFF5C6BC0);      // Indigo 400
  static const Color secondaryColor = Color(0xFF26A69A);    // Teal 400
  static const Color accentColor = Color(0xFFFFA726);       // Orange 400
  
  static const Color backgroundColor = Color(0xFF121212);   // Deep Dark
  static const Color surfaceColor = Color(0xFF1E1E1E);      // Dark Grey Card
  static const Color errorColor = Color(0xFFEF5350);        // Red 400
  static const Color successColor = Color(0xFF66BB6A);      // Green 400

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BEC5);     // Blue Grey 200
  static const Color textMuted = Color(0xFF757575);         // Grey 600

  // 2. Theme Data
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      
      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),

      // Typography (Default Material 3 updated with colors)
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 16),
        titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 14),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: textMuted, fontSize: 12),
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),


      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2C2C2C),
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: textSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
           foregroundColor: textPrimary,
           side: BorderSide(color: Colors.white.withOpacity(0.2)),
           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 16,
          color: textSecondary,
        ),
      ),


      // Snake Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceColor,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 6,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: textPrimary,
        size: 24,
      ),
      
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.05),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
