import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:scan/data/files/repositories/files_repository.dart';
import 'package:scan/presentation/files/bloc/mutation/files_mutation_bloc.dart';
import 'package:scan/presentation/files/bloc/mutation/files_mutation_event.dart';
import 'package:scan/presentation/files/bloc/mutation/files_mutation_state.dart';

class MockFilesRepository extends Mock implements FilesRepository {}

void main() {
  late MockFilesRepository mockRepo;

  setUp(() {
    mockRepo = MockFilesRepository();
  });

  group('FilesMutationBloc', () {
    blocTest<FilesMutationBloc, FilesMutationState>(
      'emits [inProgress, success] on delete success',
      build: () {
        when(() => mockRepo.deleteFile(any())).thenAnswer((_) async {});
        return FilesMutationBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const FilesMutationEvent.deleteFile('/a.pdf')),
      expect: () => [
        const FilesMutationState(status: FilesMutationStatus.inProgress),
        const FilesMutationState(status: FilesMutationStatus.success),
      ],
      verify: (_) => verify(() => mockRepo.deleteFile('/a.pdf')).called(1),
    );

    blocTest<FilesMutationBloc, FilesMutationState>(
      'emits [inProgress, failure] on delete error',
      build: () {
        when(() => mockRepo.deleteFile(any())).thenThrow(Exception('io'));
        return FilesMutationBloc(mockRepo);
      },
      act: (bloc) => bloc.add(const FilesMutationEvent.deleteFile('/a.pdf')),
      expect: () => [
        const FilesMutationState(status: FilesMutationStatus.inProgress),
        isA<FilesMutationState>().having((s) => s.status, 'status', FilesMutationStatus.failure).having((s) => s.errorMessage, 'errorMessage', contains('io')),
      ],
    );
  });
}
