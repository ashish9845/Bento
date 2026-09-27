// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_mutation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeMutationState {

 HomeMutationStatus get status; int get importedCount; String? get errorMessage;
/// Create a copy of HomeMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeMutationStateCopyWith<HomeMutationState> get copyWith => _$HomeMutationStateCopyWithImpl<HomeMutationState>(this as HomeMutationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeMutationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeMutationState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.importedCount, _this.importedCount) || other.importedCount == _this.importedCount)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage));
}


@override
int get hashCode {
  final _this = this as HomeMutationState;
  return Object.hash(runtimeType,_this.status,_this.importedCount,_this.errorMessage);
}

@override
String toString() {
  final _this = this as HomeMutationState;
  return 'HomeMutationState(status: ${_this.status}, importedCount: ${_this.importedCount}, errorMessage: ${_this.errorMessage})';
}


}

/// @nodoc
abstract mixin class $HomeMutationStateCopyWith<$Res>  {
  factory $HomeMutationStateCopyWith(HomeMutationState value, $Res Function(HomeMutationState) _then) = _$HomeMutationStateCopyWithImpl;
@useResult
$Res call({
 HomeMutationStatus status, int importedCount, String? errorMessage
});




}
/// @nodoc
class _$HomeMutationStateCopyWithImpl<$Res>
    implements $HomeMutationStateCopyWith<$Res> {
  _$HomeMutationStateCopyWithImpl(this._self, this._then);

  final HomeMutationState _self;
  final $Res Function(HomeMutationState) _then;

/// Create a copy of HomeMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? importedCount = null,Object? errorMessage = freezed,}) {
  return _then(HomeMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HomeMutationStatus,importedCount: null == importedCount ? _self.importedCount : importedCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeMutationState].
extension HomeMutationStatePatterns on HomeMutationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeMutationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeMutationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeMutationState value)  $default,){
final _that = this;
switch (_that) {
case _HomeMutationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeMutationState value)?  $default,){
final _that = this;
switch (_that) {
case _HomeMutationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HomeMutationStatus status,  int importedCount,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeMutationState() when $default != null:
return $default(_that.status,_that.importedCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HomeMutationStatus status,  int importedCount,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _HomeMutationState():
return $default(_that.status,_that.importedCount,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HomeMutationStatus status,  int importedCount,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _HomeMutationState() when $default != null:
return $default(_that.status,_that.importedCount,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _HomeMutationState implements HomeMutationState {
  const _HomeMutationState({this.status = HomeMutationStatus.idle, this.importedCount = 0, this.errorMessage});
  

@override@JsonKey() final  HomeMutationStatus status;
@override@JsonKey() final  int importedCount;
@override final  String? errorMessage;

/// Create a copy of HomeMutationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeMutationStateCopyWith<_HomeMutationState> get copyWith => __$HomeMutationStateCopyWithImpl<_HomeMutationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeMutationState&&(identical(other.status, status) || other.status == status)&&(identical(other.importedCount, importedCount) || other.importedCount == importedCount)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,importedCount,errorMessage);
}

@override
String toString() {
    return 'HomeMutationState(status: $status, importedCount: $importedCount, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$HomeMutationStateCopyWith<$Res> implements $HomeMutationStateCopyWith<$Res> {
  factory _$HomeMutationStateCopyWith(_HomeMutationState value, $Res Function(_HomeMutationState) _then) = __$HomeMutationStateCopyWithImpl;
@override @useResult
$Res call({
 HomeMutationStatus status, int importedCount, String? errorMessage
});




}
/// @nodoc
class __$HomeMutationStateCopyWithImpl<$Res>
    implements _$HomeMutationStateCopyWith<$Res> {
  __$HomeMutationStateCopyWithImpl(this._self, this._then);

  final _HomeMutationState _self;
  final $Res Function(_HomeMutationState) _then;

/// Create a copy of HomeMutationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? importedCount = null,Object? errorMessage = freezed,}) {
  return _then(_HomeMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HomeMutationStatus,importedCount: null == importedCount ? _self.importedCount : importedCount // ignore: cast_nullable_to_non_nullable
as int,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
