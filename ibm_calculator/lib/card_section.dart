import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final Widget child;

  const CardSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
