import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aniverse/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: AniVerseApp(showOnboarding: false),
      ),
    );

    // Verify that the app title is present
    expect(find.text('AniVerse'), findsOneWidget);
  });

  testWidgets('Home screen has bottom navigation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: AniVerseApp(showOnboarding: false),
      ),
    );
    await tester.pumpAndSettle();

    // Verify bottom navigation items exist
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Manga'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
