import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scan/core/theme/app_palettes.dart';
import 'package:scan/features/settings/widgets/app_theme_preview.dart';

/// Every palette preview renders its label + mockup without overflow.
void main() {
  testWidgets('all palette previews render', (tester) async {
    for (final palette in AppPalette.values) {
      for (final bright in [Brightness.light, Brightness.dark]) {
        final scheme = bright == Brightness.light
            ? palette.lightScheme
            : palette.darkScheme;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AppThemePreview(
                palette: palette,
                scheme: scheme,
                selected: palette == AppPalette.lavender,
                onTap: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text(palette.label), findsOneWidget);
      }
    }
  });
}
