import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/competitor_dashboard.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CompetitorLogin extends StatefulWidget {
  const CompetitorLogin({super.key});

  @override
  State<CompetitorLogin> createState() => _CompetitorLoginState();
}

class _CompetitorLoginState extends State<CompetitorLogin> {
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
          'Competitor Login',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: padding + 60,
              left: padding,
              right: padding,
              bottom: padding,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    'assets/images/ccbklogo.png',
                    height: 120 * textScale,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 32 * textScale),
                  TextFormField(
                    controller: _competitorIdController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Competitor ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your competitor ID';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
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