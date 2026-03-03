// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:flash/main.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('shows empty state initially', (WidgetTester tester) async {
    await tester.pumpWidget(const FlashcardApp());
    await tester.pumpAndSettle();

    expect(find.text('Flashcard App'), findsOneWidget);
    expect(find.text('No flashcards. Add some!'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsWidgets);
  });
}
