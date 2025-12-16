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
  static const int splashBackgroundValue = 0xFF64091A;

  // Error/Status Colors
  static const int errorColorValue = 0xFFE53935;
  static const int warningColorValue = 0xFFFF9800;
  static const int successColorValue = 0xFF1E6F3E;

  // Background Colors
  static const int backgroundLightValue = 0xFFFAFAFA;
  static const int surfaceLightValue = 0xFFFFFFFF;
  static const int cardBackgroundValue = 0xFFFFF5F6;

  // Neutral Colors
  static const int whiteValue = 0xFFFFFFFF;
  static const int blackValue = 0xFF000000;
  static const int transparentValue = 0x00000000;

  // Black with opacity variants
  static const int black87Value = 0xDD000000; // 87% opacity
  static const int black54Value = 0x8A000000; // 54% opacity
  static const int black26Value = 0x42000000; // 26% opacity

  // White with opacity variants
  static const int white70Value = 0xB3FFFFFF; // 70% opacity
  static const int white54Value = 0x8AFFFFFF; // 54% opacity
  static const int white10Value = 0x1AFFFFFF; // 10% opacity

  // Grey Scale
  static const int grey50Value = 0xFFFAFAFA;
  static const int grey100Value = 0xFFF5F5F5;
  static const int grey200Value = 0xFFEEEEEE;
  static const int grey300Value = 0xFFE0E0E0;
  static const int grey400Value = 0xFFBDBDBD;
  static const int grey500Value = 0xFF9E9E9E;
  static const int grey600Value = 0xFF757575;
  static const int grey700Value = 0xFF616161;
  static const int grey800Value = 0xFF424242;
  static const int grey900Value = 0xFF212121;

  // Feature Colors
  static const int infoColorValue = 0xFF2196F3; // Blue - rest/info states
  static const int highlightPinkValue = 0xFFFFF0F3; // Light pink highlight
  static const int lightBlueValue = 0xFFE3F2FD; // Light blue background
  static const int lightPinkBgValue = 0xFFFAF0F1; // Very light pink bg
  static const int darkRedTextValue = 0xFF8B2030; // Dark red text
  static const int darkGreenValue = 0xFF1B5E20; // Dark green icons
  static const int checkGreenValue = 0xFF4CAF50; // Success checkmark
  static const int lightCyanValue = 0xFFB3E5FC; // Gradient cyan
  static const int veryLightCyanValue = 0xFFE1F5FE; // Gradient light cyan
  static const int pinkBorderValue = 0xFFF7D4DD; // Pink border color
  static const int redVideoValue = 0xFFE53935; // Video/live indicator

  // Orange Palette
  static const int orangeValue = 0xFFFF9800; // Orange
  static const int orange50Value = 0xFFFFF3E0; // Orange shade 50
  static const int orange300Value = 0xFFFFB74D; // Orange shade 300
  static const int orange400Value = 0xFFFFA726; // Orange shade 400
  static const int deepOrangeValue = 0xFFFF5722; // Deep Orange
  static const int amberValue = 0xFFFFC107; // Amber

  // Mind/Meditation Category Colors
  static const int blue400Value = 0xFF42A5F5; // Blue shade 400 - Relaxation
  static const int purple400Value = 0xFFAB47BC; // Purple shade 400 - Focus
  static const int indigo400Value = 0xFF5C6BC0; // Indigo shade 400 - Sleep
  static const int teal400Value = 0xFF26A69A; // Teal shade 400 - Stress
  static const int green400Value = 0xFF66BB6A; // Green shade 400 - Anxiety
  static const int greenValue = 0xFF4CAF50; // Green

  // Red/Error Shades
  static const int red100Value = 0xFFFFCDD2; // Red shade 100 - light bg
  static const int red700Value = 0xFFD32F2F; // Red shade 700 - dark text

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
