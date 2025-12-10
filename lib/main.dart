import 'package:flutter/material.dart';

import 'splash_page.dart';

void main() {
  runApp(const LindavSecurityApp());
}

class LindavSecurityApp extends StatelessWidget {
  const LindavSecurityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lindav Security',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
