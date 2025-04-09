import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext buildContext) {
    return MaterialApp(
      title: 'Chit Fund Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chit_fund.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const memberTable = '''CREATE TABLE members (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT
    )''';

    const contributionTable = '''CREATE TABLE contributions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      memberId INTEGER,
      amount REAL,
      date TEXT,
      FOREIGN KEY(memberId) REFERENCES members(id)
    )''';

    await db.execute(memberTable);
    await db.execute(contributionTable);
  }

  Future<int> addMember(String name) async {
    final db = await instance.database;
    final id = await db.insert('members', {'name': name});
    return id;
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    final db = await instance.database;
    return await db.query('members');
  }

  Future<int> addContribution(int memberId, double amount) async {
    final db = await instance.database;
    final date = DateTime.now().toIso8601String();
    final contribution = {'memberId': memberId, 'amount': amount, 'date': date};
    return await db.insert('contributions', contribution);
  }

  Future<List<Map<String, dynamic>>> getContributions() async {
    final db = await instance.database;
    return await db.query('contributions');
  }

  Future<List<Map<String, dynamic>>> getMonthlyContributions() async {
    final db = await instance.database;
    DateTime now = DateTime.now();
    String startOfMonth = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month, 1));
    String endOfMonth = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime(now.year, now.month + 1, 0));

    return await db.rawQuery(
      'SELECT * FROM contributions WHERE date BETWEEN ? AND ?',
      [startOfMonth, endOfMonth],
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final String correctUsername = 'admin';
  final String correctPassword = '1234';

  void _login(BuildContext buildContext) {
    if (_usernameController.text == correctUsername &&
        _passwordController.text == correctPassword) {
      Navigator.pushReplacement(
        buildContext,
        MaterialPageRoute(builder: (buildContext) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(
        buildContext,
      ).showSnackBar(SnackBar(content: Text('Invalid username or password')));
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(buildContext),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> members = [];
  List<Map<String, dynamic>> contributions = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
    _loadContributions();
  }

  void _loadMembers() async {
    final memberList = await DatabaseHelper.instance.getMembers();
    setState(() {
      members = memberList;
    });
  }

  void _loadContributions() async {
    final contributionList = await DatabaseHelper.instance.getContributions();
    setState(() {
      contributions = contributionList;
    });
  }

  void _addMember(String memberName, BuildContext buildContext) async {
    int id = await DatabaseHelper.instance.addMember(memberName);
    ScaffoldMessenger.of(buildContext).showSnackBar(
      SnackBar(content: Text('Member added successfully! ID: $id')),
    );
    _loadMembers(); // Reload members after adding
  }

  void _addContribution(
    int memberId,
    double amount,
    BuildContext buildContext,
  ) async {
    await DatabaseHelper.instance.addContribution(memberId, amount);
    ScaffoldMessenger.of(buildContext).showSnackBar(
      SnackBar(content: Text('Contribution recorded successfully!')),
    );
    _loadContributions(); // Reload contributions after adding
  }

  void _luckyDraw(BuildContext buildContext) {
    if (members.isNotEmpty) {
      var randomMember = (members..shuffle()).first;
      ScaffoldMessenger.of(buildContext).showSnackBar(
        SnackBar(content: Text('Lucky Draw Winner: ${randomMember['name']}')),
      );
    }
  }

  void _viewMonthlyContributions(BuildContext buildContext) async {
    var monthlyContributions =
        await DatabaseHelper.instance.getMonthlyContributions();
    double totalContributions = monthlyContributions.fold(
      0.0,
      (sum, item) => sum + item['amount'],
    );
    showDialog(
      context: buildContext,
      builder: (BuildContext buildContext) {
        return AlertDialog(
          title: Text('Monthly Contributions'),
          content: Text(
            'Total Contributions This Month: \$${totalContributions.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(buildContext).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: Text('Chit Fund Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  buildContext,
                  MaterialPageRoute(
                    builder:
                        (buildContext) =>
                            AddMemberScreen(addMember: _addMember),
                  ),
                );
              },
              child: Text('Add Member'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  buildContext,
                  MaterialPageRoute(
                    builder:
                        (buildContext) => RecordContributionScreen(
                          addContribution: _addContribution,
                          members: members,
                        ),
                  ),
                );
              },
              child: Text('Record Contribution'),
            ),
            ElevatedButton(
              onPressed: () => _viewMonthlyContributions(buildContext),
              child: Text('View Monthly Contributions'),
            ),
            ElevatedButton(
              onPressed: () => _luckyDraw(buildContext),
              child: Text('Lucky Draw'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: members.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(members[index]['name']));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddMemberScreen extends StatefulWidget {
  final Function(String, BuildContext) addMember;

  AddMemberScreen({required this.addMember});

  @override
  _AddMemberScreenState createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameController = TextEditingController();

  void _submit(BuildContext buildContext) {
    String name = _nameController.text;
    if (name.isNotEmpty) {
      widget.addMember(name, buildContext);
      Navigator.pop(buildContext);
    } else {
      ScaffoldMessenger.of(
        buildContext,
      ).showSnackBar(SnackBar(content: Text('Please enter a valid name')));
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Member')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Member Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submit(buildContext),
              child: Text('Add Member'),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordContributionScreen extends StatefulWidget {
  final Function(int, double, BuildContext) addContribution;
  final List<Map<String, dynamic>> members;

  RecordContributionScreen({
    required this.addContribution,
    required this.members,
  });

  @override
  _RecordContributionScreenState createState() =>
      _RecordContributionScreenState();
}

class _RecordContributionScreenState extends State<RecordContributionScreen> {
  final _amountController = TextEditingController();
  int? selectedMemberId;

  void _submitContribution(BuildContext buildContext) {
    if (selectedMemberId != null) {
      double amount = double.tryParse(_amountController.text) ?? 0.0;
      if (amount > 0) {
        widget.addContribution(selectedMemberId!, amount, buildContext);
        Navigator.pop(buildContext);
      } else {
        ScaffoldMessenger.of(
          buildContext,
        ).showSnackBar(SnackBar(content: Text('Invalid amount!')));
      }
    } else {
      ScaffoldMessenger.of(
        buildContext,
      ).showSnackBar(SnackBar(content: Text('Please select a member!')));
    }
  }

  @override
  Widget build(BuildContext buildContext) {
    return Scaffold(
      appBar: AppBar(title: Text('Record Contribution')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<int>(
              value: selectedMemberId,
              items:
                  widget.members
                      .map(
                        (member) => DropdownMenuItem<int>(
                          value: member['id'],
                          child: Text(member['name']),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  selectedMemberId = value;
                });
              },
              decoration: InputDecoration(labelText: 'Select Member'),
              hint: Text('Choose a member'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Contribution Amount'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _submitContribution(buildContext),
              child: Text('Record Contribution'),
            ),
          ],
        ),
      ),
    );
  }
}
