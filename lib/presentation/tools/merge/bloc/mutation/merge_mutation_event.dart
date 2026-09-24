import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_mutation_event.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class MergeMutationEvent with _$MergeMutationEvent {
  const factory MergeMutationEvent.submitMerge(List<String> filePaths) = SubmitMerge;
}
