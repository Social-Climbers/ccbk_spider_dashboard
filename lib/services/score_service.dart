import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/screens/scoring_page.dart';

class ScoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Stream<List<RouteScore>> getScoresStream(int competitorId, DisciplineType type) {
    print('Getting scores stream for competitor $competitorId, type: $type');
    try {
      return _firestore
          .collection('scores')
          .where('competitorId', isEqualTo: competitorId.toString())
          .where('type', isEqualTo: type == DisciplineType.topRope ? 'topRope' : 'boulder')
          .orderBy('routeNumber')
          .snapshots()
          .handleError((error) {
            print('Stream error: $error');
            if (error.toString().contains('index')) {
              print('''
Firestore requires a composite index for this query. Please create the index with these fields:
- Collection: scores
- Fields:
  - competitorId (Ascending)
  - type (Ascending)
  - routeNumber (Ascending)
You can create it by clicking the link in the error message above.
''');
            }
            throw error;
          })
          .map((snapshot) {
            print('Received ${snapshot.docs.length} scores from Firestore');
            return snapshot.docs
                .map((doc) => RouteScore(
                      routeNumber: doc['routeNumber'],
                      isCompleted: doc['isCompleted'],
                      attempts: doc['attempts'],
                      points: doc['points'],
                    ))
                .toList();
          });
    } catch (e) {
      print('Error creating stream: $e');
      rethrow;
    }
  }

  static Future<void> updateScore(
    int competitorId,
    DisciplineType type,
    int routeNumber,
    bool isCompleted,
    int attempts,
  ) async {
    print('Updating score for competitor $competitorId, route $routeNumber');
    
    // Get competitor data for denormalization
    final competitorDoc = await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .get();
    
    if (!competitorDoc.exists) {
      throw Exception('Competitor not found');
    }

    final competitorData = competitorDoc.data()!;
    
    // Update the score
    await _firestore
        .collection('scores')
        .doc('${competitorId}_${type == DisciplineType.topRope ? 'topRope' : 'boulder'}_$routeNumber')
        .set({
      'competitorId': competitorId.toString(),
      'competitorName': competitorData['name'],
      'category': competitorData['category'],
      'type': type == DisciplineType.topRope ? 'topRope' : 'boulder',
      'routeNumber': routeNumber,
      'isCompleted': isCompleted,
      'attempts': attempts,
      'points': RouteScore.getPointsForRoute(routeNumber),
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update leaderboard
    await _updateLeaderboard(competitorId, type, competitorData['category']);
  }

  static Future<void> _updateLeaderboard(int competitorId, DisciplineType type, String category) async {
    try {
      print('Updating leaderboard for competitor $competitorId, category: $category, type: ${type == DisciplineType.topRope ? 'topRope' : 'boulder'}');
      
      // Get all scores for this competitor and type
      final scoresSnapshot = await _firestore
          .collection('scores')
          .where('competitorId', isEqualTo: competitorId.toString())
          .where('type', isEqualTo: type == DisciplineType.topRope ? 'topRope' : 'boulder')
          .get();

      final scores = scoresSnapshot.docs;
      final completedRoutes = scores.where((doc) => doc['isCompleted']).length;
      final totalScore = scores
          .where((doc) => doc['isCompleted'])
          .map((doc) => doc['points'] as int)
          .fold(0, (sum, points) => sum + points);
      final totalAttempts = scores
          .map((doc) => doc['attempts'] as int)
          .fold(0, (sum, attempts) => sum + attempts);

      print('Calculated scores - completed routes: $completedRoutes, total score: $totalScore, total attempts: $totalAttempts');

      // Ensure the category document exists
      final categoryDoc = _firestore.collection('leaderboard').doc(category);
      await categoryDoc.set({}, SetOptions(merge: true));

      // Debug: Print the full Firestore path for the leaderboard entry
      final entryPath = 'leaderboard/$category/${type == DisciplineType.topRope ? 'topRope' : 'boulder'}/$competitorId';
      print('Updating leaderboard entry at path: $entryPath');

      // Update leaderboard with discipline-specific score
      await categoryDoc
          .collection(type == DisciplineType.topRope ? 'topRope' : 'boulder')
          .doc(competitorId.toString())
          .set({
        'competitorId': competitorId.toString(),
        'competitorName': scores.first['competitorName'],
        'totalScore': totalScore,
        'completedRoutes': completedRoutes,
        'totalAttempts': totalAttempts,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      print('Successfully updated leaderboard entry');
    } catch (e) {
      print('Error updating leaderboard: $e');
      rethrow;
    }
  }

  static Future<bool> _checkScoresExist(int competitorId, String type) async {
    final snapshot = await _firestore
        .collection('scores')
        .where('competitorId', isEqualTo: competitorId.toString())
        .where('type', isEqualTo: type)
        .count()
        .get();
    return snapshot.count == 15;
  }

  static Future<void> initializeScores(int competitorId) async {
    print('Initializing scores for competitor $competitorId');
    
    // Get competitor data for denormalization
    final competitorDoc = await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .get();
    
    if (!competitorDoc.exists) {
      throw Exception('Competitor not found');
    }

    final competitorData = competitorDoc.data()!;
    
    // Check if scores already exist
    final topRopeExists = await _firestore
        .collection('scores')
        .doc('${competitorId}_topRope_1')
        .get()
        .then((doc) => doc.exists);
    
    final boulderExists = await _firestore
        .collection('scores')
        .doc('${competitorId}_boulder_1')
        .get()
        .then((doc) => doc.exists);

    // Initialize top rope scores if they don't exist
    if (!topRopeExists) {
      print('Initializing top rope scores...');
      for (int i = 1; i <= 15; i++) {  // 15 routes for top rope
        await _firestore
            .collection('scores')
            .doc('${competitorId}_topRope_$i')
            .set({
          'competitorId': competitorId.toString(),
          'competitorName': competitorData['name'],
          'category': competitorData['category'],
          'type': 'topRope',
          'routeNumber': i,
          'isCompleted': false,
          'attempts': 0,
          'points': RouteScore.getPointsForRoute(i),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }

    // Initialize boulder scores if they don't exist
    if (!boulderExists) {
      print('Initializing boulder scores...');
      for (int i = 1; i <= 16; i++) {  // 16 routes for boulder
        await _firestore
            .collection('scores')
            .doc('${competitorId}_boulder_$i')
            .set({
          'competitorId': competitorId.toString(),
          'competitorName': competitorData['name'],
          'category': competitorData['category'],
          'type': 'boulder',
          'routeNumber': i,
          'isCompleted': false,
          'attempts': 0,
          'points': RouteScore.getPointsForRoute(i),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }

    // Initialize leaderboard entries
    await _updateLeaderboard(competitorId, DisciplineType.topRope, competitorData['category']);
    await _updateLeaderboard(competitorId, DisciplineType.boulder, competitorData['category']);

    print('Finished initializing scores for competitor $competitorId');
  }

  // Leaderboard methods
  static Stream<QuerySnapshot> getLeaderboardStream(String category, DisciplineType type) {
    try {
      print('Getting leaderboard stream for category: $category, type: ${type == DisciplineType.topRope ? 'topRope' : 'boulder'}');
      final collectionPath = type == DisciplineType.topRope ? 'topRope' : 'boulder';
      
      // Debug: Print the full Firestore path
      final path = 'leaderboard/$category/$collectionPath';
      print('Querying Firestore path: $path');
      
      return _firestore
          .collection('leaderboard')
          .doc(category)
          .collection(collectionPath)
          .orderBy('totalScore', descending: true)
          .snapshots()
          .handleError((error) {
            print('Leaderboard stream error: $error');
            throw error;
          })
          .map((snapshot) {
            print('Received ${snapshot.docs.length} entries from leaderboard');
            return snapshot;
          });
    } catch (e) {
      print('Error creating leaderboard stream: $e');
      rethrow;
    }
  }

  static Future<void> resetScores(int competitorId) async {
    print('Resetting all scores for competitor $competitorId');
    
    // Get competitor data for denormalization
    final competitorDoc = await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .get();
    
    if (!competitorDoc.exists) {
      throw Exception('Competitor not found');
    }

    final competitorData = competitorDoc.data()!;
    
    // Reset top rope scores
    for (int i = 1; i <= 15; i++) {
      await _firestore
          .collection('scores')
          .doc('${competitorId}_topRope_$i')
          .set({
        'competitorId': competitorId.toString(),
        'competitorName': competitorData['name'],
        'category': competitorData['category'],
        'type': 'topRope',
        'routeNumber': i,
        'isCompleted': false,
        'attempts': 0,
        'points': RouteScore.getPointsForRoute(i),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Reset boulder scores
    for (int i = 1; i <= 16; i++) {
      await _firestore
          .collection('scores')
          .doc('${competitorId}_boulder_$i')
          .set({
        'competitorId': competitorId.toString(),
        'competitorName': competitorData['name'],
        'category': competitorData['category'],
        'type': 'boulder',
        'routeNumber': i,
        'isCompleted': false,
        'attempts': 0,
        'points': RouteScore.getPointsForRoute(i),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Reset completion status
    await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .collection('completion_status')
        .doc('topRope')
        .set({
      'completed': false,
      'completionTime': null,
    });

    await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .collection('completion_status')
        .doc('boulder')
        .set({
      'completed': false,
      'completionTime': null,
    });

    // Update leaderboard entries
    await _updateLeaderboard(competitorId, DisciplineType.topRope, competitorData['category']);
    await _updateLeaderboard(competitorId, DisciplineType.boulder, competitorData['category']);

    print('Successfully reset all scores for competitor $competitorId');
  }

  static Future<void> resetTopRopeScores(int competitorId) async {
    print('Resetting top rope scores for competitor $competitorId');
    
    // Get competitor data for denormalization
    final competitorDoc = await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .get();
    
    if (!competitorDoc.exists) {
      throw Exception('Competitor not found');
    }

    final competitorData = competitorDoc.data()!;
    
    // Reset top rope scores
    for (int i = 1; i <= 15; i++) {
      await _firestore
          .collection('scores')
          .doc('${competitorId}_topRope_$i')
          .set({
        'competitorId': competitorId.toString(),
        'competitorName': competitorData['name'],
        'category': competitorData['category'],
        'type': 'topRope',
        'routeNumber': i,
        'isCompleted': false,
        'attempts': 0,
        'points': RouteScore.getPointsForRoute(i),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Reset completion status
    await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .collection('completion_status')
        .doc('topRope')
        .set({
      'completed': false,
      'completionTime': null,
    });

    // Update leaderboard entry
    await _updateLeaderboard(competitorId, DisciplineType.topRope, competitorData['category']);

    print('Successfully reset top rope scores for competitor $competitorId');
  }

  static Future<void> resetBoulderScores(int competitorId) async {
    print('Resetting boulder scores for competitor $competitorId');
    
    // Get competitor data for denormalization
    final competitorDoc = await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .get();
    
    if (!competitorDoc.exists) {
      throw Exception('Competitor not found');
    }

    final competitorData = competitorDoc.data()!;
    
    // Reset boulder scores
    for (int i = 1; i <= 16; i++) {
      await _firestore
          .collection('scores')
          .doc('${competitorId}_boulder_$i')
          .set({
        'competitorId': competitorId.toString(),
        'competitorName': competitorData['name'],
        'category': competitorData['category'],
        'type': 'boulder',
        'routeNumber': i,
        'isCompleted': false,
        'attempts': 0,
        'points': RouteScore.getPointsForRoute(i),
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Reset completion status
    await _firestore
        .collection('competitors')
        .doc(competitorId.toString())
        .collection('completion_status')
        .doc('boulder')
        .set({
      'completed': false,
      'completionTime': null,
    });

    // Update leaderboard entry
    await _updateLeaderboard(competitorId, DisciplineType.boulder, competitorData['category']);

    print('Successfully reset boulder scores for competitor $competitorId');
  }

  static Future<List<RouteScore>> getScores(String competitorId, DisciplineType type) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('scores')
          .where('competitorId', isEqualTo: competitorId)
          .where('type', isEqualTo: type == DisciplineType.topRope ? 'topRope' : 'boulder')
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return RouteScore(
          routeNumber: data['routeNumber'] as int,
          points: data['points'] as int,
          isCompleted: data['isCompleted'] as bool,
          attempts: data['attempts'] as int,
        );
      }).toList();
    } catch (e) {
      print('Error getting scores: $e');
      return [];
    }
  }
} 