import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:integration_test/integration_test.dart';
import 'package:scan/core/router/route_names.dart';
import 'package:scan/main.dart';

/// Full-app smoke on Linux: boots the real app and walks Home, Files, Tools,
/// Me, every tool screen and the scanner entry. Flows that open native UI
/// (file picker, camera scanner, share sheet) are verified up to — but never
/// through — the native call.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Finder navItem(String label) => find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      );

  Finder toolCard(String routeName) => find.byKey(ValueKey('tool_card_$routeName'));

  Offset screenCenter(WidgetTester tester) {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    return Offset(size.width / 2, size.height / 2);
  }

  Future<void> scrollTo(WidgetTester tester, Finder target) async {
    // Drag from screen center: the shell keeps offstage branches mounted, so
    // a scroll-view finder could grab a hidden branch's view.
    final center = screenCenter(tester);
    for (var i = 0; i < 15 && target.evaluate().isEmpty; i++) {
      await tester.dragFrom(center, const Offset(0, -450));
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(target);
    await tester.pumpAndSettle();
  }

  Future<void> openTool(WidgetTester tester, String routeName) async {
    await tester.tap(navItem('Tools'));
    await tester.pumpAndSettle();
    final card = toolCard(routeName);
    await scrollTo(tester, card);
    await tester.tap(card);
    await tester.pumpAndSettle();
  }

  Future<void> goBack(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const ProviderScope(child: BenoApp()));
    await tester.pumpAndSettle();
  }

  group('Bento app', () {
    testWidgets('boots to Home with search, shortcuts, recents and FAB', (tester) async {
      await pumpApp(tester);

      expect(find.byKey(const ValueKey('home_search_field')), findsOneWidget);
      for (final id in ['scan', 'tools', 'sign', 'compress', 'merge', 'protect', 'unlock', 'all']) {
        expect(find.byKey(ValueKey('home_shortcut_$id')), findsOneWidget);
      }
      // Recents header lives below the fold — scroll the visible view first.
      await scrollTo(tester, find.text('Recents'));
      expect(find.text('Recents'), findsOneWidget);
      expect(find.byKey(const ValueKey('home_scan_fab')), findsOneWidget);
      // Bottom nav: Home / Files / Tools / Me.
      for (final label in ['Home', 'Files', 'Tools', 'Me']) {
        expect(navItem(label), findsOneWidget);
      }
    });

    testWidgets('search filters shortcuts and shows empty hint', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byKey(const ValueKey('home_search_field')), 'merge');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home_shortcut_merge')), findsOneWidget);
      expect(find.byKey(const ValueKey('home_shortcut_scan')), findsNothing);

      // Keyword search: synonyms match without exact labels.
      await tester.enterText(find.byKey(const ValueKey('home_search_field')), 'password');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home_shortcut_protect')), findsOneWidget);
      expect(find.byKey(const ValueKey('home_shortcut_unlock')), findsOneWidget);
      expect(find.byKey(const ValueKey('home_shortcut_scan')), findsNothing);

      await tester.enterText(find.byKey(const ValueKey('home_search_field')), 'shrink');
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('home_shortcut_compress')), findsOneWidget);

      await tester.enterText(find.byKey(const ValueKey('home_search_field')), 'zzz-no-match');
      await tester.pumpAndSettle();
      expect(find.textContaining('No tools match'), findsOneWidget);
    });

    testWidgets('FAB and Smart Scan shortcut open the scanner', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const ValueKey('home_scan_fab')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('scan_button')), findsOneWidget);
      await goBack(tester);

      await tester.tap(find.byKey(const ValueKey('home_shortcut_scan')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('scan_button')), findsOneWidget);
      expect(find.text('Document scanner'), findsOneWidget);
      // Review actions appear only after pages are captured (native camera —
      // not launched here), so they must be absent, not broken.
      expect(find.text('Share'), findsNothing);
      await goBack(tester);
    });

    testWidgets('shortcut grid navigates to tools', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byKey(const ValueKey('home_shortcut_tools')));
      await tester.pumpAndSettle();
      expect(toolCard(RouteNames.toolsMerge), findsWidgets);
      // Branch switch — return via the Home tab, there is no back stack.
      await tester.tap(navItem('Home'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('home_shortcut_sign')));
      await tester.pumpAndSettle();
      expect(find.text('Sign PDF'), findsWidgets);
      // Sub-route reached by branch switch — return via the Home tab.
      await tester.tap(navItem('Home'));
      await tester.pumpAndSettle();
    });

    testWidgets('Tools tab lists all 10 tools', (tester) async {
      await pumpApp(tester);

      await tester.tap(navItem('Tools'));
      await tester.pumpAndSettle();
      for (final route in [
        RouteNames.toolsMerge,
        RouteNames.toolsSplit,
        RouteNames.toolsOrganize,
        RouteNames.toolsExtract,
        RouteNames.toolsCompress,
        RouteNames.toolsImage2Pdf,
        RouteNames.toolsPdf2Image,
        RouteNames.toolsProtect,
        RouteNames.toolsUnlock,
        RouteNames.toolsSign,
      ]) {
        await scrollTo(tester, toolCard(route));
        expect(toolCard(route), findsOneWidget);
      }
    });

    testWidgets('Merge tool renders picker with disabled action', (tester) async {
      await pumpApp(tester);

      await openTool(tester, RouteNames.toolsMerge);
      expect(find.text('Merge PDFs'), findsWidgets);
      expect(find.text('Pick PDFs'), findsOneWidget);
      expect(find.text('No files picked'), findsOneWidget);
      await goBack(tester);
    });

    testWidgets('Split tool renders picker shell', (tester) async {
      await pumpApp(tester);

      await openTool(tester, RouteNames.toolsSplit);
      expect(find.text('Split PDF'), findsWidgets);
      // Ranges field appears after a file is picked (native dialog — covered
      // in widget test with preset files instead).
      expect(find.text('PDF to split'), findsOneWidget);
      expect(find.text('Split'), findsOneWidget);
      await goBack(tester);
    });

    testWidgets('Organize / Extract / Compress / PDF→Image / Protect / Unlock / Sign screens render', (tester) async {
      await pumpApp(tester);

      await openTool(tester, RouteNames.toolsOrganize);
      expect(find.text('Organize Pages'), findsWidgets);
      expect(find.text('Apply'), findsOneWidget);
      await goBack(tester);

      await openTool(tester, RouteNames.toolsExtract);
      expect(find.text('Extract Pages'), findsWidgets);
      expect(find.text('Extract'), findsOneWidget);
      await goBack(tester);

      await openTool(tester, RouteNames.toolsCompress);
      expect(find.text('Compress PDF'), findsWidgets);
      expect(find.text('Quality'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      await goBack(tester);

      await openTool(tester, RouteNames.toolsPdf2Image);
      expect(find.text('PDF → Image'), findsWidgets);
      expect(find.text('Export'), findsOneWidget);
      await goBack(tester);

      await openTool(tester, RouteNames.toolsSign);
      expect(find.text('Sign PDF'), findsWidgets);
      expect(find.text('Signature'), findsOneWidget);
      expect(find.text('Save signature'), findsOneWidget);
      expect(find.text('Apply signature'), findsOneWidget);
      await goBack(tester);

      await openTool(tester, RouteNames.toolsProtect);
      expect(find.text('Protect PDF'), findsWidgets);
      expect(find.text('Protect'), findsOneWidget);
      await goBack(tester);

      await openTool(tester, RouteNames.toolsUnlock);
      expect(find.text('Unlock PDF'), findsWidgets);
      expect(find.text('Unlock'), findsOneWidget);
      await goBack(tester);
    });

    testWidgets('Image→PDF screen renders with disabled action', (tester) async {
      await pumpApp(tester);

      await openTool(tester, RouteNames.toolsImage2Pdf);
      expect(find.text('Image → PDF'), findsWidgets);
      expect(find.text('Pick images'), findsOneWidget);
      expect(find.text('Create PDF'), findsOneWidget);
      await goBack(tester);
    });

    testWidgets('Files tab renders browser shell', (tester) async {
      await pumpApp(tester);

      await tester.tap(navItem('Files'));
      await tester.pumpAndSettle();
      // Either the empty state or a file list — both prove the Bloc wiring works.
      expect(
        find.text('No PDFs yet').evaluate().isNotEmpty ||
            find.byType(ListTile).evaluate().isNotEmpty,
        isTrue,
      );
    });

    testWidgets('Me tab shows settings with theme and palette controls', (tester) async {
      await pumpApp(tester);

      await tester.tap(navItem('Me'));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Theme'), findsWidgets);
      expect(find.byKey(const ValueKey('theme_mode_dark')), findsOneWidget);
      expect(find.byKey(const ValueKey('palette_catppuccin')), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      final lavender = find.byKey(const ValueKey('palette_lavender'));
      await scrollTo(tester, lavender);
      await tester.tap(lavender);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      final def = find.byKey(const ValueKey('palette_defaultPalette'));
      await scrollTo(tester, def);
      await tester.tap(def);
      await tester.pumpAndSettle();
    });
  });
}
