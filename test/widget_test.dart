import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scan/main.dart';

void main() {
  testWidgets('BenoApp builds', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(const ProviderScope(child: BenoApp()));
    await tester.pumpAndSettle(const Duration(milliseconds: 800));
    // Bottom nav is always present after grid builds
    expect(find.text('Tools'), findsOneWidget);
    expect(find.text('Scan'), findsWidgets);
  });
}
