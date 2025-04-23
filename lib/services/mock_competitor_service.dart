import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/firebase_service.dart';

class MockCompetitorService {
  static final FirebaseService _firebaseService = FirebaseService();

  static Future<Competitor?> getCompetitor(int id) async {
    return await _firebaseService.getCompetitor(id);
  }

  static Future<List<Competitor>> getAllCompetitors() async {
    List<Competitor> allCompetitors = [];
    for (var category in Category.values) {
      final competitors = await _firebaseService.getCompetitorsByCategory(category);
      allCompetitors.addAll(competitors);
    }
    return allCompetitors;
  }

  static Future<List<Competitor>> getTopRopeLeaderboard() async {
    final competitors = await getAllCompetitors();
    competitors.sort((a, b) => b.totalTopRopeScore.compareTo(a.totalTopRopeScore));
    return competitors;
  }

  static Future<List<Competitor>> getBoulderLeaderboard() async {
    final competitors = await getAllCompetitors();
    competitors.sort((a, b) => b.totalBoulderScore.compareTo(a.totalBoulderScore));
    return competitors;
  }

  static Stream<List<Competitor>> getCategoryLeaderboardStream(Category category) {
    return _firebaseService.getCategoryLeaderboardStream(category);
  }
} 