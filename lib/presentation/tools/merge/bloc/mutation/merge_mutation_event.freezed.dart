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





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is MergeMutationEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MergeMutationEvent()';
}


}

/// @nodoc
class $MergeMutationEventCopyWith<$Res>  {
$MergeMutationEventCopyWith(MergeMutationEvent _, $Res Function(MergeMutationEvent) __);
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SubmitMerge value)?  submitMerge,TResult Function( PickRequested value)?  pickRequested,TResult Function( Picked value)?  picked,TResult Function( RemoveAt value)?  removeAt,TResult Function( Reordered value)?  reordered,TResult Function( ClearSelection value)?  clearSelection,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that);case PickRequested() when pickRequested != null:
return pickRequested(_that);case Picked() when picked != null:
return picked(_that);case RemoveAt() when removeAt != null:
return removeAt(_that);case Reordered() when reordered != null:
return reordered(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SubmitMerge value)  submitMerge,required TResult Function( PickRequested value)  pickRequested,required TResult Function( Picked value)  picked,required TResult Function( RemoveAt value)  removeAt,required TResult Function( Reordered value)  reordered,required TResult Function( ClearSelection value)  clearSelection,}){
final _that = this;
switch (_that) {
case SubmitMerge():
return submitMerge(_that);case PickRequested():
return pickRequested(_that);case Picked():
return picked(_that);case RemoveAt():
return removeAt(_that);case Reordered():
return reordered(_that);case ClearSelection():
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SubmitMerge value)?  submitMerge,TResult? Function( PickRequested value)?  pickRequested,TResult? Function( Picked value)?  picked,TResult? Function( RemoveAt value)?  removeAt,TResult? Function( Reordered value)?  reordered,TResult? Function( ClearSelection value)?  clearSelection,}){
final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that);case PickRequested() when pickRequested != null:
return pickRequested(_that);case Picked() when picked != null:
return picked(_that);case RemoveAt() when removeAt != null:
return removeAt(_that);case Reordered() when reordered != null:
return reordered(_that);case ClearSelection() when clearSelection != null:
return clearSelection(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> filePaths,  String? outputName)?  submitMerge,TResult Function()?  pickRequested,TResult Function( List<String> paths)?  picked,TResult Function( int index)?  removeAt,TResult Function( int oldIndex,  int newIndex)?  reordered,TResult Function()?  clearSelection,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that.filePaths,_that.outputName);case PickRequested() when pickRequested != null:
return pickRequested();case Picked() when picked != null:
return picked(_that.paths);case RemoveAt() when removeAt != null:
return removeAt(_that.index);case Reordered() when reordered != null:
return reordered(_that.oldIndex,_that.newIndex);case ClearSelection() when clearSelection != null:
return clearSelection();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> filePaths,  String? outputName)  submitMerge,required TResult Function()  pickRequested,required TResult Function( List<String> paths)  picked,required TResult Function( int index)  removeAt,required TResult Function( int oldIndex,  int newIndex)  reordered,required TResult Function()  clearSelection,}) {final _that = this;
switch (_that) {
case SubmitMerge():
return submitMerge(_that.filePaths,_that.outputName);case PickRequested():
return pickRequested();case Picked():
return picked(_that.paths);case RemoveAt():
return removeAt(_that.index);case Reordered():
return reordered(_that.oldIndex,_that.newIndex);case ClearSelection():
return clearSelection();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> filePaths,  String? outputName)?  submitMerge,TResult? Function()?  pickRequested,TResult? Function( List<String> paths)?  picked,TResult? Function( int index)?  removeAt,TResult? Function( int oldIndex,  int newIndex)?  reordered,TResult? Function()?  clearSelection,}) {final _that = this;
switch (_that) {
case SubmitMerge() when submitMerge != null:
return submitMerge(_that.filePaths,_that.outputName);case PickRequested() when pickRequested != null:
return pickRequested();case Picked() when picked != null:
return picked(_that.paths);case RemoveAt() when removeAt != null:
return removeAt(_that.index);case Reordered() when reordered != null:
return reordered(_that.oldIndex,_that.newIndex);case ClearSelection() when clearSelection != null:
return clearSelection();case _:
  return null;

}
}

}

/// @nodoc


class SubmitMerge implements MergeMutationEvent {
  const SubmitMerge(this.filePaths, {this.outputName});
  

 final  List<String> filePaths;
 final  String? outputName;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
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
@useResult
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
@pragma('vm:prefer-inline') $Res call({Object? filePaths = null,Object? outputName = freezed,}) {
  return _then(SubmitMerge(
null == filePaths ? _self.filePaths : filePaths // ignore: cast_nullable_to_non_nullable
as List<String>,outputName: freezed == outputName ? _self.outputName : outputName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class PickRequested implements MergeMutationEvent {
  const PickRequested();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is PickRequested);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MergeMutationEvent.pickRequested()';
}


}




/// @nodoc


class Picked implements MergeMutationEvent {
  const Picked(this.paths);
  

 final  List<String> paths;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PickedCopyWith<Picked> get copyWith => _$PickedCopyWithImpl<Picked>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Picked&&const DeepCollectionEquality().equals(other.paths, paths));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(paths));
}

@override
String toString() {
    return 'MergeMutationEvent.picked(paths: $paths)';
}


}

/// @nodoc
abstract mixin class $PickedCopyWith<$Res> implements $MergeMutationEventCopyWith<$Res> {
  factory $PickedCopyWith(Picked value, $Res Function(Picked) _then) = _$PickedCopyWithImpl;
@useResult
$Res call({
 List<String> paths
});




}
/// @nodoc
class _$PickedCopyWithImpl<$Res>
    implements $PickedCopyWith<$Res> {
  _$PickedCopyWithImpl(this._self, this._then);

  final Picked _self;
  final $Res Function(Picked) _then;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? paths = null,}) {
  return _then(Picked(
null == paths ? _self.paths : paths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class RemoveAt implements MergeMutationEvent {
  const RemoveAt(this.index);
  

 final  int index;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoveAtCopyWith<RemoveAt> get copyWith => _$RemoveAtCopyWithImpl<RemoveAt>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoveAt&&(identical(other.index, index) || other.index == index));
}


@override
int get hashCode {
    return Object.hash(runtimeType,index);
}

@override
String toString() {
    return 'MergeMutationEvent.removeAt(index: $index)';
}


}

/// @nodoc
abstract mixin class $RemoveAtCopyWith<$Res> implements $MergeMutationEventCopyWith<$Res> {
  factory $RemoveAtCopyWith(RemoveAt value, $Res Function(RemoveAt) _then) = _$RemoveAtCopyWithImpl;
@useResult
$Res call({
 int index
});




}
/// @nodoc
class _$RemoveAtCopyWithImpl<$Res>
    implements $RemoveAtCopyWith<$Res> {
  _$RemoveAtCopyWithImpl(this._self, this._then);

  final RemoveAt _self;
  final $Res Function(RemoveAt) _then;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? index = null,}) {
  return _then(RemoveAt(
null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class Reordered implements MergeMutationEvent {
  const Reordered(this.oldIndex, this.newIndex);
  

 final  int oldIndex;
 final  int newIndex;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReorderedCopyWith<Reordered> get copyWith => _$ReorderedCopyWithImpl<Reordered>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is Reordered&&(identical(other.oldIndex, oldIndex) || other.oldIndex == oldIndex)&&(identical(other.newIndex, newIndex) || other.newIndex == newIndex));
}


@override
int get hashCode {
    return Object.hash(runtimeType,oldIndex,newIndex);
}

@override
String toString() {
    return 'MergeMutationEvent.reordered(oldIndex: $oldIndex, newIndex: $newIndex)';
}


}

/// @nodoc
abstract mixin class $ReorderedCopyWith<$Res> implements $MergeMutationEventCopyWith<$Res> {
  factory $ReorderedCopyWith(Reordered value, $Res Function(Reordered) _then) = _$ReorderedCopyWithImpl;
@useResult
$Res call({
 int oldIndex, int newIndex
});




}
/// @nodoc
class _$ReorderedCopyWithImpl<$Res>
    implements $ReorderedCopyWith<$Res> {
  _$ReorderedCopyWithImpl(this._self, this._then);

  final Reordered _self;
  final $Res Function(Reordered) _then;

/// Create a copy of MergeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? oldIndex = null,Object? newIndex = null,}) {
  return _then(Reordered(
null == oldIndex ? _self.oldIndex : oldIndex // ignore: cast_nullable_to_non_nullable
as int,null == newIndex ? _self.newIndex : newIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ClearSelection implements MergeMutationEvent {
  const ClearSelection();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ClearSelection);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'MergeMutationEvent.clearSelection()';
}


}




// dart format on
