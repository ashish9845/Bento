import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan/features/scan/openscan/openscan_capture_screen.dart';

/// No camera exists headless (the plugin call never resolves there): the
/// screen must reach its friendly error state via the init timeout.
/// Explicit pumps — pumpAndSettle can't settle camera plugin timing.
void main() {
  testWidgets('shows camera-unavailable state without a camera', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const MaterialApp(home: OpenScanCaptureScreen()));
    for (var i = 0;
        i < 15 && find.textContaining('Camera unavailable').evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(find.textContaining('Camera unavailable'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
