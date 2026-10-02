import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/pickers/pdf_picker_gateway.dart';
import '../../../../../data/tools/repositories/tools_repository.dart';
import 'merge_mutation_event.dart';
import 'merge_mutation_state.dart';

class MergeMutationBloc extends Bloc<MergeMutationEvent, MergeMutationState> {
  final ToolsRepository repository;
  final PdfPickerGateway picker;

  new(this.repository, {PdfPickerGateway? picker})
    : picker = picker ?? const FilePickerPdfGateway(),
      super(const MergeMutationState()) {
    on<SubmitMerge>(_onSubmit);
    on<PickRequested>(_onPickRequested);
    on<Picked>(_onPicked);
    on<RemoveAt>(_onRemoveAt);
    on<Reordered>(_onReordered);
    on<ClearSelection>(_onClear);
  }

  Future<void> _onPickRequested(
    PickRequested event,
    Emitter<MergeMutationState> emit,
  ) async {
    try {
      final paths = await picker.pickPdfPaths();
      if (paths.isNotEmpty) add(MergeMutationEvent.picked(paths));
    } on Exception catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: MergeMutationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onPicked(Picked event, Emitter<MergeMutationState> emit) {
    final next = [...state.pickedPaths];
    for (final p in event.paths) {
      if (p.isNotEmpty && !next.contains(p)) next.add(p);
    }
    emit(state.copyWith(pickedPaths: next));
  }

  void _onRemoveAt(RemoveAt event, Emitter<MergeMutationState> emit) {
    final next = [...state.pickedPaths];
    if (event.index < 0 || event.index >= next.length) return;
    next.removeAt(event.index);
    emit(state.copyWith(pickedPaths: next));
  }

  void _onReordered(Reordered event, Emitter<MergeMutationState> emit) {
    final next = [...state.pickedPaths];
    if (event.oldIndex < 0 ||
        event.oldIndex >= next.length ||
        event.newIndex < 0 ||
        event.newIndex > next.length) {
      return;
    }
    final item = next.removeAt(event.oldIndex);
    // Caller uses onReorderItem semantics (newIndex already adjusted).
    final insertAt = event.newIndex.clamp(0, next.length);
    next.insert(insertAt, item);
    emit(state.copyWith(pickedPaths: next));
  }

  void _onClear(ClearSelection event, Emitter<MergeMutationState> emit) {
    emit(state.copyWith(pickedPaths: const []));
  }

  Future<void> _onSubmit(
    SubmitMerge event,
    Emitter<MergeMutationState> emit,
  ) async {
    emit(state.copyWith(status: MergeMutationStatus.inProgress));
    try {
      final files = event.filePaths.map(File.new).toList();
      final result = await repository.mergePdfs(
        files,
        outputName: event.outputName,
      );
      await repository.saveFile(result);
      emit(
        state.copyWith(
          status: MergeMutationStatus.success,
          resultPath: result.path,
        ),
      );
    } on Exception catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          status: MergeMutationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
