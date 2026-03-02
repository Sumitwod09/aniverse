// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aniverse/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AniVerseApp());

    // Verify that the app title is present
    expect(find.text('AniVerse'), findsOneWidget);
  });

  testWidgets('Home screen has bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const AniVerseApp());
    await tester.pumpAndSettle();

    // Verify bottom navigation items exist
    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
    expect(find.byIcon(Icons.bookmark), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
  });
}
