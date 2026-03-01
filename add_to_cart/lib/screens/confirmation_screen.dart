import 'package:add_to_cart/routes/app_routes.dart';
import 'package:add_to_cart/state/cart_store.dart';
import 'package:add_to_cart/utils/formatters.dart';
import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  const ConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final argsRaw = ModalRoute.of(context)?.settings.arguments;
    final args =
        argsRaw is Map ? Map<String, String>.from(argsRaw) : <String, String>{};
    final name = args['name'] ?? '';
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth =
              constraints.maxWidth > 900 ? 900.0 : constraints.maxWidth;

          return Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              child: Icon(Icons.check_circle_rounded),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              name.isEmpty
                                  ? 'Ready to place order?'
                                  : 'Thanks, $name!',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: isNarrow ? 18 : 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Review total and place your order securely.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: CartStore.items.entries.length,
                        itemBuilder: (context, index) {
                          final entry = CartStore.items.entries.elementAt(
                            index,
                          );
                          final item = entry.key;
                          final quantity = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Card(
                              child: ListTile(
                                title: Text(item.name),
                                subtitle: Text('Qty: $quantity'),
                                trailing: Text(
                                  formatCurrency(item.price * quantity),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  formatCurrency(CartStore.total),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  CartStore.clear();
                                  showDialog<void>(
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Order Placed'),
                                        content: const Text(
                                          'Your delicious items are on the way!',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              Navigator.popUntil(
                                                context,
                                                ModalRoute.withName(
                                                  AppRoutes.home,
                                                ),
                                              );
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: const Text('Place Order'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
