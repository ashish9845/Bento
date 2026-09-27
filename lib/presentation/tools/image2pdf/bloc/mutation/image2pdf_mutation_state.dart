import 'package:freezed_annotation/freezed_annotation.dart';

part 'image2pdf_mutation_state.freezed.dart';

enum Image2PdfMutationStatus { idle, inProgress, success, failure }

@freezed
abstract class Image2PdfMutationState with _$Image2PdfMutationState {
  const factory({
    @Default(Image2PdfMutationStatus.idle) Image2PdfMutationStatus status,
    String? errorMessage,
    String? resultPath,
  }) = _Image2PdfMutationState;
}
