import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan/data/files/models/bento_file.dart';
import 'package:scan/data/files/repositories/files_repository.dart';
import 'package:scan/presentation/home/bloc/mutation/home_mutation_bloc.dart';
import 'package:scan/presentation/home/bloc/mutation/home_mutation_event.dart';
import 'package:scan/presentation/home/bloc/mutation/home_mutation_state.dart';

class MockFilesRepository extends Mock implements FilesRepository {}

BentoFile _file(String name) => BentoFile(
      path: '/docs/$name',
      name: name,
      size: 100,
      modified: DateTime(2024),
    );

void main() {
  late MockFilesRepository mockRepo;

  setUp(() {
    mockRepo = MockFilesRepository();
  });

  setUpAll(() {
    registerFallbackValue(File('fallback.pdf'));
  });

  group('HomeMutationBloc', () {
    blocTest<HomeMutationBloc, HomeMutationState>(
      'emits [inProgress, success] with imported count',
      build: () {
        when(() => mockRepo.importFiles(any()))
            .thenAnswer((_) async => [_file('a.pdf'), _file('b.pdf')]);
        return HomeMutationBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const HomeMutationEvent.importFiles(['/tmp/a.pdf', '/tmp/b.pdf'])),
      expect: () => [
        const HomeMutationState(status: HomeMutationStatus.inProgress),
        const HomeMutationState(status: HomeMutationStatus.success, importedCount: 2),
      ],
      verify: (_) => verify(() => mockRepo.importFiles(any())).called(1),
    );

    blocTest<HomeMutationBloc, HomeMutationState>(
      'emits [inProgress, failure] when import throws',
      build: () {
        when(() => mockRepo.importFiles(any())).thenThrow(Exception('copy failed'));
        return HomeMutationBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const HomeMutationEvent.importFiles(['/tmp/a.pdf'])),
      expect: () => [
        const HomeMutationState(status: HomeMutationStatus.inProgress),
        isA<HomeMutationState>()
            .having((s) => s.status, 'status', HomeMutationStatus.failure)
            .having((s) => s.errorMessage, 'errorMessage', contains('copy failed')),
      ],
    );

    blocTest<HomeMutationBloc, HomeMutationState>(
      'emits nothing for empty picks',
      build: () => HomeMutationBloc(mockRepo),
      act: (bloc) => bloc.add(const HomeMutationEvent.importFiles([])),
      expect: () => <HomeMutationState>[],
      verify: (_) => verifyNever(() => mockRepo.importFiles(any())),
    );
  });
}
