import 'package:freezed_annotation/freezed_annotation.dart';

part 'image2pdf_mutation_event.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class Image2PdfMutationEvent with _$Image2PdfMutationEvent {
  const factory Image2PdfMutationEvent.submit(
    List<String> imagePaths, {
    String? outputName,
  }) = SubmitImage2Pdf;
}
