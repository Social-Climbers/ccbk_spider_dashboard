import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ccbk_spider_kids_comp/models/competitor.dart';
import 'dart:math';

class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _idController = TextEditingController();
  Category _selectedCategory = Category.kidsA;
  String _status = '';

  // List of sample first names and last names for random generation
  final _firstNames = ['Alex', 'Sam', 'Jordan', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Parker'];
  final _lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'];

  Future<void> _deleteCompetitor(String id) async {
    try {
      await FirebaseFirestore.instance
          .collection('competitors')
          .doc(id)
          .delete();
      setState(() => _status = 'Competitor deleted successfully');
    } catch (e) {
      setState(() => _status = 'Error deleting competitor: ${e.toString()}');
    }
  }

  Future<void> _generateRandomCompetitor() async {
    try {
      setState(() => _status = 'Fetching last ID...');

      // Get the last competitor ID from Firestore
      final querySnapshot = await FirebaseFirestore.instance
          .collection('competitors')
          .orderBy('id', descending: true)
          .limit(1)
          .get();

      // Start with ID 1 if no competitors exist, otherwise increment the last ID
      int nextId = 1;
      if (querySnapshot.docs.isNotEmpty) {
        nextId = (querySnapshot.docs.first.data()['id'] as int) + 1;
      }

      // Generate random name
      final random = Random();
      final firstName = _firstNames[random.nextInt(_firstNames.length)];
      final lastName = _lastNames[random.nextInt(_lastNames.length)];
      final fullName = '$firstName $lastName';

      // Generate random category and valid birth year
      final category = Category.values[random.nextInt(Category.values.length)];
      int birthYear;
      switch (category) {
        case Category.kidsA:
          birthYear = random.nextInt(2) + 2011; // 2011-2012
          break;
        case Category.kidsB:
          birthYear = random.nextInt(2) + 2013; // 2013-2014
          break;
        case Category.kidsC:
          birthYear = random.nextInt(4) + 2015; // 2015-2018
          break;
      }

      // Set the values in the form
      setState(() {
        _idController.text = nextId.toString();
        _nameController.text = fullName;
        _birthYearController.text = birthYear.toString();
        _selectedCategory = category;
      });

      setState(() => _status = 'Random competitor generated - ready to create');
    } catch (e) {
      setState(() => _status = 'Error generating random competitor: ${e.toString()}');
    }
  }

  Future<void> _createCompetitor() async {
    try {
      setState(() => _status = 'Creating competitor...');
      
      final id = int.parse(_idController.text.trim());
      final birthYear = int.parse(_birthYearController.text.trim());
      
      if (!_selectedCategory.isValidBirthYear(birthYear)) {
        setState(() => _status = 'Error: Birth year $birthYear is not valid for category ${_selectedCategory.displayName}');
        return;
      }

      final competitor = Competitor(
        id: id,
        name: _nameController.text.trim(),
        birthYear: birthYear,
        category: _selectedCategory,
      );

      await FirebaseFirestore.instance
          .collection('competitors')
          .doc(id.toString())
          .set({
            'id': competitor.id,
            'name': competitor.name,
            'birthYear': competitor.birthYear,
            'category': competitor.category.toString().split('.').last,
            'topRopeScores': [],
            'boulderScores': [],
          });

      setState(() => _status = 'Competitor created successfully: ${competitor.name} (Bib #${competitor.bibNumber})');
      
      _nameController.clear();
      _birthYearController.clear();
      _idController.clear();
    } catch (e) {
      setState(() => _status = 'Error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Tools'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Create Competitor',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _idController,
                    decoration: const InputDecoration(
                      labelText: 'ID/Bib Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _generateRandomCompetitor,
                  icon: const Icon(Icons.casino),
                  tooltip: 'Generate Random Competitor',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _birthYearController,
              decoration: const InputDecoration(
                labelText: 'Birth Year (e.g., 2011)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: Category.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.displayName),
                );
              }).toList(),
              onChanged: (Category? value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _createCompetitor,
              child: const Text('Create Competitor'),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: TextStyle(
                color: _status.startsWith('Error') ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Competitor List',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('competitors')
                  .orderBy('id')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final competitors = snapshot.data?.docs ?? [];

                if (competitors.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No competitors found'),
                    ),
                  );
                }

                return Column(
                  children: competitors.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text(data['id'].toString()),
                        ),
                        title: Text(data['name']),
                        subtitle: Text(
                          'Category: ${data['category']}\nBirth Year: ${data['birthYear']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteCompetitor(doc.id),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 