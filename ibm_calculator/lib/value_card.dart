import 'package:flutter/material.dart';
import 'card_section.dart';

class ValueCard extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const ValueCard({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    super.key,
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
                IconButton(
                  onPressed: onDecrement,
                  icon: const Icon(Icons.remove),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    fixedSize: const Size(40, 40),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add),
                  color: Colors.white,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    fixedSize: const Size(40, 40),
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
