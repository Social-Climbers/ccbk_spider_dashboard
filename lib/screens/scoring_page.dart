import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';

enum DisciplineType {
  topRope,
  boulder,
}

class ScoringPage extends StatefulWidget {
  final DisciplineType type;
  final List<RouteScore> scores;
  final Function(int routeNumber, bool isCompleted, int attempts) onScoreUpdate;

  const ScoringPage({
    super.key,
    required this.type,
    required this.scores,
    required this.onScoreUpdate,
  });

  @override
  State<ScoringPage> createState() => _ScoringPageState();
}

class _ScoringPageState extends State<ScoringPage> {
  int _totalScore = 0;
  int _completedRoutes = 0;

  @override
  void initState() {
    super.initState();
    _calculateScore();
  }

  void _calculateScore() {
    var completedRoutes = widget.scores
        .where((score) => score.isCompleted)
        .toList()
      ..sort((a, b) => b.routeNumber.compareTo(a.routeNumber));
    
    _completedRoutes = completedRoutes.length;
    _totalScore = completedRoutes
        .take(10)
        .fold(0, (sum, score) => sum + score.points);
  }

  Future<void> _showCompletionDialog(RouteScore score) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Mark Route ${score.routeNumber} as ${score.isCompleted ? 'incomplete' : 'complete'}?'),
          content: Text(
            score.isCompleted
                ? 'This will mark the route as not completed.'
                : 'Are you sure you want to mark this route as completed?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      widget.onScoreUpdate(
        score.routeNumber,
        !score.isCompleted,
        score.attempts,
      );
      setState(() {
        _calculateScore();
      });
    }
  }

  void _updateAttempts(RouteScore score, int newAttempts) {
    widget.onScoreUpdate(
      score.routeNumber,
      score.isCompleted,
      newAttempts,
    );
    setState(() {
      _calculateScore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 8.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.type == DisciplineType.topRope ? 'Top Rope' : 'Boulder',
          style: TextStyle(fontSize: isSmallScreen ? 18 : 20),
        ),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: EdgeInsets.fromLTRB(padding, padding, padding, 80),
            itemCount: widget.scores.length,
            itemBuilder: (context, index) {
              final score = widget.scores[index];
              final routeNumber = score.routeNumber;
              return _buildRouteCard(
                routeNumber: routeNumber,
                score: score,
                textScale: textScale,
              );
            },
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Score',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          _totalScore.toString(),
                          style: TextStyle(
                            fontSize: 24 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Completed Routes',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          '$_completedRoutes/15',
                          style: TextStyle(
                            fontSize: 24 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  Widget _buildRouteCard({
    required int routeNumber,
    required RouteScore score,
    required double textScale,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Route $routeNumber',
                  style: TextStyle(
                    fontSize: 18 * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${score.points} points',
                  style: TextStyle(
                    fontSize: 16 * textScale,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attempts',
                        style: TextStyle(
                          fontSize: 14 * textScale,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: score.attempts > 0
                                ? () => _updateAttempts(score, score.attempts - 1)
                                : null,
                          ),
                          Text(
                            '${score.attempts}',
                            style: TextStyle(fontSize: 16 * textScale),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: widget.type == DisciplineType.topRope && score.attempts >= 3
                                ? null
                                : () => _updateAttempts(score, score.attempts + 1),
                          ),
                          if (widget.type == DisciplineType.topRope && score.attempts >= 3)
                            Text(
                              '(max 3)',
                              style: TextStyle(
                                fontSize: 12 * textScale,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 14 * textScale,
                        color: Colors.grey[600],
                      ),
                    ),
                    Switch(
                      value: score.isCompleted,
                      onChanged: widget.type == DisciplineType.topRope && score.attempts >= 3
                          ? null
                          : (value) => _showCompletionDialog(score),
                      activeColor: widget.type == DisciplineType.topRope && score.attempts >= 3
                          ? Colors.red
                          : Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 