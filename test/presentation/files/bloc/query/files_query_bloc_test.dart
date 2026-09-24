import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan/core/errors/failures.dart';
import 'package:scan/data/files/models/bento_file.dart';
import 'package:scan/data/files/repositories/files_repository.dart';
import 'package:scan/presentation/files/bloc/query/files_query_bloc.dart';
import 'package:scan/presentation/files/bloc/query/files_query_event.dart';
import 'package:scan/presentation/files/bloc/query/files_query_state.dart';

class MockFilesRepository extends Mock implements FilesRepository {}

void main() {
  late MockFilesRepository mockRepo;

  setUp(() {
    mockRepo = MockFilesRepository();
  });

  group('FilesQueryBloc', () {
    final tFiles = [
      BentoFile(path: '/a.pdf', name: 'a.pdf', size: 100, modified: DateTime(2024)),
    ];

    blocTest<FilesQueryBloc, FilesQueryState>(
      'emits [loading, loaded] when fetch succeeds',
      build: () {
        when(() => mockRepo.fetchRecentFiles()).thenAnswer((_) async => tFiles);
        return FilesQueryBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const FilesQueryEvent.fetch()),
      expect: () => [
        const FilesQueryState(status: FilesQueryStatus.loading),
        FilesQueryState(status: FilesQueryStatus.loaded, files: tFiles),
      ],
      verify: (_) => verify(() => mockRepo.fetchRecentFiles()).called(1),
    );

    blocTest<FilesQueryBloc, FilesQueryState>(
      'emits [loading, error] when fetch throws CacheException',
      build: () {
        when(() => mockRepo.fetchRecentFiles()).thenThrow(const CacheException('fail'));
        return FilesQueryBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const FilesQueryEvent.fetch()),
      expect: () => [
        const FilesQueryState(status: FilesQueryStatus.loading),
        const FilesQueryState(status: FilesQueryStatus.error, errorMessage: 'CacheException: fail'),
      ],
    );

    blocTest<FilesQueryBloc, FilesQueryState>(
      'refresh also triggers loading -> loaded',
      build: () {
        when(() => mockRepo.fetchRecentFiles()).thenAnswer((_) async => tFiles);
        return FilesQueryBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const FilesQueryEvent.refresh()),
      expect: () => [
        const FilesQueryState(status: FilesQueryStatus.loading),
        FilesQueryState(status: FilesQueryStatus.loaded, files: tFiles),
      ],
    );
  });
}
