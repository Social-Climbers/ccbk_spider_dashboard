import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/login_page.dart';
import 'package:ccbk_spider_kids_comp/screens/leaderboard_page.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Image.asset(
                    'assets/ccbklogo.png',
                    height: 120 * textScale,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 32 * textScale),
                  Text(
                    'Spider Kids Competition',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16 * textScale),
                  Text(
                    'Climb Central Bangkok',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18 * textScale,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 48 * textScale),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 16 * textScale,
                        horizontal: 32 * textScale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Enter Competition',
                      style: TextStyle(
                        fontSize: 18 * textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardPage(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 16 * textScale,
                        horizontal: 32 * textScale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Colors.deepOrange),
                      foregroundColor: Colors.deepOrange,
                    ),
                    icon: const Icon(Icons.leaderboard),
                    label: Text(
                      'View Scores',
                      style: TextStyle(
                        fontSize: 18 * textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: const SponsorBar(),
          ),
        ],
      ),
    );
  }
} 