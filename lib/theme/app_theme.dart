import 'package:flutter/material.dart';

class AppColors {
  static const bg = Color(0xFF080808);
  static const bg2 = Color(0xFF0F0F0F);
  static const bg3 = Color(0xFF161616);
  static const bg4 = Color(0xFF1E1E1E);
  static const gold = Color(0xFFC9A84C);
  static const goldBright = Color(0xFFE4C46A);
  static const textPrimary = Color(0xFFF5F0E8);
  static const textSecondary = Color(0xFFA8A090);
  static const textTertiary = Color(0xFF5C5650);
  static const border = Color(0xFF1E1E1E);
  static const green = Color(0xFF2ECC71);
  static const red = Color(0xFFE5341A);

  static Color get goldGlow => gold.withOpacity(0.15);
  static Color get borderGold => gold.withOpacity(0.25);
}

class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        surface: AppColors.bg2,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}