import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccbk_spider_kids_comp/theme/app_theme.dart';
import 'package:ccbk_spider_kids_comp/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const SpiderKidsApp());
}

class SpiderKidsApp extends StatelessWidget {
  const SpiderKidsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spider Kids Competition 2025',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Get the screen size
        final mediaQuery = MediaQuery.of(context);
        final isPortrait = mediaQuery.orientation == Orientation.portrait;
        final screenWidth = mediaQuery.size.width;

        // If device is a phone (width < 600) and not in portrait, show warning
        if (screenWidth < 600 && !isPortrait) {
          return const Material(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.screen_rotation,
                      size: 64,
                      color: Colors.orange,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Please rotate your device to portrait mode',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MediaQuery(
          // Set text scaling to prevent text from being too large
          data: mediaQuery.copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
