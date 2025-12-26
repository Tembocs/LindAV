import 'package:flutter/material.dart';

import 'services/theme_provider.dart';
import 'splash_page.dart';

// Global theme provider instance
final themeProvider = ThemeProvider();

void main() {
  runApp(const LindavSecurityApp());
}

class LindavSecurityApp extends StatefulWidget {
  const LindavSecurityApp({super.key});

  @override
  State<LindavSecurityApp> createState() => _LindavSecurityAppState();
}

class _LindavSecurityAppState extends State<LindavSecurityApp> {
  @override
  void initState() {
    super.initState();
    themeProvider.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    themeProvider.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lindav Security',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.materialThemeMode,
      home: const SplashPage(),
    );
  }
}
