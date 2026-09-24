// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bento_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BentoFile _$BentoFileFromJson(Map<String, dynamic> json) => _BentoFile(
  path: json['path'] as String,
  name: json['name'] as String,
  size: (json['size'] as num).toInt(),
  modified: DateTime.parse(json['modified'] as String),
);

Map<String, dynamic> _$BentoFileToJson(_BentoFile instance) =>
    <String, dynamic>{
      'path': instance.path,
      'name': instance.name,
      'size': instance.size,
      'modified': instance.modified.toIso8601String(),
    };
