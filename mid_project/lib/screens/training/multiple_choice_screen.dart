import 'package:flutter/material.dart';
import '../../utils/storage.dart';

class MultipleChoiceScreen extends StatefulWidget {
  @override
  _MultipleChoiceScreenState createState() => _MultipleChoiceScreenState();
}

class _MultipleChoiceScreenState extends State<MultipleChoiceScreen> {
  int _a = 1, _b = 1, _score = 0;
  List<int> options = [];

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      _a =
          (1 + (12 * (new DateTime.now().millisecondsSinceEpoch % 100) / 100))
              .toInt();
      _b =
          (1 + (12 * (new DateTime.now().millisecondsSinceEpoch % 200) / 200))
              .toInt();
      int correct = _a * _b;
      options = [correct];
      while (options.length < 4) {
        int wrong =
            (1 +
                    (144 *
                        (new DateTime.now().millisecondsSinceEpoch % 300) /
                        300))
                .toInt();
        if (!options.contains(wrong)) options.add(wrong);
      }
      options.shuffle();
    });
  }

  void _checkAnswer(int answer) async {
    if (answer == _a * _b) {
      _score++;
      await Storage.saveScore('multiple_choice', _score);
    }
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Multiple Choice")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$_a × $_b = ?", style: TextStyle(fontSize: 28)),
          ...options.map(
            (e) => Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: () => _checkAnswer(e),
                child: Text('$e', style: TextStyle(fontSize: 20)),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text("Score: $_score", style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
