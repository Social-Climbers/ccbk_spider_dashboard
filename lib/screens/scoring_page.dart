import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/score_service.dart';
import 'package:ccbk_spider_kids_comp/services/local_storage_service.dart';

enum DisciplineType {
  topRope,
  boulder,
}

class ScoringPage extends StatefulWidget {
  final DisciplineType type;

  const ScoringPage({
    super.key,
    required this.type,
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
  int? _competitorId;
  late Stream<List<RouteScore>> _scoresStream;

  @override
  void initState() {
    super.initState();
    _loadCompetitorId();
  }

  Future<void> _loadCompetitorId() async {
    try {
      final id = await LocalStorageService.getCompetitorId();
      print('Loaded competitor ID: $id');
      if (id != null) {
        setState(() {
          _competitorId = id;
          _scoresStream = ScoreService.getScoresStream(id, widget.type);
        });
      } else {
        print('No competitor ID found in local storage');
      }
    } catch (e) {
      print('Error loading competitor ID: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading competitor ID: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateScore(List<RouteScore> scores) {
    print('Calculating score for ${scores.length} routes');
    _sortedCompletedRoutes = scores
        .where((score) => score.isCompleted)
        .toList()
      ..sort((a, b) => b.routeNumber.compareTo(a.routeNumber));
    
    _completedRoutes = _sortedCompletedRoutes!.length;
    _totalScore = _sortedCompletedRoutes!
        .take(_maxRoutesForScore)
        .fold(0, (sum, score) => sum + score.points);
    print('Calculated score: $_totalScore, completed routes: $_completedRoutes');
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false && _competitorId != null) {
      try {
        // If marking as completed and attempts is 0, increment to 1
        final newAttempts = !score.isCompleted && score.attempts == 0 ? 1 : score.attempts;
        
        await ScoreService.updateScore(
          _competitorId!,
          widget.type,
          score.routeNumber,
          !score.isCompleted,
          newAttempts,
        );
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

    if (_competitorId != null) {
      try {
        ScoreService.updateScore(
          _competitorId!,
          widget.type,
          score.routeNumber,
          score.isCompleted,
          newAttempts,
        );
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

    if (_competitorId == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
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
      body: StreamBuilder<List<RouteScore>>(
        stream: _scoresStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('Stream error: ${snapshot.error}');
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

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No data in snapshot');
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No scores found. Please try again later.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final scores = snapshot.data!;
          print('Received ${scores.length} scores from stream');
          _calculateScore(scores);

          return Stack(
            children: [
              Column(
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    color: Colors.blue[50],
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Remember to record the number of attempts for each route, even if not completed. This is important for scoring!',
                            style: TextStyle(
                              color: Colors.blue[900],
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(padding, padding, padding, isTablet ? 120 : 80),
                      itemCount: scores.length,
                      itemBuilder: (context, index) {
                        final score = scores[index];
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
                ],
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
                    vertical: isTablet ? 16 : 12,
                  ),
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 12 : 8,
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
                                  fontSize: (isTablet ? 14 : 12) * textScale,
                                  color: Colors.grey[600],
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isTablet ? 8 : 4),
                              Text(
                                _totalScore.toString(),
                                style: TextStyle(
                                  fontSize: (isTablet ? 28 : 24) * textScale,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: isTablet ? 40 : 32,
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
                                  fontSize: (isTablet ? 14 : 12) * textScale,
                                  color: Colors.grey[600],
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: isTablet ? 8 : 4),
                              Text(
                                '$_completedRoutes/15',
                                style: TextStyle(
                                  fontSize: (isTablet ? 28 : 24) * textScale,
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
              ),
            ],
          );
        },
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
                      onTap: type == DisciplineType.topRope && routeNumber <= 3
                          ? null
                          : onCompletionToggle,
                      child: Container(
                        width: isTablet ? 36 : 28,
                        height: isTablet ? 36 : 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: score.isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[200],
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
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