import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:math';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Calculator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _input = '';
  String _result = '';
  late Database _database;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calculator.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE history(id INTEGER PRIMARY KEY AUTOINCREMENT, expression TEXT, result TEXT)',
        );
      },
    );
    _loadHistory();
  }

  Future<void> _saveToHistory(String expression, String result) async {
    await _database.insert('history', {
      'expression': expression,
      'result': result,
    });
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _database.query('history', orderBy: 'id DESC');
    setState(() {
      _history = data;
    });
  }

  Future<void> _clearHistory() async {
    await _database.delete('history');
    _loadHistory();
  }

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _input = '';
        _result = '';
      } else if (value == '=') {
        try {
          String finalInput = _input.replaceAll('x', '*').replaceAll('÷', '/');
          final expression = finalInput;
          final res = _evaluateExpression(finalInput);
          _result = res.toString();
          _saveToHistory(expression, res.toString());
        } catch (e) {
          _result = 'Error';
        }
      } else {
        _input += value;
      }
    });
  }

  double _evaluateExpression(String expression) {
    try {
      final exp = expression.replaceAll('×', '*').replaceAll('÷', '/');
      final result = _safeEval(exp);
      return result;
    } catch (e) {
      return 0;
    }
  }

  double _safeEval(String expression) {
    try {
      // Using dart:math to perform arithmetic operations
      final result = _calculate(expression);
      return result;
    } catch (e) {
      return 0;
    }
  }

  double _calculate(String expression) {
    try {
      final res = _parseAndEvaluate(expression);
      return res;
    } catch (e) {
      return 0;
    }
  }

  double _parseAndEvaluate(String expression) {
    final parser = ExpressionParser(expression);
    return parser.evaluate();
  }

  Widget _buildButton(String value, {Color? color}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(value),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.deepPurple.shade400,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(value, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_input, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    _result,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildButton('7'),
                        _buildButton('8'),
                        _buildButton('9'),
                        _buildButton('÷', color: Colors.orange),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('4'),
                        _buildButton('5'),
                        _buildButton('6'),
                        _buildButton('x', color: Colors.orange),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('1'),
                        _buildButton('2'),
                        _buildButton('3'),
                        _buildButton('-', color: Colors.orange),
                      ],
                    ),
                    Row(
                      children: [
                        _buildButton('0'),
                        _buildButton('.'),
                        _buildButton('C', color: Colors.red),
                        _buildButton('+', color: Colors.orange),
                      ],
                    ),
                    Row(children: [_buildButton('=', color: Colors.green)]),
                    const Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const Text(
                            'History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _clearHistory,
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return ListTile(
                          title: Text(item['expression']),
                          subtitle: Text('= ${item['result']}'),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExpressionParser {
  final String expression;
  late List<String> _tokens;

  ExpressionParser(this.expression);

  void _tokenize() {
    _tokens = [];
    final buffer = StringBuffer();
    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      if ('0123456789.'.contains(char)) {
        buffer.write(char);
      } else if ('+-*/()'.contains(char)) {
        if (buffer.isNotEmpty) {
          _tokens.add(buffer.toString());
          buffer.clear();
        }
        _tokens.add(char);
      }
    }
    if (buffer.isNotEmpty) {
      _tokens.add(buffer.toString());
    }
  }

  double evaluate() {
    _tokenize();
    return _evaluateTokens(_tokens);
  }

  double _evaluateTokens(List<String> tokens) {
    final ops = <String>[];
    final nums = <double>[];

    for (var token in tokens) {
      if ('0123456789.'.contains(token)) {
        nums.add(double.parse(token));
      } else if ('+-*/'.contains(token)) {
        while (ops.isNotEmpty && _precedence(ops.last) >= _precedence(token)) {
          final op = ops.removeLast();
          final b = nums.removeLast();
          final a = nums.removeLast();
          nums.add(_applyOperator(op, a, b));
        }
        ops.add(token);
      } else if (token == '(') {
        ops.add(token);
      } else if (token == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          final op = ops.removeLast();
          final b = nums.removeLast();
          final a = nums.removeLast();
          nums.add(_applyOperator(op, a, b));
        }
        ops.removeLast(); // Remove '('
      }
    }

    while (ops.isNotEmpty) {
      final op = ops.removeLast();
      final b = nums.removeLast();
      final a = nums.removeLast();
      nums.add(_applyOperator(op, a, b));
    }

    return nums.first;
  }

  int _precedence(String op) {
    if (op == '+' || op == '-') {
      return 1;
    } else if (op == '*' || op == '/') {
      return 2;
    }
    return 0;
  }

  double _applyOperator(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        if (b == 0) {
          throw 'Division by zero';
        }
        return a / b;
      default:
        throw 'Invalid operator';
    }
  }
}
