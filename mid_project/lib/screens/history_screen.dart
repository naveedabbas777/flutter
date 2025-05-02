import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<String> scores = [];

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      scores = prefs.getStringList('trainingScores') ?? [];
    });
  }

  Future<void> _clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('trainingScores');
    setState(() {
      scores = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Progress History"),
        actions: [
          IconButton(onPressed: _clearHistory, icon: const Icon(Icons.delete)),
        ],
      ),
      body:
          scores.isEmpty
              ? const Center(child: Text("No scores yet."))
              : ListView(
                children:
                    scores
                        .map((score) => ListTile(title: Text(score)))
                        .toList(),
              ),
    );
  }
}
