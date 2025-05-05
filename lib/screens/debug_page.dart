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
  String _selectedGender = 'boy';
  String _status = '';

  // List of sample first names and last names for random generation
  final _firstNames = ['Alex', 'Sam', 'Jordan', 'Taylor', 'Morgan', 'Casey', 'Riley', 'Avery', 'Quinn', 'Parker'];
  final _lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez'];

  Category _determineCategory(int birthYear, String gender) {
    if (birthYear >= 2011 && birthYear <= 2012) {
      return gender == 'boy' ? Category.kidsABoy : Category.kidsAGirl;
    } else if (birthYear >= 2013 && birthYear <= 2014) {
      return gender == 'boy' ? Category.kidsBBoy : Category.kidsBGirl;
    } else if (birthYear >= 2015 && birthYear <= 2018) {
      return gender == 'boy' ? Category.kidsCBoy : Category.kidsCGirl;
    } else {
      throw Exception('Invalid birth year for any category');
    }
  }

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

      // Generate random gender and birth year
      final gender = random.nextBool() ? 'boy' : 'girl';
      final ageGroup = random.nextInt(3); // 0: A, 1: B, 2: C
      
      int birthYear;
      switch (ageGroup) {
        case 0:
          birthYear = random.nextInt(2) + 2011; // 2011-2012
          break;
        case 1:
          birthYear = random.nextInt(2) + 2013; // 2013-2014
          break;
        case 2:
          birthYear = random.nextInt(4) + 2015; // 2015-2018
          break;
        default:
          birthYear = 2015;
      }

      // Set the values in the form
      setState(() {
        _idController.text = nextId.toString();
        _nameController.text = fullName;
        _birthYearController.text = birthYear.toString();
        _selectedGender = gender;
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
      
      // Determine category based on birth year and gender
      final category = _determineCategory(birthYear, _selectedGender);
      
      if (!category.isValidBirthYear(birthYear)) {
        setState(() => _status = 'Error: Birth year $birthYear is not valid for category ${category.displayName}');
        return;
      }

      final competitor = Competitor(
        id: id,
        name: _nameController.text.trim(),
        birthYear: birthYear,
        category: category,
        gender: _selectedGender,
      );

      await FirebaseFirestore.instance
          .collection('competitors')
          .doc(id.toString())
          .set({
            'id': competitor.id,
            'name': competitor.name,
            'birthYear': competitor.birthYear,
            'category': competitor.category.toString().split('.').last,
            'gender': competitor.gender,
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
        title: const Text('Debug Page'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'Competitor ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthYearController,
              decoration: const InputDecoration(
                labelText: 'Birth Year',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'boy',
                  child: Text('Boy'),
                ),
                DropdownMenuItem(
                  value: 'girl',
                  child: Text('Girl'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedGender = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _createCompetitor,
              child: const Text('Create Competitor'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateRandomCompetitor,
              child: const Text('Generate Random Competitor'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: _status),
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }
} 