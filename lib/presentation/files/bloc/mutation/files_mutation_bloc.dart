import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/files/repositories/files_repository.dart';
import 'files_mutation_event.dart';
import 'files_mutation_state.dart';

class FilesMutationBloc extends Bloc<FilesMutationEvent, FilesMutationState> {
  final FilesRepository repository;
  FilesMutationBloc(this.repository) : super(const FilesMutationState()) {
    on<DeleteFile>(_onDelete);
  }

  Future<void> _onDelete(DeleteFile event, Emitter<FilesMutationState> emit) async {
    emit(state.copyWith(status: FilesMutationStatus.inProgress));
    try {
      await repository.deleteFile(event.path);
      emit(state.copyWith(status: FilesMutationStatus.success));
    } catch (e) {
      emit(state.copyWith(status: FilesMutationStatus.failure, errorMessage: e.toString()));
    }
  }
}
