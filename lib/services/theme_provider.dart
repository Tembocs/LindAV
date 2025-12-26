import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Available theme colors
class AppThemeColor {
  final String name;
  final Color color;

  const AppThemeColor({required this.name, required this.color});
}

/// Available theme colors for the app
const List<AppThemeColor> availableColors = [
  AppThemeColor(name: 'Green', color: Colors.green),
  AppThemeColor(name: 'Blue', color: Colors.blue),
  AppThemeColor(name: 'Purple', color: Colors.purple),
  AppThemeColor(name: 'Orange', color: Colors.orange),
  AppThemeColor(name: 'Red', color: Colors.red),
  AppThemeColor(name: 'Teal', color: Colors.teal),
  AppThemeColor(name: 'Pink', color: Colors.pink),
  AppThemeColor(name: 'Indigo', color: Colors.indigo),
  AppThemeColor(name: 'Cyan', color: Colors.cyan),
  AppThemeColor(name: 'Amber', color: Colors.amber),
];

/// Theme mode options
enum AppThemeMode { light, dark, system }

/// Theme settings data class
class ThemeSettings {
  final AppThemeMode themeMode;
  final int colorIndex;

  const ThemeSettings({
    this.themeMode = AppThemeMode.system,
    this.colorIndex = 0,
  });

  Color get primaryColor => availableColors[colorIndex].color;
  String get colorName => availableColors[colorIndex].name;

  ThemeSettings copyWith({AppThemeMode? themeMode, int? colorIndex}) {
    return ThemeSettings(
      themeMode: themeMode ?? this.themeMode,
      colorIndex: colorIndex ?? this.colorIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
    'colorIndex': colorIndex,
  };

  factory ThemeSettings.fromJson(Map<String, dynamic> json) {
    return ThemeSettings(
      themeMode: AppThemeMode.values[json['themeMode'] as int? ?? 0],
      colorIndex: json['colorIndex'] as int? ?? 0,
    );
  }
}

/// Theme provider that manages app theme state
class ThemeProvider extends ChangeNotifier {
  ThemeSettings _settings = const ThemeSettings();

  ThemeSettings get settings => _settings;

  AppThemeMode get themeMode => _settings.themeMode;
  Color get primaryColor => _settings.primaryColor;
  int get colorIndex => _settings.colorIndex;

  ThemeProvider() {
    _loadSettings();
  }

  Future<Directory> _getDataDirectory() async {
    final dir = await getApplicationSupportDirectory();
    final appDir = Directory('${dir.path}${Platform.pathSeparator}lindav');
    if (!await appDir.exists()) {
      await appDir.create(recursive: true);
    }
    return appDir;
  }

  Future<void> _loadSettings() async {
    try {
      final dir = await _getDataDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}theme.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final json = jsonDecode(content) as Map<String, dynamic>;
          _settings = ThemeSettings.fromJson(json);
          notifyListeners();
        }
      }
    } catch (_) {
      // Use default settings if loading fails
    }
  }

  Future<void> _saveSettings() async {
    try {
      final dir = await _getDataDirectory();
      final file = File('${dir.path}${Platform.pathSeparator}theme.json');
      await file.writeAsString(jsonEncode(_settings.toJson()));
    } catch (_) {
      // Ignore save errors
    }
  }

  void setThemeMode(AppThemeMode mode) {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    _saveSettings();
  }

  void setColorIndex(int index) {
    if (index >= 0 && index < availableColors.length) {
      _settings = _settings.copyWith(colorIndex: index);
      notifyListeners();
      _saveSettings();
    }
  }

  ThemeMode get materialThemeMode {
    switch (_settings.themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
    );
  }
}
