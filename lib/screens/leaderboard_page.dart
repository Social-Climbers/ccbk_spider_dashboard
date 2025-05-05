import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccbk_spider_kids_comp/models/leaderboard_entry.dart';
import 'package:ccbk_spider_kids_comp/services/score_service.dart';
import 'package:ccbk_spider_kids_comp/screens/scoring_page.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Kids A Boys (2011-2012)';
  List<String> _categories = [];
  static const _maxTopRopeRoutes = 15;  // 15 routes for top rope
  static const _maxBoulderRoutes = 16;  // 16 routes for boulder

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    print('Loading categories');
    setState(() {
      _categories = [
        'Kids A Boys (2011-2012)',
        'Kids A Girls (2011-2012)',
        'Kids B Boys (2013-2014)',
        'Kids B Girls (2013-2014)',
        'Kids C Boys (2015-2018)',
        'Kids C Girls (2015-2018)',
      ];
      // Ensure we start with a valid category
      if (!_categories.contains(_selectedCategory)) {
        _selectedCategory = _categories[0];
      }
    });
    print('Categories loaded: $_categories');
    print('Selected category: $_selectedCategory');
  }

  String _getCategoryValue(String displayName) {
    print('Converting display name to category value: $displayName');
    String categoryValue;
    
    // Convert display name to Firestore category value
    if (displayName.contains('Kids A Boys')) {
      categoryValue = 'kidsABoy';
    } else if (displayName.contains('Kids A Girls')) {
      categoryValue = 'kidsAGirl';
    } else if (displayName.contains('Kids B Boys')) {
      categoryValue = 'kidsBBoy';
    } else if (displayName.contains('Kids B Girls')) {
      categoryValue = 'kidsBGirl';
    } else if (displayName.contains('Kids C Boys')) {
      categoryValue = 'kidsCBoy';
    } else if (displayName.contains('Kids C Girls')) {
      categoryValue = 'kidsCGirl';
    } else {
      categoryValue = displayName;
    }
    
    print('Converted to category value: $categoryValue');
    return categoryValue;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildLeaderboardList(DisciplineType type) {
    final categoryValue = _getCategoryValue(_selectedCategory);
    print('Building leaderboard list for category: $categoryValue, type: ${type == DisciplineType.topRope ? 'topRope' : 'boulder'}');
    
    return StreamBuilder<QuerySnapshot>(
      stream: ScoreService.getLeaderboardStream(categoryValue, type),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print('Leaderboard error: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        print('Received ${docs.length} documents for category: $categoryValue');
        
        List<LeaderboardEntry> entries = docs
            .map((doc) => LeaderboardEntry.fromFirestore(doc))
            .toList();
        print('Converted to ${entries.length} LeaderboardEntry objects');
        
        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  entry.competitorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('Bib #${entry.competitorId}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Score: ${entry.totalScore}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Routes: ${entry.completedRoutes}/${type == DisciplineType.topRope ? _maxTopRopeRoutes : _maxBoulderRoutes}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Top Rope'),
            Tab(text: 'Boulder'),
            Tab(text: 'Combined'),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SponsorBar(isDarkTheme: false),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardList(DisciplineType.topRope),
                    _buildLeaderboardList(DisciplineType.boulder),
                    _buildCombinedLeaderboardList(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedLeaderboardList() {
    final categoryValue = _getCategoryValue(_selectedCategory);
    print('Building combined leaderboard list for category: $categoryValue');
    
    return StreamBuilder<QuerySnapshot>(
      stream: ScoreService.getLeaderboardStream(categoryValue, DisciplineType.topRope),
      builder: (context, topRopeSnapshot) {
        if (topRopeSnapshot.hasError) {
          print('Top rope leaderboard error: ${topRopeSnapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error: ${topRopeSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (topRopeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final topRopeDocs = topRopeSnapshot.data?.docs ?? [];
        final topRopeEntries = topRopeDocs
            .map((doc) => LeaderboardEntry.fromFirestore(doc))
            .toList();

        return StreamBuilder<QuerySnapshot>(
          stream: ScoreService.getLeaderboardStream(categoryValue, DisciplineType.boulder),
          builder: (context, boulderSnapshot) {
            if (boulderSnapshot.hasError) {
              print('Boulder leaderboard error: ${boulderSnapshot.error}');
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${boulderSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            if (boulderSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final boulderDocs = boulderSnapshot.data?.docs ?? [];
            final boulderEntries = boulderDocs
                .map((doc) => LeaderboardEntry.fromFirestore(doc))
                .toList();

            // Combine scores and sort by total
            final combinedEntries = <LeaderboardEntry>[];
            for (final entry in topRopeEntries) {
              final boulderEntry = boulderEntries.firstWhere(
                (e) => e.competitorId == entry.competitorId,
                orElse: () => LeaderboardEntry(
                  competitorId: entry.competitorId,
                  competitorName: entry.competitorName,
                  totalScore: 0,
                  completedRoutes: 0,
                  totalAttempts: 0,
                  lastUpdated: DateTime.now(),
                ),
              );
              int combinedScore;
              if (entry.totalScore > 0 && boulderEntry.totalScore > 0) {
                combinedScore = entry.totalScore * boulderEntry.totalScore;
              } else if (entry.totalScore > 0) {
                combinedScore = entry.totalScore;
              } else if (boulderEntry.totalScore > 0) {
                combinedScore = boulderEntry.totalScore;
              } else {
                combinedScore = 0;
              }
              combinedEntries.add(LeaderboardEntry(
                competitorId: entry.competitorId,
                competitorName: entry.competitorName,
                totalScore: combinedScore,
                completedRoutes: entry.completedRoutes + boulderEntry.completedRoutes,
                totalAttempts: entry.totalAttempts + boulderEntry.totalAttempts,
                lastUpdated: entry.lastUpdated.isAfter(boulderEntry.lastUpdated)
                    ? entry.lastUpdated
                    : boulderEntry.lastUpdated,
              ));
            }

            combinedEntries.sort((a, b) => b.totalScore.compareTo(a.totalScore));

            return ListView.builder(
              itemCount: combinedEntries.length,
              itemBuilder: (context, index) {
                final entry = combinedEntries[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      entry.competitorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Bib #${entry.competitorId}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Score: ${entry.totalScore}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Routes: ${entry.completedRoutes}/${_maxTopRopeRoutes + _maxBoulderRoutes}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
} 