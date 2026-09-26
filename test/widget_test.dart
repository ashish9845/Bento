import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan/main.dart';

void main() {
  testWidgets('BenoApp boots to Home with nav shell', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const ProviderScope(child: BenoApp()));
    // Explicit pumps instead of pumpAndSettle: background async work
    // (prefs/engine warm-up) can hold pending timers under the standard
    // binding without scheduling frames.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Home dashboard: search + shortcuts + bottom nav.
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_shortcut_scan')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_scan_fab')), findsOneWidget);
    for (final label in ['Home', 'Files', 'Tools', 'Me']) {
      expect(
        find.descendant(of: find.byType(NavigationBar), matching: find.text(label)),
        findsOneWidget,
      );
    }
  });

  testWidgets('swipe left/right switches tabs with animation', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const ProviderScope(child: BenoApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Explicit pumps (not pumpAndSettle): the loading spinner animates
    // forever under the test binding.
    Future<void> flingAndSettle(Offset delta) async {
      await tester.fling(find.byType(Scaffold).first, delta, 900);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
    }

    // Home → fling left → Files tab.
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
    await flingAndSettle(const Offset(-320, 0));
    expect(find.byKey(const ValueKey('home_search_field')), findsNothing);

    // Files → fling right → back Home.
    await flingAndSettle(const Offset(320, 0));
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);

    // Clamped at the first tab: fling right on Home stays Home.
    await flingAndSettle(const Offset(320, 0));
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
  });
}
