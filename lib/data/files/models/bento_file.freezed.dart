// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bento_file.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BentoFile {

 String get path; String get name; int get size; DateTime get modified;
/// Create a copy of BentoFile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BentoFileCopyWith<BentoFile> get copyWith => _$BentoFileCopyWithImpl<BentoFile>(this as BentoFile, _$identity);

  /// Serializes this BentoFile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BentoFile&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,name,size,modified);

@override
String toString() {
  return 'BentoFile(path: $path, name: $name, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class $BentoFileCopyWith<$Res>  {
  factory $BentoFileCopyWith(BentoFile value, $Res Function(BentoFile) _then) = _$BentoFileCopyWithImpl;
@useResult
$Res call({
 String path, String name, int size, DateTime modified
});




}
/// @nodoc
class _$BentoFileCopyWithImpl<$Res>
    implements $BentoFileCopyWith<$Res> {
  _$BentoFileCopyWithImpl(this._self, this._then);

  final BentoFile _self;
  final $Res Function(BentoFile) _then;

/// Create a copy of BentoFile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? path = null,Object? name = null,Object? size = null,Object? modified = null,}) {
  return _then(_self.copyWith(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BentoFile].
extension BentoFilePatterns on BentoFile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BentoFile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BentoFile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BentoFile value)  $default,){
final _that = this;
switch (_that) {
case _BentoFile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BentoFile value)?  $default,){
final _that = this;
switch (_that) {
case _BentoFile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String path,  String name,  int size,  DateTime modified)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BentoFile() when $default != null:
return $default(_that.path,_that.name,_that.size,_that.modified);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String path,  String name,  int size,  DateTime modified)  $default,) {final _that = this;
switch (_that) {
case _BentoFile():
return $default(_that.path,_that.name,_that.size,_that.modified);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String path,  String name,  int size,  DateTime modified)?  $default,) {final _that = this;
switch (_that) {
case _BentoFile() when $default != null:
return $default(_that.path,_that.name,_that.size,_that.modified);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BentoFile implements BentoFile {
  const _BentoFile({required this.path, required this.name, required this.size, required this.modified});
  factory _BentoFile.fromJson(Map<String, dynamic> json) => _$BentoFileFromJson(json);

@override final  String path;
@override final  String name;
@override final  int size;
@override final  DateTime modified;

/// Create a copy of BentoFile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BentoFileCopyWith<_BentoFile> get copyWith => __$BentoFileCopyWithImpl<_BentoFile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BentoFileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BentoFile&&(identical(other.path, path) || other.path == path)&&(identical(other.name, name) || other.name == name)&&(identical(other.size, size) || other.size == size)&&(identical(other.modified, modified) || other.modified == modified));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,path,name,size,modified);

@override
String toString() {
  return 'BentoFile(path: $path, name: $name, size: $size, modified: $modified)';
}


}

/// @nodoc
abstract mixin class _$BentoFileCopyWith<$Res> implements $BentoFileCopyWith<$Res> {
  factory _$BentoFileCopyWith(_BentoFile value, $Res Function(_BentoFile) _then) = __$BentoFileCopyWithImpl;
@override @useResult
$Res call({
 String path, String name, int size, DateTime modified
});




}
/// @nodoc
class __$BentoFileCopyWithImpl<$Res>
    implements _$BentoFileCopyWith<$Res> {
  __$BentoFileCopyWithImpl(this._self, this._then);

  final _BentoFile _self;
  final $Res Function(_BentoFile) _then;

/// Create a copy of BentoFile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? path = null,Object? name = null,Object? size = null,Object? modified = null,}) {
  return _then(_BentoFile(
path: null == path ? _self.path : path // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,modified: null == modified ? _self.modified : modified // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
