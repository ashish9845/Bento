import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan/features/tools/home/tool_grid_screen.dart';

/// Tools grid at phone widths: 4 compact cards per row, all 10 tools
/// present, zero layout overflow (fails loudly on RenderFlex overflow).
void main() {
  testWidgets('tool grid renders 10 compact cards without overflow', (
    tester,
  ) async {
    for (final size in [const Size(360, 640), const Size(320, 568)]) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(const MaterialApp(home: ToolGridScreen()));
      await tester.pumpAndSettle();
      // A re-pump reuses the previous iteration's state (including any
      // typed query), so always reset the search field first.
      await tester.enterText(
        find.byKey(const ValueKey('tools_search_field')),
        '',
      );
      await tester.pumpAndSettle();
      expect(find.text('Most popular'), findsOneWidget);
      expect(find.text('Protect PDF'), findsOneWidget);
      expect(find.text('Unlock PDF'), findsOneWidget);
      expect(find.text('10 tools'), findsOneWidget);
      expect(find.text('More tools Coming soon'), findsOneWidget);

      // Search filters the grid (label + subtitle)…
      await tester.enterText(
        find.byKey(const ValueKey('tools_search_field')),
        'password',
      );
      await tester.pumpAndSettle();
      expect(find.text('Protect PDF'), findsOneWidget);
      expect(find.text('Unlock PDF'), findsOneWidget);
      expect(find.text('Merge PDFs'), findsNothing);

      // …including fuzzy abbreviation + typo matches…
      await tester.enterText(
        find.byKey(const ValueKey('tools_search_field')),
        'mrege',
      );
      await tester.pumpAndSettle();
      expect(find.text('Merge PDFs'), findsOneWidget);
      expect(find.text('Sign PDF'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('tools_search_field')),
        'cmpress',
      );
      await tester.pumpAndSettle();
      expect(find.text('Compress PDF'), findsOneWidget);
      expect(find.text('Merge PDFs'), findsNothing);

      // …and shows an empty hint when nothing matches.
      await tester.enterText(
        find.byKey(const ValueKey('tools_search_field')),
        'zzz-no-match',
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('No tools match'), findsOneWidget);
    }
  });
}
