import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final String baseUrl = "http://<YOUR_PC_IP>:3000/items";
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  Future<List> fetchItems() async {
    final response = await http.get(Uri.parse('$baseUrl?search=$searchQuery'));
    return json.decode(response.body);
  }

  Future<void> addItem(String name, int price) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"name": name, "price": price}),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Item Manager")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: "Search Item",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      searchQuery = searchController.text;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = int.tryParse(priceController.text.trim()) ?? 0;
                if (name.isNotEmpty && price > 0) {
                  addItem(name, price);
                  nameController.clear();
                  priceController.clear();
                }
              },
              child: Text("Add Item"),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List>(
                future: fetchItems(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());
                  final items = snapshot.data!;
                  if (items.isEmpty) return Text("No items found.");
                  return ListView.builder(
                    itemCount: items.length,
                    itemBuilder:
                        (_, index) => ListTile(
                          title: Text(items[index]['name']),
                          subtitle: Text("PKR ${items[index]['price']}"),
                        ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
