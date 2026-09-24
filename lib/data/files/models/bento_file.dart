import 'package:freezed_annotation/freezed_annotation.dart';

part 'bento_file.freezed.dart';
part 'bento_file.g.dart';

@freezed
abstract class BentoFile with _$BentoFile {
  const factory BentoFile({
    required String path,
    required String name,
    required int size,
    required DateTime modified,
  }) = _BentoFile;

  factory BentoFile.fromJson(Map<String, dynamic> json) => _$BentoFileFromJson(json);
}
