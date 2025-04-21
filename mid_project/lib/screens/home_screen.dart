import 'package:flutter/material.dart';
import 'training_screen.dart';
import 'learn_table_screen.dart';
import 'test_screen.dart';
import 'puzzle_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Multiplication Learning App")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _buildTile(context, "Training", Icons.school, const TrainingScreen()),
          _buildTile(
            context,
            "Learn Table",
            Icons.table_chart,
            const LearnTableScreen(),
          ),
          _buildTile(
            context,
            "Start Test",
            Icons.play_circle,
            const TestScreen(),
          ),
          _buildTile(context, "Puzzles", Icons.extension, const PuzzleScreen()),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen,
  ) {
    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple[100],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.deepPurple),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
