import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pdf_manipulator/pdf_manipulator.dart';
import 'package:scan/core/errors/failures.dart';
import 'package:scan/data/tools/datasources/pdf_engine_data_source.dart';
import 'package:scan/data/tools/repositories/tools_repository_impl.dart';

class MockPdfEngineDataSource extends Mock implements PdfEngineDataSource {}

void main() {
  late MockPdfEngineDataSource mockEngine;
  late ToolsRepositoryImpl repository;

  setUp(() {
    mockEngine = MockPdfEngineDataSource();
    repository = ToolsRepositoryImpl(mockEngine);
  });

  setUpAll(() {
    registerFallbackValue(File('fallback.pdf'));
    registerFallbackValue(PdfImagePolicy.ebook);
    registerFallbackValue(Uint8List(0));
  });

  group('ToolsRepository (FFI engine)', () {
    final input = File('/tmp/in.pdf');
    final output = File('/tmp/out.pdf');

    test('pageCount delegates to engine', () async {
      when(() => mockEngine.pageCount(any())).thenAnswer((_) async => 7);
      expect(await repository.pageCount(input), 7);
      verify(() => mockEngine.pageCount(input)).called(1);
    });

    test('mergePdfs delegates to engine', () async {
      when(() => mockEngine.merge(any())).thenAnswer((_) async => output);
      expect(await repository.mergePdfs([input, input]), output);
    });

    test('splitPdf delegates to engine', () async {
      when(() => mockEngine.split(any(), any(), baseName: any(named: 'baseName')))
          .thenAnswer((_) async => [output]);
      expect(await repository.splitPdf(input, '1-1, 2-end'), [output]);
    });

    test('extractPages delegates to engine', () async {
      when(() => mockEngine.extract(any(), any())).thenAnswer((_) async => output);
      expect(await repository.extractPages(input, [0, 2]), output);
    });

    test('organizePdf delegates to engine with delete/rotations', () async {
      when(() => mockEngine.organize(any(),
              delete: any(named: 'delete'),
              rotations: any(named: 'rotations'),
              order: any(named: 'order')))
          .thenAnswer((_) async => output);
      expect(
        await repository.organizePdf(input, delete: {1}, rotations: {0: 90}),
        output,
      );
    });

    test('compressPdf delegates to engine with policy', () async {
      when(() => mockEngine.compress(any(), any())).thenAnswer((_) async => output);
      expect(await repository.compressPdf(input, PdfImagePolicy.screen), output);
    });

    test('imageToPdf delegates to engine with output name', () async {
      when(() => mockEngine.imagesToPdf(any(), outputName: any(named: 'outputName')))
          .thenAnswer((_) async => output);
      expect(await repository.imageToPdf([input], outputName: 'Doc'), output);
    });

    test('renderPages delegates to engine', () async {
      when(() => mockEngine.renderPages(any(), maxSize: any(named: 'maxSize')))
          .thenAnswer((_) async => [output]);
      expect(await repository.renderPages(input), [output]);
    });

    test('signPdf stamps onto original pages via engine', () async {
      final sig = Uint8List.fromList([1, 2, 3]);
      when(() => mockEngine.signPdf(any(),
              signaturePng: any(named: 'signaturePng'),
              page: any(named: 'page'),
              widthPts: any(named: 'widthPts')))
          .thenAnswer((_) async => output);
      expect(
        await repository.signPdf(input, signaturePng: sig, page: 1),
        output,
      );
      verify(() => mockEngine.signPdf(input,
          signaturePng: sig, page: 1, widthPts: any(named: 'widthPts'))).called(1);
    });

    test('engine errors surface as CacheException', () async {
      when(() => mockEngine.pageCount(any())).thenThrow(Exception('boom'));
      expect(() => repository.pageCount(input), throwsA(isA<CacheException>()));
    });
  });
}
