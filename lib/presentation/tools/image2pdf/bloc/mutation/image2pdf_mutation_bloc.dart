import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/tools/repositories/tools_repository.dart';
import 'image2pdf_mutation_event.dart';
import 'image2pdf_mutation_state.dart';

class Image2PdfMutationBloc extends Bloc<Image2PdfMutationEvent, Image2PdfMutationState> {
  final ToolsRepository repository;
  Image2PdfMutationBloc(this.repository) : super(const Image2PdfMutationState()) {
    on<SubmitImage2Pdf>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitImage2Pdf event, Emitter<Image2PdfMutationState> emit) async {
    emit(state.copyWith(status: Image2PdfMutationStatus.inProgress));
    try {
      final files = event.imagePaths.map((p) => File(p)).toList();
      final result = await repository.imageToPdf(files, outputName: event.outputName);
      // Already saved to chosen location inside data source; just expose path
      emit(state.copyWith(status: Image2PdfMutationStatus.success, resultPath: result.path));
    } catch (e) {
      emit(state.copyWith(status: Image2PdfMutationStatus.failure, errorMessage: e.toString()));
    }
  }
}
