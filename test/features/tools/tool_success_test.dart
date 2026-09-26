import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan/core/storage/open_file.dart';
import 'package:scan/features/tools/widgets/tool_progress.dart';

void main() {
  testWidgets('ToolSuccess shows Open folder instead of Save when wired so', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ToolSuccess(
            message: 'Exported 3 image(s) to Test_1/',
            onOpenFolder: () => opened = true,
            onShare: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open folder'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text('Open folder'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });

  testWidgets('ToolSuccess shows Open instead of Save when wired so', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    var opened = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ToolSuccess(
            message: 'Signed!',
            onOpen: () => opened = true,
            onShare: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });

  testWidgets('openDoc reports failure visibly instead of silently', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return FilledButton(
              onPressed: () => openDoc(context, '/nonexistent_xyz/nope.pdf'),
              child: const Text('Open it'),
            );
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Call the helper directly (bypasses tap dispatch) with real async time.
    final context = tester.element(find.byType(Scaffold));
    await tester.runAsync(() => openDoc(context, '/nonexistent_xyz/nope.pdf'));
    // Single pump only: pumpAndSettle would fast-forward the snackbar's
    // auto-dismiss timer and hide the very thing we assert on.
    await tester.pump();
    // On Linux headless, xdg-open fails and the snackbar must appear.
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('nope.pdf'), findsOneWidget);
  });
}
