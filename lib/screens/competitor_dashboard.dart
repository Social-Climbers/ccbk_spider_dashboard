import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/scoring_page.dart';
import 'package:ccbk_spider_kids_comp/services/local_storage_service.dart';
import 'package:ccbk_spider_kids_comp/services/score_service.dart';
import 'package:ccbk_spider_kids_comp/screens/settings_page.dart';
import 'package:ccbk_spider_kids_comp/screens/leaderboard_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompetitorDashboard extends StatefulWidget {
  const CompetitorDashboard({super.key});

  @override
  State<CompetitorDashboard> createState() => _CompetitorDashboardState();
}

class _CompetitorDashboardState extends State<CompetitorDashboard> {
  String? _competitorId;
  String? _category;
  String? _competitorName;
  bool _hasSubmittedScore = false;
  bool _isLoading = true;
  bool _isTopRopeCompleted = false;
  bool _isBoulderCompleted = false;
  DateTime? _topRopeCompletionTime;
  DateTime? _boulderCompletionTime;

  @override
  void initState() {
    super.initState();
    _loadCompetitorId();
  }

  Future<void> _loadCompetitorId() async {
    try {
      final id = await LocalStorageService.getCompetitorId();
      if (id != null) {
        setState(() {
          _competitorId = id.toString();
        });
        await _loadCompetitorDetails();
        await _loadCompletionStatus();
      }
    } catch (e) {
      print('Error loading competitor ID: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCompetitorDetails() async {
    if (_competitorId == null) return;
    
    try {
      final doc = await FirebaseFirestore.instance
          .collection('competitors')
          .doc(_competitorId)
          .get();
      
      if (doc.exists) {
        setState(() {
          _category = doc.data()?['category'] as String? ?? 'all';
          _competitorName = doc.data()?['name'] as String? ?? 'Unknown';
        });
      }
    } catch (e) {
      print('Error loading competitor details: $e');
    }
  }

  Future<void> _loadCompletionStatus() async {
    if (_competitorId == null) return;

    try {
      final topRopeDoc = await FirebaseFirestore.instance
          .collection('competitors')
          .doc(_competitorId)
          .collection('completion_status')
          .doc('topRope')
          .get();

      final boulderDoc = await FirebaseFirestore.instance
          .collection('competitors')
          .doc(_competitorId)
          .collection('completion_status')
          .doc('boulder')
          .get();

      setState(() {
        _isTopRopeCompleted = topRopeDoc.exists && topRopeDoc.data()?['completed'] == true;
        _isBoulderCompleted = boulderDoc.exists && boulderDoc.data()?['completed'] == true;
        _topRopeCompletionTime = topRopeDoc.exists ? (topRopeDoc.data()?['completionTime'] as Timestamp?)?.toDate() : null;
        _boulderCompletionTime = boulderDoc.exists ? (boulderDoc.data()?['completionTime'] as Timestamp?)?.toDate() : null;
      });
    } catch (e) {
      print('Error loading completion status: $e');
    }
  }

  Future<void> _submitScore() async {
    if (_competitorId == null) return;

    try {
      // Update competitor's completion status
      await FirebaseFirestore.instance
          .collection('competitors')
          .doc(_competitorId)
          .collection('completion_status')
          .doc('topRope')
          .set({
        'completed': true,
        'completionTime': FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore.instance
          .collection('competitors')
          .doc(_competitorId)
          .collection('completion_status')
          .doc('boulder')
          .set({
        'completed': true,
        'completionTime': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isTopRopeCompleted = true;
        _isBoulderCompleted = true;
        _topRopeCompletionTime = DateTime.now();
        _boulderCompletionTime = DateTime.now();
        _hasSubmittedScore = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scores submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate to leaderboard after successful submission
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LeaderboardPage(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting scores: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTitleSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${_competitorName?.split(' ').first ?? 'Climber'}! 🧗‍♂️',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitorHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _competitorName ?? 'Loading...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tag,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${_competitorId ?? '...'}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _category == 'kidsABoy' ? 'Kids A Boys' :
                                _category == 'kidsAGirl' ? 'Kids A Girls' :
                                _category == 'kidsBBoy' ? 'Kids B Boys' :
                                _category == 'kidsBGirl' ? 'Kids B Girls' :
                                _category == 'kidsCBoy' ? 'Kids C Boys' :
                                _category == 'kidsCGirl' ? 'Kids C Girls' :
                                (_category ?? '...'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('scores')
                .where('competitorId', isEqualTo: _competitorId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError || !snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final docs = snapshot.data?.docs ?? [];
              final totalCompletedRoutes = docs.where((doc) => doc['isCompleted'] == true).length;
              
              // Calculate separate scores for top rope and boulder
              final topRopeScore = docs
                  .where((doc) => doc['isCompleted'] == true && doc['type'] == 'topRope')
                  .map((doc) => doc['points'] as int)
                  .fold<int>(0, (sum, points) => sum + points);
              
              final boulderScore = docs
                  .where((doc) => doc['isCompleted'] == true && doc['type'] == 'boulder')
                  .map((doc) => doc['points'] as int)
                  .fold<int>(0, (sum, points) => sum + points);
              
              // Calculate total score by multiplying the two scores
              final totalScore = topRopeScore * boulderScore;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Routes',
                      totalCompletedRoutes.toString(),
                      Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Score',
                      totalScore.toString(),
                      Icons.stars,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisciplineCard({
    required String title,
    required String description,
    required IconData icon,
    required DisciplineType type,
    required Color primaryColor,
    required Color secondaryColor,
  }) {
    final isCompleted = type == DisciplineType.topRope ? _isTopRopeCompleted : _isBoulderCompleted;
    final completionTime = type == DisciplineType.topRope ? _topRopeCompletionTime : _boulderCompletionTime;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScoringPage(type: type),
                    ),
                  ).then((_) {
                    setState(() {
                      _loadCompetitorDetails();
                    });
                  });
                },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(
                        type == DisciplineType.topRope ? 'assets/images/toperope.png' : 'assets/images/boulder.png',
                        width: 31,
                        height: 31,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_competitorId != null)
                  FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('scores')
                        .where('competitorId', isEqualTo: _competitorId)
                        .where('type', isEqualTo: type == DisciplineType.topRope ? 'topRope' : 'boulder')
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        print('Error loading scores: ${snapshot.error}');
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Error loading score',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final docs = snapshot.data?.docs ?? [];
                      final completedRoutes = docs.where((doc) => doc['isCompleted'] == true).length;
                      final totalScore = docs
                          .where((doc) => doc['isCompleted'] == true)
                          .map((doc) => doc['points'] as int)
                          .fold<int>(0, (sum, points) => sum + points);

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Completed Routes',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$completedRoutes',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Total Score',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        totalScore.toString(),
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isCompleted)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Completed ${completionTime != null ? 'at ${completionTime.hour}:${completionTime.minute.toString().padLeft(2, '0')}' : ''}',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ScoringPage(type: type),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      _loadCompetitorDetails();
                                    });
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Go to Score Card',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
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

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Spider Kids 2025',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: SizedBox(
            height: 40,
            child: Image.asset(
              'assets/images/ccbklogo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.grey[900],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
           
            _buildCompetitorHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  _buildDisciplineCard(
                    title: 'Top Rope',
                    description: 'Complete as many top rope routes as possible',
                    icon: Icons.vertical_align_top,
                    type: DisciplineType.topRope,
                    primaryColor: Colors.blue,
                    secondaryColor: Colors.cyan,
                  ),
                  _buildDisciplineCard(
                    title: 'Boulder',
                    description: 'Complete as many boulder problems as possible',
                    icon: Icons.rocket_launch,
                    type: DisciplineType.boulder,
                    primaryColor: Colors.orange,
                    secondaryColor: Colors.amber,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (!_isTopRopeCompleted || !_isBoulderCompleted)
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please only tap when you are finished',
                                  style: TextStyle(
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final shouldSubmit = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Submission'),
                                  content: const Text('Are you sure you want to submit your scores? This action cannot be undone.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Finish'),
                                    ),
                                  ],
                                ),
                              );
                              
                              if (shouldSubmit == true) {
                                _submitScore();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Finish',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'All scores submitted',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LeaderboardPage(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'View Leaderboard',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 