import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/files/repositories/files_repository.dart';
import 'files_query_event.dart';
import 'files_query_state.dart';

class FilesQueryBloc extends Bloc<FilesQueryEvent, FilesQueryState> {
  final FilesRepository repository;
  FilesQueryBloc(this.repository) : super(const FilesQueryState()) {
    on<FetchFiles>(_onFetch);
    on<RefreshFiles>(_onFetch);
  }

  Future<void> _onFetch(
    FilesQueryEvent event,
    Emitter<FilesQueryState> emit,
  ) async {
    emit(state.copyWith(status: FilesQueryStatus.loading));
    try {
      final files = await repository.fetchRecentFiles();
      emit(state.copyWith(status: FilesQueryStatus.loaded, files: files));
    } catch (e) {
      emit(
        state.copyWith(
          status: FilesQueryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
