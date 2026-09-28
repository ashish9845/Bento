import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_mutation_event.freezed.dart';

@freezed
abstract class HomeMutationEvent with _$HomeMutationEvent {
  const factory importFiles(List<String> pickedPaths) = ImportFiles;
}
