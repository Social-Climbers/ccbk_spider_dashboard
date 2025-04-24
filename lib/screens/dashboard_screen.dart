import 'package:flutter/material.dart';
import 'package:ccbk_spider_kids_comp/screens/settings_page.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(
                Icons.settings,
                size: 28,
                color: Colors.white,
              ),
              onPressed: () {
                debugPrint('Settings button pressed');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('Dashboard Screen'),
      ),
    );
  }
} 