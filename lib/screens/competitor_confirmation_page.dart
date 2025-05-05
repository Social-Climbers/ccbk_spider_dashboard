import 'package:ccbk_spider_kids_comp/screens/competitor_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/screens/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccbk_spider_kids_comp/services/local_storage_service.dart';
import 'package:ccbk_spider_kids_comp/services/score_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CompetitorConfirmationPage extends StatefulWidget {
  final Map<String, dynamic> competitorData;
  final String? documentId;

  const CompetitorConfirmationPage({
    super.key,
    required this.competitorData,
    this.documentId,
  });

  @override
  State<CompetitorConfirmationPage> createState() => _CompetitorConfirmationPageState();
}

class _CompetitorConfirmationPageState extends State<CompetitorConfirmationPage> {
  bool _isLoading = false;

  String get _displayId {
    // First try to get the ID from the document ID
    if (widget.documentId != null) {
      return widget.documentId!;
    }
    // Then try to get it from the competitor data
    if (widget.competitorData['id'] != null) {
      return widget.competitorData['id'].toString();
    }
    // If both are null, return a default value
    return 'N/A';
  }

  Future<void> _signInAnonymously(BuildContext context) async {
    setState(() => _isLoading = true);
    try {
      print('Starting anonymous sign in...');
      await FirebaseAuth.instance.signInAnonymously();
      print('Successfully signed in anonymously');
      
      // Use the document ID if available, otherwise use the id field
      final idToSave = widget.documentId != null 
          ? int.parse(widget.documentId!)
          : widget.competitorData['id'] as int;
      print('Saving competitor ID: $idToSave');
      await LocalStorageService.saveCompetitorId(idToSave);
      
      print('Initializing scores...');
      await ScoreService.initializeScores(idToSave);
      print('Scores initialized successfully');
      
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const CompetitorDashboard(),
          ),
        );
      }
    } catch (e) {
      print('Error during sign in process: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing in: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('Confirm Details'),
            centerTitle: true,
            backgroundColor: Colors.deepOrange,
            foregroundColor: Colors.white,
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    //const SponsorBar(isDarkTheme: false),
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Warning Card
                          Card(
                            color: Colors.amber[100],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.amber[700]!, width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 48,
                                    color: Colors.amber[800],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Important!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Please verify that this is your information. If this is not you, tap "Go Back" to try again.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Competitor Info Card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '#$_displayId',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    widget.competitorData['name'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildInfoRow(
                                    Icons.groups_outlined,
                                    'Category',
                                    widget.competitorData['category'] == 'kidsABoy' ? 'Kids A Boys' :
                                    widget.competitorData['category'] == 'kidsAGirl' ? 'Kids A Girls' :
                                    widget.competitorData['category'] == 'kidsBBoy' ? 'Kids B Boys' :
                                    widget.competitorData['category'] == 'kidsBGirl' ? 'Kids B Girls' :
                                    widget.competitorData['category'] == 'kidsCBoy' ? 'Kids C Boys' :
                                    widget.competitorData['category'] == 'kidsCGirl' ? 'Kids C Girls' :
                                    widget.competitorData['category'],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.person_outline,
                                    'Gender',
                                    widget.competitorData['gender'] == 'boy' ? 'Boy' :
                                    widget.competitorData['gender'] == 'girl' ? 'Girl' :
                                    widget.competitorData['gender'],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    Icons.cake_outlined,
                                    'Birth Year',
                                    widget.competitorData['birthYear'].toString(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(color: Colors.grey[400]!),
                                  ),
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('Go Back'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : () => _signInAnonymously(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Confirm'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 