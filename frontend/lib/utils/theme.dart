import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'constants.dart';

class AppTheme {
  static const Color _darkBackground = Color(0xFF0F1018);
  static const Color _darkSurface = Color(0xFF181B24);
  static const Color _darkTextPrimary = Color(0xFFF4F4F6);
  static const Color _darkTextSecondary = Color(0xFFB0B4C3);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFFF5A5F),
      onError: Colors.white,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.textSecondary.withOpacity(0.4),
      outlineVariant: AppColors.textSecondary.withOpacity(0.2),
      inversePrimary: Colors.white,
      shadow: Colors.black.withOpacity(0.1),
      surfaceTint: AppColors.primary,
      scrim: Colors.black54,
      tertiary: AppColors.accent,
      onTertiary: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      primaryColor: AppColors.primary,
      fontFamily: 'Fredoka',
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: 'Fredoka',
            bodyColor: colorScheme.onBackground,
            displayColor: colorScheme.onBackground,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        titleTextStyle: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Fredoka',
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      dialogBackgroundColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: const Color(0xFFFF5A5F),
      onError: Colors.white,
      background: _darkBackground,
      onBackground: _darkTextPrimary,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      outline: _darkTextSecondary.withOpacity(0.5),
      outlineVariant: _darkTextSecondary.withOpacity(0.2),
      inversePrimary: AppColors.accent,
      shadow: Colors.black,
      surfaceTint: _darkSurface,
      scrim: Colors.black87,
      tertiary: AppColors.accent,
      onTertiary: Colors.black,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      primaryColor: AppColors.primary,
      fontFamily: 'Fredoka',
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: 'Fredoka',
            bodyColor: colorScheme.onBackground,
            displayColor: colorScheme.onBackground,
          ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onBackground),
        titleTextStyle: TextStyle(
          color: colorScheme.onBackground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Fredoka',
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      dialogBackgroundColor: colorScheme.surface,
      dividerColor: colorScheme.outlineVariant,
    );
  }
}
