import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VAZHI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    // Start the animation and navigate to the next screen after 2 seconds
    _controller.forward();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => UserDetailsPage()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Text(
            'Vazhi',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class UserDetailsPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController activityController = TextEditingController();
  final TextEditingController interestsController = TextEditingController();
  final TextEditingController hobbiesController = TextEditingController();
  final TextEditingController timePeriodController = TextEditingController();

  void navigateToDreamJob(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DreamJobPage(
          name: nameController.text,
          gender: genderController.text,
          age: int.tryParse(ageController.text) ?? 0,
          currentActivity: activityController.text,
          interests: interestsController.text,
          hobbies: hobbiesController.text,
          timePeriod: timePeriodController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: genderController,
              decoration: InputDecoration(labelText: 'Gender'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: activityController,
              decoration: InputDecoration(labelText: 'Current Activity'),
            ),
            TextField(
              controller: interestsController,
              decoration: InputDecoration(labelText: 'Interests'),
            ),
            TextField(
              controller: hobbiesController,
              decoration: InputDecoration(labelText: 'Hobbies'),
            ),
            TextField(
              controller: timePeriodController,
              decoration: InputDecoration(labelText: 'Time Period (e.g., weeks, months)'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => navigateToDreamJob(context),
              child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}

class DreamJobPage extends StatelessWidget {
  final String name;
  final String gender;
  final int age;
  final String currentActivity;
  final String interests;
  final String hobbies;
  final String timePeriod;
  final TextEditingController dreamJobController = TextEditingController();

  DreamJobPage({
    required this.name,
    required this.gender,
    required this.age,
    required this.currentActivity,
    required this.interests,
    required this.hobbies,
    required this.timePeriod,
  });

  void predictFuture(BuildContext context) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8000/predict_future'), // Change to your IP if using a device
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'name': name,
        'gender': gender,
        'age': age,
        'current_activity': currentActivity,
        'interests': interests,
        'hobbies': hobbies,
        'time_period': timePeriod,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PredictionPage(
            prediction: data['prediction'],
            tasks: List<String>.from(data['tasks']),
          ),
        ),
      );
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What is Your Dream Job?'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: dreamJobController,
              decoration: InputDecoration(labelText: 'Dream Job'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => predictFuture(context),
              child: Text('Predict Future'),
            ),
          ],
        ),
      ),
    );
  }
}

class PredictionPage extends StatelessWidget {
  final String prediction;
  final List<String> tasks;

  PredictionPage({required this.prediction, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Future Prediction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Prediction: $prediction', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Text('Tasks to Achieve Your Goals:', style: TextStyle(fontSize: 16)),
            ...tasks.map((task) => ListTile(title: Text(task))).toList(),
          ],
        ),
      ),
    );
  }
}
