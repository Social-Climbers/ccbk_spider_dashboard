import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/widgets/sponsor_bar.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final textScale = isSmallScreen ? 0.85 : 1.0;
    final padding = screenWidth < 400 ? 12.0 : 16.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Categories',
          style: TextStyle(
            fontSize: isSmallScreen ? 18 : 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kids A'),
            Tab(text: 'Kids B'),
            Tab(text: 'Kids C'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryView(Category.kidsA, textScale, padding),
              _buildCategoryView(Category.kidsB, textScale, padding),
              _buildCategoryView(Category.kidsC, textScale, padding),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: const SponsorBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryView(Category category, double textScale, double padding) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: padding + 60,
        left: padding,
        right: padding,
        bottom: padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 24 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16 * textScale),
                  Text(
                    'Age Range: ${_getAgeRange(category)}',
                    style: TextStyle(
                      fontSize: 16 * textScale,
                    ),
                  ),
                  SizedBox(height: 8 * textScale),
                  Text(
                    'Competition Format:',
                    style: TextStyle(
                      fontSize: 18 * textScale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8 * textScale),
                  _buildFormatCard(
                    'Top Rope',
                    '• 16 routes available\n• Top 10 routes counted\n• 3 attempts maximum per route\n• Attempts not counted for ranking',
                    textScale,
                  ),
                  SizedBox(height: 8 * textScale),
                  _buildFormatCard(
                    'Boulder',
                    '• 16 problems available\n• Top 10 problems counted\n• Unlimited attempts\n• Attempts counted for ranking',
                    textScale,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16 * textScale),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to competitor info page
            },
            icon: const Icon(Icons.person),
            label: Text(
              'Check Your Information',
              style: TextStyle(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: 16 * textScale,
                horizontal: 32 * textScale,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
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

  Widget _buildFormatCard(String title, String details, double textScale) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16 * textScale,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4 * textScale),
            Text(
              details,
              style: TextStyle(
                fontSize: 14 * textScale,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 