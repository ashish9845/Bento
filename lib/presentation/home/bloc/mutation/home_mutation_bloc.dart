import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/files/repositories/files_repository.dart';
import 'home_mutation_event.dart';
import 'home_mutation_state.dart';

class HomeMutationBloc extends Bloc<HomeMutationEvent, HomeMutationState> {
  final FilesRepository repository;
  HomeMutationBloc(this.repository) : super(const HomeMutationState()) {
    on<ImportFiles>(_onImport);
  }

  Future<void> _onImport(
    ImportFiles event,
    Emitter<HomeMutationState> emit,
  ) async {
    if (event.pickedPaths.isEmpty) return;
    emit(state.copyWith(status: HomeMutationStatus.inProgress));
    try {
      final saved = await repository.importFiles(
        event.pickedPaths.map(File.new).toList(),
      );
      emit(
        state.copyWith(
          status: HomeMutationStatus.success,
          importedCount: saved.length,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeMutationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
