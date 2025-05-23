import 'package:ccbk_spider_kids_comp/firebase_options.dart';
import 'package:ccbk_spider_kids_comp/screens/competitor_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/home_screen.dart';
import 'package:ccbk_spider_kids_comp/screens/dashboard_screen.dart';
import 'package:ccbk_spider_kids_comp/widgets/browser_check.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
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
      home: const BrowserCheck(child: AuthGate()),
    );
  }
}
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData) {
          print("User Not logged in");
          return HomeScreen();
        }

        print("User Logged in");
        return CompetitorDashboard();
      },
    );
  }
}