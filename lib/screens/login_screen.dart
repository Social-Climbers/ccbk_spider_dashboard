import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccbk_spider_kids_comp/screens/competitor_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  String? _errorMessage;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      final id = int.parse(_idController.text);
      if (id >= 1 && id <= 100) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CompetitorDashboard(),
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid competitor ID. Please enter a number between 1 and 100.';
        });
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Competitor Login',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth < 600 ? screenWidth * 0.9 : 400),
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.sports_gymnastics,
                  size: 80 * textScale,
                  color: Colors.orange,
                ),
                SizedBox(height: 32 * textScale),
                Text(
                  'Spider Kids 2025',
                  style: TextStyle(
                    fontSize: 24 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8 * textScale),
                Text(
                  'Enter your competitor ID to access your information',
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32 * textScale),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _idController,
                    decoration: InputDecoration(
                      labelText: 'Competitor ID',
                      hintText: 'Enter your ID (1-100)',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16 * textScale,
                        vertical: 12 * textScale,
                      ),
                    ),
                    style: TextStyle(fontSize: 16 * textScale),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your competitor ID';
                      }
                      final id = int.tryParse(value);
                      if (id == null) {
                        return 'Please enter a valid number';
                      }
                      if (id < 1 || id > 100) {
                        return 'ID must be between 1 and 100';
                      }
                      return null;
                    },
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.only(top: 8 * textScale),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14 * textScale,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                SizedBox(height: 24 * textScale),
                ElevatedButton(
                  onPressed: _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 16 * textScale,
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 16 * textScale),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 