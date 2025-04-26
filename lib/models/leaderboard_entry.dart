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
      competitorId: data['competitorId']?.toString() ?? '',
      competitorName: data['competitorName'] as String? ?? 'Unknown',
      totalScore: data['totalScore'] as int? ?? 0,
      completedRoutes: data['completedRoutes'] as int? ?? 0,
      totalAttempts: data['totalAttempts'] as int? ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
} 