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
  // Constants for consistent styling
  static const _maxTopRopeAttempts = 3;
  static const _maxRoutesForScore = 10;
  static const _minAttempts = 0;
  
  int _totalScore = 0;
  int _completedRoutes = 0;
  List<RouteScore>? _sortedCompletedRoutes;

  @override
  void initState() {
    super.initState();
    _calculateScore();
  }

  @override
  void didUpdateWidget(ScoringPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scores != widget.scores) {
      _calculateScore();
    }
  }

  void _calculateScore() {
    _sortedCompletedRoutes = widget.scores
        .where((score) => score.isCompleted)
        .toList()
      ..sort((a, b) => b.routeNumber.compareTo(a.routeNumber));
    
    _completedRoutes = _sortedCompletedRoutes!.length;
    _totalScore = _sortedCompletedRoutes!
        .take(_maxRoutesForScore)
        .fold(0, (sum, score) => sum + score.points);
  }

  Future<void> _showCompletionDialog(RouteScore score) async {
    String title;
    String content;
    if (score.isCompleted) {
      title = 'Undo Route ${score.routeNumber}?';
      content = 'This will remove the completion status of this route. Are you sure?';
    } else {
      title = 'Complete Route ${score.routeNumber}?';
      content = 'Are you sure you want to mark this route as completed?';
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                score.isCompleted ? 'Undo' : 'Complete',
                style: TextStyle(
                  color: score.isCompleted ? Colors.red : Colors.deepOrange,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      try {
        widget.onScoreUpdate(
          score.routeNumber,
          !score.isCompleted,
          score.attempts,
        );
        setState(() {
          _calculateScore();
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update score: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _updateAttempts(RouteScore score, int newAttempts) {
    if (newAttempts < _minAttempts) return;
    if (widget.type == DisciplineType.topRope && newAttempts > _maxTopRopeAttempts) return;

    try {
      widget.onScoreUpdate(
        score.routeNumber,
        score.isCompleted,
        newAttempts,
      );
      setState(() {
        _calculateScore();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update attempts: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    final isLandscape = screenWidth > screenHeight;
    final textScale = isSmallScreen ? 0.85 : (isTablet ? 1.2 : 1.0);
    final padding = screenWidth < 400 ? 8.0 : (isTablet ? 24.0 : 16.0);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Please use a mobile device',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This app is designed for mobile devices only.\nPlease open it on your phone or tablet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isLandscape) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.screen_rotation,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                'Please rotate your device',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This app works best in portrait mode.\nPlease rotate your device back to vertical.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: Text(
          widget.type == DisciplineType.topRope ? 'Top Rope' : 'Boulder',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : (isTablet ? 24 : 20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (isDesktop)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: Colors.amber[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber[800],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'This app is designed for mobile devices. Some features may not work as expected on desktop.',
                    style: TextStyle(
                      color: Colors.amber[900],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(top: isDesktop ? 40 : 0),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, isTablet ? 120 : 80),
              itemCount: widget.scores.length,
              itemBuilder: (context, index) {
                final score = widget.scores[index];
                return _RouteCard(
                  routeNumber: score.routeNumber,
                  score: score,
                  textScale: textScale,
                  isTablet: isTablet,
                  type: widget.type,
                  onAttemptsUpdate: (newAttempts) => _updateAttempts(score, newAttempts),
                  onCompletionToggle: () => _showCompletionDialog(score),
                );
              },
            ),
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
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: isTablet ? 24 : 20,
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 20,
                          vertical: isTablet ? 20 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Total\nScore',
                                  style: TextStyle(
                                    fontSize: (isTablet ? 16 : 14) * textScale,
                                    color: Colors.grey[600],
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isTablet ? 12 : 8),
                                Text(
                                  _totalScore.toString(),
                                  style: TextStyle(
                                    fontSize: (isTablet ? 36 : 28) * textScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: isTablet ? 48 : 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Completed\nRoutes',
                                  style: TextStyle(
                                    fontSize: (isTablet ? 16 : 14) * textScale,
                                    color: Colors.grey[600],
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isTablet ? 12 : 8),
                                Text(
                                  '$_completedRoutes/15',
                                  style: TextStyle(
                                    fontSize: (isTablet ? 36 : 28) * textScale,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: isTablet ? 32 : 24),
                    SizedBox(
                      width: isTablet ? 160 : 120,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                            child: Text(
                              'Must tap\nwhen finish',
                              style: TextStyle(
                                fontSize: (isTablet ? 14 : 12) * textScale,
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Implement score submission
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 36 : 28,
                                vertical: isTablet ? 20 : 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Submit Score',
                              style: TextStyle(
                                fontSize: (isTablet ? 22 : 18) * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
}

class _RouteCard extends StatelessWidget {
  final int routeNumber;
  final RouteScore score;
  final double textScale;
  final bool isTablet;
  final DisciplineType type;
  final Function(int) onAttemptsUpdate;
  final VoidCallback onCompletionToggle;

  const _RouteCard({
    required this.routeNumber,
    required this.score,
    required this.textScale,
    required this.isTablet,
    required this.type,
    required this.onAttemptsUpdate,
    required this.onCompletionToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Route $routeNumber',
                  style: TextStyle(
                    fontSize: (isTablet ? 22 : 18) * textScale,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${score.points} points',
                  style: TextStyle(
                    fontSize: (isTablet ? 20 : 16) * textScale,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Attempts',
                        style: TextStyle(
                          fontSize: (isTablet ? 16 : 14) * textScale,
                          color: Colors.grey[600],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove_circle_outline,
                              size: isTablet ? 32 : 24,
                            ),
                            onPressed: score.attempts > 0
                                ? () => onAttemptsUpdate(score.attempts - 1)
                                : null,
                            tooltip: score.attempts > 0 ? 'Decrease attempts' : 'Minimum attempts reached',
                          ),
                          Text(
                            '${score.attempts}',
                            style: TextStyle(
                              fontSize: (isTablet ? 20 : 16) * textScale,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle_outline,
                              size: isTablet ? 32 : 24,
                            ),
                            onPressed: type == DisciplineType.topRope && score.attempts >= _ScoringPageState._maxTopRopeAttempts
                                ? null
                                : () => onAttemptsUpdate(score.attempts + 1),
                            tooltip: type == DisciplineType.topRope && score.attempts >= _ScoringPageState._maxTopRopeAttempts
                                ? 'Maximum 3 attempts allowed for Top Rope'
                                : 'Add attempt',
                          ),
                          if (type == DisciplineType.topRope && score.attempts >= _ScoringPageState._maxTopRopeAttempts)
                            Text(
                              '(max 3)',
                              style: TextStyle(
                                fontSize: (isTablet ? 14 : 12) * textScale,
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
                        fontSize: (isTablet ? 16 : 14) * textScale,
                        color: Colors.grey[600],
                      ),
                    ),
                    GestureDetector(
                      onTap: type == DisciplineType.topRope && score.attempts >= _ScoringPageState._maxTopRopeAttempts
                          ? null
                          : onCompletionToggle,
                      child: Container(
                        width: isTablet ? 36 : 28,
                        height: isTablet ? 36 : 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: score.isCompleted
                              ? Colors.deepOrange
                              : Colors.grey[200],
                          border: Border.all(
                            color: score.isCompleted
                                ? Colors.deepOrange
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: score.isCompleted
                            ? Icon(
                                Icons.check,
                                color: Colors.white,
                                size: isTablet ? 24 : 20,
                              )
                            : null,
                      ),
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