import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class AppTheme {
  static const Color background = Color(0xFF101014);
  static const Color surface = Color(0xFF18181C);
  static const Color card = Color(0xFF1A1A22);
  static const Color accent = Color(0xFF00FFD0); // Neon teal
  static const Color accent2 = Color(0xFF00B4D8); // Vibrant blue
  static const Color error = Color(0xFFFF4B4B);
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent2,
        background: background,
        surface: surface,
        error: error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.montserrat(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      cardTheme: CardThemeData(
        color: card.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 12,
        shadowColor: Colors.black.withOpacity(0.4),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          bodyMedium: TextStyle(color: Color(0xFFB0B0B0)),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
          titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      useMaterial3: true,
    );
  }

  // Glassmorphism BoxDecoration helper
  static BoxDecoration glass({double blur = 16, double opacity = 0.18, Color? color}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.18),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
    );
  }

  // Glassmorphism blur widget
  static Widget glassBlur({required Widget child, double blur = 16}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }
} 