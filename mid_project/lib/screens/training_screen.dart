import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  String selectedDifficulty = "Easy";
  int stars = 0;

  @override
  void initState() {
    super.initState();
    loadStars();
  }

  Future<void> loadStars() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      stars = prefs.getInt('training_stars') ?? 0;
    });
  }

  Future<void> addStars(int points) async {
    final prefs = await SharedPreferences.getInstance();
    stars += points;
    await prefs.setInt('training_stars', stars);
    setState(() {});
  }

  Widget _buildDifficultyButton(String label) {
    bool isSelected = selectedDifficulty == label;
    return GestureDetector(
      onTap: () => setState(() => selectedDifficulty = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildModeButton(String label, int reward) {
    return GestureDetector(
      onTap: () {
        addStars(reward);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label mode started! +$reward ✨")),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Training")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text("Select Difficulty", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  [
                    "Easy",
                    "Medium",
                    "Hard",
                  ].map(_buildDifficultyButton).toList(),
            ),
            const SizedBox(height: 30),
            _buildModeButton("Test Mode", 10),
            _buildModeButton("True/False Mode", 8),
            _buildModeButton("Input Mode", 12),
            const Spacer(),
            Text(
              "✨ Stars Earned: $stars",
              style: const TextStyle(fontSize: 18, color: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }
}
