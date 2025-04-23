import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CompetitorInfoPage extends StatefulWidget {
  const CompetitorInfoPage({super.key});

  @override
  State<CompetitorInfoPage> createState() => _CompetitorInfoPageState();
}

class _CompetitorInfoPageState extends State<CompetitorInfoPage> {
  final _idController = TextEditingController();
  Competitor? _competitor;
  bool _isLoading = false;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  void _searchCompetitor() {
    if (_idController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _competitor = null;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final competitorId = int.tryParse(_idController.text);
      if (competitorId != null) {
        final competitor = MockCompetitorService.getCompetitor(competitorId);
        setState(() {
          _competitor = competitor;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid competitor ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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
          'Competitor Info',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Check Your Information',
                  style: TextStyle(
                    fontSize: 24 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16 * textScale),
                Text(
                  'Enter your competitor ID to view your information',
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32 * textScale),
                TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Competitor ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchCompetitor,
                    ),
                  ),
                ),
                SizedBox(height: 24 * textScale),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_competitor != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _competitor!.name,
                            style: TextStyle(
                              fontSize: 20 * textScale,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8 * textScale),
                          _buildInfoRow(
                            'ID',
                            _competitor!.id.toString(),
                            textScale,
                          ),
                          _buildInfoRow(
                            'Category',
                            _competitor!.category.displayName,
                            textScale,
                          ),
                          _buildInfoRow(
                            'Birth Year',
                            _competitor!.birthYear.toString(),
                            textScale,
                          ),
                          _buildInfoRow(
                            'Top Rope Score',
                            _competitor!.totalTopRopeScore.toString(),
                            textScale,
                          ),
                          _buildInfoRow(
                            'Boulder Score',
                            _competitor!.totalBoulderScore.toString(),
                            textScale,
                          ),
                        ],
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

  Widget _buildInfoRow(String label, String value, double textScale) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 16 * textScale,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16 * textScale,
            ),
          ),
        ],
      ),
    );
  }
} 