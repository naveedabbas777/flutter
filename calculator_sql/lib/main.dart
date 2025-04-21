import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Advanced Calculator',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      routes: {'/currency': (context) => const CurrencyConverterPage()},
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});
  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _input = '';
  String _result = '';
  double _answer = 0.0;
  late Database _database;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  Future<void> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calc.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE history(id INTEGER PRIMARY KEY, expression TEXT, result TEXT)',
        );
      },
    );
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await _database.query('history', orderBy: 'id DESC');
    setState(() => _history = data);
  }

  Future<void> _saveHistory(String expression, String result) async {
    await _database.insert('history', {
      'expression': expression,
      'result': result,
    });
    _loadHistory();
  }

  Future<void> _clearHistory() async {
    await _database.delete('history');
    _loadHistory();
  }

  void _onPressed(String val) {
    setState(() {
      if (val == 'C') {
        _input = '';
        _result = '';
      } else if (val == '⌫') {
        _input =
            _input.isNotEmpty ? _input.substring(0, _input.length - 1) : '';
      } else if (val == '=') {
        try {
          String expr = _input.replaceAll('x', '*').replaceAll('÷', '/');
          expr = expr.replaceAll('√', 'sqrt');
          expr = expr.replaceAll('Ans', _answer.toString());

          final result = _evaluate(expr);
          _answer = result;
          _result = result.toString();
          _saveHistory(_input, _result);
          _input = '';
        } catch (e) {
          _result = 'Error';
        }
      } else {
        if (_input.isEmpty && RegExp(r'[0-9(√]').hasMatch(val)) {
          _input = val;
        } else {
          _input += val;
        }
      }
    });
  }

  double _evaluate(String expr) {
    expr = expr.replaceAllMapped(RegExp(r'sqrt\((.*?)\)'), (m) {
      final value = double.tryParse(m.group(1)!) ?? 0.0;
      return sqrt(value).toString();
    });

    final parser = ExpressionParser(expr);
    return parser.evaluate();
  }

  Widget _btn(String text, {Color? color, Color? textColor}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onPressed(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Colors.deepPurple.shade400,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(fontSize: 20, color: textColor ?? Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.currency_exchange),
            onPressed: () => Navigator.pushNamed(context, '/currency'),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_input, style: const TextStyle(fontSize: 22)),
                Text(
                  'Ans: $_answer',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                Text(
                  _result,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          ...[
            ['7', '8', '9', '÷'],
            ['4', '5', '6', 'x'],
            ['1', '2', '3', '-'],
            ['0', '.', '⌫', '+'],
            ['(', ')', '√(', '='],
            ['C', 'Ans', '', ''],
          ].map(
            (row) => Row(
              children:
                  row
                      .map(
                        (val) =>
                            val.isEmpty
                                ? const Spacer()
                                : _btn(
                                  val,
                                  color:
                                      val == '⌫' || val == 'C'
                                          ? Colors.red
                                          : (val == '+' ||
                                              val == '-' ||
                                              val == 'x' ||
                                              val == '÷')
                                          ? Colors.orange
                                          : null,
                                  textColor:
                                      val == 'Ans' ? Colors.orange : null,
                                ),
                      )
                      .toList(),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                const Text(
                  'History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearHistory,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _history.length,
              itemBuilder:
                  (context, i) => ListTile(
                    title: Text(_history[i]['expression']),
                    subtitle: Text('= ${_history[i]['result']}'),
                  ),
            ),
          ),
        ],
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
    if (buffer.isNotEmpty) _tokens.add(buffer.toString());
  }

  double evaluate() {
    _tokenize();
    return _evalTokens(_tokens);
  }

  double _evalTokens(List<String> tokens) {
    final ops = <String>[];
    final nums = <double>[];

    for (var token in tokens) {
      if (double.tryParse(token) != null) {
        nums.add(double.parse(token));
      } else if ('+-*/'.contains(token)) {
        while (ops.isNotEmpty && _precedence(ops.last) >= _precedence(token)) {
          _apply(ops, nums);
        }
        ops.add(token);
      } else if (token == '(') {
        ops.add(token);
      } else if (token == ')') {
        while (ops.isNotEmpty && ops.last != '(') {
          _apply(ops, nums);
        }
        ops.removeLast();
      }
    }

    while (ops.isNotEmpty) {
      _apply(ops, nums);
    }

    return nums.first;
  }

  void _apply(List<String> ops, List<double> nums) {
    final op = ops.removeLast();
    final b = nums.removeLast();
    final a = nums.removeLast();
    nums.add(_applyOperator(op, a, b));
  }

  int _precedence(String op) => (op == '+' || op == '-') ? 1 : 2;

  double _applyOperator(String op, double a, double b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
        return b == 0 ? 0 : a / b;
      default:
        throw Exception('Unknown operator');
    }
  }
}

class CurrencyConverterPage extends StatefulWidget {
  const CurrencyConverterPage({super.key});
  @override
  State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
}

class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
  final TextEditingController _amountController = TextEditingController();
  String _from = 'USD';
  String _to = 'PKR';
  double _converted = 0.0;
  Map<String, double> _rates = {};
  final List<String> _currencies = ['USD', 'EUR', 'GBP', 'PKR', 'INR', 'JPY'];

  Future<void> _fetchRates() async {
    final uri = Uri.parse(
      'http://data.fixer.io/api/latest?access_key=325ce67e0d6e3c6580c0eb1d72091ab3',
    );
    final res = await http.get(uri);
    final json = jsonDecode(res.body);
    setState(() => _rates = Map<String, double>.from(json['rates']));
  }

  void _convert() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final rate = _rates[_to] ?? 0.0;
    setState(() => _converted = amount * rate);
  }

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Currency Converter')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Enter amount'),
              keyboardType: TextInputType.number,
            ),
            Row(
              children: [
                DropdownButton<String>(
                  value: _from,
                  items:
                      _currencies
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) {
                    setState(() => _from = val!);
                    _fetchRates();
                  },
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _to,
                  items:
                      _currencies
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (val) => setState(() => _to = val!),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _convert, child: const Text('Convert')),
            Text('Converted: $_converted $_to'),
          ],
        ),
      ),
    );
  }
}
