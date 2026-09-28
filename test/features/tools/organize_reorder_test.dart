import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:scan/data/tools/repositories/tools_repository.dart';
import 'package:scan/features/tools/organize/organize_screen.dart';
import 'package:scan/features/tools/providers/tool_cubit.dart';
import 'package:scan/features/tools/widgets/tool_scaffold.dart';

class _FakeOrganizeRepo extends ToolsRepository {
  @override
  Future<int> pageCount(File input) async => 3;

  @override
  Future<List<File>> renderThumbnails(File input) async => [];

  @override
  Future<File> mergePdfs(List<File> inputs, {String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<List<File>> splitPdf(
    File input,
    String rangesSpec, {
    String? baseName,
  }) => throw UnimplementedError();

  @override
  Future<File> extractPages(
    File input,
    List<int> pages, {
    String? outputName,
  }) => throw UnimplementedError();

  @override
  Future<File> organizePdf(
    File input, {
    Set<int> delete = const {},
    Map<int, int> rotations = const {},
    List<int>? order,
    String? outputName,
  }) => throw UnimplementedError();

  @override
  Future<File> compressPdf(
    File input,
    PdfImagePolicy policy, {
    String? outputName,
  }) => throw UnimplementedError();

  @override
  Future<File> imageToPdf(List<File> images, {String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<List<File>> renderPages(File input, {String? outputName}) =>
      throw UnimplementedError();

  @override
  Future<File> signPdf(
    File input, {
    required Uint8List signaturePng,
    required int page,
    double widthPts = 140,
    String? outputName,
  }) => throw UnimplementedError();

  @override
  Future<File> protectPdf(
    File input, {
    required String userPassword,
    String? ownerPassword,
    String? outputName,
  }) => throw UnimplementedError();

  @override
  Future<File> unlockPdf(
    File input, {
    required String password,
    String? outputName,
  }) => throw UnimplementedError();

  @override
  Future<void> saveFile(File file) async {}
}

/// Organize grid: long-press-dragging the first tile onto the third tile
/// moves page 1 after page 3. Guards the reorder flow (a fullscreen swipe
/// gesture once stole these drags in the gesture arena).
void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          return null;
        });
  });

  testWidgets('long-press drag reorders pages', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: OrganizeScreen(repository: _FakeOrganizeRepo())),
    );
    await tester.pumpAndSettle();

    tester
        .element(find.byType(ToolScaffold))
        .read<ToolCubit>()
        .setFiles([File('/tmp/a.pdf')]);
    await tester.pumpAndSettle();

    expect(find.text('p1'), findsOneWidget);
    expect(find.text('p2'), findsOneWidget);
    expect(find.text('p3'), findsOneWidget);

    final p1Start = tester.getCenter(find.text('p1'));
    final p3Cell = tester.getCenter(find.text('p3'));
    expect(p1Start.dx, lessThan(p3Cell.dx));

    Future<void> drag(String fromLabel, String toLabel) async {
      final from = tester.getCenter(find.text(fromLabel));
      final to = tester.getCenter(find.text(toLabel));
      final gesture = await tester.startGesture(from);
      await tester.pump(const Duration(milliseconds: 600));
      await gesture.moveTo(to);
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();
    }

    List<double> order() => [
      tester.getCenter(find.text('p1')).dx,
      tester.getCenter(find.text('p2')).dx,
      tester.getCenter(find.text('p3')).dx,
    ];

    // Long move: page 1 onto page 3's cell → p2, p3, p1.
    await drag('p1', 'p3');
    var xs = order();
    expect(xs[1], lessThan(xs[2]));
    expect(xs[2], lessThan(xs[0]));

    // Adjacent swap (the reported bug): page 3 onto page 1's cell.
    // Order is p2, p3, p1; p1 sits in the last cell, p3 in the middle.
    await drag('p1', 'p3');
    xs = order();
    expect(xs[1], lessThan(xs[0]));
    expect(xs[0], lessThan(xs[2]));
  });

  testWidgets('adjacent pages swap in one move', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: OrganizeScreen(repository: _FakeOrganizeRepo())),
    );
    await tester.pumpAndSettle();

    tester
        .element(find.byType(ToolScaffold))
        .read<ToolCubit>()
        .setFiles([File('/tmp/a.pdf')]);
    await tester.pumpAndSettle();
    expect(find.text('p1'), findsOneWidget);

    // Page 1 onto page 2's cell → p2, p1, p3 (was a silent no-op before).
    final from = tester.getCenter(find.text('p1'));
    final to = tester.getCenter(find.text('p2'));
    final gesture = await tester.startGesture(from);
    await tester.pump(const Duration(milliseconds: 600));
    await gesture.moveTo(to);
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    final p1x = tester.getCenter(find.text('p1')).dx;
    final p2x = tester.getCenter(find.text('p2')).dx;
    final p3x = tester.getCenter(find.text('p3')).dx;
    expect(p2x, lessThan(p1x));
    expect(p1x, lessThan(p3x));
  });
}
