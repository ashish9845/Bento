// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image2pdf_mutation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Image2PdfMutationState {

 Image2PdfMutationStatus get status; String? get errorMessage; String? get resultPath;
/// Create a copy of Image2PdfMutationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Image2PdfMutationStateCopyWith<Image2PdfMutationState> get copyWith => _$Image2PdfMutationStateCopyWithImpl<Image2PdfMutationState>(this as Image2PdfMutationState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Image2PdfMutationState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Image2PdfMutationState&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.errorMessage, _this.errorMessage) || other.errorMessage == _this.errorMessage)&&(identical(other.resultPath, _this.resultPath) || other.resultPath == _this.resultPath));
}


@override
int get hashCode {
  final _this = this as Image2PdfMutationState;
  return Object.hash(runtimeType,_this.status,_this.errorMessage,_this.resultPath);
}

@override
String toString() {
  final _this = this as Image2PdfMutationState;
  return 'Image2PdfMutationState(status: ${_this.status}, errorMessage: ${_this.errorMessage}, resultPath: ${_this.resultPath})';
}


}

/// @nodoc
abstract mixin class $Image2PdfMutationStateCopyWith<$Res>  {
  factory $Image2PdfMutationStateCopyWith(Image2PdfMutationState value, $Res Function(Image2PdfMutationState) _then) = _$Image2PdfMutationStateCopyWithImpl;
@useResult
$Res call({
 Image2PdfMutationStatus status, String? errorMessage, String? resultPath
});




}
/// @nodoc
class _$Image2PdfMutationStateCopyWithImpl<$Res>
    implements $Image2PdfMutationStateCopyWith<$Res> {
  _$Image2PdfMutationStateCopyWithImpl(this._self, this._then);

  final Image2PdfMutationState _self;
  final $Res Function(Image2PdfMutationState) _then;

/// Create a copy of Image2PdfMutationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? errorMessage = freezed,Object? resultPath = freezed,}) {
  return _then(Image2PdfMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Image2PdfMutationStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resultPath: freezed == resultPath ? _self.resultPath : resultPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Image2PdfMutationState].
extension Image2PdfMutationStatePatterns on Image2PdfMutationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Image2PdfMutationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Image2PdfMutationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Image2PdfMutationState value)  $default,){
final _that = this;
switch (_that) {
case _Image2PdfMutationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Image2PdfMutationState value)?  $default,){
final _that = this;
switch (_that) {
case _Image2PdfMutationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Image2PdfMutationStatus status,  String? errorMessage,  String? resultPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Image2PdfMutationState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.resultPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Image2PdfMutationStatus status,  String? errorMessage,  String? resultPath)  $default,) {final _that = this;
switch (_that) {
case _Image2PdfMutationState():
return $default(_that.status,_that.errorMessage,_that.resultPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Image2PdfMutationStatus status,  String? errorMessage,  String? resultPath)?  $default,) {final _that = this;
switch (_that) {
case _Image2PdfMutationState() when $default != null:
return $default(_that.status,_that.errorMessage,_that.resultPath);case _:
  return null;

}
}

}

/// @nodoc


class _Image2PdfMutationState implements Image2PdfMutationState {
  const _Image2PdfMutationState({this.status = Image2PdfMutationStatus.idle, this.errorMessage, this.resultPath});
  

@override@JsonKey() final  Image2PdfMutationStatus status;
@override final  String? errorMessage;
@override final  String? resultPath;

/// Create a copy of Image2PdfMutationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$Image2PdfMutationStateCopyWith<_Image2PdfMutationState> get copyWith => __$Image2PdfMutationStateCopyWithImpl<_Image2PdfMutationState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Image2PdfMutationState&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.resultPath, resultPath) || other.resultPath == resultPath));
}


@override
int get hashCode {
    return Object.hash(runtimeType,status,errorMessage,resultPath);
}

@override
String toString() {
    return 'Image2PdfMutationState(status: $status, errorMessage: $errorMessage, resultPath: $resultPath)';
}


}

/// @nodoc
abstract mixin class _$Image2PdfMutationStateCopyWith<$Res> implements $Image2PdfMutationStateCopyWith<$Res> {
  factory _$Image2PdfMutationStateCopyWith(_Image2PdfMutationState value, $Res Function(_Image2PdfMutationState) _then) = __$Image2PdfMutationStateCopyWithImpl;
@override @useResult
$Res call({
 Image2PdfMutationStatus status, String? errorMessage, String? resultPath
});




}
/// @nodoc
class __$Image2PdfMutationStateCopyWithImpl<$Res>
    implements _$Image2PdfMutationStateCopyWith<$Res> {
  __$Image2PdfMutationStateCopyWithImpl(this._self, this._then);

  final _Image2PdfMutationState _self;
  final $Res Function(_Image2PdfMutationState) _then;

/// Create a copy of Image2PdfMutationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? errorMessage = freezed,Object? resultPath = freezed,}) {
  return _then(_Image2PdfMutationState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as Image2PdfMutationStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,resultPath: freezed == resultPath ? _self.resultPath : resultPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
