import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_mutation_state.freezed.dart';

enum MergeMutationStatus { idle, inProgress, success, failure }

@freezed
abstract class MergeMutationState with _$MergeMutationState {
  const factory({
    @Default(MergeMutationStatus.idle) MergeMutationStatus status,
    String? errorMessage,
    String? resultPath,
  }) = _MergeMutationState;
}
