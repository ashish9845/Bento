import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/features/tools/providers/tool_controller.dart';
import 'package:scan/features/tools/providers/tool_providers.dart';
import 'package:scan/features/tools/split/split_screen.dart';

/// Split screen with preset files (bypasses the native file picker, which
/// can't run headless): ranges field accepts input and validation errors show.
void main() {
  testWidgets('ranges field accepts input and run validates it', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    final repo = FakeToolsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [toolsRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: SplitScreen()),
      ),
    );
    await tester.pumpAndSettle();

    // Preset a picked file directly on the controller.
    final container = ProviderScope.containerOf(tester.element(find.byType(SplitScreen)));
    container.read(splitControllerProvider.notifier).setFiles([File('/tmp/a.pdf')]);
    await tester.pumpAndSettle();

    final field = find.byKey(const ValueKey('split_ranges_field'));
    expect(field, findsOneWidget);
    await tester.enterText(field, '1-2, 3, 4-end');
    await tester.pumpAndSettle();
    expect(find.text('1-2, 3, 4-end'), findsOneWidget);

    // Thumbnail grid shows the fake 3-page count.
    expect(find.text('3 pages'), findsOneWidget);

    // Run with garbage ranges → rename dialog first, then friendly error.
    await tester.enterText(field, 'abc');
    await tester.pumpAndSettle();
    final splitButton = find.text('Split');
    await tester.ensureVisible(splitButton);
    await tester.pumpAndSettle();
    await tester.tap(splitButton);
    await tester.pumpAndSettle();
    // Rename dialog appears before the action runs.
    expect(find.text('Name your PDF'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('outside'), findsOneWidget);
  });
}

class FakeToolsRepository extends ToolsRepository {
  FakeToolsRepository();

  @override
  Future<int> pageCount(File input) async => 3;

  @override
  Future<File> mergePdfs(List<File> inputs, {String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<List<File>> splitPdf(File input, String rangesSpec, {String? baseName}) async {
    if (rangesSpec.contains('abc')) throw Exception('"abc" is outside 1-3');
    return [File('/tmp/a_part1.pdf')];
  }

  @override
  Future<File> extractPages(File input, List<int> pages, {String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<File> organizePdf(File input,
          {Set<int> delete = const {},
          Map<int, int> rotations = const {},
          List<int>? order,
          String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<File> compressPdf(File input, PdfImagePolicy policy, {String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<File> imageToPdf(List<File> images, {String? outputName}) => throw UnimplementedError();

  @override
  Future<List<File>> renderPages(File input, {String? outputName}) => throw UnimplementedError();

  @override
  Future<List<File>> renderThumbnails(File input) => throw UnimplementedError();

  @override
  Future<File> signPdf(File input,
          {required Uint8List signaturePng,
          required int page,
          double widthPts = 140,
          String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<File> protectPdf(File input,
          {required String userPassword, String? ownerPassword, String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<File> unlockPdf(File input, {required String password, String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<void> saveFile(File file) async {}
}
