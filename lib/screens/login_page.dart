import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/competitor_dashboard.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _competitorIdController = TextEditingController();

  @override
  void dispose() {
    _competitorIdController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final competitorId = int.parse(_competitorIdController.text);
      final competitor = MockCompetitorService.getCompetitor(competitorId);
      
      if (competitor == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid competitor ID. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompetitorDashboard(competitorId: competitorId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: padding + 60, // Reduced from 80 to 60 to account for smaller sponsor bar
              left: padding,
              right: padding,
              bottom: padding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/logo.png',
                  height: 120 * textScale,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 32 * textScale),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Competitor ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 16 * textScale),
                ElevatedButton(
                  onPressed: _handleLogin,
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
                    'Login',
                    style: TextStyle(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
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