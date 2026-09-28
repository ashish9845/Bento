import 'package:freezed_annotation/freezed_annotation.dart';

part 'image2pdf_mutation_event.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Image2PdfMutationEvent with _$Image2PdfMutationEvent {
  const factory submit(List<String> imagePaths, {String? outputName}) =
      SubmitImage2Pdf;

  /// UI asks the Bloc to run the gallery picker (Bloc owns it via gateway).
  const factory pickRequested() = ImagePickRequested;

  /// Picker result (Bloc appends unique paths to selection).
  const factory picked(List<String> paths) = ImagePicked;

  /// Remove the item at [index] from the selection.
  const factory removeAt(int index) = ImageRemoveAt;

  /// Move item from [fromIndex] to [toIndex] in the selection.
  const factory reordered(int fromIndex, int toIndex) = ImageReordered;

  /// Clear the whole selection.
  const factory clearSelection() = ImageClearSelection;
}
