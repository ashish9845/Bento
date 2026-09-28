// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_mutation_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeMutationEvent {

 List<String> get pickedPaths;
/// Create a copy of HomeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeMutationEventCopyWith<HomeMutationEvent> get copyWith => _$HomeMutationEventCopyWithImpl<HomeMutationEvent>(this as HomeMutationEvent, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HomeMutationEvent;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeMutationEvent&&const DeepCollectionEquality().equals(other.pickedPaths, _this.pickedPaths));
}


@override
int get hashCode {
  final _this = this as HomeMutationEvent;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.pickedPaths));
}

@override
String toString() {
  final _this = this as HomeMutationEvent;
  return 'HomeMutationEvent(pickedPaths: ${_this.pickedPaths})';
}


}

/// @nodoc
abstract mixin class $HomeMutationEventCopyWith<$Res>  {
  factory $HomeMutationEventCopyWith(HomeMutationEvent value, $Res Function(HomeMutationEvent) _then) = _$HomeMutationEventCopyWithImpl;
@useResult
$Res call({
 List<String> pickedPaths
});




}
/// @nodoc
class _$HomeMutationEventCopyWithImpl<$Res>
    implements $HomeMutationEventCopyWith<$Res> {
  _$HomeMutationEventCopyWithImpl(this._self, this._then);

  final HomeMutationEvent _self;
  final $Res Function(HomeMutationEvent) _then;

/// Create a copy of HomeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickedPaths = null,}) {
  return _then(HomeMutationEvent.importFiles(
null == pickedPaths ? _self.pickedPaths : pickedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeMutationEvent].
extension HomeMutationEventPatterns on HomeMutationEvent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ImportFiles value)?  importFiles,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ImportFiles() when importFiles != null:
return importFiles(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ImportFiles value)  importFiles,}){
final _that = this;
switch (_that) {
case ImportFiles():
return importFiles(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ImportFiles value)?  importFiles,}){
final _that = this;
switch (_that) {
case ImportFiles() when importFiles != null:
return importFiles(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( List<String> pickedPaths)?  importFiles,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ImportFiles() when importFiles != null:
return importFiles(_that.pickedPaths);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( List<String> pickedPaths)  importFiles,}) {final _that = this;
switch (_that) {
case ImportFiles():
return importFiles(_that.pickedPaths);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( List<String> pickedPaths)?  importFiles,}) {final _that = this;
switch (_that) {
case ImportFiles() when importFiles != null:
return importFiles(_that.pickedPaths);case _:
  return null;

}
}

}

/// @nodoc


class ImportFiles implements HomeMutationEvent {
  const ImportFiles( List<String> pickedPaths): _pickedPaths = pickedPaths;
  

 final  List<String> _pickedPaths;
@override List<String> get pickedPaths {
  if (_pickedPaths is EqualUnmodifiableListView) return _pickedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pickedPaths);
}


/// Create a copy of HomeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportFilesCopyWith<ImportFiles> get copyWith => _$ImportFilesCopyWithImpl<ImportFiles>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportFiles&&const DeepCollectionEquality().equals(other.pickedPaths, _pickedPaths));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_pickedPaths));
}

@override
String toString() {
    return 'HomeMutationEvent.importFiles(pickedPaths: $pickedPaths)';
}


}

/// @nodoc
abstract mixin class $ImportFilesCopyWith<$Res> implements $HomeMutationEventCopyWith<$Res> {
  factory $ImportFilesCopyWith(ImportFiles value, $Res Function(ImportFiles) _then) = _$ImportFilesCopyWithImpl;
@override @useResult
$Res call({
 List<String> pickedPaths
});




}
/// @nodoc
class _$ImportFilesCopyWithImpl<$Res>
    implements $ImportFilesCopyWith<$Res> {
  _$ImportFilesCopyWithImpl(this._self, this._then);

  final ImportFiles _self;
  final $Res Function(ImportFiles) _then;

/// Create a copy of HomeMutationEvent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickedPaths = null,}) {
  return _then(ImportFiles(
null == pickedPaths ? _self._pickedPaths : pickedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
