import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/pickers/image_picker_gateway.dart';
import '../../../../../data/tools/repositories/tools_repository.dart';
import 'image2pdf_mutation_event.dart';
import 'image2pdf_mutation_state.dart';

class Image2PdfMutationBloc
    extends Bloc<Image2PdfMutationEvent, Image2PdfMutationState> {
  final ToolsRepository repository;
  final ImagePickerGateway picker;

  new(this.repository, {ImagePickerGateway? picker})
    : picker = picker ?? const GalleryImagePickerGateway(),
      super(const Image2PdfMutationState()) {
    on<SubmitImage2Pdf>(_onSubmit);
    on<ImagePickRequested>(_onPickRequested);
    on<ImagePicked>(_onPicked);
    on<ImageRemoveAt>(_onRemoveAt);
    on<ImageReordered>(_onReordered);
    on<ImageClearSelection>(_onClear);
  }

  Future<void> _onPickRequested(
    ImagePickRequested event,
    Emitter<Image2PdfMutationState> emit,
  ) async {
    try {
      final paths = await picker.pickImagePaths();
      if (paths.isNotEmpty) {
        add(Image2PdfMutationEvent.picked(paths));
      }
    } on Exception catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: Image2PdfMutationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onPicked(ImagePicked event, Emitter<Image2PdfMutationState> emit) {
    final next = [...state.pickedPaths];
    for (final p in event.paths) {
      if (p.isNotEmpty && !next.contains(p)) next.add(p);
    }
    emit(state.copyWith(pickedPaths: next));
  }

  void _onRemoveAt(ImageRemoveAt event, Emitter<Image2PdfMutationState> emit) {
    final next = [...state.pickedPaths];
    if (event.index < 0 || event.index >= next.length) return;
    next.removeAt(event.index);
    emit(state.copyWith(pickedPaths: next));
  }

  void _onReordered(
    ImageReordered event,
    Emitter<Image2PdfMutationState> emit,
  ) {
    final next = [...state.pickedPaths];
    if (event.fromIndex < 0 ||
        event.fromIndex >= next.length ||
        event.toIndex < 0 ||
        event.toIndex >= next.length ||
        event.fromIndex == event.toIndex) {
      return;
    }
    final item = next.removeAt(event.fromIndex);
    next.insert(event.toIndex, item);
    emit(state.copyWith(pickedPaths: next));
  }

  void _onClear(
    ImageClearSelection event,
    Emitter<Image2PdfMutationState> emit,
  ) {
    emit(state.copyWith(pickedPaths: const []));
  }

  Future<void> _onSubmit(
    SubmitImage2Pdf event,
    Emitter<Image2PdfMutationState> emit,
  ) async {
    emit(state.copyWith(status: Image2PdfMutationStatus.inProgress));
    try {
      final files = event.imagePaths.map(File.new).toList();
      final result = await repository.imageToPdf(
        files,
        outputName: event.outputName,
      );
      // Already saved to chosen location inside data source; just expose path
      emit(
        state.copyWith(
          status: Image2PdfMutationStatus.success,
          resultPath: result.path,
        ),
      );
    } on Exception catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: Image2PdfMutationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
