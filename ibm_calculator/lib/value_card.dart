import 'package:flutter/material.dart';
import 'card_section.dart';

class ValueCard extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ValueCard({
    super.key,
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CardSection(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(color: Colors.white)),
            Text(
              '$value',
              style: const TextStyle(color: Colors.white, fontSize: 30),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onDecrement,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.remove, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onIncrement,
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
