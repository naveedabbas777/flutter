import 'package:flutter/material.dart';
import '../../utils/storage.dart';

class HistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: Storage.getAllScores(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());
        final data = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text("Progress History"),
            actions: [
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  Storage.clearAll();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Progress Cleared")));
                },
              ),
            ],
          ),
          body: ListView(
            children:
                data.entries
                    .map(
                      (e) =>
                          ListTile(title: Text("${e.key} Score: ${e.value}")),
                    )
                    .toList(),
          ),
        );
      },
    );
  }
}
