// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'merge_mutation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MergeMutationEvent {

 List<String> get filePaths; String? get outputName;
/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MergeMutationEventCopyWith<MergeMutationEvent> get copyWith => _$MergeMutationEventCopyWithImpl<MergeMutationEvent>(this as MergeMutationEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MergeMutationEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeMutationEvent&&const DeepCollectionEquality().equals(other.filePaths, _this.filePaths)&&(identical(other.outputName, _this.outputName) || other.outputName == _this.outputName));
}


@override
int get hashCode {
  final _this = this as MergeMutationEvent;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.filePaths),_this.outputName);
}

@override
String toString() {
  final _this = this as MergeMutationEvent;
  return 'MergeMutationEvent(filePaths: ${_this.filePaths}, outputName: ${_this.outputName})';
}


}

/// @nodoc
abstract mixin class $MergeMutationEventCopyWith<$Res>  {
  factory $MergeMutationEventCopyWith(MergeMutationEvent value, $Res Function(MergeMutationEvent) _then) = _$MergeMutationEventCopyWithImpl;
@useResult
$Res call({
 List<String> filePaths, String? outputName
});




}
/// @nodoc
class _$MergeMutationEventCopyWithImpl<$Res>
    implements $MergeMutationEventCopyWith<$Res> {
  _$MergeMutationEventCopyWithImpl(this._self, this._then);

  final MergeMutationEvent _self;
  final $Res Function(MergeMutationEvent) _then;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? filePaths = null,Object? outputName = freezed,}) {
  return _then(MergeMutationEvent.submitMerge(
null == filePaths ? _self.filePaths : filePaths // ignore: cast_nullable_to_non_nullable
as List<String>,outputName: freezed == outputName ? _self.outputName : outputName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [MergeMutationEvent].
extension MergeMutationEventPatterns on MergeMutationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SubmitMerge value)?  submitMerge,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SubmitMerge value)  submitMerge,}){
final _that = this;
switch (_that) {
case SubmitMerge():
return submitMerge(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SubmitMerge value)?  submitMerge,}){
final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> filePaths,  String? outputName)?  submitMerge,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that.filePaths,_that.outputName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> filePaths,  String? outputName)  submitMerge,}) {final _that = this;
switch (_that) {
case SubmitMerge():
return submitMerge(_that.filePaths,_that.outputName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> filePaths,  String? outputName)?  submitMerge,}) {final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that.filePaths,_that.outputName);case _:
  return null;

}
}

}

/// @nodoc


class SubmitMerge implements MergeMutationEvent {
  const SubmitMerge(this.filePaths, {this.outputName});
  

@override final  List<String> filePaths;
@override final  String? outputName;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubmitMergeCopyWith<SubmitMerge> get copyWith => _$SubmitMergeCopyWithImpl<SubmitMerge>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is SubmitMerge&&const DeepCollectionEquality().equals(other.filePaths, filePaths)&&(identical(other.outputName, outputName) || other.outputName == outputName));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(filePaths),outputName);
}

@override
String toString() {
    return 'MergeMutationEvent.submitMerge(filePaths: $filePaths, outputName: $outputName)';
}


}

/// @nodoc
abstract mixin class $SubmitMergeCopyWith<$Res> implements $MergeMutationEventCopyWith<$Res> {
  factory $SubmitMergeCopyWith(SubmitMerge value, $Res Function(SubmitMerge) _then) = _$SubmitMergeCopyWithImpl;
@override @useResult
$Res call({
 List<String> filePaths, String? outputName
});




}
/// @nodoc
class _$SubmitMergeCopyWithImpl<$Res>
    implements $SubmitMergeCopyWith<$Res> {
  _$SubmitMergeCopyWithImpl(this._self, this._then);

  final SubmitMerge _self;
  final $Res Function(SubmitMerge) _then;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? filePaths = null,Object? outputName = freezed,}) {
  return _then(SubmitMerge(
null == filePaths ? _self.filePaths : filePaths // ignore: cast_nullable_to_non_nullable
as List<String>,outputName: freezed == outputName ? _self.outputName : outputName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
