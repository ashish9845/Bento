import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_mutation_event.freezed.dart';

@Freezed(makeCollectionsUnmodifiable: false)
abstract class HomeMutationEvent with _$HomeMutationEvent {
  const factory HomeMutationEvent.importFiles(List<String> pickedPaths) = ImportFiles;
}
