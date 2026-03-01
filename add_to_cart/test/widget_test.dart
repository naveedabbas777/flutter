import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:add_to_cart/main.dart';

void main() {
  testWidgets('Shows storefront content', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Snack Bazaar'), findsOneWidget);
    expect(find.text('Daily Deals'), findsOneWidget);
  });

  testWidgets('Opens cart from header', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined).first);
    await tester.pumpAndSettle();

    expect(find.text('Your Cart'), findsOneWidget);
    expect(find.text('Your cart is empty'), findsOneWidget);
  });
}
