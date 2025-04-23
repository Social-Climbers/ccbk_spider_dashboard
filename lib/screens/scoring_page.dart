import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/firebase_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

enum DisciplineType {
  topRope,
  boulder,
}

class ScoringPage extends StatefulWidget {
  final DisciplineType type;
  final int competitorId;

  const ScoringPage({
    super.key,
    required this.type,
    required this.competitorId,
  });

  @override
  State<ScoringPage> createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  final _firebaseService = FirebaseService();
  late Stream<Competitor> _competitorStream;

  @override
  void initState() {
    super.initState();
    _competitorStream = _firebaseService.getCompetitorStream(widget.competitorId);
  }

  Future<void> _updateScore(int routeNumber, bool isCompleted, int attempts) async {
    try {
      final competitor = await _firebaseService.getCompetitor(widget.competitorId);
      if (competitor == null) return;

      final scores = widget.type == DisciplineType.topRope
          ? competitor.topRopeScores
          : competitor.boulderScores;

      final index = scores.indexWhere((score) => score.routeNumber == routeNumber);
      if (index == -1) return;

      final updatedScore = RouteScore(
        routeNumber: routeNumber,
        isCompleted: isCompleted,
        attempts: attempts,
        points: RouteScore.getPointsForRoute(routeNumber),
      );

      final updatedScores = List<RouteScore>.from(scores);
      updatedScores[index] = updatedScore;

      await _firebaseService.saveCompetitorScores(
        widget.competitorId,
        widget.type == DisciplineType.topRope ? updatedScores : competitor.topRopeScores,
        widget.type == DisciplineType.boulder ? updatedScores : competitor.boulderScores,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update score: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type == DisciplineType.topRope ? 'Top Rope' : 'Boulder'),
      ),
      body: Column(
        children: [
          const SponsorBar(),
          Expanded(
            child: StreamBuilder<Competitor>(
              stream: _competitorStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final scores = widget.type == DisciplineType.topRope
                    ? snapshot.data!.topRopeScores
                    : snapshot.data!.boulderScores;

                return SingleChildScrollView(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    children: [
                      _buildScoreSummary(scores, textScale),
                      const SizedBox(height: 24),
                      ...scores.map((score) => _buildRouteCard(
                            score,
                            textScale,
                            (isCompleted, attempts) => _updateScore(
                              score.routeNumber,
                              isCompleted,
                              attempts,
                            ),
                          )),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreSummary(List<RouteScore> scores, double textScale) {
    final totalScore = scores.fold(0, (sum, score) => sum + score.points);
    final completedRoutes = scores.where((score) => score.isCompleted).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Total Score',
              style: TextStyle(
                fontSize: 18 * textScale,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              totalScore.toString(),
              style: TextStyle(
                fontSize: 36 * textScale,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Completed',
                  completedRoutes.toString(),
                  Icons.check_circle,
                  textScale,
                ),
                _buildStatItem(
                  'Remaining',
                  (scores.length - completedRoutes).toString(),
                  Icons.circle_outlined,
                  textScale,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, double textScale) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[600], size: 24 * textScale),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12 * textScale,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18 * textScale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard(
    RouteScore score,
    double textScale,
    Function(bool, int) onScoreUpdate,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Route ${score.routeNumber}',
                  style: TextStyle(
                    fontSize: 18 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${score.points} points',
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttemptCounter(
                    score.attempts,
                    (attempts) => onScoreUpdate(score.isCompleted, attempts),
                    textScale,
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: score.isCompleted,
                  onChanged: (value) => onScoreUpdate(value, score.attempts),
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    fontSize: 14 * textScale,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptCounter(
    int attempts,
    Function(int) onAttemptsUpdate,
    double textScale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attempts',
          style: TextStyle(
            fontSize: 14 * textScale,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: () => onAttemptsUpdate(attempts - 1),
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              attempts.toString(),
              style: TextStyle(
                fontSize: 18 * textScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => onAttemptsUpdate(attempts + 1),
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey[200],
              ),
            ),
          ],
        ),
      ],
    );
  }
} 