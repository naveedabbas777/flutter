import 'package:flutter/material.dart';

class StudyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Study Tables')),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          int table = index + 1;
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text("Table of $table"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TableDetailScreen(table: table),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class TableDetailScreen extends StatelessWidget {
  final int table;
  const TableDetailScreen({required this.table});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Table of $table")),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (context, index) {
          int multiplier = index + 1;
          return ListTile(
            title: Text('$table × $multiplier = ${table * multiplier}'),
          );
        },
      ),
    );
  }
}
