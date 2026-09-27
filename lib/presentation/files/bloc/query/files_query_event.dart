import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_query_event.freezed.dart';

@freezed
abstract class FilesQueryEvent with _$FilesQueryEvent {
  const factory fetch() = FetchFiles;
  const factory refresh() = RefreshFiles;
}
