import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'package:ccbk_spider_kids_comp/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spider Kids 2025'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'SPIDER KIDS',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '10 MAY 2025',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryCard(
                    context,
                    Category.kidsA,
                    'For climbers born in 2011-2012',
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryCard(
                    context,
                    Category.kidsB,
                    'For climbers born in 2013-2014',
                  ),
                  const SizedBox(height: 8),
                  _buildCategoryCard(
                    context,
                    Category.kidsC,
                    'For climbers born in 2015-2018',
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Competition Format',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFormatCard(
                    context,
                    'Top Rope',
                    '• 16 routes available\n• Top 10 routes counted\n• 3 attempts maximum per route\n• Attempts not counted for ranking',
                  ),
                  const SizedBox(height: 8),
                  _buildFormatCard(
                    context,
                    'Boulder',
                    '• 16 problems available\n• Top 10 problems counted\n• Unlimited attempts\n• Attempts counted for ranking',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        label: const Text('Login'),
        icon: const Icon(Icons.login),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Category category, String description) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(
          category.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to category details
        },
      ),
    );
  }

  Widget _buildFormatCard(BuildContext context, String title, String details) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(details),
          ],
        ),
      ),
    );
  }
} 