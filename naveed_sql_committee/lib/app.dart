import 'package:flutter/material.dart';
import 'screens/clients_screen.dart';

class CommitteeApp extends StatelessWidget {
  const CommitteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1565C0),
        secondary: Color(0xFF00897B),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F7FB),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      appBarTheme: const AppBarTheme(centerTitle: false),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Committee Management System',
      theme: appTheme,
      home: const ClientsScreen(),
    );
  }
}
