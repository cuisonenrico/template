import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Modern, scalable theming system with Material Design 3 and dark mode support
class AppTheme {
  // Brand Colors
  static const Color seedColor = Color(0xFF2196F3); // Material Blue
  static const Color brandPrimary = Color(0xFF1976D2);
  static const Color brandSecondary = Color(0xFF03DAC6);

  // Spacing System
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Border Radius System
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2Xl = 24.0;
  static const double radiusFull = 9999.0;

  // Elevation System
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 2.0;
  static const double elevation3 = 3.0;
  static const double elevation4 = 4.0;
  static const double elevation6 = 6.0;
  static const double elevation8 = 8.0;

  // Backward compatibility properties
  static const Color primaryColor = brandPrimary;
  static const Color secondaryColor = brandSecondary;
  static const Color backgroundColor = Colors.white;
  static const Color surfaceColor = Colors.grey;
  static const Color errorColor = Colors.red;
  static const Color onPrimaryColor = Colors.white;
  static const Color onBackgroundColor = Colors.black;

  // Backward compatibility spacing
  static const double smallSpacing = space8;
  static const double mediumSpacing = space16;
  static const double largeSpacing = space24;
  static const double extraLargeSpacing = space32;

  // Backward compatibility radius
  static const double smallRadius = radiusXs;
  static const double mediumRadius = radiusSm;
  static const double largeRadius = radiusMd;

  // Backward compatibility text styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: elevation0,
        scrolledUnderElevation: elevation2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: space16,
            vertical: space8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: elevation6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: elevation8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        elevation: elevation1,
        pressElevation: elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: space16,
      ),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        elevation: elevation0,
        scrolledUnderElevation: elevation2,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: elevation2,
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: space24,
            vertical: space12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: space16,
            vertical: space8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space16,
          vertical: space12,
        ),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: elevation6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        elevation: elevation8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        elevation: elevation8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusLg)),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        elevation: elevation1,
        pressElevation: elevation2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outline.withValues(alpha: 0.2),
        thickness: 1,
        space: space16,
      ),
    );
  }
}

/// Theme mode enumeration
enum AppThemeMode { light, dark, system }

/// Extension for easy theme mode access
extension AppThemeModeExtension on AppThemeMode {
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.auto_mode;
    }
  }

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}

/// Theme extensions for easy access to design tokens
extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => theme.colorScheme;
  TextTheme get textStyles => theme.textTheme;

  // Easy spacing access
  double get space4 => AppTheme.space4;
  double get space8 => AppTheme.space8;
  double get space12 => AppTheme.space12;
  double get space16 => AppTheme.space16;
  double get space20 => AppTheme.space20;
  double get space24 => AppTheme.space24;
  double get space32 => AppTheme.space32;
  double get space40 => AppTheme.space40;
  double get space48 => AppTheme.space48;
  double get space64 => AppTheme.space64;

  // Easy radius access
  double get radiusXs => AppTheme.radiusXs;
  double get radiusSm => AppTheme.radiusSm;
  double get radiusMd => AppTheme.radiusMd;
  double get radiusLg => AppTheme.radiusLg;
  double get radiusXl => AppTheme.radiusXl;
  double get radius2Xl => AppTheme.radius2Xl;
  double get radiusFull => AppTheme.radiusFull;
}
