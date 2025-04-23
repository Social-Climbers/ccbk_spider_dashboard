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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SponsorBar(isDarkTheme: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.blueGrey, Colors.blueGrey.shade700],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competitor.name,
                          style: TextStyle(
                            fontSize: 28 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Bib ${competitor.id}',
                                style: TextStyle(
                                  fontSize: 16 * textScale,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              competitor.category.displayName,
                              style: TextStyle(
                                fontSize: 16 * textScale,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(padding),
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
                        const SizedBox(height: 24),
                        Text(
                          'Disciplines',
                          style: TextStyle(
                            fontSize: 20 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDisciplineCard(
                          context: context,
                          title: 'Top Rope',
                          description: '16 routes, max 3 attempts per route',
                          icon: Icons.height,
                          onTap: () => Navigator.push(
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
                        const SizedBox(height: 12),
                        _buildDisciplineCard(
                          context: context,
                          title: 'Boulder',
                          description: '16 problems, attempts counted',
                          icon: Icons.landscape,
                          onTap: () => Navigator.push(
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
            child: SafeArea(
              top: false,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryLeaderboardPage(
                        category: competitor.category,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: padding * 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.leaderboard, size: 24 * textScale),
                    const SizedBox(width: 8),
                    Text(
                      'View Leaderboard',
                      style: TextStyle(
                        fontSize: 18 * textScale,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
              Icon(icon, color: Colors.deepOrange, size: 20 * textScale),
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
              color: Colors.deepOrange,
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
    required VoidCallback onTap,
    required double textScale,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24 * textScale,
                  color: Colors.deepOrange,
                ),
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
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 