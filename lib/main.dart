import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ccbk_spider_kids_comp/screens/home_screen.dart';
import 'package:ccbk_spider_kids_comp/widgets/browser_check.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Warm orange color from the CCBK Spider Kids branding
    const primaryOrange = Color(0xFFFF6B1D);

    return MaterialApp(
      title: 'CCBK Spider Kids Competition',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryOrange,
          primary: primaryOrange,
          secondary: primaryOrange,
          background: Colors.white,
          surface: Colors.white,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          elevation: 2,
          surfaceTintColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryOrange,
            foregroundColor: Colors.white,
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      home: const BrowserCheck(child: HomeScreen()),
    );
  }
}
