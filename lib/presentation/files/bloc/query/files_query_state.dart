import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../data/files/models/bento_file.dart';

part 'files_query_state.freezed.dart';

enum FilesQueryStatus { initial, loading, loaded, error }

@Freezed(makeCollectionsUnmodifiable: false)
abstract class FilesQueryState with _$FilesQueryState {
  const factory({
    @Default(FilesQueryStatus.initial) FilesQueryStatus status,
    @Default([]) List<BentoFile> files,
    String? errorMessage,
  }) = _FilesQueryState;
}
