// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'files_mutation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilesMutationState {

 FilesMutationStatus get status; String? get errorMessage; String? get sharedPath;
/// Create a copy of FilesMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesMutationStateCopyWith<FilesMutationState> get copyWith => _$FilesMutationStateCopyWithImpl<FilesMutationState>(this as FilesMutationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as FilesMutationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesMutationState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.sharedPath, _this.sharedPath) || other.sharedPath == _this.sharedPath));
}


@override
int get hashCode {
  final _this = this as FilesMutationState;
  return Object.hash(runtimeType,_this.status,_this.errorMessage,_this.sharedPath);
}

@override
String toString() {
  final _this = this as FilesMutationState;
  return 'FilesMutationState(status: ${_this.status}, errorMessage: ${_this.errorMessage}, sharedPath: ${_this.sharedPath})';
}


}

/// @nodoc
abstract mixin class $FilesMutationStateCopyWith<$Res>  {
  factory $FilesMutationStateCopyWith(FilesMutationState value, $Res Function(FilesMutationState) _then) = _$FilesMutationStateCopyWithImpl;
@useResult
$Res call({
 FilesMutationStatus status, String? errorMessage, String? sharedPath
});




}
/// @nodoc
class _$FilesMutationStateCopyWithImpl<$Res>
    implements $FilesMutationStateCopyWith<$Res> {
  _$FilesMutationStateCopyWithImpl(this._self, this._then);

  final FilesMutationState _self;
  final $Res Function(FilesMutationState) _then;

/// Create a copy of FilesMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? sharedPath = freezed,}) {
  return _then(FilesMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FilesMutationStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,sharedPath: freezed == sharedPath ? _self.sharedPath : sharedPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FilesMutationState].
extension FilesMutationStatePatterns on FilesMutationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilesMutationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilesMutationState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilesMutationState value)  $default,){
final _that = this;
switch (_that) {
case _FilesMutationState():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilesMutationState value)?  $default,){
final _that = this;
switch (_that) {
case _FilesMutationState() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FilesMutationStatus status,  String? errorMessage,  String? sharedPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilesMutationState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.sharedPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FilesMutationStatus status,  String? errorMessage,  String? sharedPath)  $default,) {final _that = this;
switch (_that) {
case _FilesMutationState():
return $default(_that.status,_that.errorMessage,_that.sharedPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FilesMutationStatus status,  String? errorMessage,  String? sharedPath)?  $default,) {final _that = this;
switch (_that) {
case _FilesMutationState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.sharedPath);case _:
  return null;

}
}

}

/// @nodoc


class _FilesMutationState implements FilesMutationState {
  const _FilesMutationState({this.status = FilesMutationStatus.idle, this.errorMessage, this.sharedPath});
  

@override@JsonKey() final  FilesMutationStatus status;
@override final  String? errorMessage;
@override final  String? sharedPath;

/// Create a copy of FilesMutationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilesMutationStateCopyWith<_FilesMutationState> get copyWith => __$FilesMutationStateCopyWithImpl<_FilesMutationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilesMutationState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.sharedPath, sharedPath) || other.sharedPath == sharedPath));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,errorMessage,sharedPath);
}

@override
String toString() {
    return 'FilesMutationState(status: $status, errorMessage: $errorMessage, sharedPath: $sharedPath)';
}


}

/// @nodoc
abstract mixin class _$FilesMutationStateCopyWith<$Res> implements $FilesMutationStateCopyWith<$Res> {
  factory _$FilesMutationStateCopyWith(_FilesMutationState value, $Res Function(_FilesMutationState) _then) = __$FilesMutationStateCopyWithImpl;
@override @useResult
$Res call({
 FilesMutationStatus status, String? errorMessage, String? sharedPath
});




}
/// @nodoc
class __$FilesMutationStateCopyWithImpl<$Res>
    implements _$FilesMutationStateCopyWith<$Res> {
  __$FilesMutationStateCopyWithImpl(this._self, this._then);

  final _FilesMutationState _self;
  final $Res Function(_FilesMutationState) _then;

/// Create a copy of FilesMutationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? sharedPath = freezed,}) {
  return _then(_FilesMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FilesMutationStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,sharedPath: freezed == sharedPath ? _self.sharedPath : sharedPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
