import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(MultiplicationApp());
}

class MultiplicationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Multiplication Table',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: HomeScreen(),
    );
  }
}
