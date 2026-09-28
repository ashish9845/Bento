import 'package:freezed_annotation/freezed_annotation.dart';

part 'merge_mutation_event.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class MergeMutationEvent with _$MergeMutationEvent {
  const factory submitMerge(List<String> filePaths, {String? outputName}) =
      SubmitMerge;

  /// UI asks the Bloc to run the picker (Bloc owns FilePicker via gateway).
  const factory pickRequested() = PickRequested;

  /// Picker result (Bloc appends unique paths to selection).
  const factory picked(List<String> paths) = Picked;

  /// Remove the item at [index] from the selection.
  const factory removeAt(int index) = RemoveAt;

  /// Reorder selection (oldIndex -> newIndex, already adjusted for removal).
  const factory reordered(int oldIndex, int newIndex) = Reordered;

  /// Clear the whole selection.
  const factory clearSelection() = ClearSelection;
}
