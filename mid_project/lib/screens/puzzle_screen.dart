import 'package:flutter/material.dart';

class PuzzleScreen extends StatelessWidget {
  const PuzzleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Puzzles")),
      body: Center(
        child: Text("Puzzle mode coming soon!", style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
