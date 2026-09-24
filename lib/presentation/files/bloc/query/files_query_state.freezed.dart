// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'files_query_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FilesQueryState {

 FilesQueryStatus get status; List<BentoFile> get files; String? get errorMessage;
/// Create a copy of FilesQueryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FilesQueryStateCopyWith<FilesQueryState> get copyWith => _$FilesQueryStateCopyWithImpl<FilesQueryState>(this as FilesQueryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FilesQueryState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(files),errorMessage);

@override
String toString() {
  return 'FilesQueryState(status: $status, files: $files, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $FilesQueryStateCopyWith<$Res>  {
  factory $FilesQueryStateCopyWith(FilesQueryState value, $Res Function(FilesQueryState) _then) = _$FilesQueryStateCopyWithImpl;
@useResult
$Res call({
 FilesQueryStatus status, List<BentoFile> files, String? errorMessage
});




}
/// @nodoc
class _$FilesQueryStateCopyWithImpl<$Res>
    implements $FilesQueryStateCopyWith<$Res> {
  _$FilesQueryStateCopyWithImpl(this._self, this._then);

  final FilesQueryState _self;
  final $Res Function(FilesQueryState) _then;

/// Create a copy of FilesQueryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? files = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FilesQueryStatus,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<BentoFile>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FilesQueryState].
extension FilesQueryStatePatterns on FilesQueryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FilesQueryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FilesQueryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FilesQueryState value)  $default,){
final _that = this;
switch (_that) {
case _FilesQueryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FilesQueryState value)?  $default,){
final _that = this;
switch (_that) {
case _FilesQueryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FilesQueryStatus status,  List<BentoFile> files,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FilesQueryState() when $default != null:
return $default(_that.status,_that.files,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FilesQueryStatus status,  List<BentoFile> files,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _FilesQueryState():
return $default(_that.status,_that.files,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FilesQueryStatus status,  List<BentoFile> files,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _FilesQueryState() when $default != null:
return $default(_that.status,_that.files,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _FilesQueryState implements FilesQueryState {
  const _FilesQueryState({this.status = FilesQueryStatus.initial, this.files = const [], this.errorMessage});
  

@override@JsonKey() final  FilesQueryStatus status;
@override@JsonKey() final  List<BentoFile> files;
@override final  String? errorMessage;

/// Create a copy of FilesQueryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FilesQueryStateCopyWith<_FilesQueryState> get copyWith => __$FilesQueryStateCopyWithImpl<_FilesQueryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FilesQueryState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(files),errorMessage);

@override
String toString() {
  return 'FilesQueryState(status: $status, files: $files, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$FilesQueryStateCopyWith<$Res> implements $FilesQueryStateCopyWith<$Res> {
  factory _$FilesQueryStateCopyWith(_FilesQueryState value, $Res Function(_FilesQueryState) _then) = __$FilesQueryStateCopyWithImpl;
@override @useResult
$Res call({
 FilesQueryStatus status, List<BentoFile> files, String? errorMessage
});




}
/// @nodoc
class __$FilesQueryStateCopyWithImpl<$Res>
    implements _$FilesQueryStateCopyWith<$Res> {
  __$FilesQueryStateCopyWithImpl(this._self, this._then);

  final _FilesQueryState _self;
  final $Res Function(_FilesQueryState) _then;

/// Create a copy of FilesQueryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? files = null,Object? errorMessage = freezed,}) {
  return _then(_FilesQueryState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FilesQueryStatus,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<BentoFile>,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
