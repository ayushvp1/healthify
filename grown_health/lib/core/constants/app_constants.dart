/// Centralized app constants for consistent styling across the app.
/// Based on Healthify design language with dark maroon color scheme.
class AppConstants {
  // App Info
  static const String appName = 'Grown Health';
  static const String appVersion = '1.0.0';

  // Primary Colors - Dark Maroon theme
  static const int primaryColorValue = 0xFF5B0C23;
  static const int secondaryColorValue = 0xFFFAFAFA;
  static const int tertiaryColorValue = 0xFF000000;
  static const int accentColorValue = 0xFFAA3D50;

  // Error/Status Colors
  static const int errorColorValue = 0xFFE53935;
  static const int warningColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF1E6F3E;

  // Background Colors
  static const int backgroundLightValue = 0xFFFAFAFA;
  static const int surfaceLightValue = 0xFFFFFFFF;
  static const int cardBackgroundValue = 0xFFFFF5F6;

  // Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceDelay = Duration(milliseconds: 500);

  // Spacing/Padding
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  static const double borderRadiusXXLarge = 24.0;
  static const double borderRadiusCircular = 50.0;

  // Font Sizes
  static const double fontSizeXSmall = 10.0;
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  static const double fontSizeXXXLarge = 24.0;

  // Icon Sizes
  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeXLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // Card/Container Settings
  static const double cardElevation = 4.0;
  static const double cardShadowOpacity = 0.08;

  // API Configuration
  static const int apiTimeoutSeconds = 30;

  // SharedPreferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyUserToken = 'user_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'userName';
}
