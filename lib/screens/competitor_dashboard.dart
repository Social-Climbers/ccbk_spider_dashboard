import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/screens/scoring_page.dart';
import 'package:ccbk_spider_kids_comp/screens/leaderboard_page.dart';
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
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: padding + 80, // Add padding for sponsor bar
              left: padding,
              right: padding,
              bottom: padding + 80, // Add padding for leaderboard button
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competitor.name,
                          style: TextStyle(
                            fontSize: 24 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${competitor.id}',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Category: ${competitor.category.displayName}',
                          style: TextStyle(fontSize: 16 * textScale),
                        ),
                        Text(
                          'Birth Year: ${competitor.birthYear}',
                          style: TextStyle(fontSize: 16 * textScale),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Top Rope Score',
                                  style: TextStyle(
                                    fontSize: 14 * textScale,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  competitor.totalTopRopeScore.toString(),
                                  style: TextStyle(
                                    fontSize: 20 * textScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Boulder Score',
                                  style: TextStyle(
                                    fontSize: 14 * textScale,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  competitor.totalBoulderScore.toString(),
                                  style: TextStyle(
                                    fontSize: 20 * textScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: padding * 2),
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
                const SizedBox(height: 8),
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
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: const SponsorBar(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
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
              padding: EdgeInsets.all(padding),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.leaderboard),
                  label: Text(
                    'View Leaderboard',
                    style: TextStyle(
                      fontSize: 16 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: padding * 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 32 * textScale,
                color: Theme.of(context).primaryColor,
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