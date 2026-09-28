import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_mutation_state.freezed.dart';

enum FilesMutationStatus {
  idle,
  inProgress,
  success,
  failure,
  shareInProgress,
  shareSuccess,
  shareFailure,
}

@freezed
abstract class FilesMutationState with _$FilesMutationState {
  const factory({
    @Default(FilesMutationStatus.idle) FilesMutationStatus status,
    String? errorMessage,
    String? sharedPath,
  }) = _FilesMutationState;
}
