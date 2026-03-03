// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:mongodp_api_app/app.dart';

void main() {
  testWidgets('Weather app renders title', (WidgetTester tester) async {
    await tester.pumpWidget(const WeatherApp());
    expect(find.text('Weather Insights'), findsOneWidget);
  });
}
