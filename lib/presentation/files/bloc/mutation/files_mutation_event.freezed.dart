// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'files_mutation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilesMutationEvent {

 String get path;
/// Create a copy of FilesMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesMutationEventCopyWith<FilesMutationEvent> get copyWith => _$FilesMutationEventCopyWithImpl<FilesMutationEvent>(this as FilesMutationEvent, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesMutationEvent&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilesMutationEvent(path: $path)';
}


}

/// @nodoc
abstract mixin class $FilesMutationEventCopyWith<$Res>  {
  factory $FilesMutationEventCopyWith(FilesMutationEvent value, $Res Function(FilesMutationEvent) _then) = _$FilesMutationEventCopyWithImpl;
@useResult
$Res call({
 String path
});




}
/// @nodoc
class _$FilesMutationEventCopyWithImpl<$Res>
    implements $FilesMutationEventCopyWith<$Res> {
  _$FilesMutationEventCopyWithImpl(this._self, this._then);

  final FilesMutationEvent _self;
  final $Res Function(FilesMutationEvent) _then;

/// Create a copy of FilesMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FilesMutationEvent].
extension FilesMutationEventPatterns on FilesMutationEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( DeleteFile value)?  deleteFile,required TResult orElse(),}){
final _that = this;
switch (_that) {
case DeleteFile() when deleteFile != null:
return deleteFile(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( DeleteFile value)  deleteFile,}){
final _that = this;
switch (_that) {
case DeleteFile():
return deleteFile(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( DeleteFile value)?  deleteFile,}){
final _that = this;
switch (_that) {
case DeleteFile() when deleteFile != null:
return deleteFile(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String path)?  deleteFile,required TResult orElse(),}) {final _that = this;
switch (_that) {
case DeleteFile() when deleteFile != null:
return deleteFile(_that.path);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String path)  deleteFile,}) {final _that = this;
switch (_that) {
case DeleteFile():
return deleteFile(_that.path);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String path)?  deleteFile,}) {final _that = this;
switch (_that) {
case DeleteFile() when deleteFile != null:
return deleteFile(_that.path);case _:
  return null;

}
}

}

/// @nodoc


class DeleteFile implements FilesMutationEvent {
  const DeleteFile(this.path);
  

@override final  String path;

/// Create a copy of FilesMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeleteFileCopyWith<DeleteFile> get copyWith => _$DeleteFileCopyWithImpl<DeleteFile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeleteFile&&(identical(other.path, path) || other.path == path));
}


@override
int get hashCode => Object.hash(runtimeType,path);

@override
String toString() {
  return 'FilesMutationEvent.deleteFile(path: $path)';
}


}

/// @nodoc
abstract mixin class $DeleteFileCopyWith<$Res> implements $FilesMutationEventCopyWith<$Res> {
  factory $DeleteFileCopyWith(DeleteFile value, $Res Function(DeleteFile) _then) = _$DeleteFileCopyWithImpl;
@override @useResult
$Res call({
 String path
});




}
/// @nodoc
class _$DeleteFileCopyWithImpl<$Res>
    implements $DeleteFileCopyWith<$Res> {
  _$DeleteFileCopyWithImpl(this._self, this._then);

  final DeleteFile _self;
  final $Res Function(DeleteFile) _then;

/// Create a copy of FilesMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,}) {
  return _then(DeleteFile(
null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
