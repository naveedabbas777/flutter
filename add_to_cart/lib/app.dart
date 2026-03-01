import 'package:add_to_cart/routes/app_routes.dart';
import 'package:add_to_cart/screens/cart_screen.dart';
import 'package:add_to_cart/screens/checkout_screen.dart';
import 'package:add_to_cart/screens/confirmation_screen.dart';
import 'package:add_to_cart/screens/home_screen.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF5B4CE1),
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    ).copyWith(
      primary: const Color(0xFF5B4CE1),
      secondary: const Color(0xFF00A89D),
      tertiary: const Color(0xFFFF6A6A),
      surface: Colors.white,
      surfaceContainerLowest: const Color(0xFFF6F7FB),
    );

    return MaterialApp(
      title: 'Snack Bazaar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: scheme.onSurface,
        ),
        textTheme: ThemeData.light().textTheme.copyWith(
          titleLarge: const TextStyle(fontWeight: FontWeight.w800),
          titleMedium: const TextStyle(fontWeight: FontWeight.w700),
        ),
        cardTheme: CardThemeData(
          margin: EdgeInsets.zero,
          elevation: 1,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 0,
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.white,
          selectedColor: scheme.primaryContainer,
          side: BorderSide(color: scheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: TextStyle(color: scheme.onSurface),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
        ),
      ),
      routes: {
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.cart: (_) => const CartScreen(),
        AppRoutes.checkout: (_) => const CheckoutScreen(),
        AppRoutes.confirmation: (_) => const ConfirmationScreen(),
      },
    );
  }
}
