import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/home_screen.dart';
import 'package:ccbk_spider_kids_comp/widgets/browser_check.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCBK Spider Kids Competition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE53935),
          primary: const Color(0xFFE53935),
          secondary: const Color(0xFF1A237E),
        ),
        useMaterial3: true,
      ),
      home: const BrowserCheck(child: HomeScreen()),
    );
  }
}
