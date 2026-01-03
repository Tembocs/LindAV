import 'package:flutter/material.dart';

import 'services/network_service.dart';
import 'splash_page.dart';
import 'theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NetworkService().initialize();
  runApp(const LindavSecurityApp());
}

class LindavSecurityApp extends StatefulWidget {
  const LindavSecurityApp({super.key});

  @override
  State<LindavSecurityApp> createState() => _LindavSecurityAppState();
}

class _LindavSecurityAppState extends State<LindavSecurityApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      themeMode: _themeMode,
      setThemeMode: _setThemeMode,
      child: MaterialApp(
        title: 'Lindav Security',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: _themeMode,
        home: const SplashPage(),
      ),
    );
  }
}
