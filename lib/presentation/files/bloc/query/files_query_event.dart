import 'package:freezed_annotation/freezed_annotation.dart';

part 'files_query_event.freezed.dart';

@freezed
abstract class FilesQueryEvent with _$FilesQueryEvent {
  const factory FilesQueryEvent.fetch() = FetchFiles;
  const factory FilesQueryEvent.refresh() = RefreshFiles;
}
