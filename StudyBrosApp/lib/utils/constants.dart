import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF); // Soft Purple
  static const Color secondary = Color(0xFFFF6584); // Soft Red/Pink
  static const Color background = Color(0xFFF8F9FE); // Very light blue-ish gray
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9C9DB9);
  static const Color accent = Color(0xFF4CD964); // Soft Green
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
