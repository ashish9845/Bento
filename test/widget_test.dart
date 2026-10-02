import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan/core/routing/glass_nav_bar.dart';
import 'package:scan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('BenoApp boots to Home with nav shell', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const BenoApp());
    // Explicit pumps instead of pumpAndSettle: background async work
    // (prefs/engine warm-up) can hold pending timers under the standard
    // binding without scheduling frames.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Home dashboard: search + shortcuts + bottom nav.
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_shortcut_scan')), findsOneWidget);
    expect(find.byKey(const ValueKey('home_scan_fab')), findsOneWidget);
    for (final label in ['Home', 'Files', 'Tools', 'Settings']) {
      expect(
        find.descendant(
          of: find.byType(GlassNavBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('theme switches keep exactly one bottom bar', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BenoApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GlassNavBar), findsOneWidget);

    // Mode switch + palette switch: still exactly one bar, no stuck overlay.
    await tester.tap(find.text('Dark'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GlassNavBar), findsOneWidget);

    final mocha = find.byKey(const ValueKey('palette_mocha'));
    await tester.ensureVisible(mocha);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(mocha);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.textContaining('Mocha'), findsWidgets);
    expect(find.byType(GlassNavBar), findsOneWidget);

    // Leave the shared router on Home so later tests start clean.
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
  });

  testWidgets('bottom bar shows on tabs only, not on tool pages', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BenoApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Tab root: bar visible.
    expect(find.byType(GlassNavBar), findsOneWidget);

    // Open a tool sub-page: bar hides (fullscreen).
    await tester.tap(find.text('Tools'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const ValueKey('tool_card_toolsMerge')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Merge PDFs'), findsWidgets);
    expect(find.byType(GlassNavBar), findsNothing);

    // Back to the tab root: bar returns.
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(GlassNavBar), findsOneWidget);

    // Leave the shared appRouter on Home so later tests start clean.
    await tester.tap(find.text('Home'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
  });

  testWidgets('swipe does not switch tabs — nav bar taps only', (tester) async {    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const BenoApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    // Flinging left/right on Home must stay on Home.
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
    await tester.fling(find.byType(Scaffold).first, const Offset(-320, 0), 900);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);

    await tester.fling(find.byType(Scaffold).first, const Offset(320, 0), 900);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
  });

  testWidgets('Sentry probe button hidden without IS_DEBUG flag', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const BenoApp());
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    await tester.tap(find.text('Settings'));
    await tester.pump(const Duration(seconds: 1));
    // Slivers build lazily — drag the Privacy toggle into view first.
    for (
      var i = 0;
      i < 10 && find.text('Send crash reports').evaluate().isEmpty;
      i++
    ) {
      await tester.drag(
        find.byType(CustomScrollView),
        const Offset(0, -500),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Send crash reports'), findsOneWidget);
    expect(find.byKey(const ValueKey('debug_crash_button')), findsNothing);
  });
}
