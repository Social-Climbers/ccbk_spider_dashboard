import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccbk_spider_kids_comp/screens/competitor_confirmation_page.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _bibNumberController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bibNumber = _bibNumberController.text.trim();
      print('Attempting to find competitor with ID: $bibNumber');
      
      // First try to get the document directly
      final doc = await FirebaseFirestore.instance
          .collection('competitors')
          .doc(bibNumber)
          .get();

      if (!mounted) return;

      if (!doc.exists) {
        print('Competitor not found with direct document lookup');
        // If direct lookup fails, try the query approach
        final querySnapshot = await FirebaseFirestore.instance
            .collection('competitors')
            .where('id', isEqualTo: int.parse(bibNumber))
            .get();

        if (querySnapshot.docs.isEmpty) {
          print('Competitor not found with query lookup');
          setState(() {
            _isLoading = false;
            _errorMessage = 'Competitor not found. Please check your ID and try again.';
          });
          return;
        }

        final competitorData = querySnapshot.docs.first.data();
        print('Found competitor with query: ${competitorData['name']}');
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompetitorConfirmationPage(
              competitorData: competitorData,
              documentId: querySnapshot.docs.first.id,
            ),
          ),
        );
      } else {
        print('Found competitor with direct lookup: ${doc.data()?['name']}');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompetitorConfirmationPage(
              competitorData: doc.data()!,
              documentId: doc.id,
            ),
          ),
        );
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('Error during login: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _bibNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Image.asset(
                    'assets/images/ccbklogo.png',
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
                  SizedBox(height: 32 * textScale),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bib Number',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'You can find your bib number on your competition card',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 8 * textScale),
                        TextFormField(
                          controller: _bibNumberController,
                          decoration: InputDecoration(
                            hintText: 'Enter your bib number (1-100)',
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
                              return 'Please enter your bib number';
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
                      ],
                    ),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16 * textScale),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16 * textScale,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 32 * textScale),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 16 * textScale,
                        horizontal: 32 * textScale,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20 * textScale,
                            width: 20 * textScale,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18 * textScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  SizedBox(height: 32 * textScale),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How to Participate:',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Enter your bib number above\n'
                          '2. View your category and scores\n'
                          '3. Record your climbs in Top Rope and Boulder',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SponsorBar(),
        ],
      ),
    );
  }
} 