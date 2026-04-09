import 'package:flutter/material.dart';
import 'package:flutter_calendar/shared/consts/enums/app_theme.dart';

class ThemeManager {
  static const Map<AppTheme, Map<String, dynamic>> themeDetails = {
    AppTheme.light: {
      'name': 'Light',
      'color': Color(0xFFEEEEEE),
      'icon': Icons.wb_sunny,
    },
    AppTheme.dark: {
      'name': 'Dark',
      'color': Color(0xFF212121),
      'icon': Icons.nightlight_round,
    },
    AppTheme.pinkyCandy: {
      'name': 'Pinky',
      'color': Color(0xFFF06292),
      'icon': Icons.icecream,
    },
    AppTheme.greenJungle: {
      'name': 'Jungle',
      'color': Color(0xFF2E7D32),
      'icon': Icons.forest,
    },
    AppTheme.deepBlue: {
      'name': 'Ocean',
      'color': Color(0xFF0D47A1),
      'icon': Icons.water,
    },
    AppTheme.lightSky: {
      'name': 'Sky',
      'color': Color(0xFF81D4FA),
      'icon': Icons.cloud,
    },
    AppTheme.yellowDessert: {
      'name': 'Desert',
      'color': Color(0xFFFFB74D),
      'icon': Icons.wb_twilight,
    },
    AppTheme.redVolcano: {
      'name': 'Volcano',
      'color': Color(0xFFB71C1C),
      'icon': Icons.volcano,
    },
    AppTheme.neonCity: {
      'name': 'Neon',
      'color': Color(0xFF4A148C),
      'icon': Icons.location_city,
    },
    AppTheme.shinyHeaven: {
      'name': 'Heaven',
      'color': Color(0xFFFFF176),
      'icon': Icons.star,
    },
  };

  static ThemeData getThemeData(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return _build(
          Brightness.light,
          const Color(0xFF1A2A6C),
          const Color(0xFFF0F2F5),
        );
      case AppTheme.dark:
        return _build(
          Brightness.dark,
          const Color(0xFF8AB4F8),
          const Color(0xFF121212),
        );
      case AppTheme.pinkyCandy:
        return _build(Brightness.light, Colors.pink, Colors.pink[50]!);
      case AppTheme.greenJungle:
        return _build(
          Brightness.dark,
          Colors.greenAccent,
          const Color(0xFF0A2E0A),
        );
      case AppTheme.deepBlue:
        return _build(
          Brightness.dark,
          Colors.lightBlueAccent,
          const Color(0xFF041024),
        );
      case AppTheme.lightSky:
        return _build(Brightness.light, Colors.blue, const Color(0xFFE0F2FE));
      case AppTheme.yellowDessert:
        return _build(
          Brightness.light,
          Colors.deepOrange,
          const Color(0xFFFFF3E0),
        );
      case AppTheme.redVolcano:
        return _build(
          Brightness.dark,
          Colors.orangeAccent,
          const Color(0xFF2B0000),
        );
      case AppTheme.neonCity:
        return _build(
          Brightness.dark,
          Colors.purpleAccent,
          const Color(0xFF1A0033),
        );
      case AppTheme.shinyHeaven:
        return _build(Brightness.light, Colors.yellow, const Color(0xFFFFFDE7));
    }
  }

  static ThemeData _build(Brightness b, Color seed, Color bg) {
    final sc = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    return ThemeData(
      colorScheme: sc,
      scaffoldBackgroundColor: bg,
      useMaterial3: true,
      cardTheme: CardThemeData(
        color: b == Brightness.dark ? sc.surfaceContainerHighest : Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
