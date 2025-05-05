import 'package:flutter/material.dart';

class CardSection extends StatelessWidget {
  final Widget child;
  final Color color;

  const CardSection({
    required this.child,
    this.color = const Color(0xFF1D1E33),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: child,
    );
  }
}
