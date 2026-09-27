import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan/core/errors/failures.dart';
import 'package:scan/data/files/datasources/files_local_data_source.dart';
import 'package:scan/data/files/models/bento_file.dart';
import 'package:scan/data/files/repositories/files_repository_impl.dart';

class MockFilesLocalDataSource extends Mock implements FilesLocalDataSource;

void main() {
  late MockFilesLocalDataSource mockLocal;
  late FilesRepositoryImpl repository;

  setUp(() {
    mockLocal = MockFilesLocalDataSource();
    repository = FilesRepositoryImpl(mockLocal);
  });

  group('FilesRepository', () {
    final tFiles = [
      BentoFile(
        path: '/a/b.pdf',
        name: 'b.pdf',
        size: 1024,
        modified: DateTime(2024),
      ),
      BentoFile(
        path: '/c/d.pdf',
        name: 'd.pdf',
        size: 2048,
        modified: DateTime(2024, 1, 2),
      ),
    ];

    test('fetchRecentFiles returns data from data source', () async {
      when(() => mockLocal.getRecentFiles(limit: any(named: 'limit')))
          .thenAnswer((_) async => tFiles);

      final result = await repository.fetchRecentFiles();

      expect(result, tFiles);
      verify(() => mockLocal.getRecentFiles()).called(1);
    });

    test(
      'fetchRecentFiles throws CacheException on data source error',
      () async {
        when(() => mockLocal.getRecentFiles(limit: any(named: 'limit')))
            .thenThrow(Exception('disk'));

        expect(
          () => repository.fetchRecentFiles(),
          throwsA(isA<CacheException>()),
        );
      },
    );

    test('deleteFile delegates to data source', () async {
      when(() => mockLocal.deleteFile(any())).thenAnswer((_) async {});

      await repository.deleteFile('/a/b.pdf');

      verify(() => mockLocal.deleteFile('/a/b.pdf')).called(1);
    });

    test('deleteFile throws CacheException on error', () async {
      when(() => mockLocal.deleteFile(any())).thenThrow(Exception('io'));

      expect(() => repository.deleteFile('/x'), throwsA(isA<CacheException>()));
    });
  });
}
