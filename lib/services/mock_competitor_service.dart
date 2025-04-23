import 'package:ccbk_spider_kids_comp/models/competitor.dart';

class MockCompetitorService {
  static final List<Competitor> _competitors = [
    Competitor(
      id: 1,
      name: 'Alex Johnson',
      birthYear: 2015,
      category: Category.kidsC,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 2,
      name: 'Emma Wilson',
      birthYear: 2014,
      category: Category.kidsB,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 3,
      name: 'Liam Chen',
      birthYear: 2013,
      category: Category.kidsA,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 4,
      name: 'Sophia Martinez',
      birthYear: 2015,
      category: Category.kidsC,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 5,
      name: 'Noah Kim',
      birthYear: 2014,
      category: Category.kidsB,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 6,
      name: 'Isabella Wong',
      birthYear: 2013,
      category: Category.kidsA,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 7,
      name: 'Ethan Patel',
      birthYear: 2015,
      category: Category.kidsC,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 8,
      name: 'Mia Rodriguez',
      birthYear: 2014,
      category: Category.kidsB,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 9,
      name: 'Lucas Smith',
      birthYear: 2013,
      category: Category.kidsA,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
    Competitor(
      id: 10,
      name: 'Ava Thompson',
      birthYear: 2015,
      category: Category.kidsC,
      topRopeScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
      boulderScores: List.generate(15, (index) => RouteScore(
        routeNumber: index + 1,
        isCompleted: false,
        attempts: 0,
        points: RouteScore.getPointsForRoute(index + 1),
      )),
    ),
  ];

  static List<Competitor> getTopRopeLeaderboard() {
    return List.from(_competitors)
      ..sort((a, b) => b.totalTopRopeScore.compareTo(a.totalTopRopeScore));
  }

  static List<Competitor> getBoulderLeaderboard() {
    return List.from(_competitors)
      ..sort((a, b) => b.totalBoulderScore.compareTo(a.totalBoulderScore));
  }

  static Competitor? getCompetitor(int id) {
    try {
      return _competitors.firstWhere((competitor) => competitor.id == id);
    } catch (e) {
      return null;
    }
  }
} 