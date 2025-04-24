import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccbk_spider_kids_comp/models/leaderboard_entry.dart';
import 'package:ccbk_spider_kids_comp/services/score_service.dart';
import 'package:ccbk_spider_kids_comp/screens/scoring_page.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'Kids A (2011-2012)';
  List<String> _categories = [];

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
        'Kids A (2011-2012)',
        'Kids B (2013-2014)',
        'Kids C (2015-2018)',
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
    if (displayName.contains('Kids A')) {
      categoryValue = 'kidsA';
    } else if (displayName.contains('Kids B')) {
      categoryValue = 'kidsB';
    } else if (displayName.contains('Kids C')) {
      categoryValue = 'kidsC';
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
        
        entries.sort((a, b) {
          // For top rope, only sort by score
          if (type == DisciplineType.topRope) {
            return b.totalScore.compareTo(a.totalScore);
          }
          
          // For boulder, sort by score first, then attempts
          final scoreComparison = b.totalScore.compareTo(a.totalScore);
          if (scoreComparison != 0) return scoreComparison;
          return a.totalAttempts.compareTo(b.totalAttempts);
        });

        if (entries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No scores yet',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to complete a route!',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            final rank = index + 1;
            final isTopThree = rank <= 3;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Rank with medal for top 3
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isTopThree 
                          ? _getRankColor(rank).withOpacity(0.1)
                          : Colors.grey[100],
                        shape: BoxShape.circle,
                        border: isTopThree ? Border.all(
                          color: _getRankColor(rank),
                          width: 2,
                        ) : null,
                      ),
                      child: Center(
                        child: isTopThree
                          ? Text(
                              rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                              style: const TextStyle(fontSize: 16),
                            )
                          : Text(
                              rank.toString(),
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Climber info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.competitorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${entry.completedRoutes} routes',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                ' • ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${entry.totalAttempts} attempts',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Score
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entry.totalScore.toString(),
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
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

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[700]!;
      case 2:
        return Colors.blueGrey[400]!;
      case 3:
        return Colors.brown[400]!;
      default:
        return Colors.grey[400]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final textScale = isSmallScreen ? 0.85 : (isTablet ? 1.2 : 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
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

            final topRopeDocs = topRopeSnapshot.data?.docs ?? [];
            final boulderDocs = boulderSnapshot.data?.docs ?? [];

            // Create a map of competitor IDs to their combined scores
            final Map<String, LeaderboardEntry> combinedEntries = {};
            
            // Process top rope entries
            for (var doc in topRopeDocs) {
              final entry = LeaderboardEntry.fromFirestore(doc);
              combinedEntries[entry.competitorId] = LeaderboardEntry(
                competitorId: entry.competitorId,
                competitorName: entry.competitorName,
                totalScore: entry.totalScore,
                completedRoutes: entry.completedRoutes,
                totalAttempts: entry.totalAttempts,
                lastUpdated: entry.lastUpdated,
              );
            }

            // Add boulder scores to the combined entries
            for (var doc in boulderDocs) {
              final entry = LeaderboardEntry.fromFirestore(doc);
              if (combinedEntries.containsKey(entry.competitorId)) {
                final existingEntry = combinedEntries[entry.competitorId]!;
                combinedEntries[entry.competitorId] = LeaderboardEntry(
                  competitorId: entry.competitorId,
                  competitorName: entry.competitorName,
                  totalScore: existingEntry.totalScore + entry.totalScore,
                  completedRoutes: existingEntry.completedRoutes + entry.completedRoutes,
                  totalAttempts: existingEntry.totalAttempts + entry.totalAttempts,
                  lastUpdated: entry.lastUpdated.isAfter(existingEntry.lastUpdated)
                      ? entry.lastUpdated
                      : existingEntry.lastUpdated,
                );
              } else {
                combinedEntries[entry.competitorId] = entry;
              }
            }

            final entries = combinedEntries.values.toList()
              ..sort((a, b) {
                // First sort by total score (higher is better)
                final scoreComparison = b.totalScore.compareTo(a.totalScore);
                if (scoreComparison != 0) return scoreComparison;
                
                // If scores are equal, sort by attempts (fewer is better)
                return a.totalAttempts.compareTo(b.totalAttempts);
              });

            if (entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No scores yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Be the first to complete a route!',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final rank = index + 1;
                final isTopThree = rank <= 3;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Rank with medal for top 3
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isTopThree 
                              ? _getRankColor(rank).withOpacity(0.1)
                              : Colors.grey[100],
                            shape: BoxShape.circle,
                            border: isTopThree ? Border.all(
                              color: _getRankColor(rank),
                              width: 2,
                            ) : null,
                          ),
                          child: Center(
                            child: isTopThree
                              ? Text(
                                  rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                                  style: const TextStyle(fontSize: 16),
                                )
                              : Text(
                                  rank.toString(),
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Climber info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.competitorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    '${entry.completedRoutes} routes',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    ' • ',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    '${entry.totalAttempts} attempts',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Score
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            entry.totalScore.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
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