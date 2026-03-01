import 'package:add_to_cart/routes/app_routes.dart';
import 'package:add_to_cart/state/cart_store.dart';
import 'package:add_to_cart/utils/formatters.dart';
import 'package:flutter/material.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final items = CartStore.items.entries.toList();
    final isNarrow = MediaQuery.sizeOf(context).width < 360;

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
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
                child:
                    items.isEmpty
                        ? const Center(
                          child: Text(
                            'Your cart is empty',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                        : Column(
                          children: [
                            Expanded(
                              child: ListView.separated(
                                itemCount: items.length,
                                separatorBuilder:
                                    (_, __) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final entry = items[index];
                                  final item = entry.key;
                                  final quantity = entry.value;

                                  return Card(
                                    child: Padding(
                                      padding: EdgeInsets.all(
                                        isNarrow ? 8 : 10,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: isNarrow ? 16 : 20,
                                            child: Icon(
                                              item.icon,
                                              size: isNarrow ? 18 : 22,
                                            ),
                                          ),
                                          SizedBox(width: isNarrow ? 8 : 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                                Text(
                                                  '${formatCurrency(item.price)} × $quantity',
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              setState(() {
                                                CartStore.decrement(item);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.remove_circle_outline,
                                            ),
                                          ),
                                          Text(
                                            '$quantity',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: isNarrow ? 13 : 14,
                                            ),
                                          ),
                                          IconButton(
                                            visualDensity:
                                                VisualDensity.compact,
                                            onPressed: () {
                                              setState(() {
                                                CartStore.increment(item);
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Items (${CartStore.count})',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
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
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.checkout,
                                          );
                                        },
                                        child: const Text(
                                          'Proceed to Checkout',
                                        ),
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
