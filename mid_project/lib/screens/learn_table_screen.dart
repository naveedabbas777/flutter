import 'package:flutter/material.dart';
import 'table_quiz_screen.dart';

class LearnTableScreen extends StatelessWidget {
  const LearnTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn Tables")),
      body: GridView.builder(
        itemCount: 18,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
        ),
        itemBuilder: (context, index) {
          int table = index + 1;
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TableQuizScreen(table: table),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  "x$table",
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
