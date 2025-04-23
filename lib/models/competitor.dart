class Competitor {
  final int id;
  final String name;
  final int birthYear;
  final Category category;
  final List<RouteScore> topRopeScores;
  final List<RouteScore> boulderScores;

  int get bibNumber => id;

  Competitor({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.category,
    List<RouteScore>? topRopeScores,
    List<RouteScore>? boulderScores,
  })  : topRopeScores = topRopeScores ?? [],
        boulderScores = boulderScores ?? [];

  int get totalTopRopeScore {
    // Filter completed routes and sort by route number (descending)
    var completedRoutes = topRopeScores
        .where((score) => score.isCompleted)
        .toList()
      ..sort((a, b) => b.routeNumber.compareTo(a.routeNumber));
    
    // Take top 10 hardest completed routes
    return completedRoutes
        .take(10)
        .fold(0, (sum, score) => sum + score.points);
  }

  int get totalBoulderScore {
    // Filter completed routes and sort by route number (descending)
    var completedRoutes = boulderScores
        .where((score) => score.isCompleted)
        .toList()
      ..sort((a, b) {
        // First sort by route number (descending)
        var routeCompare = b.routeNumber.compareTo(a.routeNumber);
        if (routeCompare != 0) return routeCompare;
        // If same route, sort by attempts (ascending)
        return a.attempts.compareTo(b.attempts);
      });
    
    // Take top 10 hardest completed routes
    return completedRoutes
        .take(10)
        .fold(0, (sum, score) => sum + score.points);
  }
}

enum Category {
  kidsA,  // 2011-2012
  kidsB,  // 2013-2014
  kidsC,  // 2015-2018
}

class RouteScore {
  final int routeNumber;
  final bool isCompleted;
  final int attempts;
  final int points;

  RouteScore({
    required this.routeNumber,
    required this.isCompleted,
    required this.attempts,
    required this.points,
  });

  static int getPointsForRoute(int routeNumber) {
    if (routeNumber == 1) return 10;
    if (routeNumber <= 3) return 20;
    if (routeNumber <= 6) return 30;
    if (routeNumber <= 9) return 40;
    if (routeNumber <= 12) return 50;
    if (routeNumber <= 15) return 60;
    return 0;
  }
}

extension CategoryExtension on Category {
  String get displayName {
    switch (this) {
      case Category.kidsA:
        return 'Kids A (2011-2012)';
      case Category.kidsB:
        return 'Kids B (2013-2014)';
      case Category.kidsC:
        return 'Kids C (2015-2018)';
    }
  }

  bool isValidBirthYear(int year) {
    switch (this) {
      case Category.kidsA:
        return year >= 2011 && year <= 2012;
      case Category.kidsB:
        return year >= 2013 && year <= 2014;
      case Category.kidsC:
        return year >= 2015 && year <= 2018;
    }
  }
} 