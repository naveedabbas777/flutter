import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TableQuizScreen extends StatelessWidget {
  final int table;
  const TableQuizScreen({super.key, required this.table});

  Future<void> saveProgress(int table) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('table_$table', true);
  }

  @override
  Widget build(BuildContext context) {
    saveProgress(table);
    return Scaffold(
      appBar: AppBar(title: Text("Table of $table")),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (_, index) {
          int multiplier = index + 1;
          return ListTile(
            title: Text(
              "$table x $multiplier = ${table * multiplier}",
              style: const TextStyle(fontSize: 20),
            ),
          );
        },
      ),
    );
  }
}
