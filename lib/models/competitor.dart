class Competitor {
  final int id;
  final String name;
  final int birthYear;
  final Category category;
  final String gender;
  final List<RouteScore> topRopeScores;
  final List<RouteScore> boulderScores;

  int get bibNumber => id;

  Competitor({
    required this.id,
    required this.name,
    required this.birthYear,
    required this.category,
    required this.gender,
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

  int get totalCombinedScore {
    return totalTopRopeScore * totalBoulderScore;
  }
}

enum Category {
  kidsABoy,    // 2011-2012 Boys
  kidsAGirl,   // 2011-2012 Girls
  kidsBBoy,    // 2013-2014 Boys
  kidsBGirl,   // 2013-2014 Girls
  kidsCBoy,    // 2015-2018 Boys
  kidsCGirl,   // 2015-2018 Girls
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
      case Category.kidsABoy:
        return 'Kids A Boys (2011-2012)';
      case Category.kidsAGirl:
        return 'Kids A Girls (2011-2012)';
      case Category.kidsBBoy:
        return 'Kids B Boys (2013-2014)';
      case Category.kidsBGirl:
        return 'Kids B Girls (2013-2014)';
      case Category.kidsCBoy:
        return 'Kids C Boys (2015-2018)';
      case Category.kidsCGirl:
        return 'Kids C Girls (2015-2018)';
    }
  }

  bool isValidBirthYear(int year) {
    switch (this) {
      case Category.kidsABoy:
      case Category.kidsAGirl:
        return year >= 2011 && year <= 2012;
      case Category.kidsBBoy:
      case Category.kidsBGirl:
        return year >= 2013 && year <= 2014;
      case Category.kidsCBoy:
      case Category.kidsCGirl:
        return year >= 2015 && year <= 2018;
    }
  }

  String get gender {
    switch (this) {
      case Category.kidsABoy:
      case Category.kidsBBoy:
      case Category.kidsCBoy:
        return 'boy';
      case Category.kidsAGirl:
      case Category.kidsBGirl:
      case Category.kidsCGirl:
        return 'girl';
    }
  }

  String get ageGroup {
    switch (this) {
      case Category.kidsABoy:
      case Category.kidsAGirl:
        return 'kidsA';
      case Category.kidsBBoy:
      case Category.kidsBGirl:
        return 'kidsB';
      case Category.kidsCBoy:
      case Category.kidsCGirl:
        return 'kidsC';
    }
  }
} 