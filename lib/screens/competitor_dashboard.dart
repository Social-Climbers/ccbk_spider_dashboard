import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/screens/scoring_page.dart';
import 'package:ccbk_spider_kids_comp/screens/leaderboard_page.dart';
import 'package:ccbk_spider_kids_comp/screens/category_leaderboard_page.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CompetitorDashboard extends StatefulWidget {
  final int competitorId;

  const CompetitorDashboard({
    super.key,
    required this.competitorId,
  });

  @override
  State<CompetitorDashboard> createState() => _CompetitorDashboardState();
}

class _CompetitorDashboardState extends State<CompetitorDashboard> {
  late Competitor competitor;
  bool _hasSubmittedScore = false;

  @override
  void initState() {
    super.initState();
    competitor = MockCompetitorService.getCompetitor(widget.competitorId)!;
  }

  void _updateTopRopeScore(int routeNumber, bool isCompleted, int attempts) {
    setState(() {
      final index = competitor.topRopeScores.indexWhere(
        (score) => score.routeNumber == routeNumber,
      );
      if (index != -1) {
        competitor.topRopeScores[index] = RouteScore(
          routeNumber: routeNumber,
          isCompleted: isCompleted,
          attempts: attempts,
          points: RouteScore.getPointsForRoute(routeNumber),
        );
      }
    });
  }

  void _updateBoulderScore(int routeNumber, bool isCompleted, int attempts) {
    setState(() {
      final index = competitor.boulderScores.indexWhere(
        (score) => score.routeNumber == routeNumber,
      );
      if (index != -1) {
        competitor.boulderScores[index] = RouteScore(
          routeNumber: routeNumber,
          isCompleted: isCompleted,
          attempts: attempts,
          points: RouteScore.getPointsForRoute(routeNumber),
        );
      }
    });
  }

  Future<void> _showSubmitConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Submit Final Score?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you sure you would like to submit your score?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Top Rope:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          competitor.totalTopRopeScore.toString(),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Boulder:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          competitor.totalBoulderScore.toString(),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          (competitor.totalTopRopeScore + competitor.totalBoulderScore).toString(),
                          style: const TextStyle(
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.deepOrange),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      setState(() {
        _hasSubmittedScore = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final textScale = isSmallScreen ? 0.85 : (isTablet ? 1.2 : 1.0);
    final padding = screenWidth < 400 ? 8.0 : (isTablet ? 24.0 : 16.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SponsorBar(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: padding,
              vertical: padding * 1.5,
            ),
            decoration: BoxDecoration(
              color: Colors.blueGrey[50],
              border: Border(
                bottom: BorderSide(
                  color: Colors.blueGrey[100]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${competitor.bibNumber}',
                    style: TextStyle(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        competitor.name,
                        style: TextStyle(
                          fontSize: 20 * textScale,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                      const SizedBox(height: 6),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Category: ',
                              style: TextStyle(
                                fontSize: 14 * textScale,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey[600],
                              ),
                            ),
                            TextSpan(
                              text: competitor.category.displayName,
                              style: TextStyle(
                                fontSize: 14 * textScale,
                                color: Colors.deepOrange,
                              ),
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
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: padding,
                  vertical: padding * 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildScoreCard(
                            'Top Rope',
                            competitor.totalTopRopeScore.toString(),
                            Icons.height,
                            textScale,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildScoreCard(
                            'Boulder',
                            competitor.totalBoulderScore.toString(),
                            Icons.landscape,
                            textScale,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: padding * 2),
                    Text(
                      'Disciplines',
                      style: TextStyle(
                        fontSize: 20 * textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: padding),
                    _buildDisciplineCard(
                      context: context,
                      title: 'Top Rope',
                      description: '16 routes, max 3 attempts per route',
                      icon: Icons.height,
                      onTap: _hasSubmittedScore 
                        ? null 
                        : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoringPage(
                              type: DisciplineType.topRope,
                              scores: competitor.topRopeScores,
                              onScoreUpdate: _updateTopRopeScore,
                            ),
                          ),
                        ),
                      textScale: textScale,
                    ),
                    SizedBox(height: padding),
                    _buildDisciplineCard(
                      context: context,
                      title: 'Boulder',
                      description: '16 problems, attempts counted',
                      icon: Icons.landscape,
                      onTap: _hasSubmittedScore 
                        ? null 
                        : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ScoringPage(
                              type: DisciplineType.boulder,
                              scores: competitor.boulderScores,
                              onScoreUpdate: _updateBoulderScore,
                            ),
                          ),
                        ),
                      textScale: textScale,
                    ),
                    SizedBox(height: padding * 2),
                  ],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                ),
              ],
            ),
            padding: EdgeInsets.all(padding),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_hasSubmittedScore) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Don\'t forget to submit your score when you finish climbing!',
                            style: TextStyle(
                              fontSize: 12 * textScale,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _showSubmitConfirmation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Submit Final Score',
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaderboardPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'View Leaderboard',
                        style: TextStyle(
                          fontSize: 16 * textScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String title, String score, IconData icon, double textScale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20 * textScale),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16 * textScale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            score,
            style: TextStyle(
              fontSize: 24 * textScale,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback? onTap,
    required double textScale,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1.0,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24 * textScale,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18 * textScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14 * textScale,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16 * textScale,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 