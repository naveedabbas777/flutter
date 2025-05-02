import 'package:flutter/material.dart';
import 'multiple_choice_screen.dart';
import 'true_false_screen.dart';
import 'input_answer_screen.dart';

class TrainingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Training Mode")),
      body: Column(
        children: [
          TrainingOption(
            title: "Multiple Choice",
            screen: MultipleChoiceScreen(),
          ),
          TrainingOption(title: "True / False", screen: TrueFalseScreen()),
          TrainingOption(title: "Input Answer", screen: InputAnswerScreen()),
        ],
      ),
    );
  }
}

class TrainingOption extends StatelessWidget {
  final String title;
  final Widget screen;

  const TrainingOption({required this.title, required this.screen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
        },
        child: Center(child: Text(title, style: TextStyle(fontSize: 18))),
      ),
    );
  }
}
