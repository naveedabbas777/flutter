import 'package:flutter/material.dart';
import 'study/study_screen.dart';
import 'training/training_screen.dart';
import 'test/test_screen.dart';
import 'history/history_screen.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> modules = [
    {'title': 'Study Mode', 'screen': StudyScreen()},
    {'title': 'Training', 'screen': TrainingScreen()},
    {'title': 'Start Test', 'screen': TestScreen()},
    {'title': 'Progress History', 'screen': HistoryScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Multiplication Learning App')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        itemBuilder: (context, index) {
          return AnimatedButton(
            title: modules[index]['title'],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => modules[index]['screen']),
              );
            },
          );
        },
      ),
    );
  }
}

class AnimatedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const AnimatedButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurpleAccent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      ),
    );
  }
}
