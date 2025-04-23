import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collections
  static const String competitorsCollection = 'competitors';
  static const String scoresCollection = 'scores';

  // Competitor Operations
  Future<void> saveCompetitor(Competitor competitor) async {
    try {
      await _firestore.collection(competitorsCollection).doc(competitor.id.toString()).set({
        'id': competitor.id,
        'name': competitor.name,
        'birthYear': competitor.birthYear,
        'category': competitor.category.toString().split('.').last,
        'bibNumber': competitor.bibNumber,
      });
    } catch (e) {
      throw Exception('Failed to save competitor: $e');
    }
  }

  Future<void> saveCompetitorScores(int competitorId, List<RouteScore> topRopeScores, List<RouteScore> boulderScores) async {
    try {
      final scoreData = {
        'competitorId': competitorId,
        'topRopeScores': topRopeScores.map((score) => {
          'routeNumber': score.routeNumber,
          'isCompleted': score.isCompleted,
          'attempts': score.attempts,
          'points': score.points,
        }).toList(),
        'boulderScores': boulderScores.map((score) => {
          'routeNumber': score.routeNumber,
          'isCompleted': score.isCompleted,
          'attempts': score.attempts,
          'points': score.points,
        }).toList(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(scoresCollection)
          .doc(competitorId.toString())
          .set(scoreData);
    } catch (e) {
      throw Exception('Failed to save scores: $e');
    }
  }

  Future<Competitor?> getCompetitor(int id) async {
    try {
      final doc = await _firestore.collection(competitorsCollection).doc(id.toString()).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      final scoresDoc = await _firestore.collection(scoresCollection).doc(id.toString()).get();
      
      List<RouteScore> topRopeScores = [];
      List<RouteScore> boulderScores = [];

      if (scoresDoc.exists) {
        final scoresData = scoresDoc.data()!;
        topRopeScores = (scoresData['topRopeScores'] as List).map((score) => RouteScore(
          routeNumber: score['routeNumber'],
          isCompleted: score['isCompleted'],
          attempts: score['attempts'],
          points: score['points'],
        )).toList();

        boulderScores = (scoresData['boulderScores'] as List).map((score) => RouteScore(
          routeNumber: score['routeNumber'],
          isCompleted: score['isCompleted'],
          attempts: score['attempts'],
          points: score['points'],
        )).toList();
      }

      return Competitor(
        id: data['id'],
        name: data['name'],
        birthYear: data['birthYear'],
        category: Category.values.firstWhere(
          (e) => e.toString().split('.').last == data['category']
        ),
        topRopeScores: topRopeScores,
        boulderScores: boulderScores,
      );
    } catch (e) {
      throw Exception('Failed to get competitor: $e');
    }
  }

  Future<List<Competitor>> getCompetitorsByCategory(Category category) async {
    try {
      final querySnapshot = await _firestore
          .collection(competitorsCollection)
          .where('category', isEqualTo: category.toString().split('.').last)
          .get();

      List<Competitor> competitors = [];
      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        final scoresDoc = await _firestore.collection(scoresCollection).doc(data['id'].toString()).get();
        
        List<RouteScore> topRopeScores = [];
        List<RouteScore> boulderScores = [];

        if (scoresDoc.exists) {
          final scoresData = scoresDoc.data()!;
          topRopeScores = (scoresData['topRopeScores'] as List).map((score) => RouteScore(
            routeNumber: score['routeNumber'],
            isCompleted: score['isCompleted'],
            attempts: score['attempts'],
            points: score['points'],
          )).toList();

          boulderScores = (scoresData['boulderScores'] as List).map((score) => RouteScore(
            routeNumber: score['routeNumber'],
            isCompleted: score['isCompleted'],
            attempts: score['attempts'],
            points: score['points'],
          )).toList();
        }

        competitors.add(Competitor(
          id: data['id'],
          name: data['name'],
          birthYear: data['birthYear'],
          category: Category.values.firstWhere(
            (e) => e.toString().split('.').last == data['category']
          ),
          topRopeScores: topRopeScores,
          boulderScores: boulderScores,
        ));
      }

      return competitors;
    } catch (e) {
      throw Exception('Failed to get competitors by category: $e');
    }
  }

  // Authentication Operations
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Stream for real-time updates
  Stream<List<Competitor>> getCategoryLeaderboardStream(Category category) {
    return _firestore
        .collection(competitorsCollection)
        .where('category', isEqualTo: category.toString().split('.').last)
        .snapshots()
        .asyncMap((snapshot) async {
          List<Competitor> competitors = [];
          for (var doc in snapshot.docs) {
            final data = doc.data();
            final scoresDoc = await _firestore.collection(scoresCollection).doc(data['id'].toString()).get();
            
            List<RouteScore> topRopeScores = [];
            List<RouteScore> boulderScores = [];

            if (scoresDoc.exists) {
              final scoresData = scoresDoc.data()!;
              topRopeScores = (scoresData['topRopeScores'] as List).map((score) => RouteScore(
                routeNumber: score['routeNumber'],
                isCompleted: score['isCompleted'],
                attempts: score['attempts'],
                points: score['points'],
              )).toList();

              boulderScores = (scoresData['boulderScores'] as List).map((score) => RouteScore(
                routeNumber: score['routeNumber'],
                isCompleted: score['isCompleted'],
                attempts: score['attempts'],
                points: score['points'],
              )).toList();
            }

            competitors.add(Competitor(
              id: data['id'],
              name: data['name'],
              birthYear: data['birthYear'],
              category: Category.values.firstWhere(
                (e) => e.toString().split('.').last == data['category']
              ),
              topRopeScores: topRopeScores,
              boulderScores: boulderScores,
            ));
          }
          return competitors;
        });
  }

  // Stream for real-time updates
  Stream<Competitor> getCompetitorStream(int competitorId) {
    return _firestore
        .collection(competitorsCollection)
        .doc(competitorId.toString())
        .snapshots()
        .asyncMap((doc) async {
          if (!doc.exists) throw Exception('Competitor not found');
          
          final data = doc.data()!;
          final scoresDoc = await _firestore.collection(scoresCollection).doc(competitorId.toString()).get();
          
          List<RouteScore> topRopeScores = [];
          List<RouteScore> boulderScores = [];

          if (scoresDoc.exists) {
            final scoresData = scoresDoc.data()!;
            topRopeScores = (scoresData['topRopeScores'] as List).map((score) => RouteScore(
              routeNumber: score['routeNumber'],
              isCompleted: score['isCompleted'],
              attempts: score['attempts'],
              points: score['points'],
            )).toList();

            boulderScores = (scoresData['boulderScores'] as List).map((score) => RouteScore(
              routeNumber: score['routeNumber'],
              isCompleted: score['isCompleted'],
              attempts: score['attempts'],
              points: score['points'],
            )).toList();
          }

          return Competitor(
            id: data['id'],
            name: data['name'],
            birthYear: data['birthYear'],
            category: Category.values.firstWhere(
              (e) => e.toString().split('.').last == data['category']
            ),
            topRopeScores: topRopeScores,
            boulderScores: boulderScores,
          );
        });
  }
} 