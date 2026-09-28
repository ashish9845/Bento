import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/sharing/share_gateway.dart';
import '../../../../data/files/repositories/files_repository.dart';
import 'files_mutation_event.dart';
import 'files_mutation_state.dart';

class FilesMutationBloc extends Bloc<FilesMutationEvent, FilesMutationState> {
  final FilesRepository repository;
  final ShareGateway shareGateway;

  new(this.repository, {ShareGateway? shareGateway})
    : shareGateway = shareGateway ?? const SharePlusGateway(),
      super(const FilesMutationState()) {
    on<DeleteFile>(_onDelete);
    on<ShareFile>(_onShare);
  }

  Future<void> _onDelete(
    DeleteFile event,
    Emitter<FilesMutationState> emit,
  ) async {
    emit(state.copyWith(status: FilesMutationStatus.inProgress));
    try {
      await repository.deleteFile(event.path);
      emit(state.copyWith(status: FilesMutationStatus.success));
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FilesMutationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onShare(
    ShareFile event,
    Emitter<FilesMutationState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FilesMutationStatus.shareInProgress,
        sharedPath: event.path,
      ),
    );
    try {
      await shareGateway.shareFile(event.path);
      emit(
        state.copyWith(
          status: FilesMutationStatus.shareSuccess,
          sharedPath: event.path,
        ),
      );
    } on Exception catch (e) {
      emit(
        state.copyWith(
          status: FilesMutationStatus.shareFailure,
          errorMessage: e.toString(),
          sharedPath: event.path,
        ),
      );
    }
  }
}
