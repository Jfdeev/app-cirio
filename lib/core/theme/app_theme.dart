import 'package:flutter/material.dart';

/// Paleta e temas do app — azul e branco remetem às cores tradicionais da
/// romaria do Círio de Nazaré.
class AppTheme {
  AppTheme._();

  static const Color azulCirio = Color(0xFF0D47A1);
  static const Color douradoCirio = Color(0xFFC9A227);

  static ThemeData get claro {
    final scheme = ColorScheme.fromSeed(
      seedColor: azulCirio,
      secondary: douradoCirio,
      brightness: Brightness.light,
    );
    return _base(scheme);
  }

  static ThemeData get escuro {
    final scheme = ColorScheme.fromSeed(
      seedColor: azulCirio,
      secondary: douradoCirio,
      brightness: Brightness.dark,
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      brightness: scheme.brightness,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
