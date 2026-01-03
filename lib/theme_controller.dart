import 'package:flutter/material.dart';

class AppTheme extends InheritedWidget {
  const AppTheme({
    super.key,
    required super.child,
    required this.themeMode,
    required this.setThemeMode,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> setThemeMode;

  static AppTheme of(BuildContext context) {
    final AppTheme? result = context
        .dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(result != null, 'AppTheme is not available in the current context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) =>
      themeMode != oldWidget.themeMode;
}
