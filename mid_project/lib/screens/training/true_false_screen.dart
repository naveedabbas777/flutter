import 'package:flutter/material.dart';
import '../../utils/storage.dart';

class TrueFalseScreen extends StatefulWidget {
  @override
  _TrueFalseScreenState createState() => _TrueFalseScreenState();
}

class _TrueFalseScreenState extends State<TrueFalseScreen> {
  int _a = 1, _b = 1, _c = 1, _score = 0;
  bool _isCorrect = true;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _generateQuestion() {
    setState(() {
      _a = 1 + (DateTime.now().millisecondsSinceEpoch % 12);
      _b = 1 + (DateTime.now().millisecondsSinceEpoch % 12);
      _isCorrect = (DateTime.now().millisecondsSinceEpoch % 2 == 0);
      _c =
          _isCorrect
              ? _a * _b
              : _a * _b + (1 + DateTime.now().millisecondsSinceEpoch % 3);
    });
  }

  void _answer(bool answer) async {
    if (answer == _isCorrect) {
      _score++;
      await Storage.saveScore('true_false', _score);
    }
    _generateQuestion();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("True / False")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$_a × $_b = $_c", style: TextStyle(fontSize: 28)),
          SizedBox(height: 30),
          ElevatedButton(onPressed: () => _answer(true), child: Text("True")),
          ElevatedButton(onPressed: () => _answer(false), child: Text("False")),
          SizedBox(height: 20),
          Text("Score: $_score", style: TextStyle(fontSize: 22)),
        ],
      ),
    );
  }
}
