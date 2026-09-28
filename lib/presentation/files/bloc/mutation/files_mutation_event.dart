import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_mutation_event.freezed.dart';

@freezed
abstract class FilesMutationEvent with _$FilesMutationEvent {
  const factory deleteFile(String path) = DeleteFile;

  /// UI asks the Bloc to share [path] (Bloc owns SharePlus via gateway).
  const factory shareFile(String path) = ShareFile;
}
