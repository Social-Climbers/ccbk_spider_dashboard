import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Competitor> _competitors;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCompetitors();
  }

  Future<void> _loadCompetitors() async {
    final competitors = await MockCompetitorService.getAllCompetitors();
    setState(() => _competitors = competitors);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Competitor> _getFilteredCompetitors(Category category) {
    return _competitors.where((c) => c.category == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Leaderboard',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kids A'),
              Tab(text: 'Kids B'),
              Tab(text: 'Kids C'),
            ],
          ),
        ),
        body: Column(
          children: [
            const SponsorBar(isDarkTheme: false),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Top Rope'),
                Tab(text: 'Boulder'),
                Tab(text: 'Combined'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildCategoryContent(Category.kidsA, textScale, padding),
                  _buildCategoryContent(Category.kidsB, textScale, padding),
                  _buildCategoryContent(Category.kidsC, textScale, padding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent(Category category, double textScale, double padding) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildLeaderboardList(
          _getFilteredAndSortedCompetitors(category, ScoreType.topRope),
          textScale,
          padding,
          ScoreType.topRope,
        ),
        _buildLeaderboardList(
          _getFilteredAndSortedCompetitors(category, ScoreType.boulder),
          textScale,
          padding,
          ScoreType.boulder,
        ),
        _buildLeaderboardList(
          _getFilteredAndSortedCompetitors(category, ScoreType.combined),
          textScale,
          padding,
          ScoreType.combined,
        ),
      ],
    );
  }

  List<Competitor> _getFilteredAndSortedCompetitors(Category category, ScoreType scoreType) {
    final filtered = _getFilteredCompetitors(category);
    switch (scoreType) {
      case ScoreType.topRope:
        return List.from(filtered)
          ..sort((a, b) => b.totalTopRopeScore.compareTo(a.totalTopRopeScore));
      case ScoreType.boulder:
        return List.from(filtered)
          ..sort((a, b) => b.totalBoulderScore.compareTo(a.totalBoulderScore));
      case ScoreType.combined:
        return List.from(filtered)
          ..sort((a, b) => (b.totalTopRopeScore + b.totalBoulderScore)
              .compareTo(a.totalTopRopeScore + a.totalBoulderScore));
    }
  }

  Widget _buildLeaderboardList(
    List<Competitor> competitors,
    double textScale,
    double padding,
    ScoreType scoreType,
  ) {
    return ListView.builder(
      padding: EdgeInsets.all(padding),
      itemCount: competitors.length,
      itemBuilder: (context, index) {
        final competitor = competitors[index];
        final score = scoreType == ScoreType.topRope
            ? competitor.totalTopRopeScore
            : scoreType == ScoreType.boulder
                ? competitor.totalBoulderScore
                : competitor.totalTopRopeScore + competitor.totalBoulderScore;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18 * textScale,
                  ),
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
              'Bib: ${competitor.id}',
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
                  scoreType.displayName,
                  style: TextStyle(
                    fontSize: 12 * textScale,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: 20 * textScale,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
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

enum ScoreType {
  topRope,
  boulder,
  combined;

  String get displayName {
    switch (this) {
      case ScoreType.topRope:
        return 'Top Rope';
      case ScoreType.boulder:
        return 'Boulder';
      case ScoreType.combined:
        return 'Combined';
    }
  }
} 