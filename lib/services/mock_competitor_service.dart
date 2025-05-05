import 'package:ccbk_spider_kids_comp/models/competitor.dart';

class MockCompetitorService {
  static List<RouteScore> _initializeRouteScores() {
    return List.generate(15, (i) => RouteScore(
      routeNumber: i + 1,
      isCompleted: false,
      attempts: 0,
      points: RouteScore.getPointsForRoute(i + 1),
    ));
  }

  static final List<Competitor> _competitors = [
    // Kids A (2011-2012)
    Competitor(
      id: 1,
      name: 'Alex Thompson',
      category: Category.kidsABoy,
      birthYear: 2011,
      gender: 'boy',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 8,
      name: 'Sarah Chen',
      category: Category.kidsAGirl,
      birthYear: 2011,
      gender: 'girl',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 15,
      name: 'Michael Kim',
      category: Category.kidsABoy,
      birthYear: 2012,
      gender: 'boy',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 22,
      name: 'Emma Davis',
      category: Category.kidsAGirl,
      birthYear: 2012,
      gender: 'girl',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    
    // Kids B (2013-2014)
    Competitor(
      id: 3,
      name: 'Lucas Wang',
      category: Category.kidsBBoy,
      birthYear: 2013,
      gender: 'boy',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 12,
      name: 'Sofia Garcia',
      category: Category.kidsBGirl,
      birthYear: 2013,
      gender: 'girl',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 17,
      name: 'David Lee',
      category: Category.kidsBBoy,
      birthYear: 2014,
      gender: 'boy',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 24,
      name: 'Olivia Brown',
      category: Category.kidsBGirl,
      birthYear: 2014,
      gender: 'girl',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    
    // Kids C (2015-2018)
    Competitor(
      id: 5,
      name: 'Ethan Park',
      category: Category.kidsCBoy,
      birthYear: 2015,
      gender: 'boy',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 10,
      name: 'Ava Wilson',
      category: Category.kidsCGirl,
      birthYear: 2015,
      gender: 'girl',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 19,
      name: 'Noah Martinez',
      category: Category.kidsCBoy,
      birthYear: 2016,
      gender: 'boy',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
    Competitor(
      id: 25,
      name: 'Isabella Taylor',
      category: Category.kidsCGirl,
      birthYear: 2016,
      gender: 'girl',
      topRopeScores: _initializeRouteScores(),
      boulderScores: _initializeRouteScores(),
    ),
  ];

  static Competitor? getCompetitor(int id) {
    try {
      return _competitors.firstWhere((comp) => comp.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Competitor> getAllCompetitors() {
    return List.from(_competitors);
  }

  static List<Competitor> getTopRopeLeaderboard() {
    return List.from(_competitors)
      ..sort((a, b) => b.totalTopRopeScore.compareTo(a.totalTopRopeScore));
  }

  static List<Competitor> getBoulderLeaderboard() {
    return List.from(_competitors)
      ..sort((a, b) => b.totalBoulderScore.compareTo(a.totalBoulderScore));
  }
} 