import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/services/mock_competitor_service.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CompetitorInfoPage extends StatefulWidget {
  final Category category;

  const CompetitorInfoPage({
    super.key,
    required this.category,
  });

  @override
  State<CompetitorInfoPage> createState() => _CompetitorInfoPageState();
}

class _CompetitorInfoPageState extends State<CompetitorInfoPage> {
  late List<Competitor> _competitors;

  @override
  void initState() {
    super.initState();
    _competitors = _getMockCompetitors();
  }

  List<Competitor> _getMockCompetitors() {
    final baseId = widget.category == Category.kidsA ? 1 : 
                  widget.category == Category.kidsB ? 11 : 21;
    final birthYear = widget.category == Category.kidsA ? 2011 : 
                     widget.category == Category.kidsB ? 2013 : 2015;

    final names = widget.category == Category.kidsA ? [
      'Alex Johnson', 'Emma Wilson', 'Liam Chen', 'Sophia Martinez', 'Noah Kim',
      'Isabella Wong', 'Ethan Patel', 'Mia Rodriguez', 'Lucas Smith', 'Ava Thompson'
    ] : widget.category == Category.kidsB ? [
      'Oliver Brown', 'Charlotte Lee', 'William Zhang', 'Amelia Garcia', 'James Park',
      'Harper Kim', 'Benjamin Singh', 'Evelyn Chen', 'Henry Wong', 'Luna Patel'
    ] : [
      'Leo Anderson', 'Chloe Tan', 'Mason Liu', 'Zoe Kim', 'Jack Wilson',
      'Lily Chen', 'Daniel Park', 'Hannah Wong', 'Samuel Lee', 'Grace Zhang'
    ];

    return List.generate(10, (index) {
      final id = baseId + index;
      return Competitor(
        id: id,
        name: names[index],
        birthYear: birthYear + (index % 2),
        category: widget.category,
        topRopeScores: List.generate(15, (i) => RouteScore(
          routeNumber: i + 1,
          isCompleted: false,
          attempts: 0,
          points: RouteScore.getPointsForRoute(i + 1),
        )),
        boulderScores: List.generate(15, (i) => RouteScore(
          routeNumber: i + 1,
          isCompleted: false,
          attempts: 0,
          points: RouteScore.getPointsForRoute(i + 1),
        )),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.category.displayName} - Competitors',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.only(
              top: padding + 60,
              left: padding,
              right: padding,
              bottom: padding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16 * textScale),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Competitor List',
                          style: TextStyle(
                            fontSize: 24 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16 * textScale),
                        Text(
                          'Category: ${widget.category.displayName}',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                          ),
                        ),
                        SizedBox(height: 8 * textScale),
                        Text(
                          'Age Range: ${_getAgeRange(widget.category)}',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16 * textScale),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _competitors.length,
                  itemBuilder: (context, index) {
                    final competitor = _competitors[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8 * textScale),
                      child: ListTile(
                        title: Text(
                          competitor.name,
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          'Birth Year: ${competitor.birthYear}',
                          style: TextStyle(
                            fontSize: 14 * textScale,
                            color: Colors.grey[600],
                          ),
                        ),
                        trailing: Text(
                          '#${competitor.id}',
                          style: TextStyle(
                            fontSize: 16 * textScale,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: const SponsorBar(isDarkTheme: true),
          ),
        ],
      ),
    );
  }

  String _getAgeRange(Category category) {
    switch (category) {
      case Category.kidsA:
        return '2011-2012';
      case Category.kidsB:
        return '2013-2014';
      case Category.kidsC:
        return '2015-2018';
    }
  }
} 