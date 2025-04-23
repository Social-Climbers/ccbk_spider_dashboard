import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/firebase_service.dart';
import 'package:ccbk_spider_kids_comp/screens/account_verification_screen.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _bibNumberController = TextEditingController();
  bool _isLoading = false;

  Future<void> _checkCompetitorAccount() async {
    setState(() => _isLoading = true);
    try {
      final bibNumber = int.parse(_bibNumberController.text);
      final competitor = await FirebaseService().getCompetitor(bibNumber);
      if (competitor != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountVerificationScreen(
              competitor: competitor,
              email: 'competitor$bibNumber@ccbk.com',
              password: 'password$bibNumber',
            ),
          ),
        );
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found for this bib number')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking account: $e')),
        );
      }
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _bibNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final padding = isSmallScreen ? 16.0 : 32.0;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        Image.asset(
                          'assets/logo.png',
                          height: 100,
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'CCBK: Spider Kids 2025',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '10 MAY 2025',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _bibNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Bib Number',
                            border: OutlineInputBorder(),
                            hintText: 'Enter your bib number (1-100)',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your bib number';
                            }
                            final number = int.tryParse(value);
                            if (number == null) {
                              return 'Please enter a valid number';
                            }
                            if (number < 1 || number > 100) {
                              return 'Bib number must be between 1 and 100';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      _checkCompetitorAccount();
                                    }
                                  },
                            child: _isLoading
                                ? const CircularProgressIndicator()
                                : const Text('Login'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SponsorBar(),
        ],
      ),
    );
  }
} 