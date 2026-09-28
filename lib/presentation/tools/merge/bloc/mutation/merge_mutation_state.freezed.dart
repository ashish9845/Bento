// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_mutation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MergeMutationState {

 MergeMutationStatus get status; String? get errorMessage; String? get resultPath; List<String> get pickedPaths;
/// Create a copy of MergeMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeMutationStateCopyWith<MergeMutationState> get copyWith => _$MergeMutationStateCopyWithImpl<MergeMutationState>(this as MergeMutationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MergeMutationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeMutationState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.resultPath, _this.resultPath) || other.resultPath == _this.resultPath)&&const DeepCollectionEquality().equals(other.pickedPaths, _this.pickedPaths));
}


@override
int get hashCode {
  final _this = this as MergeMutationState;
  return Object.hash(runtimeType,_this.status,_this.errorMessage,_this.resultPath,const DeepCollectionEquality().hash(_this.pickedPaths));
}

@override
String toString() {
  final _this = this as MergeMutationState;
  return 'MergeMutationState(status: ${_this.status}, errorMessage: ${_this.errorMessage}, resultPath: ${_this.resultPath}, pickedPaths: ${_this.pickedPaths})';
}


}

/// @nodoc
abstract mixin class $MergeMutationStateCopyWith<$Res>  {
  factory $MergeMutationStateCopyWith(MergeMutationState value, $Res Function(MergeMutationState) _then) = _$MergeMutationStateCopyWithImpl;
@useResult
$Res call({
 MergeMutationStatus status, String? errorMessage, String? resultPath, List<String> pickedPaths
});




}
/// @nodoc
class _$MergeMutationStateCopyWithImpl<$Res>
    implements $MergeMutationStateCopyWith<$Res> {
  _$MergeMutationStateCopyWithImpl(this._self, this._then);

  final MergeMutationState _self;
  final $Res Function(MergeMutationState) _then;

/// Create a copy of MergeMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? resultPath = freezed,Object? pickedPaths = null,}) {
  return _then(MergeMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MergeMutationStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resultPath: freezed == resultPath ? _self.resultPath : resultPath // ignore: cast_nullable_to_non_nullable
as String?,pickedPaths: null == pickedPaths ? _self.pickedPaths : pickedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [MergeMutationState].
extension MergeMutationStatePatterns on MergeMutationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MergeMutationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MergeMutationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MergeMutationState value)  $default,){
final _that = this;
switch (_that) {
case _MergeMutationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MergeMutationState value)?  $default,){
final _that = this;
switch (_that) {
case _MergeMutationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MergeMutationStatus status,  String? errorMessage,  String? resultPath,  List<String> pickedPaths)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MergeMutationState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.resultPath,_that.pickedPaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MergeMutationStatus status,  String? errorMessage,  String? resultPath,  List<String> pickedPaths)  $default,) {final _that = this;
switch (_that) {
case _MergeMutationState():
return $default(_that.status,_that.errorMessage,_that.resultPath,_that.pickedPaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MergeMutationStatus status,  String? errorMessage,  String? resultPath,  List<String> pickedPaths)?  $default,) {final _that = this;
switch (_that) {
case _MergeMutationState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.resultPath,_that.pickedPaths);case _:
  return null;

}
}

}

/// @nodoc


class _MergeMutationState implements MergeMutationState {
  const _MergeMutationState({this.status = MergeMutationStatus.idle, this.errorMessage, this.resultPath,  List<String> pickedPaths = const []}): _pickedPaths = pickedPaths;
  

@override@JsonKey() final  MergeMutationStatus status;
@override final  String? errorMessage;
@override final  String? resultPath;
 final  List<String> _pickedPaths;
@override@JsonKey() List<String> get pickedPaths {
  if (_pickedPaths is EqualUnmodifiableListView) return _pickedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pickedPaths);
}


/// Create a copy of MergeMutationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MergeMutationStateCopyWith<_MergeMutationState> get copyWith => __$MergeMutationStateCopyWithImpl<_MergeMutationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MergeMutationState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.resultPath, resultPath) || other.resultPath == resultPath)&&const DeepCollectionEquality().equals(other.pickedPaths, _pickedPaths));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,errorMessage,resultPath,const DeepCollectionEquality().hash(_pickedPaths));
}

@override
String toString() {
    return 'MergeMutationState(status: $status, errorMessage: $errorMessage, resultPath: $resultPath, pickedPaths: $pickedPaths)';
}


}

/// @nodoc
abstract mixin class _$MergeMutationStateCopyWith<$Res> implements $MergeMutationStateCopyWith<$Res> {
  factory _$MergeMutationStateCopyWith(_MergeMutationState value, $Res Function(_MergeMutationState) _then) = __$MergeMutationStateCopyWithImpl;
@override @useResult
$Res call({
 MergeMutationStatus status, String? errorMessage, String? resultPath, List<String> pickedPaths
});




}
/// @nodoc
class __$MergeMutationStateCopyWithImpl<$Res>
    implements _$MergeMutationStateCopyWith<$Res> {
  __$MergeMutationStateCopyWithImpl(this._self, this._then);

  final _MergeMutationState _self;
  final $Res Function(_MergeMutationState) _then;

/// Create a copy of MergeMutationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? resultPath = freezed,Object? pickedPaths = null,}) {
  return _then(_MergeMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MergeMutationStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resultPath: freezed == resultPath ? _self.resultPath : resultPath // ignore: cast_nullable_to_non_nullable
as String?,pickedPaths: null == pickedPaths ? _self._pickedPaths : pickedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
