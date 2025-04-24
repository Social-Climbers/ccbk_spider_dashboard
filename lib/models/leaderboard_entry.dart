import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String competitorId;
  final String competitorName;
  final int totalScore;
  final int completedRoutes;
  final int totalAttempts;
  final DateTime lastUpdated;

  LeaderboardEntry({
    required this.competitorId,
    required this.competitorName,
    required this.totalScore,
    required this.completedRoutes,
    required this.totalAttempts,
    required this.lastUpdated,
  });

  factory LeaderboardEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaderboardEntry(
      competitorId: data['competitorId'] as String,
      competitorName: data['competitorName'] as String,
      totalScore: data['totalScore'] as int,
      completedRoutes: data['completedRoutes'] as int,
      totalAttempts: data['totalAttempts'] as int? ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
    );
  }
} 