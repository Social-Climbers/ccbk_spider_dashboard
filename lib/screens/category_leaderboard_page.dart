import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CategoryLeaderboardPage extends StatefulWidget {
  final Category category;

  const CategoryLeaderboardPage({
    super.key,
    required this.category,
  });

  @override
  State<CategoryLeaderboardPage> createState() => _CategoryLeaderboardPageState();
}

class _CategoryLeaderboardPageState extends State<CategoryLeaderboardPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late List<Competitor> _competitors;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCompetitors();
  }

  Future<void> _loadCompetitors() async {
    try {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      if (!mounted) return;
      
      setState(() {
        _competitors = MockCompetitorService.getAllCompetitors()
            .where((c) => c.category == widget.category)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading competitors: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Competitor> _getSortedCompetitors(ScoreType scoreType) {
    switch (scoreType) {
      case ScoreType.topRope:
        return List.from(_competitors)
          ..sort((a, b) => b.totalTopRopeScore.compareTo(a.totalTopRopeScore));
      case ScoreType.boulder:
        return List.from(_competitors)
          ..sort((a, b) => b.totalBoulderScore.compareTo(a.totalBoulderScore));
      case ScoreType.combined:
        return List.from(_competitors)
          ..sort((a, b) => (b.totalTopRopeScore + b.totalBoulderScore)
              .compareTo(a.totalTopRopeScore + a.totalBoulderScore));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.category.displayName,
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Top Rope'),
            Tab(text: 'Boulder'),
            Tab(text: 'Combined'),
          ],
        ),
      ),
      body: Column(
        children: [
          const SponsorBar(isDarkTheme: false),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardList(
                  _getSortedCompetitors(ScoreType.topRope),
                  textScale,
                  padding,
                  ScoreType.topRope,
                ),
                _buildLeaderboardList(
                  _getSortedCompetitors(ScoreType.boulder),
                  textScale,
                  padding,
                  ScoreType.boulder,
                ),
                _buildLeaderboardList(
                  _getSortedCompetitors(ScoreType.combined),
                  textScale,
                  padding,
                  ScoreType.combined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
                : competitor.totalCombinedScore;

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