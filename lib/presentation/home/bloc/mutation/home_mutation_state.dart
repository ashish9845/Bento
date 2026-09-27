import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_mutation_state.freezed.dart';

enum HomeMutationStatus { idle, inProgress, success, failure }

@freezed
abstract class HomeMutationState with _$HomeMutationState {
  const factory({
    @Default(HomeMutationStatus.idle) HomeMutationStatus status,
    @Default(0) int importedCount,
    String? errorMessage,
  }) = _HomeMutationState;
}
