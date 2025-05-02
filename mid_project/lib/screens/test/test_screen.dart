import 'package:flutter/material.dart';
import '../../utils/storage.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _a = 1, _b = 1, _score = 0, _questionCount = 0;
  final _controller = TextEditingController();
  final int _totalQuestions = 10;

  @override
  void initState() {
    super.initState();
    _nextQuestion();
  }

  void _nextQuestion() {
    setState(() {
      _a = 1 + (DateTime.now().millisecondsSinceEpoch % 12);
      _b = 1 + (DateTime.now().millisecondsSinceEpoch % 12);
      _controller.clear();
    });
  }

  void _submitAnswer() async {
    if (int.tryParse(_controller.text) == _a * _b) {
      _score++;
    }
    _questionCount++;
    if (_questionCount < _totalQuestions) {
      _nextQuestion();
    } else {
      await Storage.saveTestResult(_score, _totalQuestions);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) => TestResultScreen(score: _score, total: _totalQuestions),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Mode")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Question ${_questionCount + 1} of $_totalQuestions",
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text("$_a × $_b = ?", style: TextStyle(fontSize: 28)),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submitAnswer, child: Text("Submit")),
          ],
        ),
      ),
    );
  }
}

class TestResultScreen extends StatelessWidget {
  final int score;
  final int total;

  const TestResultScreen({required this.score, required this.total});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Result")),
      body: Center(
        child: Text(
          "You scored $score out of $total",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
