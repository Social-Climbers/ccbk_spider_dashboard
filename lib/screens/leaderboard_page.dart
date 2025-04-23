import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<Competitor> _topRopeLeaderboard;
  late List<Competitor> _boulderLeaderboard;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _topRopeLeaderboard = MockCompetitorService.getTopRopeLeaderboard();
    _boulderLeaderboard = MockCompetitorService.getBoulderLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          'Leaderboard',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Top Rope'),
            Tab(text: 'Boulder'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 80),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(_topRopeLeaderboard, textScale, padding),
                _buildLeaderboardList(_boulderLeaderboard, textScale, padding),
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

  Widget _buildLeaderboardList(List<Competitor> competitors, double textScale, double padding) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: competitors.length,
      itemBuilder: (context, index) {
        final competitor = competitors[index];
        final score = _tabController.index == 0
            ? competitor.totalTopRopeScore
            : competitor.totalBoulderScore;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * textScale,
                ),
              ),
            ),
            title: Text(
              competitor.name,
              style: TextStyle(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${competitor.category.displayName} • ${competitor.birthYear}',
              style: TextStyle(
                fontSize: 14 * textScale,
                color: Colors.grey[600],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Score',
                  style: TextStyle(
                    fontSize: 12 * textScale,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 18 * textScale,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
} 