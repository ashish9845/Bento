import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../data/tools/repositories/tools_repository.dart';
import 'merge_mutation_event.dart';
import 'merge_mutation_state.dart';

class MergeMutationBloc extends Bloc<MergeMutationEvent, MergeMutationState> {
  final ToolsRepository repository;
  MergeMutationBloc(this.repository) : super(const MergeMutationState()) {
    on<SubmitMerge>(_onSubmit);
  }

  Future<void> _onSubmit(SubmitMerge event, Emitter<MergeMutationState> emit) async {
    emit(state.copyWith(status: MergeMutationStatus.inProgress));
    try {
      final files = event.filePaths.map((p) => File(p)).toList();
      final result = await repository.mergePdfs(files, outputName: event.outputName);
      await repository.saveFile(result);
      emit(state.copyWith(status: MergeMutationStatus.success, resultPath: result.path));
    } catch (e) {
      emit(state.copyWith(status: MergeMutationStatus.failure, errorMessage: e.toString()));
    }
  }
}
