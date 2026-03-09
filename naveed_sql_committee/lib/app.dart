import 'package:flutter/material.dart';
import 'screens/clients_screen.dart';
import 'screens/login_screen.dart';

class CommitteeApp extends StatelessWidget {
  const CommitteeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF1976D2), // Vibrant blue for primary actions
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE3F2FD), // Light blue for backgrounds
        onPrimaryContainer: Color(0xFF0D47A1),
        secondary: Color(0xFF4CAF50), // Green for success/add
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8F5E8),
        onSecondaryContainer: Color(0xFF1B5E20),
        tertiary: Color(0xFFFF9800), // Orange for edit/warning
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFFFF3E0),
        onTertiaryContainer: Color(0xFFE65100),
        error: Color(0xFFF44336), // Red for delete/error
        onError: Colors.white,
        errorContainer: Color(0xFFFFEBEE),
        onErrorContainer: Color(0xFFB71C1C),
        surface: Colors.white,
        onSurface: Color(0xFF1C1B1F),
        surfaceVariant: Color(0xFFE7E0EC),
        onSurfaceVariant: Color(0xFF49454F),
        outline: Color(0xFF79747E),
        outlineVariant: Color(0xFFCAC4D0),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFF313033),
        onInverseSurface: Color(0xFFF4EFF4),
        inversePrimary: Color(0xFFA4C8FF),
        surfaceTint: Color(0xFF1976D2),
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F9FA), // Light gray background
      cardTheme: CardThemeData(
        elevation: 2,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF49454F)),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1976D2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Committee Management System',
      theme: appTheme,
      home: const LoginScreen(),
    );
  }
}
