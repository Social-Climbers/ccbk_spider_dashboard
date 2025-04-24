import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  late Stream<QuerySnapshot> _competitorsStream;

  @override
  void initState() {
    super.initState();
    _initCompetitorsStream();
  }

  void _initCompetitorsStream() {
    final categoryValue = _getCategoryValue(widget.category);
    print('Initializing stream for category: $categoryValue');
    _competitorsStream = FirebaseFirestore.instance
        .collection('competitors')
        .where('category', isEqualTo: categoryValue)
        .snapshots();
  }

  String _getCategoryValue(Category category) {
    switch (category) {
      case Category.kidsA:
        return 'kidsA';
      case Category.kidsB:
        return 'kidsB';
      case Category.kidsC:
        return 'kidsC';
    }
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
              top: padding + 120,
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
                StreamBuilder<QuerySnapshot>(
                  stream: _competitorsStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final competitors = snapshot.data?.docs ?? [];
                    print('Found ${competitors.length} competitors in category ${widget.category}');

                    if (competitors.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_off,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No competitors found',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Sort competitors by name
                    final sortedCompetitors = competitors.toList()
                      ..sort((a, b) {
                        final nameA = (a.data() as Map<String, dynamic>)['name'] as String;
                        final nameB = (b.data() as Map<String, dynamic>)['name'] as String;
                        return nameA.compareTo(nameB);
                      });

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedCompetitors.length,
                      itemBuilder: (context, index) {
                        final competitor = sortedCompetitors[index].data() as Map<String, dynamic>;
                        final competitorId = sortedCompetitors[index].id;
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 8 * textScale),
                          child: ListTile(
                            title: Text(
                              competitor['name'] as String,
                              style: TextStyle(
                                fontSize: 16 * textScale,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Birth Year: ${competitor['birthYear'] ?? 'N/A'}',
                              style: TextStyle(
                                fontSize: 14 * textScale,
                                color: Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              '#$competitorId',
                              style: TextStyle(
                                fontSize: 16 * textScale,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
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