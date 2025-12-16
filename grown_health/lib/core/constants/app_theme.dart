import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_constants.dart';

/// App theme configuration with Material 3 design.
/// Uses dark maroon (#5B0C23) as primary color with Inter font.
class AppTheme {
  // Primary colors
  static const Color primaryColor = Color(AppConstants.primaryColorValue);
  static const Color secondaryColor = Color(AppConstants.secondaryColorValue);
  static const Color tertiaryColor = Color(AppConstants.tertiaryColorValue);
  static const Color accentColor = Color(AppConstants.accentColorValue);

  // Status colors
  static const Color errorColor = Color(AppConstants.errorColorValue);
  static const Color warningColor = Color(AppConstants.warningColorValue);
  static const Color successColor = Color(AppConstants.successColorValue);

  // Background colors
  static const Color backgroundLight = Color(AppConstants.backgroundLightValue);
  static const Color surfaceLight = Color(AppConstants.surfaceLightValue);
  static const Color cardBackground = Color(AppConstants.cardBackgroundValue);

  // Neutral colors
  static const Color white = Color(AppConstants.whiteValue);
  static const Color black = Color(AppConstants.blackValue);
  static const Color transparent = Color(AppConstants.transparentValue);

  // Black with opacity
  static const Color black87 = Color(AppConstants.black87Value);
  static const Color black54 = Color(AppConstants.black54Value);
  static const Color black26 = Color(AppConstants.black26Value);

  // White with opacity
  static const Color white70 = Color(AppConstants.white70Value);
  static const Color white54 = Color(AppConstants.white54Value);
  static const Color white10 = Color(AppConstants.white10Value);

  // Grey scale
  static const Color grey50 = Color(AppConstants.grey50Value);
  static const Color grey100 = Color(AppConstants.grey100Value);
  static const Color grey200 = Color(AppConstants.grey200Value);
  static const Color grey300 = Color(AppConstants.grey300Value);
  static const Color grey400 = Color(AppConstants.grey400Value);
  static const Color grey500 = Color(AppConstants.grey500Value);
  static const Color grey600 = Color(AppConstants.grey600Value);
  static const Color grey700 = Color(AppConstants.grey700Value);
  static const Color grey800 = Color(AppConstants.grey800Value);
  static const Color grey900 = Color(AppConstants.grey900Value);

  // Feature colors
  static const Color infoColor = Color(AppConstants.infoColorValue);
  static const Color highlightPink = Color(AppConstants.highlightPinkValue);
  static const Color lightBlue = Color(AppConstants.lightBlueValue);
  static const Color lightPinkBg = Color(AppConstants.lightPinkBgValue);
  static const Color darkRedText = Color(AppConstants.darkRedTextValue);
  static const Color darkGreen = Color(AppConstants.darkGreenValue);
  static const Color checkGreen = Color(AppConstants.checkGreenValue);
  static const Color lightCyan = Color(AppConstants.lightCyanValue);
  static const Color veryLightCyan = Color(AppConstants.veryLightCyanValue);
  static const Color pinkBorder = Color(AppConstants.pinkBorderValue);
  static const Color redVideo = Color(AppConstants.redVideoValue);

  // Orange palette
  static const Color orange = Color(AppConstants.orangeValue);
  static const Color orange50 = Color(AppConstants.orange50Value);
  static const Color orange300 = Color(AppConstants.orange300Value);
  static const Color orange400 = Color(AppConstants.orange400Value);
  static const Color deepOrange = Color(AppConstants.deepOrangeValue);
  static const Color amber = Color(AppConstants.amberValue);

  // Mind/Meditation category colors
  static const Color blue400 = Color(AppConstants.blue400Value);
  static const Color purple400 = Color(AppConstants.purple400Value);
  static const Color indigo400 = Color(AppConstants.indigo400Value);
  static const Color teal400 = Color(AppConstants.teal400Value);
  static const Color green400 = Color(AppConstants.green400Value);
  static const Color green = Color(AppConstants.greenValue);

  // Red/Error shades
  static const Color red100 = Color(AppConstants.red100Value);
  static const Color red700 = Color(AppConstants.red700Value);

  /// Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: tertiaryColor,
        error: errorColor,
        surface: surfaceLight,
        surfaceContainerHighest: backgroundLight,
      ),
      useMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
      scaffoldBackgroundColor: AppTheme.white,
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400),
          displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
          displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppTheme.white,
        foregroundColor: AppTheme.black,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppTheme.black,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          elevation: 0,
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: GoogleFonts.inter(
          color: AppTheme.grey500,
          fontWeight: FontWeight.w400,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
        color: surfaceLight,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppTheme.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppTheme.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      dividerTheme: DividerThemeData(color: AppTheme.grey200, thickness: 1),
    );
  }
}
