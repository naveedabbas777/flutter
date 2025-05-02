import 'package:flutter/material.dart';
import '../../utils/storage.dart';

class InputAnswerScreen extends StatefulWidget {
  @override
  _InputAnswerScreenState createState() => _InputAnswerScreenState();
}

class _InputAnswerScreenState extends State<InputAnswerScreen> {
  int _a = 1, _b = 1, _score = 0;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      _a = 1 + (DateTime.now().millisecondsSinceEpoch % 12);
      _b = 1 + (DateTime.now().millisecondsSinceEpoch % 12);
      _controller.clear();
    });
  }

  void _submit() async {
    if (int.tryParse(_controller.text) == _a * _b) {
      _score++;
      await Storage.saveScore('input_answer', _score);
    }
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Input Answer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$_a × $_b = ?", style: TextStyle(fontSize: 28)),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Your Answer'),
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text("Submit")),
            SizedBox(height: 20),
            Text("Score: $_score", style: TextStyle(fontSize: 22)),
          ],
        ),
      ),
    );
  }
}
