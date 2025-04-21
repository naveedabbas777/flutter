import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String difficulty = "Easy";
  int totalTests = 0;

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      totalTests = prefs.getInt('test_history') ?? 0;
    });
  }

  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('test_history');
    loadData();
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Widget _buildDifficultyButton(String label) {
    bool selected = label == difficulty;
    return GestureDetector(
      onTap: () => setState(() => difficulty = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.deepPurple : Colors.grey[300],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Start Test")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Select Difficulty:", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
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
            ElevatedButton(
              onPressed: () {
                // Placeholder action
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("Test started!")));
              },
              child: const Text("Start Test"),
            ),
            const Spacer(),
            Text("Total Tests Taken: $totalTests"),
            TextButton(
              onPressed: clearHistory,
              child: const Text("Clear History"),
            ),
          ],
        ),
      ),
    );
  }
}
