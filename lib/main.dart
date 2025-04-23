import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/home_screen.dart';
import 'package:ccbk_spider_kids_comp/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spider Kids Competition',
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
